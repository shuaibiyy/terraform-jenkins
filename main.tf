provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource "terraform_remote_state" "tfstate" {
  backend = "s3"

  config {
    bucket = "mycompany-terraform"
    key = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_security_group" "sg_jenkins" {
  name = "sg_${var.jenkins_name}"
  description = "Allows all traffic"

  # SSH
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # Jenkins JNLP port
  ingress {
    from_port = 50000
    to_port = 50000
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # Weave Scope port
  ingress {
    from_port = 4040
    to_port = 4040
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"
}

resource "aws_instance" "jenkins" {
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.sg_jenkins.name}"]
  ami = "${lookup(var.amis, var.region)}"
  key_name = "${var.key_name}"
  user_data = "${template_file.user_data.rendered}"

  tags {
    "Name" = "${var.jenkins_name}"
  }

  # Add backup task to crontab
  provisioner "file" {
    connection {
      user = "ec2-user"
      host = "${aws_instance.jenkins.public_ip}"
      timeout = "1m"
      key_file = "${var.key_name}.pem"
    }
    source = "templates/cron.sh"
    destination = "/home/ec2-user/cron.sh"
  }

  provisioner "remote-exec" {
    connection {
      user = "ec2-user"
      host = "${aws_instance.jenkins.public_ip}"
      timeout = "1m"
      key_file = "${var.key_name}.pem"
    }
    inline = [
      "chmod +x /home/ec2-user/cron.sh",
      "/home/ec2-user/cron.sh ${var.access_key} ${var.secret_key} ${var.s3_bucket} ${var.jenkins_name}"
    ]
  }
}
