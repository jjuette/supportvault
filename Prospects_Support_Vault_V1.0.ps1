cls
     write-host '                   ______      __              ___         __  
                  / ____/_  __/ /_  ___  _____/   |  _____/ /__Ã†
                 / /   / / / / __ \/ _ \/ ___/ /| | / ___/ //_/
                / /___/ /_/ / /_/ /  __/ /  / ___ |/ /  / ,<   
                \____/\___ /_____/\___/_/  /_/  |_/_/  /_/|_|  
                      ____/' -ForegroundColor green
write-host "#################################################################################"-ForegroundColor blue
write-host -nonewline -f blue "#";write-host -nonewline " Update Existing Prospects or Customer Locations in the Support Vault          ";write-host -f blue "#"
write-host -nonewline -f blue "#";write-host -nonewline " By Joe Juette                                                                 ";write-host -f blue "#"
write-host "#################################################################################"-ForegroundColor blue
write-host "#################################################################################"-ForegroundColor blue
#---Behind The Scenes 
#---get PACLI process 
$pacli = Get-Process pacli -ErrorAction SilentlyContinue;
#---Insure that PACLI is stopped
if ($pacli) 
{
  #---Shutdown
  & $PSScriptRoot\PACLI\pacli term
}
  ElseIf ($pacli) 
{ 
  #---kill
  Stop-Process -Name "pacli"
}
Remove-Variable pacli
#---Build PACLI Path to be used for commands based on powershell script location
$pacliPath = $PSScriptRoot + '\PACLI\pacli'
#---Init PACLI from where the script is being run from(The Pacli Directory must be in the same folder as this Script)
& $pacliPath init
#---PACLI Routines
#---Define Vault
    #---Support Vault
    #---$supVaultDef= "Support Vault"
    #---$supVaultAdd= "support.cyberark.com"
       <# 
        try {
            Set-Content .\DEFBat.bat "@echo off`n$pacliPath DEFINE VAULT=""$supVaultDef"" ADDRESS=""$supVaultAdd"""
            & .\DEFBat.bat
        } 
        catch {
              $error = $_.Exception.Message
              Write-Host "ERROR MESSAGE: $error"
        }
        finally {
                rm DEFBat.bat
        }
        #>
    #---End Support Vault Definition
    #---Hard-Coded Vault Definition
        & $pacliPath DEFINE VAULT="""Vault""" ADDRESS="""10.0.1.10"""
    #---End Hard-Coded Vault Definition
    #---From User Input
        #---User Inputs vars
        #---$usrVaultAdd = Read-Host "What is the Vault Address"#---Change to support.cyberark.com when using support vault only
        #---$usrVaultDef = Read-Host "What is the Defined Vault"
        <# 
        try {
            Set-Content .\USRDEFBat.bat "@echo off`n$pacliPath DEFINE VAULT=""$usrVaultDef"" ADDRESS=""$usrVaultAdd"""
            & .\USRDEFBat.bat
        } 
        catch {
              $error = $_.Exception.Message
              Write-Host "ERROR MESSAGE: $error"
        }
        finally {
                rm USRDEFBat.bat
        }
        #>
    #---End From User Input
#---Logon to Vault
    #---Login to Support Vault
        <# 
        Write-Host "Login to The Support Vault"
        $usrName = Read-host "Input Your Username: "
        $usrPasswd = Read-host "Input Your Password: " -AsSecureString
        $usrSecurePwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($usrPasswd))
     
            try {
                Set-Content .\SupLogBat.bat "@echo off`n$pacliPath LOGON VAULT=""$supVaultDef"" USER=""$usrName"" PASSWORD=""$usrSecurePwd"""
                & .\SupLogBat.bat
            } 
            catch {
                $error = $_.Exception.Message
                Write-Host "ERROR MESSAGE: $error"
            }
            finally {
                rm SupLogBat.bat
            }
        #>
    #---End Login to Support Vault
    #---Login to Vault by User Vault Input
        #---& $pacliPath LOGON VAULT="""$usrVaultDef""" USER="""$usrName""" PASSWORD="""$usrSecurePwd"""
    #---Login to Vault Hard-Coded Vault Def
        & $pacliPath LOGON VAULT="""Vault""" USER="""Administrator""" PASSWORD="""Cyberark1"""
        #---Hard Coded Var Delete When Done
$usrName="Administrator"
#---User Menu
function MainMenu{
    param ([string]$Title = 'Support Vault Functions')
    Write-Host "================ $Title ================"
    Write-Host "1: Press '1' to Add a new user to Support Vault "
    Write-Host "2: Press '2' to Update Existing Company Support Vault With a User"
    Write-Host "3: Press '3' to List Locations"
    Write-Host "4: Press '4' to reset Users Password"
    Write-Host "S: Press 'S' to search for Existing Users"
    Write-Host "Q: Press 'Q' To quit and Logoff."
}
do{
    Mainmenu
    $input = Read-Host "Please make a selection"
    switch ($input)
    {
        '1'{
            #---Adding New User to the Support Vault
                $newUsrName = Read-Host "Enter New Username (Users Email Address)"
            #---Generate a random password
            #---Usage: random-password <length>
                Function random-password ($length=15){
                    $punc = 46..46
                    $digits = 48..57
                    $letters = 65..90 + 97..122
                    $newPasswd = get-random -count $length `
                    -input ($punc + $digits + $letters) |
                    % -begin { $aa = $null } `
                    -process {$aa += [char]$_} `
                    -end {$aa}
                }
                
            #---End Random Password Generation
            $newUsrPasswd = random-password
            "Username:$newUsrName"| Out-File $PSScriptRoot\Logs\New_User.log -append
            "Password:$newUsrPasswd"| Out-File $PSScriptRoot\Logs\New_User.log -append
            #---Location stuff
                #---Build Location List
                    Function LocationList{
                        & $pacliPath LOCATIONSLIST VAULT="""Vault""" USER="""$usrName""" OUTPUT`(`NAME`) #---Change Vault to support vault var
                    }#---End Build Location List
                #---Build New Location Based off Input
                #---Enter Company Name
                NewLocation
                    Function NewLocation{
                    Write-Host ""
                    Write-Host ""
                        $newCompanyName = Read-Host "Enter The Company Name"
                    Write-Host ""
                    Write-Host ""
                    #---Place Built Location List in a Varable for search
                        $newCompanyLocSearch = LocationList
                    #---Search For Existing Company
                        $patternFound = select-string -pattern "$newCompanyName" -InputObject $newCompanyLocSearch
                            if ($patternFound -ne $null){
                                Write-Host "The Company Already Exists, You Must Update The Existing Company With The New User"
                                Write-Host ""
                                Write-Host ""
                               do{
                                Mainmenu
                               } until ($input -eq )
                            }
                        Else{
                    #---Create New Location Based on Company Name
                            try {
                                Write-Host = "The Company location is being created"
                                Set-Content .\ADDBat.bat "@echo off`n$pacliPath ADDLOCATION VAULT=""Vault"" USER=""$usrName"" LOCATION=""\Americas\Prospect Locations\$newCompanyName"""
                                & .\ADDBat.bat
                            } 
                            catch {
                                $error = $_.Exception.Message
                                Write-Host "ERROR MESSAGE: $error"

                            }
                            finally {
                                rm ADDBat.bat
                            }
                        }
                    }
                    #---End NewLocation Function
                    Function SafeList{
                        & $pacliPath SAFESLIST VAULT="""Vault""" USER="""$usrName""" OUTPUT`(`NAME`) #---Change Vault to support vault var
                    }
                    #---Creating New Safe
                    NewCompanySafe
                    Function NewCompanySafe{
                        $newCompanySafe = $newCompanyName
                    #---Place Built Safe List in a Varable for search
                        $newSafeSearch = SafeList
                    #---Search For Existing Company
                        $patternFound = select-string -pattern "$newCompanySafe" -InputObject $newSafeSearch
                            if ($patternFound -ne $null){
                                Write-Host = "The Safe Already Exists, You Must Update The Existing Company With The New User"
                                mainmenu
                            }
                        Else{
                    #---Create New Safe Based on Company Name
                            try {
                                Write-Host = "The Company Safe is being created"
                                Set-Content .\ADDSafeBat.bat "@echo off`n$pacliPath ADDSAFE VAULT=""Vault"" USER=""$usrName"" SAFE=""$newCompanySafe"""
                                & .\ADDSafeBat.bat
                            } 
                            catch {
                                $error = $_.Exception.Message
                                Write-Host "ERROR MESSAGE: $error"

                            }
                            finally {
                                rm ADDSafeBat.bat
                            }
                        }
                    }#---End Create New Safe
                    #---Add New User
                        $newAdduser = UserList
                        $patternFound = select-string -pattern "$newUsrName" -InputObject $newAdduser
                        if ($patternFound -ne $null){
                            Write-Host ""
                            Write-Host ""
                            Write-Host "The User Already Exists, You Must Update The User for Safe Ownership"
                            Write-Host ""
                            Write-Host ""
                            mainmenu
                        }
                        Else{
                             #---Create New User
                            try {
                                Write-Host = "The New User is being created"
                                Set-Content .\ADDUserBat.bat "@echo off`n$pacliPath ADDUSER VAULT=""Vault"" USER=""$usrName"" DESTUSER=""$newUsrName"" PASSWORD=""$newUsrName"""
                                & .\ADDUserBat.bat
                            } 
                            catch {
                                $error = $_.Exception.Message
                                Write-Host "ERROR MESSAGE: $error"

                            }
                            finally {
                                rm ADDUserBat.bat
                            }
                        }
                            mainmenu
                        
                        


        }
        #---End Menu Item 1
        #---Update Exiting Company Support Vault
        '2'{
            #---Create Location List output names to Variable
            $LocSearch = LocationList
            #---Get User Input of Company Name to update
            $CompanyName = Read-Host "Which Company would you like to update"
            #---Search Locations List Variable for Company Name
            $patternFound = select-string -pattern "$CompanyName" -InputObject $LocSearch
            if ($patternFound -eq $null){
                Write-Host = "The Company's Location Does Not Exist, You Must Create The Company's Location"
                Write-Host = "If You Think That The Location DOES Exist Please Login to PrivateArk Client to Verify"
                function CL-Menu{
                    
                    Write-Host = "1:Press'1' for Yes"
                    Write-Host = "2:Press'2' for No"
                }
                do{
                    CL-Menu
                    $clInput= Read-Host "Would You Like To Create One Now?"
                    switch ($clInput)
                    {
                        '1'{
                            NewLocation
                        }
                        '2'{
                        }
                    }
                }
                until (clInput -eq '2')
                mainmenu
            }
              
        }
    '3'{
    } 
    '4'{
    }
    's'{ 
        #---Search For Existing Users in the Vault
            #---Create Users List output users to variable
             #---Build Location List
                Write-Host = "Please wait while the existing users list is being created"
                Function UserList{
                    & $pacliPath USERSLIST VAULT="""Vault""" USER="""$usrName""" OUTPUT`(`NAME`) #---Change Vault to support vault var
                }#---End Build Location List
                #---Write UserList Function to Variable
                $usrSearch = UserList
                #---Search Users List Variable for Existing Users
                $findUsrName = Read-Host "Enter in the username on the Support Vault (Users Email Address)"
                #---Search For Existing Company
                $patternFound = select-string -pattern "$findUsrName" -InputObject $usrSearch
                    if ($patternFound -ne $null){
                        Write-Host ""
                        Write-Host ""
                        Write-Host "The User Already Exists, You Must Update The User for Safe Ownership"
                        Write-Host ""
                        Write-Host ""
                        mainmenu
                    }
                    Else{
                    Write-Host ""
                    Write-Host "" -ForegroundColor White -BackgroundColor DarkGray
                    Write-Host "User does not Exist, Please Add a New User" -ForegroundColor Yellow -BackgroundColor DarkGray
                    Write-Host "" -ForegroundColor White -BackgroundColor DarkGray
                    Write-Host ""
                    mainmenu
                    }

    }
 'q' 
{
#Logoff From Vault
#Disconnect-Vault  -vault """Vault""" -user """$usrName""" #---Change Vault to support vault var
#Stop Pacli process
#Stop-PACLI
}
}
pause
}
until ($input -eq 'q')