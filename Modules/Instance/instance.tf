variable "ENV" {
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "public_subnets" {
}

variable "vpc_id" {
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "key.pem"
}

resource "aws_instance" "instance" {
  ami           = "ami-0119aa4d67e59007c"
  instance_type = var.INSTANCE_TYPE
  user_data = <<EOF
#!/bin/bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
sudo touch ~/.bashrc
sudo terraform -install-autocomplete
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo yum install -y git
sudo curl -L https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl enable docker
cd /tmp
echo '#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm i 16.15.0
curl -o- -L https://yarnpkg.com/install.sh | bash
sudo yum install -y ruby wget
cd /home/ec2-user
sudo ln -s /home/ec2-user/.nvm/versions/node/v16.15.0/bin/node /usr/bin
sudo ln -s /home/ec2-user/.nvm/versions/node/v16.15.0/bin/npm /usr/bin
sudo ln -s /home/ec2-user/.yarn/bin/yarn /usr/bin
sudo yarn global add pm2
sudo ln -s /usr/local/bin/pm2 /usr/bin' >> init.sh
chmod +x init.sh
/bin/su -c "/tmp/init.sh" - ec2-user
rm init.sh
EOF

  tags = {
    Name         = "instance-${var.ENV}"
    Environmnent = var.ENV
  }
}

resource "aws_security_group" "allow-internal-http" {
  name        = "allow-internal-http-${var.ENV}"
  description = "Allow internal HTTP requests"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  tags = {
    Name         = "allow-internal-http"
    Environmnent = var.ENV
  }
}

resource "aws_security_group" "allow-internal-mysql" {
  name        = "allow-internal-mysql-${var.ENV}"
  description = "Allow internal MySQL requests"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  tags = {
    Name         = "allow-internal-mysql"
    Environmnent = var.ENV
  }
}

resource "aws_security_group" "allow-http" {
  name        = "allow-http-${var.ENV}"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "allow-http"
    Environmnent = var.ENV
  }
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh-${var.ENV}"
  description = "Allow SSH inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "allow-ssh"
    Environmnent = var.ENV
  }
}

resource "aws_security_group" "allow-all-outbound" {
  name        = "allow-all-outbound-${var.ENV}"
  description = "Allow all outbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name         = "allow-all-outbound"
    Environmnent = var.ENV
  }
}

resource "aws_key_pair" "positivetech-key" {
  key_name   = "PositiveTech-${var.ENV}-key"
  public_key = file("${path.root}/${var.PATH_TO_PUBLIC_KEY}")
}


output "vpc-security-group-ids" {
  description = "List of IDs of public subnets"
  value       = aws_security_group.allow-internal-mysql.id
}
