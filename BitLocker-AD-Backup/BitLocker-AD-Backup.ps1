
#Author Carlos Martinez
#Date 6/17/2019

#Description: This script backup to Active Directory the BitLocker Recovery keys for one or more drives on the system.

#Get All the Drive on the system
$Drives = Get-BitLockerVolume

#Go through each drive
foreach ($Drive in $Drives) {
  
    #If the drive is encrypted and it is unlocked 
    if ( ($Drive.VolumeStatus -eq "FullyEncrypted") -and ($Drive.LockStatus -eq "Unlocked") ) {
    
        # Get the list of protectors for each drive encrypted and unlocked
        $DriveKeyProtectors = $Drive.KeyProtector

        #Go through eacheach protector 
        foreach ($DriveKeyProtector in  $DriveKeyProtectors) {
        
            #If The Protector Type is equal to "RecoveryPassword"
            if ($DriveKeyProtector.KeyProtectorType -eq "RecoveryPassword") {

                Write-Host "Pushing BitLocker Recovery key to Active Directory for Drive :" $Drive.MountPoint  -ForegroundColor Yellow

                try {
                    #Backup RecoveryKey protector(Recovery Key) to Active Directory
                    Backup-BitLockerKeyProtector -MountPoint $Drive.MountPoint -KeyProtectorId $DriveKeyProtector.KeyProtectorId -ErrorAction Stop | Out-Null
                    
                    #if backup was success print 
                    write-host "Recovery Key successfully backup"  -ForegroundColor Green
                 
                }
                catch {
                    $error = $_.Exception.Message 
                    
                    #if backup failed print
                    Write-Host "FAILED:"$error -ForegroundColor Red
                }          
            }
        }
    }
}
