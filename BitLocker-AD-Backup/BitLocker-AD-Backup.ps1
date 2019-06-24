
#Author Carlos Martinez
#Date 6/17/2019


#Get All the Drive on the system
$Drives = Get-BitLockerVolume

#Loop in each drive
foreach ($Drive in $Drives) {
  
    #If the drive is encrypted and it is unlocked 
    if ( ($Drive.VolumeStatus -eq "FullyEncrypted") -and ($Drive.LockStatus -eq "Unlocked") ) {
    
        # Get Protectors list for each drive encrypted
        $DriveKeyProtectors = $Drive.KeyProtector

        #Loop in  each protector 
        foreach ($DriveKeyProtector in  $DriveKeyProtectors) {
        
            #If The Protector Type is equal to "RecoveryPassword"
            if ($DriveKeyProtector.KeyProtectorType -eq "RecoveryPassword") {

                Write-Host "Pushing BitLocker Recovery key to Active Directory for Drive :" $Drive.MountPoint  -ForegroundColor Yellow
                try {
                    #Backup RecoveryKey protector to Active Directory
                    Backup-BitLockerKeyProtector -MountPoint $Drive.MountPoint -KeyProtectorId $DriveKeyProtector.KeyProtectorId -ErrorAction Stop | Out-Null
                  
                    write-host "Recovery Key successfully backup"  -ForegroundColor Green
                 
                }
                catch {
                    $error = $_.Exception.Message 
                    Write-Host "FAILED:"$error -ForegroundColor Red
                }          
            }
        }
    }
}
