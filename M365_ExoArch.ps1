#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Exchange Online Archiving Module (Bulk)
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Use at your own risk 

$Loop = $true
While ($Loop)
{
write-host 
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host      XXXX Module    -foregroundcolor green
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host
write-host "1)  Verify that auto-expanding archiving is enabled" -ForegroundColor Yellow
write-host
write-host "2)  Enable archiving for specific user" -ForegroundColor Red
write-host
write-host "3)  Enable auto-expanding archiving for specific user" -ForegroundColor Cyan
write-host
write-host "4)  Disabling RetentionHold for all users (Bulk mode)" -ForegroundColor Green
write-host
write-host "5)  Enable Archiving for All Users" -ForegroundColor DarkGray
write-host
write-host "6)  Enable auto-expanding archiving for All Users" -ForegroundColor DarkGray
write-host
write-host "7)  Run the Managed Folder Assistant for all Office 365 Mailbox’s (Bulk Mode)" -ForegroundColor DarkGray
write-host
write-host "8)  Apply Retention Policy in Bulk" -ForegroundColor DarkGray
write-host
write-host "10)  Exit" -ForegroundColor white
write-host
$opt = Read-Host "Select an option [1-8]"
write-host $opt
switch ($opt) 

{


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# Script Initial
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



1{

        #——– Start of Indication  ———–

   #Verify that auto-expanding archiving is enabled
    
   $AutoArc = Get-OrganizationConfig
  If ($AutoArc.AutoExpandingArchiveEnabled -eq "false") 
   {
  "AutoExpandingArchive is Active"
  }
  Else 
  {
  "AutoExpandingArchive is Inactive"
  } 

# AutoExpandingArchive Activation
$Enabling = Read-Host "Do you want to Enable AutoExpandingArchive on Organisation [Y] Yes [N] No "

if ($Enabling -match "[yY]") {
  Set-OrganizationConfig -AutoExpandingArchive | Out-Null
  Write-Host "AutoExpandingArchive is Enabled, will impact in 2-4Hrs"
}

   $Loop = $true
   Exit

        #———— End of Indication ———————
  
}

2{

    #Enable archiving for specific user
   $Exo1 = Read-Host 'What is user email id?'
   Enable-Mailbox $Exo1 -Archive
   write-host "Archiving 50GB has been enabled for $($Exo1)"
   $Loop = $true
    Exit
     #———— End of Indication ———————

}

3{

   #Enable auto-expanding archiving for specific user
   $Exo2 = Read-Host 'What is user email id?'
   Enable-Mailbox $Exo2 -AutoExpandingArchive
   write-host "AutoExpandingArchiving till 1.5TB has been enabled for $($Exo2)"
   $Loop = $true
    Exit
    #———— End of Indication ———————
}

4{

    #Disabling RetentionHold for all users (Bulk mode)
    $Users= MSOnlineExtended\Get-MsolUser -All

    foreach ($User in $Users) 
    {
        try {
            Write-Host "Disabling RetentionHold on - $($User.DisplayName)" -ForegroundColor Yellow
            Set-Mailbox $user.UserPrincipalName -RetentionHoldEnabled $false
            Start-ManagedFolderAssistant -Identity $User.UserPrincipalName
        } 
        catch {
            Write-Warning "The call to Mailbox Assistants Service on server"
            Continue
        }         
    } 
    $Loop = $true
    Exit
    
    #———— End of Indication ———————
	
}

5{

    #Enable Archiving for All Users
    Get-Mailbox -RecipientTypeDetails UserMailbox | Select-Object UserPrincipalName | foreach-object {Enable-Mailbox $_.UserPrincipalName -Archive}
    Write-Host "Enabling Archive for Done all Users" -ForegroundColor Yellow  
    $Loop = $true
    exit
    #———— End of Indication ———————

}

6{
   #Enable auto-expanding archiving for All Users
   Get-Mailbox -RecipientTypeDetails UserMailbox | Select-Object UserPrincipalName | foreach-object {Enable-Mailbox $_.UserPrincipalName -AutoExpandingArchive}
   Write-Host "Enabling AutoExpandingArchive for all users Done" -ForegroundColor Yellow  
   $Loop = $true
   exit
    #———— End of Indication ———————

}

7{
    #Run the Managed Folder Assistant for all Office 365 Mailbox’s (Bulk Mode)
    $Userrecords= Get-Mailbox -RecipientTypeDetails UserMailbox

    foreach ($Userrecord in $Userrecords) 
    {
        try {
            Write-Host "Enabling Move Folder Assist - $($Userrecord.Alias)" -ForegroundColor Yellow
            Start-ManagedFolderAssistant -Identity $Userrecord.Alias
        } 
        catch {
            Write-Warning "The call to Mailbox Assistants Service on server"
            Continue
        }         
    }

    $Loop = $true
    Exit
    #———— End of Indication ———————

}

8{
    
   #Apply Retention Policy if required***
    Get-Mailbox | Select-Object UserPrincipalName | foreach-object {Set-Mailbox $_.UserPrincipalName –RetentionPolicy "Default 1 year move to archive"} 
    $Loop = $true
    Exit
    #———— End of Indication ———————

}

10{
    $Loop = $true
    Exit
    #———— End of Indication ———————

}

}}

