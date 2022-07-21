#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Powershell Modules installer
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Use at your own risk 

$Loop = $true
While ($Loop)
{
write-host 
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host       Microsoft 365 Powershell Modules Installer    -foregroundcolor green
write-host ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
write-host
write-host "1)  Check Installed Modules" -ForegroundColor Cyan
write-host
write-host "2)  Azure AD Module" -ForegroundColor Yellow
write-host
write-host "3)  Exchange Online Module" -ForegroundColor Yellow
write-host
write-host "4)  Microsoft Online Module" -ForegroundColor Yellow
write-host
write-host "5)  Sharepoint Online Module" -ForegroundColor Yellow
write-host
write-host "6)  Microsoft Teams Module" -ForegroundColor Yellow
write-host
write-host "7)  Microsoft PartnerCenter Module" -ForegroundColor Yellow
write-host
write-host "8)  Install All Modules(Fresh Only)" -ForegroundColor Yellow
write-host
write-host "9)  Exit" -ForegroundColor Yellow
write-host
$opt = Read-Host "Select an option [1-9]"
write-host $opt
switch ($opt) 

{


#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# PShell Module Installer
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



1{

        #——– office 365 Cmdlets  ———–

        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

        Get-InstalledModule | Select Name,Version,UpdatedDate

        Install-Module -Name PowerShellGet -Force -AllowClobber
              
 
        #———— End of Indication ———————
  
}

2{

    if (Get-Module -ListAvailable -Name AzureAD) 
        {
            Write-Host "Module exists, Hence Updating the Existing Module"

            Update-Module -Name AzureAD -Force

         }

    else 
    
    {
            Write-Host "Module does not exists, Hence Installing Module"
        
            Install-Module -Name AzureAD -Force
         }


    #———— End of Indication ———————

}

3{

if (Get-Module -ListAvailable -Name ExchangeOnlineManagement) 
        {
            Write-Host "Module exists, Hence Updating the Existing Module"

            Update-Module -Name ExchangeOnlineManagement -Force

         }

    else 
    
    {
            Write-Host "Module does not exists, Hence Installing Module"
        
            Install-Module -Name ExchangeOnlineManagement -Force
         }

   
    #———— End of Indication ———————
}

4{

if (Get-Module -ListAvailable -Name MSOnline) 
        {
            Write-Host "Module exists, Hence Updating the Existing Module"

            Update-Module -Name MSOnline -Force

         }

    else 
    
    {
            Write-Host "Module does not exists, Hence Installing Module"
        
            Install-Module -Name MSOnline -Force
         }

   
    #———— End of Indication ———————
	

}

5{


if (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell) 
        {
            Write-Host "Module exists, Hence Updating the Existing Module"

            Update-Module -Name Microsoft.Online.SharePoint.PowerShell -Force

         }

    else 
    
    {
            Write-Host "Module does not exists, Hence Installing Module"
        
            Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
         }

    
    #———— End of Indication ———————

}

6{


if (Get-Module -ListAvailable -Name MicrosoftTeams) 
        {
            Write-Host "Module exists, Hence Updating the Existing Module"

            Update-Module -Name MicrosoftTeams -Force

         }

    else 
    
    {
            Write-Host "Module does not exists, Hence Installing Module"
        
            Install-Module -Name MicrosoftTeams -Force
         }

    
    #———— End of Indication ———————

}

7{


if (Get-Module -ListAvailable -Name PartnerCenter) 
        {
            Write-Host "Module exists, Hence Updating the Existing Module"

            Update-Module -Name PartnerCenter  -Force

         }

    else 
    
    {
            Write-Host "Module does not exists, Hence Installing Module"
        
            Install-Module -Name PartnerCenter  -Force
         }

    $Loop = $true
    Exit
    #———— End of Indication ———————

}

8{
    
    Install-Module -Name PowerShellGet -Force -AllowClobber
    Install-Module -Name AzureAD -Force
    Install-Module -Name ExchangeOnlineManagement -Force
    Install-Module -Name MSOnline -Force
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force
    Install-Module -Name MicrosoftTeams -Force

    $Loop = $false
    #———— End of Indication ———————

}

9{

    $Loop = $false
    #———— End of Indication ———————

}

}}
