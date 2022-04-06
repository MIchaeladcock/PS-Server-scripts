##
function Get-PSServiceStatus {

param (
    [string[]]$ComputerName,
)

$FromAddress = "PS-Script-Alert@domain.com"
$ToAddress = "user@email.com"
$SmtpServer="mail.smtp.com"

    # Test ping
workflow Test-Ping 
    {
        param( 
            [Parameter(Mandatory=$true)] 
            [string[]]$Computers
        )

        $FromAddress = "PS-Script-Alert@domain.com"
        $ToAddress = "user@domain.com"
        $SmtpServer="mail.smtp.com"

            foreach -parallel -throttlelimit 150 ($Computer in $Computers) 
            {
                if (Test-Connection -Count 1 $Computer -Quiet -ErrorAction SilentlyContinue) 
                {    
                    $Computer
                }
                else
                {
                    Write-Warning -Message "Server: $Computer is off-line"
                    Send-MailMessage -Body "$Computer is not online" -From $FromAddress -SmtpServer $SmtpServer -Subject "Server is Offline" -To $ToAddress
                }
            }
        }
    $ComputerName = Test-Ping -Computers $ComputerName 
    
     #-- Get Automatic Service that have stopped ---
    $EmailInfo =  ""
   
    $GetAllStoppedAutoServices = Get-Service -ComputerName $ComputerName | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped' -and $_.Name -ne 'RemoteRegistry' -and $_.Name -ne 'TrustedInstaller' -and $_.Name -ne 'sppsvc' -and $_.Name -ne 'ShellHWDetection' -and $_.Name -ne 'filebeat.old'}
    
    $GetAllStoppedAutoServices | forEach-Object{
            try{
                $StoppedAutoServices =  "'$($_.Name)' has been stopped on: '$($_.MachineName)' "
                #Write-Output "Automaic Service '$($_.Name)' has been stopped on: '$($ComputerName)'` "
                $EmailInfo = $StoppedAutoServices
                
                 
            }catch {
                 Write-Warning $Error[0]
            }
        

      if ($EmailInfo)
       {
            try{
                 Write-Output $EmailInfo
                 Send-MailMessage -Body "'$($EmailInfo)'" -From $FromAddress -SmtpServer $SmtpServer -Subject "Automatic service is not running" -To $ToAddress
            }catch{
                Write-Warning $Error[0]
            }
       }

    }
}

Get-PSServiceStatus("serverName1","serverName2","DoesNotExist")
