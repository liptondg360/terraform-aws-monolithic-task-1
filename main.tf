# PROVIDER BLOCK
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.23"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  AWS_access_key = ""
  AWS_secret_key = ""
  region = "ap-southeast-1"
}

# VPC BLOCK

resource "aws_vpc" "ekyc_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    name = "ekyc_vpc"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.ekyc_vpc.id
  cidr_block        = var.public_subnet1
  availability_zone = var.az1

  tags = {
    name = "public_subnet1"
  }
}

# public subnet 2
resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.ekyc_vpc.id
  cidr_block        = var.public_subnet2
  availability_zone = var.az2

  tags = {
    name = "public_subnet2"
  }
}

# private subnet 1
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.ekyc_vpc.id
  cidr_block        = var.private_subnet1
  availability_zone = var.az1

  tags = {
    name = "private_subnet1"
  }
}

# private subnet 2
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.ekyc_vpc.id
  cidr_block        = var.private_subnet2
  availability_zone = var.az2

  tags = {
    name = "private_subnet2"
  }
}

# creating internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ekyc_vpc.id

  tags = {
    name = "igw"
  }
}

# creating route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.ekyc_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name = "rt"
  }
}

# tags are not allowed here 
# associate route table to the public subnet 1
resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.rt.id
}

# tags are not allowed here 
# associate route table to the public subnet 2
resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.rt.id
}

# tags are not allowed here 
# associate route table to the private subnet 1
resource "aws_route_table_association" "private_rt1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.rt.id
}

# tags are not allowed here 
# associate route table to the private subnet 2
resource "aws_route_table_association" "private_rt2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.rt.id
}

# SECURITY BLOCK

# create security groups for vpc (web_sg), webserver, and database

# custom vpc security group 
resource "aws_security_group" "web_sg" {
  name        = "ekyc_sg"
  description = "allow inbound HTTP traffic"
  vpc_id      = aws_vpc.ekyc_vpc.id

  # HTTP from vpc
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rules
  # internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "ekyc_sg"
  }
}

# web tier security group
resource "aws_security_group" "webserver_sg" {
  name        = "ekycserver_sg"
  description = "allow inbound traffic from ALB"
  vpc_id      = aws_vpc.ekyc_vpc.id

  # allow inbound traffic from web
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "webserver_sg"
  }
}

# database security group
resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "allow inbound traffic from ALB"
  vpc_id      = aws_vpc.ekyc_vpc.id

  # allow traffic from ALB 
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_sg.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "database_sg"
  }
}

# INSTANCES BLOCK - EC2 and DATABASE

# 1st ec2 instance on public subnet 1
resource "aws_instance" "ec2_1" {
  ami                    = var.ec2_instance_ami
  instance_type          = var.ec2_instance_type
  availability_zone      = var.az1
  subnet_id              = aws_subnet.public_subnet1.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  user_data              = file("info.sh")

  tags = {
    name = "ec2_1"
  }
}

# 2nd ec2 instance on public subnet 2
resource "aws_instance" "ec2_2" {
  ami                    = var.ec2_instance_ami
  instance_type          = var.ec2_instance_type
  availability_zone      = var.az2
  subnet_id              = aws_subnet.public_subnet2.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  user_data              = file("info.sh")

  tags = {
    name = "ec2_2"
  }
}

#DynamoDB COnfiguration
resource "aws_dynamodb_table" "ekyc" {
  name           = var.name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key
  range_key      = var.range_key
  write_capacity = var.write_capacity
  read_capacity  = var.read_capacity

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value["name"]
      type = attribute.value["type"]
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value["name"]
      hash_key           = global_secondary_index.value["hash_key"]
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      projection_type    = global_secondary_index.value["projection_type"]
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
    }
  }

  dynamic "replica" {
    for_each = var.replicas
    content {
      region_name = replica.value["name"]
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  tags = var.tags

}

# S3 configuration
resource "aws_s3_bucket" "ekyc" {
  bucket = "${var.name}"
  acl    = "${var.acl}"

  versioning {
    enabled = "${var.enable_versioning}"
  }

  tags = "${var.tags}"

  lifecycle = "${var.lifecycle}"
}

# Cloudfront-CDN
resource "aws_cloudfront_distribution" "distribution" {

  # wheather or not the distribution is enabled
  enabled = var.enabled

  # wheather or not IPV6 is enabled
  is_ipv6_enabled = var.ipv6_enabled

  # attach the WAF when an Id is given
  web_acl_id = length(var.waf_id) == 0 ? null : var.waf_id

  default_root_object = var.default_root_object

  comment      = var.comment
  http_version = var.http_version
  tags         = var.tags

  # wire in any aliases given
  aliases = var.aliases

  # country restrictions
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction.type
      locations        = var.geo_restriction.locations
    }
  }

  # price class for the distribution
  price_class = var.price_class

  # only creates a logging configuration when logging_enabled is true
  dynamic "logging_config" {
    iterator = x
    for_each = var.logging_enabled ? [var.logging_config] : []
    content {
      bucket          = "${x.value.bucket}.s3.amazonaws.com"
      include_cookies = x.value.include_cookies
      prefix          = x.value.prefix
    }
  }

  # configuration for ACM certificate
  dynamic "viewer_certificate" {
    iterator = x
    for_each = local.use_acm_certificate ? [var.viewer_certificate] : []
    content {
      acm_certificate_arn            = x.value.acm_certificate_arn
      minimum_protocol_version       = try(x.value.minimum_protocol_version, "TLSv1.2_2018")
      ssl_support_method             = try(x.value.ssl_support_method, "sni-only")
      cloudfront_default_certificate = false
    }
  }

  # configuration for IAM certificates
  dynamic "viewer_certificate" {
    iterator = x
    for_each = local.use_iam_certificate ? [var.viewer_certificate] : []
    content {
      iam_certificate_id             = x.value.iam_certificate_id
      minimum_protocol_version       = try(x.value.minimum_protocol_version, "TLSv1.2_2018")
      ssl_support_method             = try(x.value.ssl_support_method, "sni-only")
      cloudfront_default_certificate = false
    }
  }

  # use the default cloudfront certificate when ACM and IAM is not configured
  dynamic "viewer_certificate" {
    iterator = x
    for_each = !local.use_iam_certificate && !local.use_acm_certificate ? [true] : []
    #for_each = length(var.viewer_certificate.iam_certificate_id) > 0 || length(var.viewer_certificate.acm_certificate_arn) > 0 ? [] : [true]
    content {
      minimum_protocol_version       = "TLSv1" # Only TLSv1 is compatible with default certificate
      cloudfront_default_certificate = true
    }
  }

  dynamic "origin" {
    iterator = x
    for_each = var.custom_origins
    content {
      domain_name = x.value.domain_name
      origin_id   = x.value.origin_id
      origin_path = try(x.value.origin_path, null)
      dynamic "custom_header" {
        iterator = y
        for_each = x.value.custom_headers
        content {
          name  = y.value.name
          value = y.value.value
        }
      }
      custom_origin_config {
        origin_protocol_policy   = try(x.value.origin_protocol_policy, "match-viewer")
        origin_ssl_protocols     = try(x.value.origin_ssl_protocols, ["TLSv1.1", "TLSv1.2"])
        origin_keepalive_timeout = try(x.value.origin_keepalive_timeout, 60)
        origin_read_timeout      = try(x.value.origin_read_timeout, 60)
        http_port                = try(x.value.http_port, 80)
        https_port               = try(x.value.https_port, 443)
      }
    }
  }

  dynamic "origin" {
    iterator = x
    for_each = var.s3_origins
    content {
      domain_name = x.value.domain_name
      origin_id   = x.value.origin_id
      dynamic "s3_origin_config" {
        iterator = y
        for_each = x.value.origin_access_identity != null ? [x.value.origin_access_identity] : []
        content {
          origin_access_identity = y.value
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = try(var.default_cache_behavior.allowed_methods, ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
    cached_methods         = try(var.default_cache_behavior.cached_methods, ["GET", "HEAD"])
    target_origin_id       = var.default_cache_behavior.origin_id
    default_ttl            = try(var.default_cache_behavior.default_ttl, 86400)
    min_ttl                = try(var.default_cache_behavior.min_ttl, 0)
    max_ttl                = try(var.default_cache_behavior.max_ttl, 31536000)
    viewer_protocol_policy = try(var.default_cache_behavior.viewer_protocol_policy, "redirect-to-https")

    forwarded_values {
      cookies {
        forward           = var.default_cache_behavior.forward_cookies
        whitelisted_names = length(var.default_cache_behavior.forward_cookies_whitelist) == 0 ? null : var.default_cache_behavior.forward_cookies_whitelist
      }
      headers                 = var.default_cache_behavior.forward_headers
      query_string            = var.default_cache_behavior.forward_querystring
      query_string_cache_keys = length(var.default_cache_behavior.forward_querystring_cache_keys) == 0 ? null : var.default_cache_behavior.forward_querystring_cache_keys
    }
    dynamic "lambda_function_association" {
      iterator = x
      for_each = try(var.default_cache_behavior.lambda_function_association, [])
      content {
        event_type   = x.value.event_type
        lambda_arn   = x.value.lambda_arn
        include_body = x.value.include_body
      }
    }
    dynamic "function_association" {
      iterator = x
      for_each = try(var.default_cache_behavior.function_association, [])
      content {
        event_type   = x.value.event_type
        function_arn = x.value.function_arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    iterator = x
    for_each = var.cache_behaviors
    content {
      path_pattern           = x.value.path_pattern
      target_origin_id       = x.value.origin_id
      allowed_methods        = try(x.value.allowed_methods, ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"])
      cached_methods         = try(x.value.cached_methods, ["GET", "HEAD"])
      min_ttl                = try(x.value.min_ttl, 0)
      default_ttl            = try(x.value.default_ttl, 86400)
      max_ttl                = try(x.value.max_ttl, 31536000)
      viewer_protocol_policy = try(x.value.viewer_protocol_policy, "redirect-to-https")
      compress               = try(x.value.compress, "false")

      forwarded_values {
        cookies {
          forward           = try(x.value.forward_cookies, "none")
          whitelisted_names = try(x.value.forward_cookies_whitelist, null)
        }
        headers                 = try(x.value.forward_headers, null)
        query_string            = try(x.value.forward_querystring, true)
        query_string_cache_keys = try(x.value.forward_querystring_cache_keys, null)
      }
      dynamic "lambda_function_association" {
        iterator = y
        for_each = try(x.value.lambda_function_association, [])
        content {
          event_type   = y.value.event_type
          lambda_arn   = y.value.lambda_arn
          include_body = y.value.include_body
        }
      }
      dynamic "function_association" {
        iterator = y
        for_each = try(x.value.function_association, [])
        content {
          event_type   = y.value.event_type
          function_arn = y.value.function_arn
        }
      }
    }
  }
}

# ALB BLOCK

# # only alpha numeric and hyphen is allowed in name
# alb target group
resource "aws_lb_target_group" "external_target_g" {
  name     = "ekyc-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ekyc_vpc.id
}

resource "aws_lb_target_group_attachment" "ec2_1_target_g" {
  target_group_arn = aws_lb_target_group.external_target_g.arn
  target_id        = aws_instance.ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_2_target_g" {
  target_group_arn = aws_lb_target_group.external_target_g.arn
  target_id        = aws_instance.ec2_2.id
  port             = 80
}

# ALB
resource "aws_lb" "external_alb" {
  name               = "ekyc-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ekyc_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  tags = {
    name = "ekyc-ALB"
  }
}

# create ALB listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_target_g.arn
  }
}
