data "amazon-ami" "autogenerated_1" {
  filters = {
    name                = "ubuntu/images/*ubuntu-bionic-20.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.region}"
}

source "amazon-ebs" "autogenerated_1" {
  ami_name      = "ctfd-ami-${formatdate("YYYY-MM-DD.hhmm-ZZZ", timestamp())}"
  instance_type = "t3.medium"
  region        = var.region
  source_ami    = data.amazon-ami.autogenerated_1.id
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  # wait for cloud-init
  provisioner "shell" {
    inline = ["while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"]
  }

  # wait for apt tasks
  provisioner "shell" {
    inline = ["while [ `ps aux | grep -E '[a]pt|[d]pkg|[l]ock_is_held' | wc -l` -ne 0 ]; do echo \"apt, dpkg, or lock process still found\"; sleep 5; done"]
  }

  # install app deps
  provisioner "shell" {
    script = "setup.sh"
  }

}

