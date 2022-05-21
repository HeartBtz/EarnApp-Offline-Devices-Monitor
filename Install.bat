setx EarnAppLogPath C:\Users\Public\Documents\EarnappOfflineMonitor\
setx EarnAppPath %~dp0%
schtasks /create /TN 'EarnApp_Offline_Monitor' /RL HIGHEST /SC minute /MO 15 /TR "powershell.exe -file %~dp0%LectureJSON.ps1"
