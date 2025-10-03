variable "name_prefix"         { type = string }
variable "cidr_block"          { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "availability_zones" {
    type = list(string)
    default = ["eu-north-1a", "eu-north-1b"]
}
