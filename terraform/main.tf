# Bloco 1: Configura o provedor AWS, dizendo ao Terraform que vamos criar recursos na AWS.
provider "aws" {
  region = var.aws_region
}

# Pesquisa pela AMI mais recente do Ubuntu 22.04 na região configurada
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # ID da Canonical, a empresa por trás do Ubuntu
}

# Bloco 2: Cria a nossa rede privada virtual (VPC). É o nosso espaço de rede isolado na nuvem.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Bloco 3: Cria um Gateway de Internet para permitir a comunicação entre nossa VPC e a internet.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Bloco 4: Cria uma sub-rede pública. Servidores ficarão aqui para serem acessíveis.
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true # Atribui um IP público automaticamente a qualquer instância na sub-rede.
  tags = {
    Name = "public-subnet"
  }
}

# Bloco 5: Cria uma tabela de rotas para direcionar o tráfego da sub-rede para a internet via Gateway.
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # "Qualquer lugar da internet"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Bloco 6: Associa sub-rede à tabela de rotas.
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

# Bloco 7: Cria um grupo de segurança (firewall) para a instância.
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Libera todo o tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bloco 8: Cria a instância EC2
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id # Imagem de Máquina: Ubuntu 22.04 LTS na região us-east-1
  instance_type = "t2.micro"             # Tipo de instância (incluído no nível gratuito da AWS)

  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Script de inicialização: Este script roda automaticamente quando o servidor é criado.
  # Ele prepara o ambiente, baixa seu código do GitHub e inicia a aplicação.
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y git

              # Instala NVM e Node.js
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
              export NVM_DIR="$HOME/.nvm"
              [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
              nvm install --lts

              git clone https://github.com/Luizdetec/Projeto-de-Computacao-em-Nuvem.git /home/ubuntu/app

              # Entra na pasta da aplicação
              cd /home/ubuntu/app/app

              # Instala dependências da aplicação
              npm install

              # Instala o PM2 para gerenciar o processo do Node.js
              npm install pm2 -g
              
              # Inicia o servidor com PM2
              pm2 start server.js
              EOF

  tags = {
    Name = "Servidor-Chat"
  }
}

# Bloco 9: (Opcional) Mostra o IP público da instância no final para você poder acessá-la.
output "instance_public_ip" {
  value = aws_instance.app_server.public_ip
}