provider "aws" {
  
  region = "us-east-2"
}



# Security Group
variable "ingressrules" {
  type    = list(number)
  default = [8080, 22, 80, 443]
}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  dynamic "ingress" {
  for_each = var.ingressrules
  iterator = port
    content {
      from_port        = port.value
      to_port          = port.value
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
    }
}
   egress {
     from_port        = 0
     to_port          = 0
     protocol         = "-1"
     cidr_blocks      = ["0.0.0.0/0"]
   }

  tags = {
    "Terraform" = "true"
  }
}

# resorce block
resource "aws_instance" "Ansible" {
  ami             = "ami-0fa49cc9dc8d62c84"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "praveen"

  provisioner "file"{
  source      =  "praveen.pem"
  destination = "/tmp/praveen.pem"

}
  

   provisioner "remote-exec" {
       inline = [
         
         "sudo yum update -y",
         "sudo yum -y install wget",
         "sudo yum -y install python3",
         "sudo amazon-linux-extras install ansible2 -y",
         "ansible --version",
         "sudo chmod 666 /tmp/praveen.pem"

       ]
   }
   connection {
        type        = "ssh"
        host        = self.public_ip
        user        = "ec2-user"
        private_key = file("praveen.pem")
    }

    tags = {
        "Name"      = "Ansible Master"

          }

    }

    output "Ansibleinstance_public_ip" {
     description = "Public Ip address of the Ansible instance"
     value       = aws_instance.Ansible.public_ip
    }
    
    