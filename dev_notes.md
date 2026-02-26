# Terraform -- Infrastructure

# Azure CLI — Infrastructure Debug

## Check available free/low SKU
az vm list-skus -l northeurope --resource-type virtualMachines -o table \
--query "[?capabilities[?name=='vCPUs' && (value=='1' || value=='2')]].{Name:name, Tier:tier}"

## Check Public IP from Terraform
terraform output -raw public_ip

## Check Public IP via Azure CLI
az network public-ip show -g hylastix-rg -n hylastix-ip \
--query "{ip:ipAddress, nic:ipConfiguration.id}" -o json

## Check subnet NSG binding
az network vnet subnet show -g hylastix-rg \
--vnet-name hylastix-vnet -n hylastix-subnet \
--query "{nsg:networkSecurityGroup.id}" -o json


# SSH Access

## Generate RSA key (Azure-compatible)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/hylastix_rsa -C "hylastix"

## Connect to VM
ssh -i ~/.ssh/hylastix_rsa azureuser@YOUR-IP

## Fix permissions (if needed)
chmod 600 ~/.ssh/hylastix_rsa

## Test open ports
nc -vz YOUR-IP 22
nc -vz YOUR-IP 80
nc -vz YOUR-IP 8080


# Ansible — Provisioning

## Test connectivity
ansible -i inventory.ini web -m ping

## Run playbook
ansible-playbook -i inventory.ini playbook.yml

# Service Checks

## Check nginx locally
curl -I http://127.0.0.1/

## Check Keycloak locally
curl -I http://127.0.0.1:8080/

## External access
http://20.223.216.43/
http://20.223.216.43:8080/


# Azure Cleanup

# Delete resource group
az group delete -n hylastix-rg --yes --no-wait

## Check if exists
az group exists -n hylastix-rg

az group list --output table


# Change files in server

sudo nano /opt/hylastix/docker/static/index.html