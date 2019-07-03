#Author: Carlos Martinez  - GitHub @cmartinezone
#Date: 7-3-2019 
 
#Get-TPM Status
$TPM = Get-Tpm | Select-Object -Property TpmPresent, AutoProvisioning -ErrorAction SilentlyContinue

#Get-Drive encryption status
$DriveStatus = Get-BitLockerVolume -MountPoint "C:" | Select-Object -Property VolumeStatus
 
#If Drive is fully decrypted and TPM is anable and TPM is actived
if (($DriveStatus.VolumeStatus -eq "FullyDecrypted") -and ($TPM.TpmPresent -eq "True") -and ($TPM.AutoProvisioning -eq "Enabled")) {

    #Extract Pin number from computername if 6 digits number is included on the name
    $PinNumber = $env:COMPUTERNAME -replace "[^0-9]" , ''
    
    #Verify if the number extracted from the computer name meet the requirements of 8 digits.
    if ($PinNumber.Length -eq 8) 
    {
        #Create security pin
        $SecureString = ConvertTo-SecureString $PinNumber -AsPlainText -Force
    }
    else 
    {
        #Set default Pin number if the computer name doesn't contain 8 degit numbers:
        $PinNumber = "12345678"
        $SecureString = ConvertTo-SecureString $PinNumber -AsPlainText -Force
    }
   
    #Add RecoveryKey to the drive requires by GPO
    Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector -ErrorAction SilentlyContinue

    #Enable BitLocker Encryption
    Enable-BitLocker -MountPoint "C:"  -EncryptionMethod XtsAes256  -TpmAndPinProtector -Pin $SecureString -SkipHardwareTest -ErrorAction SilentlyContinue

    #Backup Recovery Keys Asociated with the C: Drive to AD:
    $Drive = Get-BitLockerVolume -MountPoint "C:"
    
    foreach ($KeyProtector in $Drive.KeyProtector) {
        
        if ($KeyProtector.KeyProtectorType -eq "RecoveryPassword") {
        
            Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $KeyProtector.KeyProtectorId 

        }
    }

}


