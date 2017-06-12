configuration AudioServiceConfig
{ 
    param([string[]] $computerName) 
 
    node $computerName 
    {    
        Service Audio 
        { 
            Name        = 'Audiosrv' 
            StartupType = 'Automatic' 
            State       = 'Running' 
        }    
    } 
} 
 
AudioServiceConfig -ComputerName "add your client hostname here" 