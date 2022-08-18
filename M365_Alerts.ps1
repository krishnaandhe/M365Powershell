#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Security Assesment Module
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Use at your own risk 

$Loop = $true
While ($Loop)
{
write-host 
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host       Microsoft 365 Security Assesment Module    -foregroundcolor green
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host
write-host "1)  External email warning" -ForegroundColor Yellow
write-host
write-host "2)  External Senders with matching Display Names" -ForegroundColor Red
write-host
write-host "3)  Organization Disclaimer" -ForegroundColor Cyan
write-host
write-host "4)  Domain Rejection" -ForegroundColor Green
write-host
write-host "5)  Bitcoin Block" -ForegroundColor DarkGray
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

        #——– Start of Indication  ———–

        $ruleName1 = "External Email Warning"
        $ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#ffff00;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#ffffcc;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'>This email originated from outside of the organization & using company domain name, do not click on any links or open attachments unless you recognize the sender and know the content is safe Or Report email as Junk/Spam <o:p></o:p></span></p></div></td></tr></table>"
 
        $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName1}
 
        if (!$rule) {
        Write-Host "Rule not found, creating rule External Email Warning" -ForegroundColor Green
        New-TransportRule -Name $ruleName1 -Priority 0 -FromScope "NotInOrganization" -SentToScope "InOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
        -ApplyHtmlDisclaimerText $ruleHtml -ExceptIfSubjectContainsWords "fwd:","re:"
                    }
        else {
            Write-Host "Rule found, updating rule External Email Warning" -ForegroundColor Green
         Set-TransportRule -Identity $ruleName1 -Priority 0 -FromScope "NotInOrganization" -SentToScope "InOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
            -ApplyHtmlDisclaimerText $ruleHtml -ExceptIfSubjectContainsWords "fwd:","re:"
                    }
              
        $Loop = $true
        Exit
        #———— End of Indication ———————
  
}

2{

    $ruleName2 = "External Senders with matching Display Names"
    $ruleHtml = "<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 align=left width=`"100%`" style='width:100.0%;mso-cellspacing:0cm;mso-yfti-tbllook:1184; mso-table-lspace:2.25pt;mso-table-rspace:2.25pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:column;mso-table-left:left;mso-padding-alt:0cm 0cm 0cm 0cm'>  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'><td style='background:#910A19;padding:5.25pt 1.5pt 5.25pt 1.5pt'></td><td width=`"100%`" style='width:100.0%;background:#FDF2F4;padding:5.25pt 3.75pt 5.25pt 11.25pt; word-wrap:break-word' cellpadding=`"7px 5px 7px 15px`" color=`"#212121`"><div><p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:2.25pt; mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal: column;mso-height-rule:exactly'><span style='font-size:9.0pt;font-family: `"Segoe UI`",sans-serif;mso-fareast-font-family:`"Times New Roman`";color:#212121'>This message was sent from outside the company by someone with a display name matching a user in your organisation. Please do not click links or open attachments unless you recognise the source of this email and know the content is safe. <o:p></o:p></span></p></div></td></tr></table>"
 
    $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName2}
    $displayNames = (Get-Mailbox -ResultSize Unlimited).DisplayName
 
    if (!$rule) {
        Write-Host "Rule not found, creating rule External Senders with matching Display Names" -ForegroundColor Green
        New-TransportRule -Name $ruleName2 -Priority 1 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
            -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
    }
    else {
        Write-Host "Rule found, updating rule External Senders with matching Display Names" -ForegroundColor Green
        Set-TransportRule -Identity $ruleName2 -Priority 1 -FromScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Prepend" `
            -HeaderMatchesMessageHeader From -HeaderMatchesPatterns $displayNames -ApplyHtmlDisclaimerText $ruleHtml
    }
    $Loop = $true
    Exit
    #———— End of Indication ———————

}

3{

        $ruleName3 = "Organization Disclaimer"
        $ruleDis =  "Disclaimer:  The content of this email is confidential and intended for the recipient specified in message only. It is strictly forbidden to share any part of this message with any third party, without the written consent of the sender. If you received this message by mistake, please reply to this message and follow with its deletion, so that we can ensure such a mistake does not occur in the future."
 
        $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName3}
 
        if (!$rule) {
            Write-Host "Rule not found, creating rule Organization Disclaimer" -ForegroundColor Green
            New-TransportRule -Name $ruleName3 -Priority 2 -FromScope "InOrganization" -SentToScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Append" `
                -ApplyHtmlDisclaimerText $ruleDis -ExceptIfSubjectContainsWords "fwd:","re:"
        }
        else {
            Write-Host "Rule found, updating rule Organization Disclaimer" -ForegroundColor Green
            Set-TransportRule -Identity $ruleName3 -Priority 2 -FromScope "InOrganization" -SentToScope "NotInOrganization" -ApplyHtmlDisclaimerLocation "Append" `
                -ApplyHtmlDisclaimerText $ruleDis -ExceptIfSubjectContainsWords "fwd:","re:"
        }

   
    #———— End of Indication ———————
}

4{

        $ruleName4 = "Domain Rejection"
        $ruledom = 'yooning.com','tv1862langen.de'
        $rulereply = 'Email from this domain not accepted'
 
        $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName4}
 
        if (!$rule) {
            Write-Host "Rule not found, creating rule Domain Rejectio" -ForegroundColor Green
            New-TransportRule -Name $ruleName4 -Priority 2 -SenderDomainIs $ruledom -RejectMessageReasonText $rulereply
        }
        else {
            Write-Host "Rule found, updating rule Domain Rejectio" -ForegroundColor Green
            Set-TransportRule -Identity $ruleName4 -Priority 2 -SenderDomainIs $ruledom -RejectMessageReasonText $rulereply
        }

   
    #———— End of Indication ———————
	

}

5{

        $ruleName5 = "Bitcoin-vulgar text"
        $ruletxt = 'It is a reminder about your dirty deeds', 'Professional hackers have used this data', 'purchase bitcoin', 'My BTC wallet for your transaction', 'kinky videos', 'Trojan software codes', 'masturbating', 'victims', 'bitcoin'
        $rulereply = 'Some keywords in email are not accepted'
 
        $rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName5}
 
        if (!$rule) {
            Write-Host "Rule not found, creating rule Bitcoin-vulgar text" -ForegroundColor Green
            New-TransportRule -Name $ruleName5 -Priority 2 -SubjectOrBodyContainsWords $ruletxt -RejectMessageReasonText $rulereply
        }
        else {
            Write-Host "Rule found, updating rule Bitcoin-vulgar text" -ForegroundColor Green
            Set-TransportRule -Identity $ruleName5 -Priority 2 -SubjectOrBodyContainsWords $ruletxt -RejectMessageReasonText $rulereply
        }

    
    #———— End of Indication ———————

}

6{
    #To turn on audit log search in Office 365
    Enable-OrganizationCustomization

    Start-Sleep -Seconds 30
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true

    #To verify that audit log search is turned on
    Start-Sleep -Seconds 30
    Get-AdminAuditLogConfig | FL UnifiedAuditLogIngestionEnabled

    #To block enduser to signup trial subscriptions
    Set-MsolCompanySettings -AllowAdHocSubscriptions $false

    #Create New Retention tag (Default 1 year move to archive)
    New-RetentionPolicyTag -Name "Default 1 year move to archive" -Type All -AgeLimitForRetention 365 -RetentionAction MoveToArchive -RetentionEnabled $true
    Write-Host "Default 1 year move to archive Retention tag Activated"

    #Create New Retention Policy (Default 1 year move to archive)
    New-RetentionPolicy "Default 1 year move to archive" -RetentionPolicyTagLinks "1 Month Delete","1 Week Delete","1 Year Delete","6 Month Delete" `
    "Default 1 year move to archive","Deleted Items","Junk Email","Recoverable Items 14 days move to archive"
    Write-Host "Default 1 year move to archive Policy Activated"


    #Outbound spam filter policy (Automatic >> On)
    Set-HostedOutboundSpamFilterPolicy -Identity Default -AutoForwardingMode on

    #Enable plus addressing in your Exchange Online organization & SendFromAlias & auto-expanding archiving for your entire organization & Session Timeout
    Set-OrganizationConfig -SendFromAliasEnabled $true -ActivityBasedAuthenticationTimeoutEnabled $true -ActivityBasedAuthenticationTimeoutInterval 01:00:00  `
    -ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled $true

    #Disable forwarding set through Inbox Rules
    Set-RemoteDomain Default -AutoForwardEnabled $false

    #Enable Old Smtp on Tenant
    Set-TransportConfig -SmtpClientAuthenticationDisabled $false
    #Bulk mode
    $Users = Get-CASMailbox -ResultSize unlimited | Select DisplayName, PrimarySmtpAddress
    $Users | foreach {Set-CASMailbox -Identity $_.PrimarySmtpAddress -SmtpClientAuthenticationDisabled $false}


    #———— End of Indication ———————

}

7{
    $Loop = $true
    Exit
    #———— End of Indication ———————

}

}}
