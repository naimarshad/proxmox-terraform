# proxmox-terraform

A repo to hold files related to VM Creation in Proxmox

This repo includes necessary files to spin up a VM and automate the kubernetes cluster configuration with kubeadm with proxmox hypervisor and terraform.

First of all we will create an empty project folder and then start adding the related terrafor resources.

The very first file we would like to add is `provider.tf`

In this file we will add the proxmox connection strings and some variables to hold those information. For example we will add the proxmox provider information & username password variables.

```bash
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

variable "proxmox_api_url" {
    type = string 
}

variable "proxmox_api_user" {
    type = string
    sensitive = true
}

variable "proxmox_api_password" {
    type = string
    sensitive = true
}
```

Then we will also mention the proxmox connection information and point them to above mentioned URL.

Since this is a sensitve data we have to create a separate file `credentials.auto.tfvars` to hold these sensitve values. such as;

```bash
proxmox_api_url = "https://192.168.8.50:8006/api2/json"
proxmox_api_user = "terraform-prov@pve"
proxmox_api_password = "***********"

```

**Note: to use this provider we need to add specific user and related role into proxmox hypervisor**.

```bash
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Al
locate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
pveum user add terraform-prov@pve --password ***********
pveum aclmod / -user terraform-prov@pve -role TerraformProv


```

Then we need to create a file with any name to hold the resource information of the VM we want to create. I am creating a VM creation file with cloudinit template. I have anubuntu based cloudinit template configured. So I will use that in my `create_vm.tf`.

After it is done we will run `terraform init` to initialize the project which initializes a working directory containing Terraform configuration files.

**One interesting note** about this configuration is that at the end of the `create_vm.tf` file you will see I am using a provisoner type `locale-exec`. The goal is to call a provisoner from the same VM where I am running terraform apply I want to call ansible play book to install and configure my VM accordingly.

In this example I will be creating a master node of kubernetes from a single `terraform apply` command.

Once the Project directory is initialized now we can simply run the terraform apply with extra variables

`terraform apply -var "pvt_key=/home/USER/.ssh/id_rsa" -var "pub_key=/home/USER/.ssh/id_rs.pub`

This will tell terraform to use the public and private key combination to for ansible playbook command.

`proxmox_vm_qemu.k8s-cp: Provisioning with 'local-exec'... proxmox_vm_qemu.k8s-cp (local-exec): Executing: ["/bin/sh" "-c" "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i 192.168.8.91, --private-key /home/n/.ssh/id_rsa -e 'pub_key=/home/n/.ssh/id_rs.pub' install-kubernetes-kubeadm.yaml"]`

`proxmox_vm_qemu.k8s-cp (local-exec): TASK [Initialize Kubernetes cluster with kubeadm] ****************************** proxmox_vm_qemu.k8s-cp: Still creating... [4m30s elapsed] proxmox_vm_qemu.k8s-cp: Still creating... [4m40s elapsed] proxmox_vm_qemu.k8s-cp: Still creating... [4m50s elapsed] proxmox_vm_qemu.k8s-cp: Still creating... [5m0s elapsed] proxmox_vm_qemu.k8s-cp: Still creating... [5m10s elapsed] proxmox_vm_qemu.k8s-cp: Still creating... [5m20s elapsed] proxmox_vm_qemu.k8s-cp: Still creating... [5m30s elapsed] proxmox_vm_qemu.k8s-cp (local-exec): changed: [192.168.8.91]`

Now by the end of successfule execution of the terraform command we will have kubernetes controlplane running, we can simply add worker node later on to the cluster.

**Note: If for some reasone you cannot apply the canal manifest. Just ssh to VM's IP and apply the manifest manually.**
