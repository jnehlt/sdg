# RUNME

## VPSS based on CentOS-7.7
To run this stack just simply...:
```bash
$ /bin/bash ./run-vpss.sh
```
Quick description:

* Tools:
  * Packer v1.5.4
  * Terraform v0.12.23 (because why not :P )
  * Vagrant v2.2.7
  * Virtualbox v6.1.4 r136177

Security:
  * Simply hardened (see: [here](https://github.com/jnehlt/sdg/tree/master/packer/pscr))

* Provisioning time
  * ~25mins

## K8S stack
To run this stack just simply...:
```bash
$ /bin/bash ./run-k8s.sh
```
Quick description:

* Tools:
  * Vagrant v2.2.7
  * Ansible v2.9.2
  * Virtualbox v6.1.4 r136177

* Security:
  * None (RAW K8S cluster)

* Provisioning time
  * ~10mins  

Hope you're doing well