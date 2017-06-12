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
The image used will be microsoft/iis:latest and it will be labelled 'iis01'    
The bridged network will allow you to use the same network your client is on, i.e. no nat is required   
On your workstation (client), place all scripts under c:\dsc, i.e.  
AudioServiceConfig.ps1  
CreatePullServer.ps1  
LCMPullMode .ps1  
docker-compose.yml  

## Client

install latest powershell DSC development tools  
```
Register-PSRepository -Name DockerPS-Dev -SourceLocation https://ci.appveyor.com/nuget/docker-powershell-dev
Install-Module Docker -Repository DockerPS-Dev
```

### Bridged Network on Docker for Windows

check for bridged network in existing list  
`docker network list`

if missing, create bridge network using transparent driver   
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

 












