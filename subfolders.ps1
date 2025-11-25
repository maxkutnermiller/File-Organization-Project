# Input folder paths (replace with your actual paths)
$aiFolder = Read-Host "Enter the location of the AI files"
$pdfFolder = Read-Host "Enter the location of the PDF files"

# Function to move PDFs with matching names to PDF subdirectories
function Move-MatchingPDFs {
    param (
        [string]$aiFolder,
        [string]$pdfFolder
    )

    try {
        # Get a list of PDF files
        $pdfFiles = Get-ChildItem -Path $pdfFolder -Filter "*.pdf" -File -Recurse

        # Iterate through AI files in subdirectories
        Get-ChildItem -Path $aiFolder -File -Recurse -Filter "*.ai" | ForEach-Object {
            $aiFile = $_
            $aiFileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($aiFile.Name)
            $pdfNamePrefix = $aiFileNameWithoutExtension

            # Find matching PDF files (including revisions)
            $matchingPdf = $pdfFiles | Where-Object {
                $pdfBaseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
                $pdfBaseName.StartsWith($pdfNamePrefix) -and ($pdfBaseName -eq $pdfNamePrefix -or $_.Name -match "_R\d*.pdf")
            }

            foreach ($pdf in $matchingPdf) {
                # Determine the AI subdirectory path
                $aiSubdirectory = Join-Path -Path $aiFolder -ChildPath $aiFile.Directory.Name

                # Determine the PDF subdirectory path
                $pdfSubdirectory = Join-Path -Path $pdfFolder -ChildPath $aiFile.Directory.Name

                # Create the PDF subdirectory if it doesn't exist
                if (-not (Test-Path -Path $pdfSubdirectory -PathType Container)) {
                    New-Item -Path $pdfSubdirectory -ItemType Directory -Force
                }

                # Move the PDF file to the PDF subdirectory
                $pdfDestination = Join-Path -Path $pdfSubdirectory -ChildPath $pdf.Name
                Move-Item -Path $pdf.FullName -Destination $pdfDestination -Force
                Write-Host "Moved $($pdf.Name) to $($pdfDestination)"
            }
        }
    } catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
    }
}

# Call the function to move matching PDFs
Move-MatchingPDFs -aiFolder $aiFolder -pdfFolder $pdfFolder

# Confirmation message
Write-Host "Processing complete."
