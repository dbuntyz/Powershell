Install-Module Microsoft.Graph -Scope CurrentUser
Install-Module -Name Microsoft.Online.SharePoint.PowerShell


Connect-MgGraph -Scopes 'User.ReadWrite.All','LicenseAssignment.ReadWrite.All'
Connect-SPOService -Url https://companyyname-admin.sharepoint.com/

$users = Get-MgUser -All # Get the list of users
$count = $users.Count
$i = 0
$j = 0
$list = @()

foreach ($u in $users) {
    try {
        $j++
        Write-Host "$j/$count - Processing: $($u.userprincipalname)"

        $upn = $u.userprincipalname

        # Check if the OneDrive site already exists
        $existingSite = Get-SPOSite -Limit All | Where-Object { $_.Owner -eq $upn }

        if ($existingSite) {
            Write-Host "OneDrive site already exists for $upn, skipping provisioning." -ForegroundColor Yellow
            continue
        }

        # Add UPN to the list for batch processing
        $list += $upn
        $i++

        # Request provisioning when batch limit is reached
        if ($i -eq 199) {
            Write-Host "Batch limit reached. Requesting provision for the current batch."
            Request-SPOPersonalSite -UserEmails $list -NoWait
            Start-Sleep -Milliseconds 2000
            $list = @() # Reset the list
            $i = 0 # Reset counter
        }
    } catch {
        Write-Host "Error processing $($u.userprincipalname): $($_.Exception.Message)" -ForegroundColor Red
        continue
    }
}

# Provision any remaining users in the list
if ($list.Count -gt 0) {
    Write-Host "Processing remaining users."
    Request-SPOPersonalSite -UserEmails $list -NoWait
}
