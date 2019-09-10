Param([string]$ResourceGroupName,

    [string]$ComputerName, 
    
    [ValidateSet("Hours", "Days")]
    [string]$Unit = "Days", 
    
    [int]$Value = 1)

Connect-AzAccount
$tenantId = (Get-AzContext).Tenant.Id
$tokenCache = Get-AzContext | Select-Object -ExpandProperty TokenCache

$cachedTokens = $tokenCache.ReadItems() `
| Where-Object { $_.TenantId -eq $tenantId } `
| Sort-Object -Property ExpiresOn -Descending
$accessToken = $cachedTokens[0].AccessToken

$endTime = (Get-Date (Get-Date).ToUniversalTime() -Format "yyyy-MM-ddTHH:mm:ss.fffZ")

switch ($Unit) {
    "Hours" { $startTime = (Get-Date (Get-Date).AddHours(-$Value).ToUniversalTime() -Format "yyyy-MM-ddTHH:mm:ss.fffZ"); break }
    "Days" { $startTime = (Get-Date (Get-Date).AddDays(-$Value).ToUniversalTime() -Format "yyyy-MM-ddTHH:mm:ss.fffZ"); break }
}

$resourceID = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $ComputerName | Select-Object -ExpandProperty Id

$uri = "https://management.azure.com/providers/Microsoft.ResourceGraph/resourceChanges?api-version=2018-09-01-preview"

$json2 = @{
    resourceId = $resourceID
    interval   = @{
        start = $startTime
        end   = $endTime
    }
} | ConvertTo-Json -Depth 5

$response = Invoke-WebRequest -Method POST `
    -Uri $uri `
    -Body $json2 `
    -Headers @{ "Authorization" = "Bearer " + $accessToken; 'Content-Type' = 'application/json' } -UseBasicParsing

$changeURI = "https://management.azure.com/providers/Microsoft.ResourceGraph/resourceChangeDetails?api-version=2018-09-01-preview"
$jsonObj = ConvertFrom-Json $([String]::new($response.Content))

foreach ($changeID in $jsonObj.changes.changeId ) { 
    $json2 = @{
        resourceId = $resourceID
        changeId   = $changeID
    } | ConvertTo-Json -Depth 5

    $response = Invoke-RestMethod -Method POST `
        -Uri $changeURI `
        -Body $json2 `
        -Headers @{ "Authorization" = "Bearer " + $accessToken; 'Content-Type' = 'application/json' } 

    $response.beforeSnapshot.content | ConvertTo-Json -Depth 100 | Out-file tmp
    $response.afterSnapshot.content | ConvertTo-Json -Depth 100 | Out-file tmp2
    Compare-Object -ReferenceObject (Get-Content tmp) -DifferenceObject (Get-Content tmp2)
    Remove-Item tmp -Force
    Remove-Item tmp2 -Force
}










