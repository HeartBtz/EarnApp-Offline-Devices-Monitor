
##########################################################################################################################################
#                                                                                                                                        #
#                                                                                                                                        #
#                     ==============================Préréquis====================================                                        #
#                                                                                                                                        #
# Lancer en tant qu'ADMINISTRATEUR le script Install.bat présent dans le dossier                                                         #
# Installer Node.js : https://nodejs.org/dist/v16.15.0/node-v16.15.0-x64.msi                                                             #
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
$oAuthRefreshToken = ''       #
$AvatarImageURL = 'https://cdn.discordapp.com/attachments/972197177029980172/975730277139746826/progyblue.png'                           #
$AvatarName = "Monitor-Senseii"                                                                                                          #
$WebHookUrl = '' #
$ExcludedDevices = [System.Collections.ArrayList]@("DeviceName1","DeviceName2","DeviceName...","DeviceNameX","2Win7")                   #                                                                                                                                        #
#                                                                                                                                        #
#                                                                                                                                        #                                                                                                                                        #
##########################################################################################################################################

function ObtainDate{
$date = Get-Date -Format "yyyyMMdd_H:mm:ss"
$date = "[$date]"
return $date
}
function MakeLogMessage($message){
    ADD-content -path ($env:EarnAppLogPath + 'LogsEarnappOfflineMonitor.log') -value "$(ObtainDate) $($message)"
}
function FileTime{
$ft = (Get-Date).ToFileTime().ToString()
return $ft
}


$scriptWay = $env:EarnAppPath # Cherche le chemin dans lequel les scripts sont.
$resultsLogDir = $env:EarnAppLogPath
$OutputVar = node ( $scriptWay + "Infos.js" ) $oAuthRefreshToken | Out-String #Lance le script JavaScript & envoie le résultat dans la variable $OutputVar => chemin du fichier JSON
if (Test-Path ($resultsLogDir + "results.json")){
    MakeLogMessage('JSON récupéré avec succès')#Logs
    $inputJson = Get-Content ($resultsLogDir + 'results.json' ) | ConvertFrom-Json #Lecture & Inteprétation de results.json ($OutputVar) || Reading & Interprate of results.json
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
    MakeLogMessage("Il y a $offlineDeviceNumber client(s) déconnecté(s) ")#Logs
    #$isExcluded = [System.Collections.ArrayList]@() #Tableau vide
    if($offlineDeviceNumber -ne 0){ # Si le nombre de machines éteintes est différent de zéro
        MakeLogMessage("Un message va donc être envoyé sur Discord")
        $Exclusion = 0
        For ($j = 0; $j -lt $offlineDeviceNumber; $j++){
            $device = [string]$offlineDevices[$j]
            if ($device -in $ExcludedDevices){ #si y'a le device qui apparaît est dans la liste d'exclusion alors...
                $Exclusion++
            }else{ #sinon...
                $Name = ":red_square: **Device:** " + $inputJson[0].$device.title + " :red_square:" 
                $Value = ":biohazard: **UUID:**   " + $inputJson[0].$device.uuid  + " 
                :globe_with_meridians: **IP:**   " + $inputJson[0].$device.ips #laisser la ligne sautée, c'est pour la présentation de l'embed dans discord
                $temp3 =  $Fact.Add($j) 
                $Fact[$j] = New-DiscordFact -Name $Name -Value $Value -Inline $false
            }
        }
        MakeLogMessage("$Exclusion Appareils ont été exclus")

        #DISCORD BOT SECTION | Consultez la Doc des devs pour plus d'informations sur la Librairie: https://evotec.xyz/hub/scripts/psdiscord-powershell-module/
        $Author = New-DiscordAuthor -Name $AvatarName -IconUrl $AvatarImageURL
        $Section = New-DiscordSection -Title "$(Get-Date -Format 'HH:mm') | $($offlineDeviceNumber - $Exclusion) Device(s) offline | $Exclusion Excluded Device(s) " -Facts $Fact -Color BlueViolet -Author $Author -Thumbnail $Thumbnail 
        $Thumbnail = New-DiscordThumbnail -Url $AvatarImageURL
        if(!$env:LAST_MESSAGE_HOUR){
            Send-DiscordMessage -WebHookUrl $WebHookUrl -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarImageURL
            cmd.exe /c "setx LAST_MESSAGE_HOUR $(FileTime)"
            MakeLogMessage("Le Bot a transmis le message sur Discord à $(Get-Date -Format 'HH:mm')")
            MakeLogMessage("Compteur démarré dans env:LAST_MESSAGE_HOUR")
        }else{
            $TimeDifference = ($(FileTime) - $env:LAST_MESSAGE_HOUR)
            if($TimeDifference -ge 54000000000){
                Send-DiscordMessage -WebHookUrl $WebHookUrl -Sections $Section -AvatarName $AvatarName -AvatarUrl $AvatarImageURL
                cmd.exe /c "setx LAST_MESSAGE_HOUR $(FileTime)"
                MakeLogMessage("Le Bot a transmis le message sur Discord à $(Get-Date -Format 'HH:mm')")
                MakeLogMessage("Compteur renouvelé dans env:LAST_MESSAGE_HOUR")
            }else{
                MakeLogMessage("Un message a déjà été envoyé il y a moins de 1h30")
            }
        }             
    }
    Remove-Item ( $resultsLogDir + 'results.json' )
    if ((Test-Path ( $resultsLogDir + 'results.json' )) -like "False" ){
        MakeLogMessage('JSON Supprimé avec succès')
    }else{
        MakeLogMessage('Echec de la suppression du fichier JSON')
    }
}#endIF Line:30
ADD-content -path ( $resultsLogDir + 'LogsEarnappOfflineMonitor.log' ) -value "$(ObtainDate)======================================================================="