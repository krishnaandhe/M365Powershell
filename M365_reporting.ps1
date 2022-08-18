#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Reporting M365 Module
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
write-host "1)  Create report of all OneDrive size to CSV" -ForegroundColor Yellow
write-host
write-host "2)  Create report of all mailbox and archive sizes to CSV" -ForegroundColor Red
write-host
write-host "3)  Create report of all mailbox permissions to CSV" -ForegroundColor Cyan
write-host
write-host "4)  Create report of all mailbox reporting in MB to CSV " -ForegroundColor Green
write-host
write-host "5)  XXX" -ForegroundColor DarkGray
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
    # Create report of all OneDrive size export to CSV

  $url = Read-Host 'Please share SharePoint Admin Url?'
  $path = ".\OneDriveSizeReport-$((Get-Date -format "MMM-dd-yyyy").ToString()).csv"


    Function ConnectTo-SharePoint {
      <#
        .SYNOPSIS
            Connects to PNP Online no connection exists. Checks for PnPOnline Module
      #>
  
      process {
        # Check if EXO is installed and connect if no connection exists
        if ((Get-Module -ListAvailable -Name PnP.PowerShell) -eq $null)
        {
          Write-Host "PnPOnline Module is required, do you want to install it?" -ForegroundColor Yellow
      
          $install = Read-Host Do you want to install module? [Y] Yes [N] No 
          if($install -match "[yY]") 
          { 
            Write-Host "Installing PnP PowerShell module" -ForegroundColor Cyan
            Install-Module PnP.PowerShell -Repository PSGallery -AllowClobber -Force
          } 
          else
          {
	          Write-Error "Please install PnP Online module."
          }
        }


        if ((Get-Module -ListAvailable -Name PnP.PowerShell) -ne $null) 
        {
	        Connect-PnPOnline -Url $Url -Credentials $Credential
        }
        else{
          Write-Error "Please install PnP PowerShell module."
        }
      }
    }

    Function ConvertTo-Gb {
      <#
        .SYNOPSIS
            Convert mailbox size to Gb for uniform reporting.
      #>
      param(
        [Parameter(
          Mandatory = $true
        )]
        [string]$size
      )
      process {
        if ($size -ne $null) {
          $sizeInGb = ($size / 1024)

          return [Math]::Round($sizeInGb,2,[MidPointRounding]::AwayFromZero)
        }
      }
    }


    Function Get-OneDriveStats {
      <#
        .SYNOPSIS
            Get the mailbox size and quota
      #>
      process {
        $oneDrives = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'" -Detailed | Select Title,Owner,StorageQuota,StorageQuotaWarningLevel,StorageUsageCurrent,LastContentModifiedDate,Status
        $i = 0

        $oneDrives | ForEach {
  
          [pscustomobject]@{
            "Display Name" = $_.Title
            "Owner" = $_.Owner
            "Onedrive Size (Gb)" = ConvertTo-Gb -size $_.StorageUsageCurrent
            "Storage Warning Quota (Gb)" = ConvertTo-Gb -size $_.StorageQuotaWarningLevel
            "Storage Quota (Gb)" = ConvertTo-Gb -size $_.StorageQuota
            "Last Used Date" = $_.LastContentModifiedDate
            "Status" = $_.Status
          }

          $currentUser = $_.Title
          Write-Progress -Activity "Collecting OneDrive Sizes" -Status "Current Count: $i" -PercentComplete (($i / $oneDrives.Count) * 100) -CurrentOperation "Processing OneDrive: $currentUser"
          $i++;
        }
      }
    }

    # Connect to SharePoint Online
    ConnectTo-SharePoint

    # Get OneDrive status
    Get-OneDriveStats | Export-CSV -Path $path -NoTypeInformation

    if ((Get-Item $path).Length -gt 0) {
      Write-Host "Report finished and saved in $path" -ForegroundColor Green
    }else{
      Write-Host "Failed to create report" -ForegroundColor Red
    }
    $Loop = $true
    Exit
        #———— End of Indication ———————
  
}

2{

    #Create report of all mailbox and archive sizes

    $path = ".\MailboxSizeReport-$((Get-Date -format "MMM-dd-yyyy").ToString()).csv"

    Function Get-Mailboxes {
      <#
        .SYNOPSIS
            Get all the mailboxes for the report
      #>
      process {
        switch ($sharedMailboxes)
        {
          "include" {$mailboxTypes = "UserMailbox,SharedMailbox"}
          "only" {$mailboxTypes = "SharedMailbox"}
          "no" {$mailboxTypes = "UserMailbox"}
        }

        Get-EXOMailbox -ResultSize unlimited -RecipientTypeDetails $mailboxTypes -Properties IssueWarningQuota, ProhibitSendReceiveQuota, ArchiveQuota, ArchiveWarningQuota, ArchiveDatabase | 
          Select-Object UserPrincipalName, DisplayName, PrimarySMTPAddress, RecipientType, RecipientTypeDetails, IssueWarningQuota, ProhibitSendReceiveQuota, ArchiveQuota, ArchiveWarningQuota, ArchiveDatabase
      }
    }

    Function ConvertTo-Gb {
      <#
        .SYNOPSIS
            Convert mailbox size to Gb for uniform reporting.
      #>
      param(
        [Parameter(
          Mandatory = $true
        )]
        [string]$size
      )
      process {
        if ($size -ne $null) {
          $value = $size.Split(" ")

          switch($value[1]) {
            "GB" {$sizeInGb = ($value[0])}
            "MB" {$sizeInGb = ($value[0] / 1024)}
            "KB" {$sizeInGb = ($value[0] / 1024 / 1024)}
          }

          return [Math]::Round($sizeInGb,2,[MidPointRounding]::AwayFromZero)
        }
      }
    }


    Function Get-MailboxStats {
      <#
        .SYNOPSIS
            Get the mailbox size and quota
      #>
      process {
        $mailboxes = Get-Mailboxes
        $i = 0

        $mailboxes | ForEach-Object {

          # Get mailbox size     
          $mailboxSize = Get-MailboxStatistics -identity $_.UserPrincipalName | Select-Object TotalItemSize,TotalDeletedItemSize,ItemCount,DeletedItemCount,LastUserActionTime

          if ($null -ne $mailboxSize) {
      
            # Get archive size if it exists and is requested
            $archiveSize = 0
            $archiveResult = $null

            if ($archive.IsPresent -and ($null -ne $_.ArchiveDatabase)) {
              $archiveResult = Get-EXOMailboxStatistics -UserPrincipalName $_.UserPrincipalName -Archive | Select-Object ItemCount,DeletedItemCount,@{Name = "TotalArchiveSize"; Expression = {$_.TotalItemSize.ToString().Split("(")[0]}}
              if ($null -ne $archiveResult) {
                $archiveSize = ConvertTo-Gb -size $archiveResult.TotalArchiveSize
              }else{
                $archiveSize = 0
              }
            }  
    
            [pscustomobject]@{
              "Display Name" = $_.DisplayName
              "Email Address" = $_.PrimarySMTPAddress
              "Mailbox Type" = $_.RecipientTypeDetails
              "Last User Action Time" = $mailboxSize.LastUserActionTime
              "Total Size (GB)" = ConvertTo-Gb -size $mailboxSize.TotalItemSize.ToString().Split("(")[0]
              "Deleted Items Size (GB)" = ConvertTo-Gb -size $mailboxSize.TotalDeletedItemSize.ToString().Split("(")[0]
              "Item Count" = $mailboxSize.ItemCount
              "Deleted Items Count" = $mailboxSize.DeletedItemCount
              "Mailbox Warning Quota (GB)" = $_.IssueWarningQuota.ToString().Split("(")[0]
              "Max Mailbox Size (GB)" = $_.ProhibitSendReceiveQuota.ToString().Split("(")[0]
              "Archive Size (GB)" = $archiveSize
              "Archive Items Count" = $archiveResult.ItemCount
              "Archive Deleted Items Count" = $archiveResult.DeletedItemCount
              "Archive Warning Quota (GB)" = $_.ArchiveWarningQuota.ToString().Split("(")[0]
              "Archive Quota (GB)" = ConvertTo-Gb -size $_.ArchiveQuota.ToString().Split("(")[0]
            }

            $currentUser = $_.DisplayName
            Write-Progress -Activity "Collecting mailbox status" -Status "Current Count: $i" -PercentComplete (($i / $mailboxes.Count) * 100) -CurrentOperation "Processing mailbox: $currentUser"
            $i++;
          }
        }
      }
    }

    # Get mailbox status
    Get-MailboxStats | Export-CSV -Path $path -NoTypeInformation -Encoding UTF8

    if ((Get-Item $path).Length -gt 0) {
      Write-Host "Report finished and saved in $path" -ForegroundColor Green
    }else{
      Write-Host "Failed to create report" -ForegroundColor Red
    }


     #———— End of Indication ———————

}

3{

    <#Create report of all mailbox permissions#>

    param(
     [string]$path = ".\MailboxPermissionReport-$((Get-Date -format "MM-dd-yyyy").ToString()).csv"
    )

    # Configuration

    $inboxFolderName = "inbox"  # Default "inbox"
    $calendarFolderName = "calendar"  # Default "calendar"


    Function ConnectTo-EXO {
      <# Connects to EXO when no connection exists. Checks for EXO v2 module #>
  
          if ((Get-Module -ListAvailable -Name ExchangeOnlineManagement) -ne $null) 
        {
	        # Check if there is a active EXO sessions
	        $psSessions = Get-PSSession | Select-Object -Property State, Name
	        If (((@($psSessions) -like '@{State=Opened; Name=ExchangeOnlineInternalSession*').Count -gt 0) -ne $true) {
		        Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName -Credential $Credential
	        }
        }
        else{
          Write-Error "Please install EXO v2 module."
        }
      }

    Function Find-LargestValue {
      <#
        .SYNOPSIS
            Find the value with the most records
      #>
      param(
        [Parameter(Mandatory = $true)]$sob,
        [Parameter(Mandatory = $true)]$fa,
        [Parameter(Mandatory = $true)]$sa,
        [Parameter(Mandatory = $true)]$ib,
        [Parameter(Mandatory = $true)]$ca
      )

      if ($sob -gt $fa -and $sob -gt $sa -and $sob -gt $ib -and $sob -gt $ca) {return $sob}
      elseif ($fa -gt $sa -and $fa -gt $ib -and $fa -gt $ca) {return $fa}
      elseif ($sa -gt $ib -and $sa -gt $ca) {return $sa}
      elseif ($ib -gt $ca) {return $ib}
      else {return $ca}
    }

    Function Get-DisplayName {
      <#
        .SYNOPSIS
          Get the full displayname (if requested) or return only the userprincipalname
      #>
      param(
        [Parameter(
          Mandatory = $true
        )]
        $identity
      )

      if ($displayNames.IsPresent) {
        Try {
          return (Get-EXOMailbox -Identity $identity -ErrorAction Stop).DisplayName
        }
        Catch{
          return $identity
        }
      }else{
        return $identity.ToString().Split("@")[0]
      }
    }

    Function Get-SingleUser {
      <#
        .SYNOPSIS
          Get only the requested mailbox
      #>
      param(
        [Parameter(
          Mandatory = $true
        )]
        $identity
      )

      Get-EXOMailbox -Identity $identity -Properties GrantSendOnBehalfTo, ForwardingSMTPAddress | 
          select UserPrincipalName, DisplayName, PrimarySMTPAddress, RecipientType, RecipientTypeDetails, GrantSendOnBehalfTo, ForwardingSMTPAddress
    }

    Function Get-Mailboxes {
      <#
        .SYNOPSIS
            Get all the mailboxes for the report
      #>
      process {
        switch ($sharedMailboxes)
        {
          "include" {$mailboxTypes = "UserMailbox,SharedMailbox"}
          "only" {$mailboxTypes = "SharedMailbox"}
          "no" {$mailboxTypes = "UserMailbox"}
        }

        Get-EXOMailbox -ResultSize unlimited -RecipientTypeDetails $mailboxTypes -Properties GrantSendOnBehalfTo, ForwardingSMTPAddress| 
          select UserPrincipalName, DisplayName, PrimarySMTPAddress, RecipientType, RecipientTypeDetails, GrantSendOnBehalfTo, ForwardingSMTPAddress
      }
    }

    Function Get-SendOnBehalf {
      <#
        .SYNOPSIS
            Get Display name for each Send on Behalf entity
      #>
      param(
        [Parameter(
          Mandatory = $true
        )]
        $mailbox
      )

      # Get Send on Behalf
      $SendOnBehalfAccess = @();
      if ($mailbox.GrantSendOnBehalfTo -ne $null) {
    
        # Get a proper displayname of each user
        $mailbox.GrantSendOnBehalfTo | ForEach {
          $sendOnBehalfAccess += Get-DisplayName -identity $_
        }
      }
      return $SendOnBehalfAccess
    }

    Function Get-SendAsPermissions {
      <#
        .SYNOPSIS
            Get all users with Send as Permissions
      #>
      param(
        [Parameter(
          Mandatory = $true
        )]
        $identity
      )
      $users = Get-EXORecipientPermission -Identity $identity | where { -not ($_.Trustee -match "NT AUTHORITY") -and ($_.IsInherited -eq $false)}

      $sendAsUsers = @();
  
      # Get a proper displayname of each user
      $users | ForEach {
        $sendAsUsers += Get-DisplayName -identity $_.Trustee
      }
      return $sendAsUsers
    }

    Function Get-FullAccessPermissions {
      <#
        .SYNOPSIS
            Get all users with Read and manage (full access) permissions
      #>
      param(
        [Parameter(
          Mandatory = $true
        )]
        $identity
      )
  
      $users = Get-EXOMailboxPermission -Identity $identity | where { -not ($_.User -match "NT AUTHORITY") -and ($_.IsInherited -eq $false)}

      $fullaccessUsers = @();
  
      # Get a proper displayname of each user
      $users | ForEach {
        $fullaccessUsers += Get-DisplayName -identity $_.User
      }
      return $fullaccessUsers
    }

    Function Get-FolderPermissions {
      <#
        .SYNOPSIS
          Get Inbox folder permisions
      #>
      param(
        [Parameter(Mandatory = $true)] $identity,
        [Parameter(Mandatory = $true)] $folder
      )
  
      $return = @{
        users = @()
        permission = @()
        delegated = @()
      }

      Try {
        $ErrorActionPreference = "Stop"; #Make all errors terminating
        $users = Get-EXOMailboxFolderPermission -Identity "$($identity):\$($folder)" | where { -not ($_.User -match "Default") -and -not ($_.AccessRights -match "None")}
      }
      Catch{
        return $return
      }
      Finally{
       $ErrorActionPreference = "Continue"; #Reset the error action pref to default
      }

      $folderUsers = @();
      $folderAccessRights = @();
      $folderDelegated = @();
  
      # Get a proper displayname of each user
      $users | ForEach {
        $folderUsers += Get-DisplayName -identity $_.User
        $folderAccessRights += $_.AccessRights
        $folderDelegated += $_.SharingPermissionFlags
      }

      $return.users = $folderUsers
      $return.permission = $folderAccessRights
      $return.delegated = $folderDelegated

      return $return
    }

    Function Get-AllMailboxPermissions {
      <#
        .SYNOPSIS
          Get all the permissions of each mailbox
        
          Permission are spread into 4 parts.
          - Read and Manage permission
          - Send as Permission
          - Send on behalf of permission
          - Folder permissions (inbox and calendar set by the user self)
      #>
      process {

        if ($UserPrincipalName) {
      
          Write-Host "Collecting mailboxes" -ForegroundColor Cyan
          $mailboxes = @()

          # Get the requested mailboxes
          foreach ($user in $UserPrincipalName) {
            Write-Host "- Get mailbox $user" -ForegroundColor Cyan
            $mailboxes += Get-SingleUser -identity $user
          }
        }elseif ($csvFile) {
      
          Write-Host "Using CSV file" -ForegroundColor Cyan
          $mailboxes = @()

          # Test CSV file path
          if (Test-Path $csvFile) {

            # Read CSV File
            Import-Csv $csvFile | ForEach {
              Write-Host "- Get mailbox $($_.UserPrincipalName)" -ForegroundColor Cyan
              $mailboxes += Get-SingleUser -identity $_.UserPrincipalName
            }
          }else{
            Write-Host "Unable to find CSV file $csvFile" -ForegroundColor black -BackgroundColor Yellow
          }
        }else{
          Write-Host "Collecting mailboxes" -ForegroundColor Cyan
          $mailboxes = Get-Mailboxes
        }
    
        $i = 0
        Write-Host "Collecting permissions" -ForegroundColor Cyan
        $mailboxes | ForEach {
     
          # Get Send on Behalf Permissions
          $sendOnbehalfUsers = Get-SendOnBehalf -mailbox $_
      
          # Get Fullaccess Permissions
          $fullAccessUsers = Get-FullAccessPermissions -identity $_.UserPrincipalName

          # Get Send as Permissions
          $sendAsUsers = Get-SendAsPermissions -identity $_.UserPrincipalName

          # Count number or records
          $sob = $sendOnbehalfUsers.Count
          $fa = $fullAccessUsers.Count
          $sa = $sendAsUsers.Count

          if ($folderPermissions.IsPresent) {
        
            # Get Inbox folder permission
            $inboxFolder = Get-FolderPermissions -identity $_.UserPrincipalName -folder $inboxFolderName
            $ib = $inboxFolder.users.Count

            # Get Calendar permissions
            $calendarFolder = Get-FolderPermissions -identity $_.UserPrincipalName -folder $calendarFolderName
            $ca = $calendarFolder.users.Count
          }else{
            $inboxFolder = @{
                users = @()
                permission = @()
                delegated = @()
            }
            $calendarFolder = @{
                users = @()
                permission = @()
                delegated = @()
            }
            $ib = 0
            $ca = 0
          }
     
          $mostRecords = Find-LargestValue -sob $sob -fa $fa -sa $sa -ib $ib -ca $ca

          $x = 0
          if ($mostRecords -gt 0) {
          
              Do{
                if ($x -eq 0) {
                    [pscustomobject]@{
                      "Display Name" = $_.DisplayName
                      "Emailaddress" = $_.PrimarySMTPAddress
                      "Mailbox type" = $_.RecipientTypeDetails
                      "Read and manage" = @($fullAccessUsers)[$x]
                      "Send as" = @($sendAsUsers)[$x]
                      "Send on behalf" = @($sendOnbehalfUsers)[$x]
                      "Inbox folder" = @($inboxFolder.users)[$x]
                      "Inbox folder Permission" = @($inboxFolder.permission)[$x]
                      "Inbox folder Delegated" = @($inboxFolder.delegated)[$x]
                      "Calendar" = @($calendarFolder.users)[$x]
                      "Calendar Permission" = @($calendarFolder.permission)[$x]
                      "Calendar Delegated" = @($calendarFolder.delegated)[$x]
                    }
                    $x++;
                }else{
                    [pscustomobject]@{
                      "Display Name" = ''
                      "Emailaddress" = ''
                      "Mailbox type" = ''
                      "Read and manage" = @($fullAccessUsers)[$x]
                      "Send as" = @($sendAsUsers)[$x]
                      "Send on behalf" = @($sendOnbehalfUsers)[$x]
                      "Inbox folder" = @($inboxFolder.users)[$x]
                      "Inbox folder Permission" = @($inboxFolder.permission)[$x]
                      "Inbox folder Delegated" = @($inboxFolder.delegated)[$x]
                      "Calendar" = @($calendarFolder.users)[$x]
                      "Calendar Permission" = @($calendarFolder.permission)[$x]
                      "Calendar Delegated" = @($calendarFolder.delegated)[$x]
                    }
                    $x++;
                }

                $currentUser = $_.DisplayName
                if ($mailboxes.Count -gt 1) {
                  Write-Progress -Activity "Collecting mailbox permissions" -Status "Current Count: $i" -PercentComplete (($i / $mailboxes.Count) * 100) -CurrentOperation "Processing mailbox: $currentUser"
                }
              }
              while($x -ne $mostRecords)
          }
          $i++;
        }
      }
    }

    # Connect to Exchange Online
    ConnectTo-EXO

    Get-AllMailboxPermissions | Export-CSV -Path $path -NoTypeInformation

    if ((Get-Item $path).Length -gt 0) {
      Write-Host "Report finished and saved in $path" -ForegroundColor Green

      }else{
      Write-Host "Failed to create report" -ForegroundColor Red
    }

    $Loop = $true
    Exit
   
    #———— End of Indication ———————
}

4{

    #Mailbox reporting Powershell (MB)
    Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | select DisplayName,@{name="TotalitemSize(MB)";expression={[math]::Round((($_.TotalitemSize.Value.ToString()).Split("(")[1].Split("")[0].Replace(",","")/1MB),2)}},ItemCount,DeletedItemCount| Sort "TotalitemSize(MB)" -Descending | Export-csv $path
    [string]$path = ".\MailboxReport_in_MB-$((Get-Date -format "dd-MMM-yyyy").ToString()).csv"

    #———— End of Indication ———————
	
}

5{

    #———— End of Indication ———————

}

6{
   

    #———— End of Indication ———————

}

7{
    $Loop = $true
    Exit
    #———— End of Indication ———————

}

}}
