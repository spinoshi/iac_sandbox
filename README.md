# IaC sandbox

This repository gives you the all the necessary to spin up a small development environment that you can use to practice with IaC concepts.

What you will get is:
- An Ubuntu based VM with installed Openstack (Using Microstack - https://microstack.run/ )
- An Ubuntu based VM with installed Terraform (https://www.terraform.io/) and Packer (https://packer.io)

What you need is:

A Linux or OsX computer with 10GB of RAM available and the following software installed:

- Git (https://git-scm.com/downloads)
- VirtualBox (https://www.virtualbox.org/)
- Vagrant (https://www.vagrantup.com/)

## Setting up the sandbox

Once you have all the software installed, you can clone this repository using the following command:

``` git clone git@github.com:spinoshi/iac_sandbox.git ```

If you step into the newly created directory you will find this:

```
➜ cd iac_sandbox
➜ tree
.
├── README.md
├── scripts
│   ├── install_openstack_client.sh
│   ├── install_packer_and_terraform.sh
│   └── os_refinements.sh
└── Vagrantfile

```

At this point you can use vagrant to turn on the VMs, using the command ``` vagrant up ``` and you can check the status using:
```
➜ vagrant status
Current machine states:

os-controller             running (virtualbox)
dev-host                  running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

Login into the dev-host vm using ``` vagrant ssh dev-host ```.
This VM will be used to interact with openstack.

We check that everything is working correctly importing the stackrc file and listing the  openstack service endpoints:
```
vagrant@dev-host:~$ source stackrc
vagrant@dev-host:~$ openstack endpoint list
+----------------------------------+------------+--------------+--------------+---------+-----------+-----------------------------+
| ID                               | Region     | Service Name | Service Type | Enabled | Interface | URL                         |
+----------------------------------+------------+--------------+--------------+---------+-----------+-----------------------------+
| 097a573ca7de478bbe304b7022625ea6 | microstack | neutron      | network      | True    | public    | http://10.20.20.1:9696      |
| 0b75f5492a7746dd9cb7f541df7e97ef | microstack | nova         | compute      | True    | public    | http://10.20.20.1:8774/v2.1 |
| 18de5e0e7eb74b848d4b98e7efb5c43f | microstack | neutron      | network      | True    | admin     | http://10.20.20.1:9696      |
| 2ae3b7ddce56494aafcaeea09d439237 | None       | keystone     | identity     | True    | public    | http://10.20.20.1:5000/v3/  |
| 34a6b514ac4d4b58b5723285995f795f | microstack | neutron      | network      | True    | internal  | http://10.20.20.1:9696      |
| 466e5d8b006243debe318f0750cc03ee | microstack | nova         | compute      | True    | admin     | http://10.20.20.1:8774/v2.1 |
| 487f41eb2ede422b9b0b3d6b756c83ed | microstack | glance       | image        | True    | public    | http://10.20.20.1:9292      |
| 6321d32a056943948ad139296db4fb29 | microstack | placement    | placement    | True    | admin     | http://10.20.20.1:8778      |
| 8aae69f2a49f43f687a6c676229346c9 | None       | keystone     | identity     | True    | admin     | http://10.20.20.1:5000/v3/  |
| 8dcae2853f3049fba1283944c7d58364 | microstack | glance       | image        | True    | admin     | http://10.20.20.1:9292      |
| a3cef7c29fdd45a49d0ccc57e0610e25 | microstack | placement    | placement    | True    | internal  | http://10.20.20.1:8778      |
| c33289808d26445bbea10912e2cc2870 | microstack | nova         | compute      | True    | internal  | http://10.20.20.1:8774/v2.1 |
| c5d2f39b31c04b2f9afecd1a2a03ffa6 | microstack | glance       | image        | True    | internal  | http://10.20.20.1:9292      |
| e006132abf83470aaa23c59c9bd741e3 | microstack | placement    | placement    | True    | public    | http://10.20.20.1:8778      |
| f595154702b944d0b188d4597d1b83fc | None       | keystone     | identity     | True    | internal  | http://10.20.20.1:5000/v3/  |
+----------------------------------+------------+--------------+--------------+---------+-----------+-----------------------------+
vagrant@dev-host:~$

```
## Terraform

Using terraform you can define and deploy entire infrastructures.
We will use terraform to spin up 2 VMs on our Openstack cloud platform.

Our working directory will be:
```
mkdir OS_Terraform && cd OS_Terraform
```
First we need to configure terraform provider to access openstack (copy and paste  into your shell and then press CTRL-D):
```
$ cat > provider.tf
``` 

```
### copy this: vvvvvvv
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "keystone"
  auth_url    = "http://192.168.56.200:5000/v3"
  region      = "microstack"
}
```
We can then enable the providers using:
```
vagrant@dev-host:~/OS_Terraform$  terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "openstack" (terraform-providers/openstack) 1.29.0...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.openstack: version = "~> 1.29"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

At this point we can create some initial resources (SSH keypairs and Network):
```
$ cat > main.tf
``` 

```
### copy this: vvvvvvv
resource "openstack_compute_keypair_v2" "my_first_keypair" {
name = "my_first_keypair"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2oxvCpd67VmqfEcz0YgkHwSfvLUXFGbyOePrjpt/ayz5g530jCmAvNzuSyTyPCVcMAYserK2zBMfa+vgS1yLc49wYNRz6JPJv/G9osUYmUzApmDaSuRWq/SOOivQSJ0JPBTrvSf0Ag21GlvkuNA4ebYPVRJLx8ZQWANEfMnPdSJUkRc+sJDeE9/5i+RpnZRUR6ShYkd8N+6cdrnsZL8Jd1UguUz9l/hM1oRB6LGUtSU8Omsw4PMGyPARI2vqJqAFWPk/JKEKc0j8Ledz2TYK4sz7H3Bwgzcq7OWPf4DD0j/YQOUHMFyQJq7ozwuvFpQ7vv3xvbhQNYIgxbh78fQpf vagrant@dev-host"
}
resource "openstack_networking_network_v2" "my_first_network" {
name = "my_first_network"
admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "my_first_subnet" {
name = "my_first_subnet"
network_id = openstack_networking_network_v2.my_first_network.id
cidr = "10.0.0.0/24"
ip_version = 4
dns_nameservers = ["8.8.8.8","8.8.4.4"]
}
```
We can use the command ``` terraform plan ``` to inspect what is going to be created:

```
vagrant@dev-host:~/OS_Terraform$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # openstack_compute_keypair_v2.my_first_keypair will be created
  + resource "openstack_compute_keypair_v2" "my_first_keypair" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + name        = "my_first_keypair"
      + private_key = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2oxvCpd67VmqfEcz0YgkHwSfvLUXFGbyOePrjpt/ayz5g530jCmAvNzuSyTyPCVcMAYserK2zBMfa+vgS1yLc49wYNRz6JPJv/G9osUYmUzApmDaSuRWq/SOOivQSJ0JPBTrvSf0Ag21GlvkuNA4ebYPVRJLx8ZQWANEfMnPdSJUkRc+sJDeE9/5i+RpnZRUR6ShYkd8N+6cdrnsZL8Jd1UguUz9l/hM1oRB6LGUtSU8Omsw4PMGyPARI2vqJqAFWPk/JKEKc0j8Ledz2TYK4sz7H3Bwgzcq7OWPf4DD0j/YQOUHMFyQJq7ozwuvFpQ7vv3xvbhQNYIgxbh78fQpf vagrant@dev-host"
      + region      = (known after apply)
    }

  # openstack_networking_network_v2.my_first_network will be created
  + resource "openstack_networking_network_v2" "my_first_network" {
      + admin_state_up          = true
      + all_tags                = (known after apply)
      + availability_zone_hints = (known after apply)
      + dns_domain              = (known after apply)
      + external                = (known after apply)
      + id                      = (known after apply)
      + mtu                     = (known after apply)
      + name                    = "my_first_network"
      + port_security_enabled   = (known after apply)
      + qos_policy_id           = (known after apply)
      + region                  = (known after apply)
      + shared                  = (known after apply)
      + tenant_id               = (known after apply)
      + transparent_vlan        = (known after apply)
    }

  # openstack_networking_subnet_v2.my_first_subnet will be created
  + resource "openstack_networking_subnet_v2" "my_first_subnet" {
      + all_tags          = (known after apply)
      + cidr              = "10.0.0.0/24"
      + dns_nameservers   = [
          + "8.8.8.8",
          + "8.8.4.4",
        ]
      + enable_dhcp       = true
      + gateway_ip        = (known after apply)
      + id                = (known after apply)
      + ip_version        = 4
      + ipv6_address_mode = (known after apply)
      + ipv6_ra_mode      = (known after apply)
      + name              = "my_first_subnet"
      + network_id        = (known after apply)
      + no_gateway        = false
      + region            = (known after apply)
      + tenant_id         = (known after apply)

      + allocation_pool {
          + end   = (known after apply)
          + start = (known after apply)
        }

      + allocation_pools {
          + end   = (known after apply)
          + start = (known after apply)
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

At this point we can actually deploy these resources using ```terraform apply ``` (you need to say "yes" when requested):

```
vagrant@dev-host:~/OS_Terraform$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # openstack_compute_keypair_v2.my_first_keypair will be created
  + resource "openstack_compute_keypair_v2" "my_first_keypair" {
      + fingerprint = (known after apply)
      + id          = (known after apply)
      + name        = "my_first_keypair"
      + private_key = (known after apply)
      + public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2oxvCpd67VmqfEcz0YgkHwSfvLUXFGbyOePrjpt/ayz5g530jCmAvNzuSyTyPCVcMAYserK2zBMfa+vgS1yLc49wYNRz6JPJv/G9osUYmUzApmDaSuRWq/SOOivQSJ0JPBTrvSf0Ag21GlvkuNA4ebYPVRJLx8ZQWANEfMnPdSJUkRc+sJDeE9/5i+RpnZRUR6ShYkd8N+6cdrnsZL8Jd1UguUz9l/hM1oRB6LGUtSU8Omsw4PMGyPARI2vqJqAFWPk/JKEKc0j8Ledz2TYK4sz7H3Bwgzcq7OWPf4DD0j/YQOUHMFyQJq7ozwuvFpQ7vv3xvbhQNYIgxbh78fQpf vagrant@dev-host"
      + region      = (known after apply)
    }

  # openstack_networking_network_v2.my_first_network will be created
  + resource "openstack_networking_network_v2" "my_first_network" {
      + admin_state_up          = true
      + all_tags                = (known after apply)
      + availability_zone_hints = (known after apply)
      + dns_domain              = (known after apply)
      + external                = (known after apply)
      + id                      = (known after apply)
      + mtu                     = (known after apply)
      + name                    = "my_first_network"
      + port_security_enabled   = (known after apply)
      + qos_policy_id           = (known after apply)
      + region                  = (known after apply)
      + shared                  = (known after apply)
      + tenant_id               = (known after apply)
      + transparent_vlan        = (known after apply)
    }

  # openstack_networking_subnet_v2.my_first_subnet will be created
  + resource "openstack_networking_subnet_v2" "my_first_subnet" {
      + all_tags          = (known after apply)
      + cidr              = "10.0.0.0/24"
      + dns_nameservers   = [
          + "8.8.8.8",
          + "8.8.4.4",
        ]
      + enable_dhcp       = true
      + gateway_ip        = (known after apply)
      + id                = (known after apply)
      + ip_version        = 4
      + ipv6_address_mode = (known after apply)
      + ipv6_ra_mode      = (known after apply)
      + name              = "my_first_subnet"
      + network_id        = (known after apply)
      + no_gateway        = false
      + region            = (known after apply)
      + tenant_id         = (known after apply)

      + allocation_pool {
          + end   = (known after apply)
          + start = (known after apply)
        }

      + allocation_pools {
          + end   = (known after apply)
          + start = (known after apply)
        }
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

openstack_networking_network_v2.my_first_network: Creating...
openstack_compute_keypair_v2.my_first_keypair: Creating...
openstack_compute_keypair_v2.my_first_keypair: Creation complete after 2s [id=my_first_keypair]
openstack_networking_network_v2.my_first_network: Creation complete after 7s [id=e35d78cd-ead4-4a2b-a977-b50fb26761d3]
openstack_networking_subnet_v2.my_first_subnet: Creating...
openstack_networking_subnet_v2.my_first_subnet: Creation complete after 6s [id=c12cb60d-2b60-40ab-a61d-f0808657a4d3]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

We will see the network we have just created using: ``` openstack network list ```:
```
vagrant@dev-host:~/OS_Terraform$ openstack network list
+--------------------------------------+------------------+--------------------------------------+
| ID                                   | Name             | Subnets                              |
+--------------------------------------+------------------+--------------------------------------+
| 84b48980-96b0-4ae8-b8f7-62b5345c8fcf | test             | 4d7fe2e5-714e-4811-93da-11fda0aa9748 |
| c5afd488-d8fb-4ec8-91f4-3ba2a928badd | my_first_network | 7ff86d95-f028-46e0-b9a9-387ab38b5d5e |
| df6e2ac7-3598-4181-8f7b-d4880734e576 | external         | 0de21c3c-6122-4b7f-9265-85de5248aaf9 |
+--------------------------------------+------------------+--------------------------------------+
```

