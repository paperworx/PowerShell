# This script is for use for NorPass gate systems, under the precondition that the cards that are currently in use are MiFare based ones.
# This will convert MiFare card numbers to NorPass ones.

function ConvertTo-NorPass() {
  Write-Warning "This script will convert a MiFare ID to a NorPass ID.`n`n"

  $TestID = Read-Host "Scan card now" # Get MiFare ID.

  [int]$LastOctet = [Convert]::ToInt32(($TestID[6] + $TestID[7]), 16) # Get the last octet.

  If ($LastOctet -ge 128) {
    $LastOctet = $LastOctet - 128; # Remove 128 bits if over or equal to 128 bits.
  }

  [string]$LastOctet = ('{0:X}' -f $LastOctet) # Convert last octet to string value.

  $Octets = ""
  $x = 0

  For ($i = 1; $i -lt 4; $i++) { # Reverse first 3 octets of card number.
    $Octet = $TestID[$x] + $TestID[$x + 1]
    $Octets = $Octet + $Octets
    $x = $x + 2
  }

  If ($LastOctet -ne 128) {
    $Octets = ($LastOctet + $Octets) # Append modified last octet to the start of the card number.
  }

  [int]$Octets = [Convert]::ToInt32($Octets, 16) # Convert all octets to decimal for NorPass.

  Write-Host "NorPass ID: $($Octets)"

  Set-Clipboard $Octets

  Write-Host "The NorPass ID has been copied to your clipboard!`n"

  Write-Host "Press Enter to convert another MiFare card..."

  Read-Host

  ConvertTo-NorPass
}

ConvertTo-NorPass