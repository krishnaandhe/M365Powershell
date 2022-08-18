#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  M365-Deployment Module
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Use at your own risk 

$Loop = $true
While ($Loop)
{
write-host 
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host       M365-Deployment Module    -foregroundcolor green
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host
write-host "1)  XXX" -ForegroundColor Yellow
write-host
write-host "2)  XXX" -ForegroundColor Red
write-host
write-host "3)  OneDrive Pre-Provision(Bulk)" -ForegroundColor Cyan
write-host
write-host "4)  Basic Security Assesment" -ForegroundColor Green
write-host
write-host "5)  DKIM Activation" -ForegroundColor DarkGray
write-host
write-host "6)  Exit" -ForegroundColor white
write-host
$opt = Read-Host "Select an option [1-6]"
write-host $opt
switch ($opt) 

{


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Script Initial
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



1{
        #———— Basic Deployments ———————
        
    #To set TimeZone for all Users
    Get-Mailbox -ResultSize unlimited | Set-MailboxRegionalConfiguration -Language en-US -TimeZone "India Standard Time" -DateFormat  "dd-MMM-yy" -TimeFormat "h:mm tt"

    #To Increase Mail Attachment Size
    Get-MailboxPlan | Set-MailboxPlan –MaxSendSize 145MB –MaxReceiveSize 145MB
    Get-Mailbox | Set-Mailbox –MaxSendSize 145MB –MaxReceiveSize 145MB

    #To Create New Exo-Admin Role & add members & Roles

    $rolusr = Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName "Company Administrator").ObjectId | Select DisplayName

    New-RoleGroup -Name "M365 Management" -Description "M365 Management Roles" -Roles "ApplicationImpersonation","Mailbox Import Export" `
    "Mailbox Search","Message Tracking","Migration","Move Mailboxes" -Members $rolusr.DisplayName

    #enable auto-expanding archiving for your entire organization
    Set-OrganizationConfig -AutoExpandingArchive
    
        #———— End of Indication ———————
  
}

2{

    #———— End of Indication ———————

}

3{

    #———— Start of Indication ———————
    #———— OneDrive Preprovision ———————

        $list = @()
        #Counters
        $i = 0


        #Get licensed users
        $users = Get-MsolUser -All | Where-Object { $_.islicensed -eq $true }
        #total licensed users
        $count = $users.count

        foreach ($u in $users) {
            $i++
            Write-Host "$i/$count"

            $upn = $u.userprincipalname
            $list += $upn

            if ($i -eq 199) {
                #We reached the limit
                Request-SPOPersonalSite -UserEmails $list -NoWait
                Start-Sleep -Milliseconds 655
                $list = @()
                $i = 0
            }
        }

        if ($i -gt 0) {
            Request-SPOPersonalSite -UserEmails $list -NoWait
        }    

   
    #———— End of Indication ———————
}

4{

    #Basic Security Assesment
    #To Enable Organization Customization Office 365
    Enable-OrganizationCustomization -ErrorAction 'silentlycontinue'

    Start-Sleep -Seconds 30
      $Admincust = Get-AdminAuditLogConfig
      If ($Admincust.UnifiedAuditLogIngestionEnabled -eq "false") 
       {
      "Unified_Audit_Log is Active"
      }
      Else 
      {
      "Unified_Audit_Log is Inactive"
      } 

    # Unified_Audit_Log Activation
    $Enabling = Read-Host "Do you want to Enable Unified_Audit_Log on Organisation [Y] Yes [N] No "

    if ($Enabling -match "[yY]") {
      Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true | Out-Null
      Write-Host "Unified_Audit_Log is Enabled, will impact in 2-4Hrs"
    }

    #To block enduser to signup trial subscriptions
    Set-MsolCompanySettings -AllowAdHocSubscriptions $false
    Write-Host "block enduser to signup trial subscriptions 2-4Hrs"

    #Create New Retention tag (Default 1 year move to archive)
    New-RetentionPolicyTag -Name "Default 1 year move to archive" -Type All -AgeLimitForRetention 365 -RetentionAction MoveToArchive `
    -RetentionEnabled $true -ErrorAction 'silentlycontinue'

    #Create New Retention Policy (Default 1 year move to archive)
    New-RetentionPolicy "Default 1 year move to archive" -RetentionPolicyTagLinks "1 Month Delete","1 Week Delete","1 Year Delete", `
    "6 Month Delete","Default 1 year move to archive","Deleted Items","Junk Email","Recoverable Items 14 days move to archive"

    #Outbound spam filter policy (Automatic >> On)
    Set-HostedOutboundSpamFilterPolicy -Identity Default -AutoForwardingMode on

    #Disable forwarding set through Inbox Rules
    Set-RemoteDomain Default -AutoForwardEnabled $false

    #To Increase Mail Attachment Size
    Get-MailboxPlan | Set-MailboxPlan –MaxSendSize 145MB –MaxReceiveSize 145MB
    Get-Mailbox | Set-Mailbox –MaxSendSize 145MB –MaxReceiveSize 145MB

    $Loop = $true
    Exit
   
    #———— End of Indication ———————
	

}

5{
    #DKIM Activation

   #Dkim Signing Config cmdlet to a particular domain:
$dom = (Get-MsolDomain | Where-Object {$_.isDefault}).name
New-DkimSigningConfig -DomainName $dom -Enabled $true

#To Crosscheck Dkim enabled
Get-DkimSigningConfig -Identity $dom | Format-List Selector1CNAME, Selector2CNAME

#to enable dkim
Set-DkimSigningConfig -Identity $dom -Enabled $true
      
    
    #———— End of Indication ———————

}

6{
    $Loop = $true
    Exit
    #———— End of Indication ———————

}

}}
