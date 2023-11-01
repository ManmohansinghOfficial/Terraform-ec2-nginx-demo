variable "cidr" {
  default = "10.0.0.0/16"
}

variable "PATH_TO_PRIVATE_KEY" {
  default="id_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "id_rsa.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}