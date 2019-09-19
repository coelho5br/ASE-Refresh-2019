param (
    [string]$ResourceGroupName
)

$NSGName = "ASE-TR-NSG-User"
$RG = $ResourceGroupName
$Location = (Get-AzureRmResourceGroup $ResourceGroupName).Location
$SubnetConfigName = "Subnet5"
$NSGName = "Subnet5-NSG"


# Inbound Rules
$ir1 = New-AzureRmNetworkSecurityRuleConfig -Name "Inbound-management" -Description "Used to manage ASE from public VIP" `
    -Access Allow -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 444-445

$ir2 = New-AzureRmNetworkSecurityRuleConfig -Name "Inbound-load-balancer-port" -Description "ASE-internal-inbound" `
    -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix AzureLoadBalancer `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 16001
    
$ir3 = New-AzureRmNetworkSecurityRuleConfig -Name "ASE-internal-inbound" -Description "ASE-internal-inbound" `
    -Access Allow -Protocol * -Direction Inbound -Priority 120 -SourceAddressPrefix 10.11.4.0/24 `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

$ir4 = New-AzureRmNetworkSecurityRuleConfig -Name "Inbound-FTP" -Description "Allow FTP over port 21" `
    -Access Allow -Protocol * -Direction Inbound -Priority 130 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 21     
    
$ir5 = New-AzureRmNetworkSecurityRuleConfig -Name "Inbound-FTPs" -Description "Allow FTPS" `
    -Access Allow -Protocol * -Direction Inbound -Priority 140 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 990 
    
$ir6 = New-AzureRmNetworkSecurityRuleConfig -Name "Inbound-FTP-Data" -Description "Allow FTP Data" `
    -Access Allow -Protocol * -Direction Inbound -Priority 150 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 10001-10020         

$ir7 = New-AzureRmNetworkSecurityRuleConfig -Name "Inbound-Remote-Debugging" -Description "Visual Studio remote debugging" `
    -Access Allow -Protocol * -Direction Inbound -Priority 160 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 4016-4022    

# Outbound Rules
$or1 = New-AzureRmNetworkSecurityRuleConfig -Name "Outbound-443" -Description "Azure Storage queue" `
    -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 445
    
$or2 = New-AzureRmNetworkSecurityRuleConfig -Name "Outbound-SMB" -Description "Azure Storage queue" `
    -Access Allow -Protocol * -Direction Outbound -Priority 110 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 445

$or3 = New-AzureRmNetworkSecurityRuleConfig -Name "Outbound-DB" -Description "Database" `
    -Access Allow -Protocol * -Direction Outbound -Priority 120 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 1433
    
$or4 = New-AzureRmNetworkSecurityRuleConfig -Name "Outbound-DB2" -Description "Database 2" `
    -Access Allow -Protocol * -Direction Outbound -Priority 130 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 11000-11999
    
$or5 = New-AzureRmNetworkSecurityRuleConfig -Name "Outbound-DB3" -Description "Database 3" `
    -Access Allow -Protocol * -Direction Outbound -Priority 140 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 14000-14999
    
$or6 = New-AzureRmNetworkSecurityRuleConfig -Name "Outbound-DNS" -Description "DNS" `
    -Access Allow -Protocol * -Direction Outbound -Priority 150 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 53
    
$or7 = New-AzureRmNetworkSecurityRuleConfig -Name "ASE-internal-outbound" -Description "Azure Storage queue" `
    -Access Allow -Protocol * -Direction Outbound -Priority 160 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix 10.11.4.0/24 -DestinationPortRange *
    
$or8 = New-AzureRmNetworkSecurityRuleConfig -Name "Outbound-80" -Description "Outbound 80" `
    -Access Allow -Protocol * -Direction Outbound -Priority 170 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80
    
$or9 = New-AzureRmNetworkSecurityRuleConfig -Name "ASE-to-VNET" -Description "ASE to VNET" `
    -Access Allow -Protocol * -Direction Outbound -Priority 180 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix 10.11.4.0/24 -DestinationPortRange * 

New-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RG -SecurityRules $ir1,$ir2,$ir3,$ir4,$ir5,$ir6,$ir7,$or1,$or2,$or3,$or4,$or5,$or6,$or7,$or8 -Location $Location

Start-Sleep -Seconds 30

$VNet = Get-AzureRmVirtualNetwork -Name "ASE-TR-VNET" -ResourceGroupName $RG
$SubnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -Name ($SubnetConfigName) -VirtualNetwork $VNet
Set-AzureRmVirtualNetworkSubnetConfig -Name $SubnetConfig.Name -VirtualNetwork $VNet -AddressPrefix $SubnetConfig.AddressPrefix -NetworkSecurityGroup $NSGName
$VNet | Set-AzureRmVirtualNetwork
}
