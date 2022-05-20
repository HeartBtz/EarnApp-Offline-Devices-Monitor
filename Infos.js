const { Client } = require("earnapp.js");
const fs = require('fs');
//const fsAsync = require('fs').promises;
//import { Client } from "earnapp.js";

const client = new Client();

var Token = process.argv

client.login({
    authMethod: "google",
    oauthRefreshToken: Token[2],
    xsrfToken: "uE9Tm4sXtk4wHEz4tZFJyANB", //needed for endpoints like linking a device / or making a payout
});

//OR
const getStats = async () => {
    const data = await client.stats();
    console.log(data);
};

const getDevices = async () => {
    const devices = await client.devices();
  
    const checkStatusDevices = [];
    for(const device of devices) checkStatusDevices.push({uuid: device.uuid, appid: device.appid});

    const status = (await client.devicesStatus(checkStatusDevices)).statuses;
  
    const results = {};
  
    for(const device of devices)
    {
        const {online} = status[device.uuid];
        results[device.title] = {title: device.title, online, uuid: device.uuid, ips: device.ips};
    }
    var scriptWay = 'C:\\Users\\Public\\Documents\\EarnappOfflineMonitor\\results.json'
    fs.writeFile(scriptWay, JSON.stringify(results), 'utf8', (err)=>{
      
      if(err){
        console.log("Une erreur s'est produite lors de l'écriture en format JSON")
      }else{
        //console.log("Le JSON a été écrit avec succès.")
      }
      
    });

};
//-----------------------------------------------------------------------

const readFileJson = async () => {
  fs.readFile('C:\\Users\\Public\\Documents\\EarnappOfflineMonitor\\results.json', 'utf8', (err, data) => {
    if (err){
        console.log(err);
    } else {
       obj = JSON.parse(data); //now it an object
       console.log(obj);
    }
  });
}

//getStats();
//readFileJson();
getDevices();