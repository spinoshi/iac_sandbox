#!/bin/bash

wget https://releases.hashicorp.com/packer/1.6.0/packer_1.6.0_linux_amd64.zip > /dev/null 2>&1
wget https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip > /dev/null 2>&1

unzip packer_1.6.0_linux_amd64.zip 
unzip terraform_0.12.28_linux_amd64.zip 


sudo mv terraform /usr/local/bin/
sudo  mv packer /usr/local/bin/

rm *.zip
