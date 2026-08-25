variable "project_name" {
  description = "AWS-resurssien etuliitteenä käytettävä nimi"
  type        = string
  default     = "terraform-docker"
}

variable "vpc_cidr" {
  description = "VPC:lle osoitettu CIDR-lohko"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR-lohko joka on määrätty julkiselle aliverkolle"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance tyyppi"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nimi olemassa olevalle EC2-avainparille"
  type        = string
}

variable "ssh_source_cidr" {
  description = "Lähdeosoite joka saa yhdistää SSH:llä, esimerkiksi 203.0.113.10/32"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_source_cidr))
    error_message = "SSH-lähteen on oltava kelvollinen IPv4-CIDR-lohko."
  }
}

variable "root_volume_size" {
  description = "EC2 root-taltion koko GiB-muunnoksessa"
  type        = number
  default     = 10

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "EC2 root-taltion on oltava vähintään 8 GiB."
  }
}