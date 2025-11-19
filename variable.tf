variable "aws_region" {
  type = string

}
variable "vpc_name" {
  type = string

}
variable "vpc_cidr" {
  type = string

}
variable "sub-1_cidr" {
  type = string

}
variable "sub-2_cidr" {
  type = string

}
variable "sub-2_name" {
  type = string

}
variable "sub-1_name" {
  type = string

}
variable "igw_name" {
  type = string

}
variable "route_table_name" {
  type = string

}
variable "security_group_name" {
  type = string

}
variable "image_id" {
  type = string
}
variable "instance_type" {
  type = string

}
variable "security_group_id" {
  type = string

}
variable "subnet_id" {
  type = list(string)

}

variable "public_subnet" {
  type = list(string)

}
variable "cloudfront_name" {
  type = string

}