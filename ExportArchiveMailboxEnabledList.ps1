Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://companyyname-admin.sharepoint.com/

Get-Mailbox -ResultSize Unlimited | Where-Object { $_.ArchiveStatus -eq 'Active' } | ForEach-Object {
    $archiveStats = Get-MailboxStatistics -Archive -Identity $_.PrimarySmtpAddress
    [PSCustomObject]@{
        DisplayName        = $_.DisplayName
        PrimarySmtpAddress = $_.PrimarySmtpAddress
        ArchiveStatus      = $_.ArchiveStatus
        ArchiveSize        = $archiveStats.TotalItemSize.Value
    }
} | Export-Csv -Path "C:\ArchiveUsersWithSize.csv" -NoTypeInformation
