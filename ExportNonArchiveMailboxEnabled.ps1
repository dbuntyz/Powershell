Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://companyyname-admin.sharepoint.com/

Get-Mailbox -ResultSize Unlimited | Where-Object { 
    $_.ArchiveDatabase -eq $null -and $_.RecipientTypeDetails -eq 'UserMailbox'
} | Select-Object DisplayName,PrimarySmtpAddress | Export-Csv -Path "C:\NonArchivedLicensedUsers.csv" -NoTypeInformation
