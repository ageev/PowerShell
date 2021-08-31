$domainObj = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$PDC = ($domainObj.PdcRoleOwner).Name
$SearchString = "LDAP://"
$SearchString += $PDC + "/"
$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
$SearchString += $DistinguishedName
$DirSearcher = New-Object System.DirectoryServices.DirectorySearcher([adsi]$SearchString)
# get computers
#$DirSearcher.Filter = '(objectClass=Computer)'
#$DirSearcher.Filter = 'serviceprincipalname=*http*'
$DirSearcher.Filter = '(&(objectCategory=Person)(objectClass=User))'
$DirSearcher.FindAll().GetEnumerator() | %{ $_.Properties.name } 

# get all properties
$DirSearcher.FindAll().GetEnumerator() | %{ $_.Properties } 

#all win10 systems
$DirSearcher.FindAll().GetEnumerator() | %{ $_.Properties } | ?{$_.operatingsystem -eq "Windows 10 Pro" } |ft -Wrap
