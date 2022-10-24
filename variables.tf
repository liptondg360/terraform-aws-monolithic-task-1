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
  default     = "m5a.xlarge"
}

#DynamoDB Configuration
variable "name" {
  type        = string
  description = "ekyc-db"
}

variable "billing_mode" {
  type        = string
  description = "PROVISIONED or PAY_PER_REQUEST, check https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table"
}

variable "hash_key" {
  type        = string
  description = "DynamoDB primary partition key"
}

variable "range_key" {
  type        = string
  description = "DynamoDB primary sort key"
  default     = null
}

variable "write_capacity" {
  type        = number
  description = "Write Capacity Units (WCUs), check https://calculator.aws/#/createCalculator/amazonDynamoDB"
  default     = null
}

variable "read_capacity" {
  type        = number
  description = "Read Capacity Units (WCUs), check https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/ProvisionedThroughput.html"
  default     = null
}

variable "attributes" {
  type        = list(map(string))
  description = <<EOL
    DynamoDB Table attributes, hash_key and sort_key (if given) should be defined here.
    JSON tfvars Example
    "attributes": [
        {
            "name": "HashKeyName",
            "type": "S"
        },
        {
            "name": "RangeKeyName",
            "type": "B"
        }
    ]
    EOL
}

variable "point_in_time_recovery" {
  type        = bool
  description = "Allow Point in time recovery of backed up table, check https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = <<EOL
    Tags for the table.
    JSON tfvars Example
    "tags": {
        "Name": "MyTable",
        "ENVIRONEMNT": "DEV"
    }
    EOL
  default     = {}
}

variable "replicas" {
  type        = list(string)
  description = "AWS regions for Global DynamoDB Tables V2, check https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/globaltables.V2.html"
  default     = []
}

variable "global_secondary_indexes" {
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    write_capacity     = number
    read_capacity      = number
    projection_type    = string
    non_key_attributes = list(string)
  }))
  description = <<EOL
    Seettings for GLobal Secondary Index in the create DynamoDB Table(s), check https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSI.html
    If you are using Global Tables and you have defined replicas variable, check https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/globaltables_reqs_bestpractices.html
    JSON tfvars Example
    "global_secondary_indexes": {
        "name": "ekyc",
        "hash_key": "Title"
        "range_key": "Rating"
        "write_capacity": 10
        "read_capacity": 10
        "projection_type": "INCLUDE"
        "non_key_attributes": ["Authors"] 
    }
    EOL
  default     = []
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