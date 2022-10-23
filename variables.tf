# custom VPC variable
variable "vpc_cidr" {
  description = "custom vpc CIDR notation"
  type        = string
  default     = "10.0.0.0/16"
}


# public subnet 1 variable
variable "public_subnet1" {
  description = "public subnet 1 CIDR notation"
  type        = string
  default     = "10.0.1.0/24"
}


# public subnet 2 variable
variable "public_subnet2" {
  description = "public subnet 2 CIDR notation"
  type        = string
  default     = "10.0.2.0/24"
}


# private subnet 1 variable
variable "private_subnet1" {
  description = "private subnet 1 CIDR notation"
  type        = string
  default     = "10.0.3.0/24"
}


# private subnet 2 variable
variable "private_subnet2" {
  description = "private subnet 2 CIDR notation"
  type        = string
  default     = "10.0.4.0/24"
}


# AZ 1
variable "az1" {
  description = "availability zone 1"
  type        = string
  default     = "ap-southeast-1a"
}


# AZ 2
variable "az2" {
  description = "availability zone 2"
  type        = string
  default     = "ap-southeast-1b"
}


# ec2 instance ami for Linux
variable "ec2_instance_ami" {
  description = "ec2 instance ami id"
  type        = string
  default     = "ami-00e912d13fbb4f225"
}


# ec2 instance type
variable "ec2_instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}


# db engine
variable "db_engine" {
  description = "db engine"
  type        = string
  default     = "mysql"
}


# db engine version
variable "db_engine_version" {
  description = "db engine version"
  type        = string
  default     = "5.7"
}


# db name
variable "db_name" {
  description = "ekyc-db"
  type        = string
  default     = "test_db"
}


# db instance class
variable "db_instance_class" {
  description = "db instance class"
  type        = string
  default     = "db.t2.micro"
}


# database username variable
variable "db_username" {
  description = "admin"
  type        = string
  sensitive   = true
}


# database password variable
variable "db_password" {
  description = "password"
  type        = string
  sensitive   = true
}

# S3 Configuration
variable "name" {
  description = "ekyc"
  default     = ""
}

variable "acl" {
  description = "ekyc-acl"
  default     = "private"
}

variable "enable_versioning" {
  description = "enable bucket versioning"
  default     = "false"
}

variable "tags" {
  description = "tags"
  default     = {}
}

variable "lifecycle" {
  description = "lifecycle"
  default     = {}
}

# Defining for Cloudfront-CDN
variable "enabled" {
  type    = bool
  default = true
}
variable "ipv6_enabled" {
  type    = bool
  default = false
}
variable "logging_enabled" {
  type    = bool
  default = false
}
variable "waf_id" {
  type    = string
  default = ""
}
variable "aliases" {
  type    = list(string)
  default = []
}
variable "logging_config" {
  type = object({
    bucket          = string
    prefix          = string
    include_cookies = bool
  })
}
variable "viewer_certificate" {
  type        = any
  description = "Viewer certificate map with fields: acm_certificate_arn, iam_certificate_id, minimum_protocol_version, ssl_support_method"
}
variable "custom_origins" {
  type        = any
  default     = []
  description = "List of custom origin maps"
}
variable "s3_origins" {
  type = list(object({
    domain_name            = string
    origin_id              = string
    origin_access_identity = string
  }))
  default = []
}
variable "geo_restriction" {
  type = object({
    type      = string
    locations = list(string)
  })
  default = {
    type      = "none"
    locations = []
  }
}
variable "price_class" {
  type    = string
  default = "PriceClass_200"
}
variable "default_cache_behavior" {
  type        = any
  description = "The default cache behavior"
}
variable "cache_behaviors" {
  type        = any
  default     = []
  description = "List of cache behavior maps"
}

variable "default_root_object" {
  type    = string
  default = null
}
variable "comment" {
  type        = string
  default     = null
  description = "Comment field for the distribution"
}
variable "http_version" {
  type        = string
  default     = null #terraform will default this to http2
  description = "http_version field for the distribution; options are http1.1, http2"
}
variable "tags" {
  default     = null
  description = "List of key-value pairs to assign to tags of the distribution"
}