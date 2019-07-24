
#Carlos Martinez Date: 7/22/2019 GitHub @cmartinezone

#DESCRIPTION:  Set Windows 1803 update as hidden on windows updates
#The script hides the Windows 1803 Feature updates from windows updates list.


#Create object session for windows updates
$session = new-object -ComObject Microsoft.Update.Session
#Windows Object searcher 
$searcher = $session.CreateUpdateSearcher()
#Get List of updates not installed
$result = $searcher.Search("IsInstalled=0")

#Get Update List
$Updatelist = $result.Updates 

#Windows 1803 update title: "Feature update to Windows 10, version 1803 x64 2019-07C"
#Updates KB ID: 4507466
#Multiple IDs can be added on the following object
$ListOfUpdateIDs = @(
    "4507466"
)

$LastUpdateStatus = $null

$Updatelist | ForEach-Object{

    #If the Update exists on the object array of updates  and it is already hidden 
    if ($_.KBArticleIDs -in $ListOfUpdateIDs -and $_.IsHidden -eq $true) {
        
        Write-Host "The Update is already hidden." -ForegroundColor Green
        
        #store object status
        $LastUpdateStatus = $_
     }


    #if any of the ids on the updates array match with the update list ids and
    #If the update is not hidden
    if ($_.KBArticleIDs -in $ListOfUpdateIDs -and $_.IsHidden -eq $false) {
        
        try {

        #Set Update as Hidden
         $_.IsHidden = $true  
         
         Write-Host "Update has been successfully hidden." -ForegroundColor Green

         #store object status
         $LastUpdateStatus = $_

        }
        catch {
            $error = $_.Exception.Message 
            Write-Host "FAILED:"$error -ForegroundColor Red
        }   
    }

}

#Print Object status
$LastUpdateStatus | Select-Object Title, IsHidden 
