# Auto Template OS & Upload to Proxmox

Motivation: I wanted to create a template for Proxmox that would automatically install the latest version of Ubuntu among with any other software I needed. I realized pretty early on that the existing tools for this aren't great when trying to do this with Proxmox. 

## Ubuntu 

The approach I ended up taking for Ubuntu was the following (motivated by steps over at: https://austinsnerdythings.com/2021/08/30/how-to-create-a-proxmox-ubuntu-cloud-init-image/): 

1. Use Ansible to remote onto Proxmox host. 
2. Execute script which downloads the latest cloud-ready img (with cloud-init)
3. Use virt-customize to make customizations such as installing vm tools and other software. 
4. Create new Proxmox VM with the img 
5. Create a template from the new VM.
6. Run Terraform (on one's local machine) to create a new VMs from the template.  


The advantages of this approach (unlike the other approaches I tried) is that this process should work with any Linux dist that supports cloud-init. 

### Execute  

```bash
# Note need comma after host name
ansible-playbook -i {host}, proxmox_run.yml --user root --private-key=~/.ssh/id_rsa
```

## MIT License

Copyright (c) 2023 Justin Marwad 

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
