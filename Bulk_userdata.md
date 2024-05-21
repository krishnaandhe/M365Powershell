<h1 align="center">Bulk update user data fields in the Office 365 Exchange Global Address List</h1>

https://community.spiceworks.com/how_to/132771-bulk-update-user-data-fields-in-the-office-365-exchange-global-address-list

This command will put a CSV file on your hard drive containing all the data fields in your GAL for all your users.

get-user -resultsize unlimited |select * |export-csv c:\scripts\users.csv

You can modify the path and filename at the end of the command as appropriate for your needs

Import-Csv "c:\stellium.csv" | foreach{Set-MsolUser -UserPrincipalName $_.UserPrincipalName -Country $_.Country -Title $_.title -Department $_.Department -DisplayName $_.DisplayName -PhoneNumber $_.MobilePhone}
