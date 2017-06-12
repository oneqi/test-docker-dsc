#test-docker-dsc
docker for windows and DSC

##Environment

This test lab uses Docker for Windows   
However, you can use the scripts in other test labs where you have 2 VMs / workstations  
iis01  
client  
Where iis01 is the DSC pull server (using basic HHTP) and your workstation is client (both joined to the same domain)  

We are using your workstation as the 'client' and a bridged network to communicate with the microsoft docker container.  
The image use will be microsoft/iis:latest and it will be labelled (called) iis01  
The bridged network will allow you to use the same network your client is on, i.e. no nat is involved and no port mappings  
On your workstation, place all scripts under c:\admin as we willuse this folder to share with iis01 container  

##Client

install latest ps DSC development tools  
```
Register-PSRepository -Name DockerPS-Dev -SourceLocation https://ci.appveyor.com/nuget/docker-powershell-dev
Install-Module Docker -Repository DockerPS-Dev
```








