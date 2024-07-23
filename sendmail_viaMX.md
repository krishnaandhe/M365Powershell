<h1 align="center">Send email to recipient Via MX record</h1>

In our example, we will use the MX record to send emails via Microsoft 365 using port 25.

To send an email to a recipient with the MX record, follow these steps:

- Specify SMTPServer in line 2
- Specify Port number in line 5
- Specify From in line 8
- Specify RecipientList mailbox in line 12
- Specify Subject in line 15
- Specify TextBody in line 18
- Run the PowerShell script

⚡⚡ Script Starts ⚡⚡

# SMTP server (Required)
$SMTPServer = "domain-com.mail.protection.outlook.com"

# Port (Required)
$Port = "25"

# Sender Email ID (Required)
$From ="User1@domain.com"

# Recipient list ([Required)
$RecipientList = "User2@domain.com"

# Subject ([string], optional)
$Subject = [string]"This is the subject"

⚡⚡# Text body ([string], optional choose any 1 )
```
$TextBody = [string]"This is the text body"
```
⚡⚡#HTML body ([string], optional choose any 1 )
```
$HTMLBody = [string]"HTMLBody";
```
# Splat parameters
```
$Parameters = @{
    "SMTPServer"    = $SMTPServer
    "Port"          = $Port
    "From"          = $From
    "RecipientList" = $RecipientList
    "Subject"       = $Subject
    "TextBody"      = $TextBody
}
```
# Send message
```
Send-MailKitMessage @Parameters
```

⚡⚡ Script Ends ⚡⚡


⚡⚡ For Bulk Receipents ⚡⚡

<h2 align="center">Send email to all recipient from csv Via MX record, notifying the message size limits</h2>

# SMTP server ([string], required)
$SMTPServer = "domain-com.mail.protection.outlook.com"

# Port ([int], required)
$Port = "25"

# Sender
$From = "no-reply@domain.com"

# Recipent

$Recipientcsv = Import-Csv C:\Users\admin\Downloads\data.csv

```
Foreach($Recipient in $Recipientcsv)
{
    Write-Host "---------------------------------------" 
    Write-Host "Started Reading data $($Recipient.DisplayName)"

    # Set the variables here
    $MaxReceiveSize = $Recipient.MaxReceiveSize
    $MaxSendSize = $Recipient.MaxSendSize
    $Disp = $Recipient.DisplayName

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
<b><p>Your Name! $Disp </p></b>
<p>Your Sendsize - $MaxSendSize</p>
<p>Your ReceiveSize - $MaxReceiveSize</p>
<p><br>More information </p></b>
<p>Greetings,</p>
<p>Helpdesk IT</p>
</body>
</html>
"@
```
```
    # Splat parameters
    $Parameters = @{
        "SMTPServer"    = $SMTPServer
        "Port"          = $Port
        "From"          = $From
        "RecipientList" = $Recipientcsv.PrimarySmtpAddress
        "Subject"       = $Subject
        "HTMLBody"      = $HTMLBody
    }
```
    # Send the email (use the correct command for your setup)
    Send-MailKitMessage @Parameters

 Write-Host "Completed Sending Email $($Recipientcsv.DisplayName)"
 Write-Host "        "
}

  
