#LoopUp Endpoint URL
$endpointUrl = "https://prod-116.westus.logic.azure.com:443/workflows/51082ef9eaf04300a64f250b4faa22d6/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=b72Wpa2uw86bK4zf2QjqsApSEhZMqe8qebB9kRvD1Ls"

#Teams PowerShell Authentication
$credentials = Get-AutomationPSCredential -Name 'LoopUpServiceAccountCredentials'
Connect-MicrosoftTeams -Credential $credentials 

#Days in the month
$firstDaysInMonth = get-date -day 1 -Hour 0 -Minute 0 -Second 0
$lastDaysInMonth = get-date $firstDaysInMonth.AddMonths(1).AddSeconds(-1)
$daysInMonth = ($lastDaysInMonth-$firstDaysInMonth).Days + 1

#Pro Rata
$proRata = "1"

#Tenant OnMicrosoft Domain
$tenantVerifiedDomain = (Get-CsTenant).DisplayName

#Tenant ID
$tenantId = (Get-CsTenant).TenantId.Guid

#Automation Account Variables
$filterOVRP = Get-AutomationVariable -Name "filterOVRP"

#Teams data collection
if ($filterOVRP -eq "N/A") {
    $billingData = Get-CsOnlineUser | where-object {
        $_.EnterpriseVoiceEnabled -like '*True*' -and ($_.LineUri -notlike '')
    } | Select-Object @{
        Name='LineUri'; Expression={$_.LineURI.ToLower().replace("tel:+","")}
    }, OnlineVoiceRoutingPolicy, @{
        Name='TenantId'; Expression = {$tenantId} 
    }, @{
        Name='TenantName'; Expression = {$tenantVerifiedDomain}
    }, @{
        Name='DaysInMonth'; Expression = {$daysInMonth}
    }, @{
        Name='ProRata'; Expression = {$proRata}
    }
}else {
    $billingData = Get-CsOnlineUser | where-object {
        $_.EnterpriseVoiceEnabled -like '*True*' -and ($_.OnlineVoiceRoutingPolicy -like "*$filterOutput*")
    } | Select-Object @{
        Name='LineUri'; Expression={$_.LineURI.ToLower().replace("tel:+","")}
    }, OnlineVoiceRoutingPolicy, @{
        Name='TenantId'; Expression = {$tenantId} 
    }, @{
        Name='TenantName'; Expression = {$tenantVerifiedDomain}
    }, @{
        Name='DaysInMonth'; Expression = {$daysInMonth}
    }, @{
        Name='ProRata'; Expression = {$proRata}       
    }
}

#Convert data to Json
$output = ConvertTo-Json $billingData -Depth 1

#Send data to endpoint url
Invoke-RestMethod -Method Post -Uri $endpointUrl -Body $output -ContentType application/json

#Output
Write-Output $output

