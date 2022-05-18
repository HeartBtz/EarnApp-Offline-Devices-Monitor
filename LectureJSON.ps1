
##########################################################################################################################################
#                                                                                                                                        #
#                                                                                                                                        #
#                     ==============================Préréquis====================================                                        #
#                                                                                                                                        #
#Lancer le script Install.bat présent dans le dossier en tant qu'ADMINISTRATEUR                                                          #
#Installer Node.js : https://nodejs.org/dist/v16.15.0/node-v16.15.0-x64.msi                                                              #
#                                                                                                                                        #
#                                                                                                                                        #
#                     ===Discord Powershell Bot Librairy https://github.com/EvotecIT/PSDiscord===                                        #
#                                                                                                                                        #
#                                                                                                                                        #
#> Install-Module PSDiscord                                                                                                              #
#> Update-Module PSDiscord                                                                                                               #
#                                                                                                                                        #
#                                                                                                                                        #
#                     =====================Informations WebHook Discord==========================                                        #
#                                                                                                                                        #
#                                                                                                                                        #
$AvatarImageURL = 'https://cdn.discordapp.com/attachments/972197177029980172/975730277139746826/progyblue.png'                           #
$AvatarName = "Monitor-Senseii"                                                                                                          #
$WebHookUrl = 'https://discord.com/YourWebHookURL' #
#                                                                                                                                        #
#                                                                                                                                        #
##########################################################################################################################################

function ObtainDate{
$date = Get-Date -Format "yyyyMMdd_H:mm:ss"
$date = "[$date]"
return $date
}
function MakeLogMessage($message){
    ADD-content -path "C:\LogsEarnappOfflineMonitor.log" -value "$(ObtainDate) $($message)"
}
function FileTime{
$ft = (Get-Date).ToFileTime()
return $ft
}


$way = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition) # Cherche le chemin dans lequel les scripts sont.
$OutputVar = node "$way\Infos.js" | Out-String #Lance le script JavaScript & envoie le résultat dans la variable $OutputVar => chemin du fichier JSON
if (Test-Path "C:\results.json"){
    MakeLogMessage('JSON récupéré avec succès')
    $inputJson = Get-Content "C:\results.json" | ConvertFrom-Json #Lecture & Inteprétation de results.json ($OutputVar) || Reading & Interprate of results.json
    $deviceNumber = $inputJson[0].PSObject.Properties.Name.Length #Nombre de Machines || Number of Devices 
    $devicesList = [System.Collections.ArrayList]@() #Tableau vide
    $offlineDevices = [System.Collections.ArrayList]@() #Tableau vide
    $Fact = [System.Collections.ArrayList]@() #Tableau vide
    For ($i = 0; $i -lt $DeviceNumber; $i++){
        $deviceName = [string]$inputJson[0].PSObject.Properties.Name[$i] #Nom de la Machine
        $temp = $devicesList.Add($deviceName) # Nom de toutes les machines
        if($inputJson[0].$deviceName.online -notlike "true" ){ #Si l'attribut online est différent de "true" alors...
            $temp2 = $offlineDevices.Add($deviceName) #Ajout dans un nouveau tableau les machines Offline.
        }  
    }
    $offlineDeviceNumber = $offlineDevices.Count #Nombre de Machines offline || Number of offline devices
    MakeLogMessage("Il y a $offlineDeviceNumber client(s) déconnecté(s) ")
    
    if($offlineDeviceNumber -ne 0){ # Si le nombre de machines éteintes est différent de zéro
        MakeLogMessage("Un message va donc être envoyé sur Discord")
        For ($j = 0; $j -lt $offlineDeviceNumber; $j++){
            $device = [string]$offlineDevices[$j]
            $Name = ":red_square: Concerned Device:  " + $inputJson[0].$device.title + " :red_square:"
            $Value = "UUID: " + $inputJson[0].$device.uuid + "
            IP: " + $inputJson[0].$device.ips
            $temp3 =  $Fact.Add($j)
            $Fact[$j] = New-DiscordFact -Name $Name -Value $Value -Inline $false
        }
        #DISCORD BOT SECTION | Consultez la Doc des devs pour plus d'informations sur la Librairie: https://evotec.xyz/hub/scripts/psdiscord-powershell-module/
        $Author = New-DiscordAuthor -Name $AvatarName -IconUrl $AvatarImageURL
        $Section = New-DiscordSection -Title "$offlineDeviceNumber Device(s) offline: " -Facts $Fact -Color BlueViolet -Author $Author -Thumbnail $Thumbnail 
        $Thumbnail = New-DiscordThumbnail -Url $AvatarImageURL
        if(!$env:LAST_MESSAGE_HOUR){
            Send-DiscordMessage -WebHookUrl $WebHookUrl -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarImageURL
            $env:LAST_MESSAGE_HOUR=FileTime
            MakeLogMessage("Le Bot a transmis le message sur Discord à $(Get-Date -Format 'HH:mm')")
            MakeLogMessage("Compteur démarré dans env:LAST_MESSAGE_HOUR")
        }else{
            $TimeDifference = ($(FileTime) - $env:LAST_MESSAGE_HOUR).ToString()
            if($TimeDifference -ge 54000000000){
                Send-DiscordMessage -WebHookUrl $WebHookUrl -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarImageURL
                $env:LAST_MESSAGE_HOUR=FileTime
                MakeLogMessage("Le Bot a transmis le message sur Discord à $(Get-Date -Format 'HH:mm')")
                MakeLogMessage("Compteur renouvelé dans env:LAST_MESSAGE_HOUR")
            }else{
                MakeLogMessage("Un message a déjà été envoyé il y a moins de 1h30")
            }
        }             
     }
    Remove-Item 'C:\results.json'
    if ((Test-Path "C:\results.json") -like "False" ){
        MakeLogMessage('JSON Supprimé avec succès')
    }else{
        MakeLogMessage('Echec de la suppression du fichier JSON')
    }
}#endIF Line:30
ADD-content -path "C:\LogsEarnappOfflineMonitor.log" -value "$(ObtainDate)======================================================================="