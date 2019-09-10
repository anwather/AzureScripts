$vms = Get-AzVM

foreach ($vm in $vms) {
    $tags = (Get-AzResource -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName).Tags
    if ($null -eq $tags.size) {
        $tags += @{
            VmSize = $vm.HardwareProfile.VmSize
        }
        Set-AzResource -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Tag $tags -ResourceType "Microsoft.Compute/virtualMachines" -Force
    }
    elseif ($tags.size -ne $vm.HardwareProfile.VmSize) {
        $tags += @{
            VmSize = $vm.HardwareProfile.VmSize
        }
        Set-AzResource -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Tag $tags -ResourceType "Microsoft.Compute/virtualMachines" -Force
    }
    
}