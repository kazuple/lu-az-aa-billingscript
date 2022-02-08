#Get Automation Account Variables (LUCT TLD)
#$luServiceAccountUsername = Get-AutomationVariable -Name 'luServiceAccountUsername'
#$luServiceAccountPassword = Get-AutomationVariable -Name 'luServiceAccountPassword'

#LoopUp Endpoint URL
$endpointUrl = "https://prod-166.westus.logic.azure.com:443/workflows/7c0497e062234ff2ae617fd21231e89b/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=1eveUH7pqDXn0lrY9dspfuMXBeTIwPgrMAynFPP-5Lo"

#Teams PowerShell
#$User = "$luServiceAccountUsername"
#$PWord = ConvertTo-SecureString -String $luServiceAccountPassword -AsPlainText -Force
#$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
#Connect-MicrosoftTeams -Credential $credential

#Teams PowerShell Authentication
$credentials = Get-AutomationPSCredential -Name 'LoopUp Service Account Credentials'
Connect-MicrosoftTeams -Credential $credentials 
Write-Output "1/4 - Connected to Teams Tenant via PowerShell"

#First/Last Day of Month
$currentDate = Get-Date -Format "dd/MM/yyyy"
$firstDayOfMonth = Get-Date $CURRENTDATE -Day 1
$lastDayOfMonth = Get-Date $FIRSTDAYOFMONTH.AddMonths(1).AddSeconds(-1)

#Teams data collection
$tenantVerifiedDomain = (Get-CsTenant).VerifiedDomains.Name | Where-Object {$_ -match "^([^.]+).onmicrosoft.com"}
$billingData = Get-CsOnlineUser | where-object {$_.EnterpriseVoiceEnabled -like '*True*' -and ($_.Enabled -like '*True')} | Select-Object LineURI,OnPremLineURI,OnlineVoiceRoutingPolicy, @{Name='TenantName'; Expression = {$tenantVerifiedDomain}}, @{Name='StartMonth'; Expression = {$firstDayOfMonth}}, @{Name='EndMonth'; Expression = {$lastDayOfMonth}}
Write-Output "2/4 - Collected Billing Data"

#Convert data to Json
$output = ConvertTo-Json $billingData

#Send data to endpoint url
Invoke-RestMethod -Method Post -Uri $endpointUrl -Body $output -ContentType application/json
Write-Output "3/4 - Data sent to LoopUp"

#Remove PS Session
Get-PSSession | Where-Object {$_.ComputerName -like "*api*"} | Remove-PSSession
Write-Output "4/4 - PowerShell Session Removed"