resource "proxmox_vm_qemu" "k8s-cp" {
  name        = "k8s-cp"
  desc        = "k8s controlplane"
  vmid        = 110
  target_node = "home-pve"
 
  agent   = 1

  clone     = "ubuntu-2004-cloudinit-template"
  cores     = 4
  sockets   = 1
  cpu       = "host"
  memory    = 4096
  ssh_user  = "ubuntu"
  scsihw    = "virtio-scsi-pci"
  bootdisk  = "scsi0"

  # The destination resource pool for the new VM
  #pool = "pool0"


  # Setup the disk
  disk {
      slot = 0
      size = "20G"
      type = "scsi"
      storage = "proxmox-disks-on-shared"
      iothread = 0
      ssd = 0
  }

network {
  model = "virtio"
  bridge = "vmbr0"
}

  os_type   = "cloud-init"
  ipconfig0 = "ip=192.168.8.91/24,gw=192.168.8.1"
  nameserver = "192.168.8.1"
  searchdomain = "linuxtechinfo.com"

  sshkeys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDN9nMkzH8fq5tgmNdKBKLauLFw8pcCSxSbIQuySszrjEKoxXyFx8/Hv4HRR9P2UM1boGn15c2DohG9f5zw3bRIN8Oehgvb3dS0ACC7Y8q4ZaLIyknGGTQpFkv6I8F8qzQDKtYn3ZeplfnSj+WaB7/cGLfxdRkr00ERlWW1IR3RkzzlM9oQnqX5JFeMhGv79pR+o8ta+jKocgWjIOVU5/9+2Hr2fMYt9neDwfpGsIWOOVPg7hVlXweRqjuVkr/eMm5w/poiQkk2fUsx3N4E3fEk/1iFwnpBp98YISd/HHnSUK6VFvc91wbZLLcvapoNPWhRciRD86lOENIIIFZ9CsdhTQjYFPe2VsxZcrD5wjZCK2AkzsLRhwqr8yhJeF4EnQ1tqOIZeocZX9inFldWEXX4HLhbvja/jKBQ35mylm6J8qryr8MMLjgdiUe5E81xDa564Joa+WSjcJ4IErSoMmfxDyXiwQVxUHkUClP/xabNUxBXxoLiIO6c5aPsgd0dJJU= naeem@office-arch
EOF


provisioner "remote-exec" {
#   inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]
  inline = ["echo Done!"]

  connection {
    host        = "192.168.8.91"
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.pvt_key)
   }
}

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -u ubuntu -i 192.168.8.91, --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' install-kubernetes-kubeadm.yaml"
}

}