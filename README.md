# Duplicate DNS Records Finder

This PowerShell script allows you to find duplicate DNS records by IP address in a specified DNS zone. It queries the DNS server and identifies any duplicate IP addresses, providing you with the associated DNS records.

## Prerequisites

- Windows operating system with PowerShell installed.
- Access to a DNS server with the appropriate permissions to query DNS records in the target zone.

## How to Use

1. Clone or download the script file `FindDuplicateDNSRecords.ps1`.

2. Open a PowerShell session.

3. Navigate to the directory where the script is saved using the `cd` command. For example:
    ```powershell
    cd C:\Scripts
    ```

4. Run the script with the appropriate parameters. Here's an example command:
    ```powershell
    .\FindDuplicateDNSRecords.ps1 -DnsServer "dns-server.example.com" -ZoneName "yourdomain.com" -ExcludeRecordNames "*.example.com" -OutputFile "duplicate_records.csv" -EmailNotification "admin@example.com" -RecordType "A"
    ```

   Replace the parameter values with the following:
   - `-DnsServer`: The hostname or IP address of your DNS server.
   - `-ZoneName`: The name of the DNS zone you want to analyze.
   - `-ExcludeRecordNames`: (Optional) Any specific record names you want to exclude, such as `*.example.com`.
   - `-OutputFile`: (Optional) The desired path and filename for the output CSV file.
   - `-EmailNotification`: (Optional) An email address to receive a notification with the CSV file attached.
   - `-RecordType`: (Optional) The specific record type you want to filter on (default is "A").

5. Press Enter to execute the command.

## Results

After running the script, the results will be displayed in the console. The script will identify duplicate IP addresses and list the associated DNS records (host names and TTLs) for each duplicate IP. If an output file is specified using the `-OutputFile` parameter, the results will also be saved in a CSV file.

## Additional Features

The script includes several additional features that can be customized:
- Exclude specific DNS record names.
- Output the results to a CSV file.
- Send email notification with the results.
- Support for different record types.
- Error handling and logging.

Feel free to modify the script to suit your specific requirements.

## License

This script is licensed under the [MIT License](LICENSE).

