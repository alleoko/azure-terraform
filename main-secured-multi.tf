provider "aws" {
  region = "us-east-1"
}

# Create security group
resource "aws_security_group" "monitoring" {
  name        = "monitoring-sg"
  description = "Security group for monitoring stack"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_LOCAL_IP/32"] #/32 means single ip access
  }

  # Allow Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["YOUR_LOCAL_IP/32"]
  }

  # Allow Jenkins
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["YOUR_LOCAL_IP/32"]
  }

  # Allow Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["YOUR_LOCAL_IP/32"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitoring-sg"
  }
}

# Create EC2 instance
resource "aws_instance" "monitoring" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type = "t2.micro"

  security_groups = [aws_security_group.monitoring.name]

  tags = {
    Name = "monitoring-instance"
  }
}

# Output the public IP
output "instance_public_ip" {
  value       = aws_instance.monitoring.public_ip
  description = "Public IP of the EC2 instance"
}