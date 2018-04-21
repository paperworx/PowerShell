# This script is for use with organizations that use AD and ID cards linked up to AD users via an AD attribute.
# Ensure that you change the UserAttribute variable to the one that your cards have been linked to.

function RFID-PasswordReset {
  $UserAttribute = "" # CHANGE THIS! User attribute to look for in Active Directory which has the card number.

  If ($UserAttribute -eq "") {
    Write-Error "User attribute to look for in AD has not been set, please read the script."
    Read-Host
    Return
  }

  $WordList = "Keyboard", # List of random words for password generation.
              "Network",
              "Computer",
              "Staples",
              "Speaker",
              "Telephone",
              "Calculator",
              "Dictionary",
              "Waterfall"

  Write-Warning "This script will allow you to reset a user account's password using their associated card.`n"
  Write-Warning "Ctrl + C to abort.`n`n"

  Write-Host "Waiting for card..."

  $ID = Read-Host

  If ($ID -eq "") {
    Clear-Host
    Return Password-Reset
  }

  $User = Get-ADUser -Filter "$($UserAttribute) -eq '$($ID)'"

  If ($User) {
    $Password = ($WordList[(Get-Random -Minimum 0 -Maximum ($WordList.Length - 1))]) + (Get-Random -Minimum 100 -Maximum 999)

    $EncryptedPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    $Reset = ""

    While ($Reset -notmatch "[y|n]") {
      $Reset = Read-Host "`nDo you want to reset $($User.SamAccountName)'s password (y/n)"

      If ($Reset -eq "y") {
          Set-ADAccountPassword -Identity $User -Reset -NewPassword $EncryptedPassword

          Write-Host "`nPassword has been reset..."
          Write-Warning "Generated password is ""$($Password)""."

          Set-ADUser -Identity $User -ChangePasswordAtLogon $True
      } Elseif ($Reset -eq "n") {
        Write-Host "`nPassword was NOT reset!"
      }
    }

    $Password = Out-Null
    $EncryptedPassword = Out-Null

    Unlock-ADAccount -Identity $User

    Write-Host "Account has been unlocked!"
  } Else {
    Write-Warning "User could not be found, is the ID card associated properly?`n"
  }

  Write-Host "`nPress Enter to continue with another card..."

  Read-Host

  Clear-Host

  RFID-PasswordReset
}

RFID-PasswordReset