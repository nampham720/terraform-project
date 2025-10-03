
variable "project_name" {
  type    = string
  default = "test-pipeline"
}
variable "environment" {
  type    = string
  default = "dev"
}
variable "region" {
  type    = string
  default = "eu-north-1"
} # Stockholm 

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro" # Free tier eligible in many regions; switch to t4g.micro if preferred
}
variable "db_name" {
  type    = string
  default = "testdb"
}
variable "db_username" {
  type    = string
  default = "testdbv1"
}
variable "allowed_cidr_ssh" {
  description = "CIDR to allow SSH if ever opened; unused by default."
  type        = string
  default     = "0.0.0.0/0"
}


