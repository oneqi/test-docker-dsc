# test-docker-dsc
docker for windows and DSC

## Environment

This test lab uses Docker for Windows   
However, you can use the scripts in other test labs where you have 2 VMs / workstations    
iis01  
client  
Where iis01 is the DSC pull server (using basic HTTP) and your workstation is the client   
(both do NOT have to be joined to the same domain)    

We are using your workstation as the 'client' and a bridged network to communicate with the microsoft docker container.  
The image used will be "microsoft/iis:latest" and it will be labelled 'iis01'    
The bridged network will allow you to use the same network your client is on, i.e. no NAT is required   
On your workstation (client), place all scripts under c:\dsc, i.e.  
AudioServiceConfig.ps1  
CreatePullServer.ps1  
LCMPullMode .ps1  
docker-compose.yml  

## Client

install the latest powershell DSC development tools  
```
Register-PSRepository -Name DockerPS-Dev -SourceLocation https://ci.appveyor.com/nuget/docker-powershell-dev
Install-Module Docker -Repository DockerPS-Dev
```

### Bridged Network on Docker for Windows

Check for bridged network in existing list  
`docker network list`

If missing, create bridge network using transparent driver   
`docker network create -d transparent bridged`

### Windows container

Create running container with preconfigured docker-compose file  
Place docker-compose file under c:\dsc  
```
cd\
cd dsc
docker-compose up -d
```
The name of container will be dsc_iis01_1    

Create a powershell session to dsc_iis01_1 using the installed dev ps tools  
Now connect using the 'enter-pssession' on client (using ISE !) .. so that we can use psedit !  
You may need to resart ISE (as administrator !)  
`Enter-PSSession -ContainerId (Get-Container dsc_iis01_1).ID -RunAsAdministrator`

## iis01

Check hostname and IOP address of iis01 ( to make sure it is in the same network as client)    
```
hostname
ipconfig
```

### DSC Resource components for the HTTP pull server

Once connected, we need to install key DSC components  
```
Install-WindowsFeature DSC-Service
winrm qc
```

We need tocreate an 'admin' folder    
```
cd \
mkdir admin
cd admin
```

Next, we need to download xPsDesiredStateConfiguration DSC resource  
```
Invoke-WebRequest -Uri https://gallery.technet.microsoft.com/scriptcenter/DSC-Resource-Kit-All-c449312d/file/131371/4/DSC%20Resource%20Kit%20Wave%2010%2004012015.zip -OutFile "C:\admin\xyz.zip"
Expand-Archive -LiteralPath "C:\admin\xyz.zip" -DestinationPath "C:\admin\"
Copy-Item "C:\admin\All Resources\xPSDesiredStateConfiguration" -Destination "C:\Program Files\WindowsPowerShell\Modules" -recurse
```

We need to heck 'DSCResources' on iis01 as we require 'xDscWebService' which is in 'xPSDesiredStateConfiguration'  
We need xDSCWebService for the CreatePullServer.ps1 script to work  
```
Get-DSCResource
Get-DscResource xDSCWebService | fl *
```

Now reate an empty .ps1 file  
`New-Item c:\admin\CreatePullServer.ps1 -type file`

Copy and paste contents of my CreatePullServer.ps1 into this file and save 
Paste it onto the ISE which should indicate remote file and save !   
```
cd\
cd admin
psedit CreatePullServer.ps1
```

Run the CreatePullServer.ps1 to creat a localhost.MOF file in c:\admin\CreatePullServer  
`.\CreatePullServer.ps1`

Run the following command to configure our Pull Server  
`Start-DSCConfiguration -Path "C:\admin\CreatePullServer" -Wait -Verbose`
(ignore the errors)  

We need to verify that everything went well  
To check if the DSC features are installed    
```
Get-WindowsFeature -Name DSC-Service
Get-Website | ft -Autosize
ipconfig
```
(you can open up a browser on the client and try ... http://<IP address of iis01>:8080/PSDSCPullServer.svc/ .. or use hostfile for DNS)  

### Configure the LCM agent for the Client

Node configuration (keep ps session open and configure on iis01)  
```
$guidClient = [GUID]::NewGuid()
$guidClient
```
(Take note of the guid value !)  

Set the correct settings for LCM for the client(s) (keep ps session open and configure on iis01)  
`New-Item c:\admin\LCMPullMode.ps1 -type file`

Copy and paste contents of my LCMPullMode.ps1 into this file and save  
```
cd\
cd admin
psedit LCMPullMode.ps1
```
(Warning .. you need to add you 'client' hostname in the bottom of the script !)  

Now to create the .MOF file for our client in c:\admin\LCMPullMode  
```
cd\
cd admin
.\LCMPullMode.ps1
```

We can now push this config for the LCM onto the client  
```
cd\
cd admin
Set-DscLocalConfigurationManager -Path .\LCMPullMode
```

To check if the config has been pushed through  
```
$session = New-CimSession -ComputerName "your hostname for the client"
Get-DscLocalConfigurationManager -CimSession $session
```

### DSC node configuration for the Client

Now to deploy a dsc config to the client  
Create a file AudioServiceConfig.ps1 in c:\admin  
```
cd\
cd admin
New-Item c:\admin\AudioServiceConfig.ps1 -type file
```

Copy and paste contents of my AudioServiceConfig.ps1 into this file and save  
(Warning .. you need to add you 'client' hostname in the bottom of the script !)  
```
cd\
cd admin
psedit AudioServiceConfig.ps1
```

Now to create .MOF file for our client in in c:\admin\AudioServiceConfig  
```
cd\
cd admin
.\AudioServiceConfig.ps1
```

Rename the .MOF file with the GUID ID  
```
cd\
cd admin\AudioServiceConfig
Rename-Item .\"your client hostname".mof "$guidClient.mof"
```

This will generate a checksum .. so you will now have 2 .mof files for the client  
``` 
cd\
cd admin\AudioServiceConfig
New-DSCChecksum *
```

Now we need to move both .mof files into the correct folder so that the   
audio settings of our client will become 'automatic' ...   
this will happen approx 15 minutes after the transfer  
```
$destination = 'C:\Program Files\WindowsPowerShell\DscService\Configuration'
Copy 'C:\admin\AudioServiceConfig\*.mof*' -Destination $destination
```

To exit out of the ps session ... type  
`exit` 
















