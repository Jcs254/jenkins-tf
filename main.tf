provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0e8a34246278c21e4"  # Specify your desired Jenkins AMI
  instance_type = "t2.micro"  # Specify your desired instance type
  key_name      = "privatekeypair"  # Specify your key pair

#  security_group = [aws_security_group.jenkins_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              sudo yum upgrade -y

              ## Install Java 11:
              sudo yum install java-11* -y

              ## Install Jenkins then Enable the Jenkins service to start at boot :
              sudo yum install jenkins -y
              sudo systemctl enable jenkins

              ## Start Jenkins as a service:
              sudo systemctl start jenkins
              EOF
}

terraform {
  backend "s3" {
    bucket         = "jenkin-terraform"
    key            = "jenkin-terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}