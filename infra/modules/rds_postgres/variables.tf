variable "name_prefix"        { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_instance_class"  { type = string }
variable "db_name"            { type = string }
variable "master_username"    { type = string }
