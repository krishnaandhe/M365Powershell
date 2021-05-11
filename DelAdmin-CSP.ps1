To Find Global admin & remove it

$customers = Get-msolpartnercontract -All
foreach ($customer in $customers) 
{
    $InitialDomain = Get-MsolDomain -TenantId $customer.TenantId | Where-Object {$_.IsInitial -eq $true}
    
    Write-Host "---------------------------------------" 
    Write-Host "Checking $($customer.Name)"
    $DelegatedOrgURL = "https://outlook.office365.com/powershell-liveid?DelegatedOrg=" + $InitialDomain.Name
    $s = New-PSSession -ConnectionUri $DelegatedOrgURL -Credential $credential -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection
    Import-PSSession $s -CommandName Get-Mailbox, Get-AcceptedDomain -AllowClobber
    $mailboxes = $null
    $mailboxes = Get-Mailbox -ResultSize Unlimited
    $domains = Get-AcceptedDomain
    $deluser = Read-Host 'Please enter the name of user?'
 
    foreach ($mailbox in $mailboxes)
    {
    Get-MsolUser -TenantId $customer.TenantId -SearchString "$deluser" | Remove-MsolUser -TenantId $customer.TenantId -Force
    
    $wipeacc = Get-MsolUser -TenantId $customer.TenantId -SearchString "axima" -ReturnDeletedUsers | Select UserPrincipalName
    Remove-MsolUser -TenantId $customer.TenantId -UserPrincipalName $wipeacc.UserPrincipalName -RemoveFromRecycleBin -Force


    }
}
