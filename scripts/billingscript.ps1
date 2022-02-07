#Get Automation Account Variables (LUCT TLD)
$luServiceAccountUsername = Get-AutomationVariable -Name 'luServiceAccountUsername'
$luServiceAccountPassword = Get-AutomationVariable -Name 'luServiceAccountPassword'

#LoopUp Endpoint URL
$endpointUrl = "https://prod-166.westus.logic.azure.com:443/workflows/7c0497e062234ff2ae617fd21231e89b/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=1eveUH7pqDXn0lrY9dspfuMXBeTIwPgrMAynFPP-5Lo"

#Teams PowerShell
$User = "$luServiceAccountUsername"
$PWord = ConvertTo-SecureString -String $luServiceAccountPassword -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
Connect-MicrosoftTeams -Credential $credential

#First/Last Day of Month
$CURRENTDATE=GET-DATE -Format "MM/dd/yyyy"
$FIRSTDAYOFMONTH=GET-DATE $CURRENTDATE -Day 1
$LASTDAYOFMONTH=GET-DATE $FIRSTDAYOFMONTH.AddMonths(1).AddSeconds(-1)

$tenantId = (Get-CsTenant).VerifiedDomains.Name | Where-Object {$_ -match "^([^.]+).onmicrosoft.com"}
$luctUser = Get-CsOnlineUser | where-object {$_.EnterpriseVoiceEnabled -like '*True*' -and ($_.Enabled -like '*True')} | Select-Object TenantId,DisplayName,LineURI,OnPremLineURI,OnlineVoiceRoutingPolicy, @{Name='TenantName'; Expression = {$tenantId}}, @{Name='StartDate'; Expression = {$FIRSTDAYOFMONTH}}, @{Name='StartDate'; Expression = {$LASTDAYOFMONTH}}

$output = ConvertTo-Json $luctUser

Invoke-RestMethod -Method Post -Uri $endpointUrl -Body $output -ContentType application/json