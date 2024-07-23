# Fetch all mailbox users
```
$mailboxes = Get-Mailbox -ResultSize Unlimited
```
# Initialize an array to store user information
```
$userInfo = @()

foreach ($mailbox in $mailboxes) {
    $mailboxStatistics = Get-MailboxStatistics -Identity $mailbox.UserPrincipalName
    $archiveStatistics = if ($mailbox.ArchiveStatus -eq 'Active') { Get-MailboxStatistics -Archive -Identity $mailbox.UserPrincipalName } else { $null }

    $user = [PSCustomObject]@{
        DisplayName          = $mailbox.DisplayName
        PrimarySMTPAddress   = $mailbox.PrimarySmtpAddress
        MaxSendSize          = $mailbox.MaxSendSize
        MaxReceiveSize       = $mailbox.MaxReceiveSize
        TotalMailboxSize     = $mailbox.ProhibitSendQuota
        MailboxUsedSize      = $mailboxStatistics.TotalItemSize.Value.ToString()
        TotalArchiveSize     = if ($archiveStatistics) { $mailbox.ArchiveQuota } else { "N/A" }
        ArchiveUsedSize      = if ($archiveStatistics) { $archiveStatistics.TotalItemSize.Value.ToString() } else { "N/A" }
    }
    $userInfo += $user
}
```
# Export user information to CSV
```
$userInfo | Export-Csv -Path "C:\Users\systems.admin\Downloads\MailboxInfo.csv" -NoTypeInformation
```
# SMTP server ([string], required)
```
$SMTPServer = "mukwano-com.mail.protection.outlook.com"
```
# Port ([int], required)
```
$Port = "25"
```
# Sender
```
$From = "no-reply@mukwano.com"
```
# Recipient list
```
$RecipientList = "systems.admin@mukwano.com"
$Recipientcsv = Import-Csv C:\Users\systems.admin\Downloads\MailboxInfo.csv

Foreach($Recipient in $Recipientcsv)
{
    Write-Host "---------------------------------------" 
    Write-Host "Started Reading data $($Recipient.DisplayName)"

    # Set the variables here
    $MaxReceiveSize = $Recipient.MaxReceiveSize
    $MaxSendSize = $Recipient.MaxSendSize
    $Disp = $Recipient.DisplayName
    $psmtp = $Recipient.PrimarySmtpAddress
    $totalmxsz = $Recipient.MailboxUsedSize
    $totalsz = $Recipient.TotalMailboxSize
    $archusz = $Recipient.ArchiveUsedSize
    $totalarchsz = $Recipient.TotalArchiveSize


    # Subject ([string], optional)
    $Subject = [string]"This is the subject"

    # HTML Body ([string], optional)
    $HTMLBody = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8">
</head>
<body>
<b><p>Hi $Disp</p>
<p>&nbsp;</p>
<p>As per new email attachment policy your message limit has been revised as follows:</p>
<figure class="table" style="float:left;width:28.44%;">
    <table class="ck-table-resized" style="border:3px solid hsl(0, 0%, 0%);">
        <colgroup>
            <col style="width:48.3%;">
            <col style="width:51.7%;">
        </colgroup>
        <tbody>
            <tr>
                <th style="border:2px solid hsl(0, 0%, 0%);">Can send email upto</th>
                <td style="border:2px solid hsl(0, 0%, 0%);">$MaxSendSize</td>
            </tr>
            <tr>
                <th style="border:2px solid hsl(0, 0%, 0%);">Can receive email upto</th>
                <td style="border:2px solid hsl(0, 0%, 0%);">$MaxReceiveSize</td>
            </tr>
            <tr>
                <th style="border:2px solid hsl(0, 0%, 0%);">Email Address</th>
                <td style="border:2px solid hsl(0, 0%, 0%);">$psmtp</td>
            </tr>
            <tr>
                <th style="border:2px solid hsl(0, 0%, 0%);">Used Mailbox Size</th>
                <td style="border:2px solid hsl(0, 0%, 0%);">$totalmxsz</td>
            </tr>
            <tr>
                <th style="border:2px solid hsl(0, 0%, 0%);">Total Mailbox Size</th>
                <td style="border:2px solid hsl(0, 0%, 0%);">$totalsz</td>
            </tr>
            <tr>
                <th style="border:2px solid hsl(0, 0%, 0%);">Used Online Archive Size</th>
                <td style="border:2px solid hsl(0, 0%, 0%);">$archusz</td>
            </tr>
            <tr>
                <th style="border:2px solid hsl(0, 0%, 0%);">Total Online Archive Size</th>
                <td style="border:2px solid hsl(0, 0%, 0%);">$totalarchsz</td>
            </tr>
        </tbody>
    </table>
</figure>

<p>This change is implemented to ease your communication with Top management only. Always share large files through SharePoint, OneDrive and Teams to internal and external users. Clean your mail box regularly and keep it lean.</p>
<p>&nbsp;</p>
<p>Thanks,</p>
<p>Mukwano IT</p>
</body>
</html>
"@

    # Splat parameters
    $Parameters = @{
        "SMTPServer"    = $SMTPServer
        "Port"          = $Port
        "From"          = $From
        "RecipientList" = $Recipient.PrimarySMTPAddress
        "Subject"       = $Subject
        "HTMLBody"      = $HTMLBody
    }

    # Send the email (use the correct command for your setup)
    Send-MailKitMessage @Parameters

 Write-Host "Completed Sending Email $($Recipientcsv.DisplayName)"
 Write-Host "        "
}
```
