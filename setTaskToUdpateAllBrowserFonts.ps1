# Define a logging function
function Write-Log {
    param (
        [string]$Message
    )

    # Define the log file path
    $logPath = "C:\Packages\Logs\RemediationLog.txt"
    Add-Content -Path $logPath -Value ("[" + (Get-Date).ToString() + "] " + $Message)
}

try {
    # Ensure the destination directory exists
    if (-not (Test-Path C:\Packages\Scripts)) {
        New-Item -Path C:\Packages\Scripts -ItemType Directory
        Write-Log "Created directory: C:\Packages\Scripts"
    }

    # Download the PS file
    $outPut = 'C:\Packages\Scripts\setTrebuchetMSAllBrowsers.ps1'
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/CIPDRepo/Desktop/main/setTrebuchetMSAllBrowsers.ps1" -OutFile $outPut
    Write-Log "Downloaded PowerShell script to $outPut"

    # Download the XML file
    $outPutXML = 'C:\Packages\Scripts\EPSetBrowserFontsv1.xml'
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/CIPDRepo/Desktop/main/EPSetBrowserFontsv1.xml" -OutFile $outPutXML
    Write-Log "Downloaded XML configuration to $outPutXML"

    # Check if the task exists and unregister it
    $existingTask = Get-ScheduledTask | Where-Object { $_.TaskName -eq "EP Set Browser Fonts" }
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName "EP Set Browser Fonts" -Confirm:$false
        Write-Log "Unregistered existing task: EP Set Browser Fonts"
    }

    # Import the task
    Register-ScheduledTask -Xml (Get-Content $outPutXML | Out-String) -TaskName "EP Set Browser Fonts"
    Write-Log "Attempted to register the scheduled task: EP Set Browser Fonts"

    # Confirm task creation
    $confirmation = Get-ScheduledTask | Where-Object { $_.TaskName -eq "EP Set Browser Fonts" }
    if ($confirmation) {
        Write-Log "Confirmed: The scheduled task 'EP Set Browser Fonts' has been successfully created."
    } else {
        Write-Log "Error: The scheduled task 'EP Set Browser Fonts' was not found after the creation attempt."
        throw "Failed to create the scheduled task."
    }
}
catch {
    Write-Log ("ERROR: " + $_.Exception.Message)
    throw $_.Exception
}
