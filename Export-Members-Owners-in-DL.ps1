# Connect to Exchange Online
Connect-ExchangeOnline

# Get all distribution groups
$distributionGroups = Get-DistributionGroup -ResultSize Unlimited

$results = @()

foreach ($dl in $distributionGroups) {
    $dlName = $dl.DisplayName
    $dlEmail = $dl.PrimarySmtpAddress
    $dlId = $dl.Identity

    # Get Members
    $members = Get-DistributionGroupMember -Identity $dlId -ResultSize Unlimited | Select-Object -ExpandProperty PrimarySmtpAddress
    $membersString = if ($members) { $members -join ";" } else { "No Members" }

    # Get Owners (ManagedBy)
    $owners = $dl.ManagedBy | ForEach-Object {
        try {
            Get-Recipient $_ | Select-Object -ExpandProperty PrimarySmtpAddress
        } catch {
            "Unresolved Owner ($_)"
        }
    }
    $ownersString = if ($owners) { $owners -join ";" } else { "No Owners" }

    $results += [PSCustomObject]@{
        DL_Name         = $dlName
        DL_Email        = $dlEmail
        DL_Members      = $membersString
        DL_Owners       = $ownersString
    }
}

# Export to CSV
$results | Export-Csv -Path ".\DistributionGroupsWithMembersAndOwners.csv" -NoTypeInformation -Encoding UTF8

# Disconnect session
Disconnect-ExchangeOnline -Confirm:$false

Write-Output "Export completed: DistributionGroupsWithMembersAndOwners.csv"
