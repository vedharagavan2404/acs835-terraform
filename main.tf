# Define the provider
provider "aws" {
  region = "us-east-1"
}


# Create a new VPC 
resource "aws_default_vpc" "default" {
   // default=true
    
    tags={
        Name="default vpc"
    }
}


# Add provisioning of the public subnetin the default VPC
resource "aws_subnet" "public_SN1" {
  vpc_id            = aws_default_vpc.default.id
  //cidr_block        = aws_default_vpc.default.cidr_block
  cidr_block= "172.31.0.0/24"
  availability_zone = "us-east-1a"
  
  map_public_ip_on_launch=true
  
  tags = {
      Name= "Public Subnet Assignment1"
  }
}

#creating a security group
resource "aws_security_group" "ec2_sg"{
    name = "ec2_sg"
    description = "Security group for EC2 instance"
    
    vpc_id = aws_default_vpc.default.id
    
    ingress {
    description      = "HTTP from everywhere"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 8082
    to_port          = 8082
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    
} 



resource "aws_ecr_repository" "appplication_repo" {
  name = "web-application-image-repo"  
}

resource "aws_ecr_repository" "database_repo" {
  name = "mysqldb-image-repo"  
}


resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "linux_vm"{
    ami = "ami-0715c1897453cabd1"
    instance_type = "t2.micro"
    key_name      = aws_key_pair.ec2_key.key_name
    subnet_id= aws_subnet.public_SN1.id
    security_groups= [aws_security_group.ec2_sg.id]
    
    tags={
        Name = "Linux EC2 Instance"
    }
}