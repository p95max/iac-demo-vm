# Terraform -- Infrastructure

## Init
terraform init

## Plan
terraform plan

## Apply
terraform apply

## Destroy
terraform destroy -auto-approve


# Reset Terraform state (if broken)

rm -rf .terraform
rm -f terraform.tfstate terraform.tfstate.backup
terraform init


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


# Docker Setup (on VM)

## Install official Docker CE
sudo apt remove -y docker.io
sudo apt update
sudo apt install -y ca-certificates curl gnupg

## Add Docker repo
sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Check Docker
docker info
docker compose version


# Docker Compose — Stack

## Pull images
docker compose pull

## Start stack
docker compose up -d

## Restart service
docker compose restart nginx

## Stop service
docker compose stop oauth2-proxy

## Show running containers
docker ps

## View logs
docker compose logs -f --tail=200
docker compose logs -f --tail=200 keycloak
docker compose logs -f --tail=200 oauth2-proxy


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


# Terraform Import (when provider bugged)

terraform import azurerm_network_security_group.nsg "/subscriptions/.../networkSecurityGroups/hylastix-nsg"

terraform import azurerm_linux_virtual_machine.vm "/subscriptions/.../virtualMachines/hylastix-vm"