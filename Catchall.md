<h1 align="center">Catch emails which is delivered to your domain but no longer active or incorrect id</h1>

<h3 align="center">A catch-all email account is an address that is specified to receive all messages that are addressed to an incorrect email address for a domain.</h3>

⚡⚡The Script starts from here ⚡⚡

I Assume, you know how to Connect Microsoft Services, if no then check out my Script https://github.com/krishnaandhe/M365Powershell/blob/main/M365_Connect.ps1

#To create Transport Rule
```
$ruleName = "Catch All"
```

#To Get Global Admins
```
$admins =  Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName "Company Administrator").ObjectId
$adminusr= $admins.EmailAddress -Join ","
$CharArray = $adminusr.Split("-")
```
#To config Internal Relay
```
$dom = (Get-MsolDomain | Where-Object {$_.isDefault}).name
Set-AcceptedDomain -Identity $dom -DomainType InternalRelay
Write-Host "InternalRelay Activated for $($dom)"
```

#To Shared mailbox Creation
```
$catchallbox = "catchallbox"+"@"+$dom
$catchallgrp = Get-DynamicDistributionGroup | Where-Object {$_.Identity -contains $ruleName}

if (!$catchallgrp) {
    Write-Host "Catchall Mailbox not found, creating CatchallBox" -ForegroundColor Green
    New-Mailbox -Name "CatchAll Box" -Shared -PrimarySmtpAddress $catchallbox -Alias "catchallbox"
Write-Host "Shared Mailbox created as $($catchallbox )"
}
else {
    Write-Host "Catchall Mailbox found, updating CatchallBox" -ForegroundColor Green
    Set-Mailbox -Identity $catchallbox -Alias "catchallbox"
}
```
#Assign Members to Shared mailbox
```
  foreach ($admin in $admins) 
    { 
      Add-MailboxPermission -Identity $catchallbox -AccessRights FullAccess -InheritanceType All -User $admin.EmailAddress
    }
Write-Host "Added Members in Shared Mailbox "
```
#To create Dynamic group all employees for exception with send mail restriction
```
$catchgrp = "all"+"@"+$dom
$catchallgrp = Get-DynamicDistributionGroup | Where-Object {$_.Identity -contains $ruleName}

if (!$catchallgrp) {
    Write-Host "Dynamic Group not found, creating Group" -ForegroundColor Green
    New-DynamicDistributionGroup -Name "All Employees" -Alias "allusers" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress $catchgrp
}
else {
    Write-Host "Dynamic Group found, updating Group" -ForegroundColor Green
    Set-DynamicDistributionGroup -Identity "All Employees" -Alias "allusers" -IncludedRecipients "MailboxUsers" -PrimarySmtpAddress $catchgrp
}
```
#Assign Members to DynamicGroup
```
Set-DynamicDistributionGroup -Identity $catchgrp -AcceptMessagesOnlyFrom $CharArray -ModeratedBy $CharArray
```
#Update properties of DynamicGroup
```
Set-DynamicDistributionGroup -Identity $catchgrp -ModerationEnabled $true -RequireSenderAuthenticationEnabled $true
```
#To Create Transport rule
```
$TSrule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
 
if (!$TSrule) {
    Write-Host "Rule not found, creating rule" -ForegroundColor Green
    New-TransportRule -Name $ruleName -Priority 0 -FromScope "NotInOrganization" -SentToScope "InOrganization" -RedirectMessageTo $catchallbox -ExceptIfSentToMemberOf $catchgrp
}
else {
    Write-Host "Rule found, updating rule" -ForegroundColor Green
    Set-TransportRule -Identity $ruleName -Priority 0 -FromScope "NotInOrganization" -SentToScope "InOrganization" -RedirectMessageTo $catchallbox -ExceptIfSentToMemberOf $catchgrp
}
```
#To Print Information
```
Write-Host "InternalRelay Activated for $($dom)"
Write-Host "Shared Mailbox created as $($catchallbox )"
Write-Host "Added Members in Shared Mailbox as $($admins) "
Write-Host "Dynamic Group created as $($catchgrp)" -ForegroundColor Green
Write-Host "Transport Rule as $($TSrule)" -ForegroundColor Green
```

⚡⚡The Script ends from here ⚡⚡
