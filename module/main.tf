resource "aws_instance" "instance" {
  ami                    = data.aws_ami.centos.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]

  tags = {
    Name = local.name
  }
}

resource "null_resource" "provisioner" {

  depends_on = [aws_instance.instance, aws_route53_record.records]
  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = aws_instance.instance.private_ip
    }

    inline = [
      "rm -rf pro-roboshop-shell-rs",
      "git clone https://github.com/TechlabRS/pro-roboshop-shell-rs",
      "cd pro-roboshop-shell-rs",
      "sudo bash ${var.component_name}.sh ${var.password}"
    ]
  }
}


resource "aws_route53_record" "records" {
  zone_id = "Z004850315D4679O2YUJ7"
  name    = "${var.component_name}-dev.uknowme.tech"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

