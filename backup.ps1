$way = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition) # Cherche le chemin dans lequel les scripts sont.
$OutputVar = node "$way\Infos.js" | Out-String #Lance le script JavaScript & envoie le résultat dans la variable $OutputVar => chemin du fichier JSON
Write-Output $OutputVar
Start-Sleep -Seconds 3 #Pause de 10 secondes le temps de récup le JSON
Write-Output "Test 1 OK"
$OutputVar
$inputJson = Get-Content $OutputVar | ConvertFrom-Json #Lecture & Inteprétation de results.json ($OutputVar) || Reading & Interprate of results.json
$deviceNumber = $inputJson[0].PSObject.Properties.Name.Length #Nombre de Machines || Number of Devices
$devicesList = [System.Collections.ArrayList]@() #Tableau vide
$offlineDevices = [System.Collections.ArrayList]@() #Tableau vide
$Fact = [System.Collections.ArrayList]@() #Tableau vide
Start-Sleep -Seconds 3 #Pause de 10 secondes le temps de récup le JSON
Write-Output "Test 2 OK"
For ($i = 0; $i -lt $DeviceNumber; $i++){
    $deviceName = [string]$inputJson[0].PSObject.Properties.Name[$i] #Nom de la Machine
    $temp = $devicesList.Add($deviceName) # Nom de toutes les machines
    if($inputJson[0].$deviceName.online -notlike "true" ){ #Si l'attribut online est différent de "true" alors...
        $temp2 = $offlineDevices.Add($deviceName) #Ajout dans un nouveau tableau les machines Offline.
    }  
}
Start-Sleep -Seconds 3 #Pause de 10 secondes le temps de récup le JSON
Write-Output "Test 3 Boucle For 1 OK"
$offlineDeviceNumber = $offlineDevices.Count #Nombre de Machines offline || Number of offline devices

For ($j = 0; $j -lt $offlineDeviceNumber; $j++){
    $device = [string]$offlineDevices[$j]
    $Name = ":red_square: Concerned Device:  " + $inputJson[0].$device.title
    $Value = "UUID: " + $inputJson[0].$device.uuid + "
    IP: " + $inputJson[0].$device.ips
    $temp3 =  $Fact.Add($j)
    $Fact[$j] = New-DiscordFact -Name $Name -Value $Value -Inline $false
}
Start-Sleep -Seconds 3 #Pause de 10 secondes le temps de récup le JSON
Write-Output "Test 4 OK"
if($offlineDeviceNumber -ne 0){ # Si le nombre de machines éteintes est différent de zéro

    #BOT DISCORD
    $Uri = 'https://discord.com/api/webhooks/972083332978442270/RhkhfyJXxXk0r2uHisA5oPyPAFg7Ng0KXa9JpCYMvLKQr3u7a6NSx_79awbRRADplJEh'
    $Author = New-DiscordAuthor -Name 'Monitoring-Chan' -IconUrl "https://cdn.discordapp.com/attachments/972197177029980172/975730277139746826/progyblue.png"
    $Section = New-DiscordSection -Title 'Liste des machines déconnectées :' -Facts $Fact -Color BlueViolet -Author $Author -Thumbnail $Thumbnail
    $Thumbnail = New-DiscordThumbnail -Url "https://cdn.discordapp.com/attachments/972197177029980172/975730277139746826/progyblue.png"


    Send-DiscordMessage -WebHookUrl $Uri -Sections $Section -AvatarName 'Monitoring-Chan' -AvatarUrl "https://cdn.discordapp.com/attachments/972197177029980172/975730277139746826/progyblue.png"
    Write-Output "Condition Machine down OK"
}
Write-Output "Fin Script OK"