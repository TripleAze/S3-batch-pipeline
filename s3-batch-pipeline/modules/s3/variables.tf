variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "source_bucket" {
  type = string
}

variable "destination_bucket" {
  type = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "enable_encryption" {
  type    = bool
  default = true
}
