# VNet-to-Vnet connection via VPN Gateway
## What Does this plan do ?
A total of 40 resources are created.

1. Creates a 3 Resource Groups in eastus2,centralus & westus2 regions
2. Sets a tag on Resource Group
3. Creates 3 Virtual Networks
   * vnet04-eastus2     10.10.0.0/16 
   * vnet05-centralus  10.20.0.0/16 
   * vnet06-westus2     10.30.0.0/16 
4. Creates 3 VM Subnets
   * 10.10.10.0/24 (vnet04-eastus2 ) 
   * 10.20.20.0/24 (vnet05-centralus)
   * 10.30.30.0/24 (vnet06-westus2)
5. Creates 3 Gateway Subnets
   * 10.10.40.0/27 (vnet04-eastus2 ) 
   * 10.20.40.0/27 (vnet05-centralus)
   * 10.30.40.0/27 (vnet06-westus2)
6. Creates 3 Public IPs for Virtual Network Gateways
   * vgw-pubip01-vnet04 
   * vgw-pubip01-vnet05
   * vgw-pubip01-vnet06
7. Creates 3 Network Security Groups with Rules to allow inbound SSH
   * nsg04-eastus2 associated to default-subnet-vnet04
   * nsg05-eastus2 associated to default-subnet-vnet05
   * nsg06-eastus2 associated to default-subnet-vnet06
8.  Creates 3 Public IPs for VMs
    * vm04-pubip01  
    * vm05-pubip01  
    * vm06-pubip01  
9.  Creates 3 Network Interfaces for VMs
10. Creates 3 Standard_B2s Linux VMs (Ubuntu 16.04 LTS)
    * vm04 connected to vm04-nic01
    * vm05 connected to vm05-nic01
    * vm06 connected to vm06-nic01
11. Creates 3 Virtual Network Gateways, SKU : VpnGw2, BGP : enabled
    * vng-vnet04 
    * vng-vnet05
    * vng-vnet06 
12. Creates 4 Virtual Network Connections
    * conn_eastus2_centralus
    * conn_centralus_eastus2
    * conn_westus2_centralus
    * conn_centralus_westus2
13. Shows Output of VM's private and public ip's

authenticate using : 
```
az login
```

post authentication token is received :

```
terraform init
terraform plan
terraform apply
```

*the code can be further reduced by moving them in variables and common files, however the idea for this is for a simpler understanding without calling refrences*
VPN Gateways take a while to provision and can go beyond 90 mins, in this case the gateway creation will still proceed on Azure and when it get's provosioned import it using the command below.

```
terraform import azurerm_virtual_network_gateway.vng-vnet04 /subscriptions/0000000000/resourceGroups/rg04-eastus2/providers/Microsoft.Network/virtualNetworkGateways/vng-vnet04
terraform import azurerm_virtual_network_gateway.vng-vnet04 /subscriptions/0000000000/resourceGroups/rg05-centralus/providers/Microsoft.Network/virtualNetworkGateways/vng-vnet05
terraform import azurerm_virtual_network_gateway.vng-vnet04 /subscriptions/0000000000/resourceGroups/rg06-westus2/providers/Microsoft.Network/virtualNetworkGateways/vng-vnet06
terraform plan
terraform apply
```