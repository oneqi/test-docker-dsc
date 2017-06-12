configuration LCMPullMode 
{
    param 
    ( 
        [string]$ComputerName,
        [string]$GUID
    ) 

    node $ComputerName
    {    
        LocalConfigurationManager 
        { 
            ConfigurationID                = $GUID
            ConfigurationMode              = 'ApplyAndAutocorrect' 
            RefreshMode                    = 'Pull' 
            DownloadManagerName            = 'WebDownloadManager' 
            DownloadManagerCustomData = @{ 
               ServerUrl = 'http://dsc_iis01_1:8080/PSDSCPullServer.svc' 
               AllowUnsecureConnection = 'true' } 
            RebootNodeIfNeeded             = $true 
        } 
    } 
}

# e.g.LCMPullMode -ComputerName DESKTOP-F026CP4 -GUID 18ca85b8-1500-4aca-8f05-fbf61c1f48b0
LCMPullMode -ComputerName "add your client hostname here" -GUID $guidClient