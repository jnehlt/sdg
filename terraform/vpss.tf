resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "private_key" {
  filename          = "${local.keys_path}sdg"
  sensitive_content = tls_private_key.ssh_key.private_key_pem
  file_permission   = "0400"
}

resource "local_file" "public_key" {
  filename          = "${local.keys_path}sdg.pub"
  sensitive_content = local.public_key
  file_permission   = "0600"
}

resource "null_resource" "exec_packer" {
  depends_on = [
    local_file.private_key,
    local_file.private_key
  ]
  provisioner "local-exec" {
    command = "cd ../packer && packer build tmpl/centOS7.json"
  }
}

resource "null_resource" "register_box" {
  provisioner "local-exec" {
    command = "cd ../packer && vagrant box add sdg/centOS CentOS-7.7.1908_aarch64-virtualbox.box"
  }
}

resource "null_resource" "exec_vagrant" {
  depends_on = [
    null_resource.exec_packer
  ]
  provisioner "local-exec" {
    command = "cd ../packer && vagrant up"
  }
}

locals {
  keys_path      = "../packer/keys/"
  public_key_tmp = chomp(tls_private_key.ssh_key.public_key_openssh)
  public_key     = join(" ", [local.public_key_tmp], ["sdg"])
}

