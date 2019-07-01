
 
 #Author: Carlos Martinez - 7-1-2019

#Get-TPM Status
$TPM = Get-Tpm | Select-Object -Property TpmPresent, AutoProvisioning -ErrorAction SilentlyContinue

#Get-Drive encryption status
$DriveStatus = Get-BitLockerVolume -MountPoint "C:\" | Select-Object -Property VolumeStatus
 
#If Drive is fully decrypted and TPM is anable and TPM is actived
if (($DriveStatus.VolumeStatus -eq "FullyDecrypted") -and  ($TPM.TpmPresent -eq "True") -and ($TPM.AutoProvisioning -eq "Enabled")) {

    #Extract Pin number from computername
    $PinNumber = $env:COMPUTERNAME -replace "[^0-9]" , ''

    #Create security pin
    $SecureString = ConvertTo-SecureString $PinNumber -AsPlainText -Force

    #Add Recovery Key to the drive requires by GPO
    Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector

    #Enable Encryption
    Enable-BitLocker -MountPoint "C:\"  -EncryptionMethod XtsAes256  -TpmAndPinProtector -Pin $SecureString -SkipHardwareTest

    #Push Recovery Key to AD:
    $Drive = Get-BitLockerVolume -MountPoint "C:\"
    Backup-BitLockerKeyProtector -MountPoint "C:\" -KeyProtectorId $Drive.KeyProtector[0].KeyProtectorId

}


