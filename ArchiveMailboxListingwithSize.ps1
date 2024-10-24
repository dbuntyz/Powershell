

# Path to your input CSV file
$csvPath = "D:\import.csv"

# Path for the output CSV file
$outputCsvPath = "D:\MailboxSizes.csv"

# Import the CSV file
$users = Import-Csv -Path $csvPath

# Create an array to hold the results
$results = @()

# Loop through each user and get mailbox statistics
foreach ($user in $users) {
    try {
        # Get mailbox statistics
        $mailboxStats = Get-EXOMailboxStatistics -Identity $user.UserEmail
        
        # Check if mailboxStats is not null
        if ($mailboxStats -and $mailboxStats.TotalItemSize) {
            # Get the TotalItemSize in GB
            $sizeInGB = [math]::round($mailboxStats.TotalItemSize.Value.ToBytes() / 1GB, 2)

            # Add result to the array
            $results += [PSCustomObject]@{
                UserEmail      = $user.UserEmail
                MailboxSizeGB  = $sizeInGB
            }
        } else {
            throw "Mailbox statistics not found for $($user.UserEmail)."
        }
    }
    catch {
        # Handle errors (e.g., user not found)
        $results += [PSCustomObject]@{
            UserEmail      = $user.UserEmail
            MailboxSizeGB  = "Error: $_"
        }
    }
}

# Export the results to a new CSV file
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation

# Optional: Output the results to the console
$results | Format-Table -AutoSize
