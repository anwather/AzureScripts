# Update-VMSizeTag.ps1

Run while logged into an Azure subscription - will tag each virtual machine resource with a tag called VmSize containing the virtual machine size.

# Get-VirtualMachineChanges.ps1

Will determine changes of a virtual machine between now and 14 days prior.

### Usage

```
Get-VirtualMachineChanges.ps1 [[-ResourceGroupName] <string>] [[-ComputerName] <string>] [[-Unit] <string>] [[-Value] <int>]
```

e.g. 

```
Get-VirtualMachineChanges.ps1 -ResourceGroupName test-rg -ComputerName MyVM01 -Unit Days -Value 6
```
