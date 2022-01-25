#$service = Get-CsOnlineUser | Select-Object DisplayName,UserPrincipalName,SipAddress,HostingProvider,LineURI,OnPremLineURI,OnlineVoiceRoutingPolicy
#get-csonlineuser -identity adelev@M365x643811.onmicrosoft.com

$url = "https://prod-166.westus.logic.azure.com:443/workflows/7c0497e062234ff2ae617fd21231e89b/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=1eveUH7pqDXn0lrY9dspfuMXBeTIwPgrMAynFPP-5Lo"

$luctUser = Get-CsOnlineUser | Select-Object DisplayName,LineURI,OnPremLineURI,OnlineVoiceRoutingPolicy
#$luctUser = Get-CsOnlineUser -identity adelev@M365x643811.onmicrosoft.com | Select-Object DisplayName,LineURI,OnPremLineURI,OnlineVoiceRoutingPolicy

#$luctApplication = Get-CsOnlineApplicationInstance | Select-Object PhoneNumber
 
$service = ConvertTo-Json $luctUser

Invoke-RestMethod -Method Post -Uri $url -Body $service -ContentType application/json