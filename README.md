# Hello and welcome to Earnapp Offline Monitor

Here is a **scriptbot** to see in real time the status of your devices linked to **EarnApp**.  
The script runs every **15** minutes, but you will only receive an alert every **1.5** hours if your device is offline. If a new device appears in the offline list, a new **Discord** message will be sent.  
**This is a script, not a bot, so no program running in the background.**

![Discord message rendering](https://media.discordapp.net/attachments/972078178963177502/977725325926613042/unknown.png)

a big thank you to **https://github.com/EvotecIT** for their PSDiscord module, and to **https://github.com/LockBlock-dev** for its API allowing to talk with Earnapp interface.


# Prerequisites  
Several libraries are needed here. This script is in Powershell. I also use javascript.  

 **1. Activate Powershell**  
 Powershell in Administrator mode => `set-executionpolicy unrestricted`  
 chose `yes for all` if necessary  
 
**2. Download PSDiscord Module**  
Powershell in Administrator mode => `Install-Module PSDiscord` & also  `Update-Module PSDiscord`  
chose `yes for all` if necessary  
Thanks to https://github.com/EvotecIT

 **3. Donwload NodeJS**  
 Install NodeJs using this link => https://nodejs.org/dist/v16.15.0/node-v16.15.0-x64.msi  

 **4. Install Earnapp.js Module**  
Open a `Command Prompt` window in Administrator mode  

   ```py
   npm install earnapp.js
   ```  

Thanks to https://github.com/LockBlock-dev  

 **5. Install Batch script**  
Run the `Install.bat` script in administrator mode
![Run as Administrator the Install.bat File](https://media.discordapp.net/attachments/972078178963177502/977715291540816012/unknown.png)

 **6. Filling variables in the powershell script**  
Here you will need your OAuthToken EarnApp, as well as a webhook discord.  
Some links to get this information.  
OAuthToken => [Click Here (Thanks to LockBlock)](https://github.com/LockBlock-dev/earnapp.js/blob/master/Cookies.md#how-to-login-with-cookies)  
Discord WebHook => [Discord Tutorial Link](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)  

Now Open LectureJSON.ps1 and fill in the variables 
```ps

##########################################################################################################################################
#                                               READ THE README.MD FILE                                                                  #
#                                                                                                                                        #
#                     ==============================Préréquis====================================                                        #
#                                                                                                                                        #
# Run as ADMINISTRATOR the Install.bat script                                                                                            #
# Install Node.js : https://nodejs.org/dist/v16.15.0/node-v16.15.0-x64.msi                                                               #
#                                                                                                                                        #
#                                                                                                                                        #
#                     ===Discord Powershell Bot Librairy https://github.com/EvotecIT/PSDiscord===                                        #
#                                                                                                                                        #
#                                                                                                                                        #
#> Install-Module PSDiscord                                                                                                              #
#> Update-Module PSDiscord                                                                                                               #
#                                                                                                                                        #
#                                                                                                                                        #
#                     ==================Information Variables to be completed====================                                        #
#                                                                                                                                        #
$oAuthRefreshToken = 'YOUR TOKEN HERE'       #Add your Earnapp token here
$AvatarImageURL = 'https://cdn.discordapp.com/attachments/972197177029980172/975730277139746826/progyblue.png'    #Chose the image you want for your discord WebHook
$AvatarName = "Monitor-Senseii"        #WebHook Name                                                                                           
$WebHookUrl = 'YOUR DISCORD WEBHOOK HERE' #Add here your WebHook Link
$ExcludedDevices = @("DeviceName1","DeviceName2","DeviceName...","DeviceNameX","2Win5")   #Here you enter the devices that you do not want to be displayed on the BOT 
#                                                                                                                                        #
#                                                                                                                                        #
##########################################################################################################################################

```

In case of problems, contact me on discord => HeartBtz#0110 or open an issue here.
