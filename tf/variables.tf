# Read keys/tokens from env
variable "DO_TOKEN" {
  type = string
}

variable "DO_SPACES_ACCESS_KEY" {
  type = string
}

variable "DO_SPACES_SECRET_KEY" {
  type = string
}

variable "project_name" {
  type = string
  default = "dsm-portfolio"
}