provider "aws" {
  region = "ap-south-1"  # Change this to your desired AWS region
  access_key = "key_id"
  secret_key = "Key_secret"

}


variable "subnet_prefix" {
  description = "cidr block for the subnet"

}


# # 1. Create vpc

resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# # 2. Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev-vpc.id


}
# # 3. Create Custom Route Table

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Dev"
  }
}

# # 4. Create a Subnet 

resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subnet_prefix[0].cidr_block
  availability_zone = "ap-south-1a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subnet_prefix[1].cidr_block
  availability_zone = "ap-south-1a"

  tags = {
    Name = var.subnet_prefix[1].name
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = var.subnet_prefix[2].cidr_block
  availability_zone = "ap-south-1b"

  tags = {
    Name = var.subnet_prefix[2].name
  }
}


# # 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}



# # 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_web"
  }
}

## allow rds for 5432

# resource "aws_security_group" "allow_db_psql" {
#   name        = "allow_db"
#   description = "Allow db inbound traffic"
#   vpc_id      = aws_vpc.dev-vpc.id

#   ingress {
#     description = "Postgres sql allow port"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "allow_psql"
#   }
# }
# # 7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.public-subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# resource "aws_network_interface" "web-server-nic-2" {
#   subnet_id       = aws_subnet.public-subnet-1.id
#   private_ips     = ["10.0.1.51"]
#   security_groups = [aws_security_group.allow_web.id]

# }
# # 8. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  # vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

# resource "aws_eip" "two" {
#   vpc                       = true
#   network_interface         = aws_network_interface.web-server-nic-2.id
#   associate_with_private_ip = "10.0.1.51"
#   depends_on                = [aws_internet_gateway.gw]
# }

output "server_public_ip-2" {
  value = aws_eip.one.public_ip
}

# output "server_public_ip" {
#   value = aws_eip.two.public_ip
# }
# # 9. Create Ubuntu server and install/enable apache2

# resource "aws_instance" "web-server-instance" {
#   ami               = "ami-07fd1de5f10a3eb14"
#   instance_type     = "t2.large"
#   availability_zone = "ap-south-1a"
#   key_name          = "vts-prod"

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.web-server-nic.id
#   }
#   root_block_device {
#     volume_size = 100 # in GB <<----- I increased this!
    
#   }

#   user_data = <<-EOF
#                 #!/bin/bash
#                 sudo apt update -y
#                 sudo apt-get install ca-certificates curl gnupg -y
#                 sudo apt install nginx -y
#                 sudo apt install git -y
                
#                 EOF
#   tags = {
#     Name = "vts-web-server"
#   }
# }


resource "aws_instance" "web-server-instance" {
  ami               = "ami-0f5ee92e2d63afc18"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "ec2-access"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  root_block_device {
    volume_size = 20 # in GB <<----- I increased this!
    
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                EOF
  tags = {
    Name = "web-server-test"
  }
}

# resource "aws_instance" "web-server-instance-2" {
#   ami               = "ami-085925f297f89fce1"
#   instance_type     = "t2.micro"
#   availability_zone = "ap-south-1a"
#   key_name          = "main-key"

#   network_interface {
#     device_index         = 0
#     network_interface_id = aws_network_interface.web-server-nic-2.id
#   }

#   user_data = <<-EOF
#                 #!/bin/bash
#                 sudo apt update -y
#                 sudo apt install apache2 -y
#                 sudo systemctl start apache2
#                 sudo bash -c 'echo Deepchain Labs-2 > /var/www/html/index.html'
#                 EOF
#   tags = {
#     Name = "web-server-2"
#   }
# }


output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip

}

# output "server_private_ip-2" {
#   value = aws_instance.web-server-instance-2.private_ip

# }

output "server_id" {
  value = aws_instance.web-server-instance.id
}

## 10. Rds subnet group

# resource "aws_db_subnet_group" "db-subnet-psql" {

#    name = "dbsubnetgroup"
#    description = "DB subnet group for postgres database"
#    subnet_ids = [aws_subnet.private-subnet-1.id,aws_subnet.private-subnet-2.id ]

#   }

##11. create rds for psql

# resource "aws_db_instance" "db_prod_vts" {

#   engine = "postgres"
#   engine_version = "14.4"
# 	instance_class = "db.t3.micro"
# 	allocated_storage = var.allocated_storage
# 	identifier = "vtsdb"
# 	storage_type = "gp2"
# 	username = var.db_username
# 	password = var.db_password
# 	publicly_accessible = false
# 	db_subnet_group_name = aws_db_subnet_group.db-subnet-psql.id
# 	#snapshot_identifier = "${data.aws_db_snapshot.db_snapshot.id}"
# 	vpc_security_group_ids = [aws_security_group.allow_db_psql.id]
#   skip_final_snapshot=true
# }