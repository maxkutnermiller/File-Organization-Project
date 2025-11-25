# Prompt for the location of unsorted PDFs
$sourceFolder = Read-Host "Enter the location of unsorted PDFs"

# Prompt for the location of AI files
$aiFolder = Read-Host "Enter the location of AI files"

# Prompt for the destination folder for the sorted PDFs
$destinationFolder = Read-Host "Enter the destination folder for sorted PDFs"

# Get a list of all PDF files in the source folder
$pdfFiles = Get-ChildItem -Path $sourceFolder -Filter *.pdf

# Loop through each PDF file
foreach ($pdfFile in $pdfFiles) {
    # Get the PDF file name without extension
    $pdfFileName = [System.IO.Path]::GetFileNameWithoutExtension($pdfFile.Name)
    
    # Check if the PDF file name contains a suffix like "_R1"
    $suffix = $pdfFileName -replace '^.*_([Rr]\d+)$', '$1'
    if ($suffix -ne $pdfFileName) {
        # Remove the suffix from the file name
        $pdfFileName = $pdfFileName -replace "_$suffix$"
    } else {
        $suffix = $null
    }
    
    # Search for matching AI file in the AI folder
    $matchingAiFile = Get-ChildItem -Path $aiFolder -Recurse -Filter "$pdfFileName.ai" -File | Select-Object -First 1
    
    if ($matchingAiFile) {
        # Get the subdirectory containing the matching AI file
        $subdirectory = $matchingAiFile.Directory.Name
        
        # Construct the destination path
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath $subdirectory
        
        # Create the destination directory if it doesn't exist
        if (-not (Test-Path -Path $destinationPath)) {
            New-Item -Path $destinationPath -ItemType Directory | Out-Null
        }
        
        # Move the PDF file to the corresponding subdirectory in the destination folder
        Move-Item -Path $pdfFile.FullName -Destination (Join-Path -Path $destinationPath -ChildPath "$pdfFileName$suffix.pdf")
        
        Write-Host "Successfully moved $($pdfFile.Name) to $($destinationPath)"
    } else {
        Write-Host "No matching AI file found for $($pdfFile.Name)"
    }
}

Write-Host "Script execution completed."
