<h1 align="center">Bulk update user data fields in the Office 365 Exchange Global Address List</h1>

Reference:- (https://community.spiceworks.com/how_to/132771-bulk-update-user-data-fields-in-the-office-365-exchange-global-address-list)

⚡⚡This command will put a CSV file on your hard drive containing all the data fields in your GAL for all your users.⚡⚡

get-user -resultsize unlimited |select * |export-csv c:\scripts\Raw_users.csv

👉 You can modify the path and filename at the end of the command as appropriate for your needs

Import-Csv "c:\AD_Data.csv" | foreach{Set-MsolUser -UserPrincipalName $_.UserPrincipalName -Country $_.Country -Title $_.title -Department $_.Department -DisplayName $_.DisplayName -PhoneNumber $_.MobilePhone}

Bulk update All Azure User fields
| City  | Country | Department  | Display name | First Name  | Last Name | PhoneNumber | ObjectId  | UserPrincipalName |Title |Manager |CompanyName | EmployeeId |
| ------ | ----------- | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| Mumbai  | India  | Finance  | Raghav Jha  | Raghav | Jha  | +91 7788994455  | feaf9c60-de72-46d0-ba7f-f1112f5b6b9e  | head.finance@abc.com  | Head Finance | Robert James  | ABC Corp  | 1000700  | 
| Delhi  | India  | IT  | Simon Steve  | Simon  | Steve  |  +91 7788665544  | feaf9c60-de72-46d0-ba7f-f1112f5b7b9e  | head.it@abc.com  | Head IT  | Danny Willams  | ABC Corp  | 1000800  |

👉  Get CSV content
$CSVrecords = Import-Csv C:\Users\XXX\Downloads\Aduser.csv -Delimiter ","

⚡⚡ All Records Updation ⚡⚡

Write-Host "Updating User data on Azure - $($CSVrecord.DisplayName)" -ForegroundColor Yellow

$obid = $CSVrecord.ObjectId

$CSVrecords | foreach{Set-MsolUser -UserPrincipalName $_.UserPrincipalName -DisplayName $_.DisplayName  -StreetAddress $_.StreetAddress -Office $_.Office -Country $_.Country -Title $_.title -Department $_.Department -City $_.City -PostalCode $_.PostalCode -PhoneNumber $_.PhoneNumber -State $_.State}

Write-Host "Updating Done $($CSVrecord.DisplayName)" -ForegroundColor Yellow

⚡⚡ Manager Updation ⚡⚡

foreach ($CSVrecord in $CSVrecords) 
{
    Write-Host "Updating User data on Azure - $($CSVrecord.DisplayName)" -ForegroundColor Yellow
    $obid = $CSVrecord.ObjectId
    $mgid = $CSVrecord.Manager
    Set-AzureADUserManager -ObjectId $obid -RefObjectId $mgid
    Set-AzureADUserExtension -ObjectId $obid -ExtensionName EmployeeId -ExtensionValue $CSVrecord.EmployeeId
    Set-AzureADUserExtension -ObjectId $obid -ExtensionName CompanyName -ExtensionValue $CSVrecord.CompanyName
    Write-Host "Updating Done $($CSVrecord.DisplayName)" -ForegroundColor Yellow
}

⚡⚡ To Fetch all users managers data ⚡⚡

$Result = @()
$AllUsers= Get-AzureADUser -All $true | Select-Object -Property Displayname,UserPrincipalName,CompanyName,City,Country,JobTitle,Department,AccountEnabled,DirSyncEnabled,TelephoneNumber
$TotalUsers = $AllUsers.Count
$i = 1 
$AllUsers | ForEach-Object {
$User = $_
Write-Progress -Activity "Fetching manager of $($_.Displayname)" -Status "$i out of $TotalUsers users completed"
$managerObj = Get-AzureADUserManager -ObjectId $User.UserPrincipalName
$Result += New-Object PSObject -property $([ordered]@{ 
UserName = $User.DisplayName
UserPrincipalName = $User.UserPrincipalName
CompanyName = $User.CompanyName
JobTitle = $User.JobTitle
Department = $User.Department
City = $User.City
Country = $User.Country
AccountEnabled = $User.AccountEnabled
DirSyncEnabled = $User.DirSyncEnabled
TelephoneNumber = $User.TelephoneNumber
AccountStatus = if ($User.AccountEnabled -eq $true) { "Enabled" } else { "Disabled" }
ManagerName = if ($managerObj -ne $null) { $managerObj.DisplayName } else { $null }
ManagerMail = if ($managerObj -ne $null) { $managerObj.Mail } else { $null }
})
$i++
}

$Result | Export-CSV "C:\Pshell\M365UsersManagerInfo.CSV" -NoTypeInformation -Encoding UTF8



