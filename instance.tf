resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rta1" {

  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id

}

resource "aws_security_group" "webSg" {
  name   = "websg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "web-sg"
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "id_rsa"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "nginxproject23" {
  ami                    = "ami-0a7cf821b91bcccbc"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id
  key_name               = aws_key_pair.ssh_key.key_name

  provisioner "file" {
    source      = "userdata.sh"
    destination = "/home/ubuntu/userdata.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/userdata.sh",
      "sudo /home/ubuntu/userdata.sh"
    ]
  }


  connection {
    user        = var.INSTANCE_USERNAME
    host        = self.public_ip
    type        = "ssh"
    private_key = file("${var.PATH_TO_PRIVATE_KEY}")
  }

}
