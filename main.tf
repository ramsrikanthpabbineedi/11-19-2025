provider "aws" {
  region = var.aws_region
}
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
resource "aws_subnet" "sub-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.sub-1_cidr
  tags = {
    Name = var.sub-1_name
  }
}
resource "aws_subnet" "sub-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.sub-2_cidr
  tags = {
    Name = var.sub-2_name
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.igw_name
  }
}
resource "aws_default_route_table" "rtb" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.route_table_name
  }
}
resource "aws_route_table_association" "rass-1" {
  route_table_id = aws_default_route_table.rtb.id
  subnet_id      = aws_subnet.sub-1.id
}
resource "aws_route_table_association" "rass-2" {
  route_table_id = aws_default_route_table.rtb.id
  subnet_id      = aws_subnet.sub-2.id
}
resource "aws_security_group" "sg-1" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.security_group_name
  }
}
resource "aws_launch_template" "ec2" {
  name_prefix   = "my-launch-template-"
  image_id      = var.image_id
  instance_type = var.instance_type
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg-1.id]
  }
}
resource "aws_autoscaling_group" "asg" {
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.subnet_id
  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$latest"
  }
  target_group_arns = [
    aws_lb_target_group.tcp-example.arn
  ]
  health_check_type         = "ELB"
  health_check_grace_period = 300
}
resource "aws_lb_target_group" "tcp-example" {
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }

    unhealthy_state_routing {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }
  }
}
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.sg-1.id]
  subnets            = var.public_subnet

}
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "http"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tcp-example.arn
  }

}
resource "aws_cloudfront_distribution" "domin" {
  enabled             = true
  comment             = "cloudfront in front to alb"
  default_root_object = "index.html"

  origin {
    domain_name = aws_lb.alb.dns_name # <-- This is your ALB
    origin_id   = "alb-origin"

    custom_origin_config { # <-- Must be nested here
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  tags = {
    Name = var.cloudfront_name
  }
}
