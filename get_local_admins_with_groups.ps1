#written with ChatGPT help

$local_admin_group_name = "Administratoren"
$csvPath = "GroupMembers.csv"

# Function to recursively retrieve members of a group
function Get-GroupMembers {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName,
        
        [Parameter(Mandatory = $true)]
        [string]$GroupPath,
        
        [Parameter(Mandatory = $false)]
        [System.Collections.ArrayList]$MembersList = $null
    )
    
    # Get the group object
    $group = Get-ADGroup $GroupName
    
    # If the group object is found
    if ($group) {
        # Get the group members
        $members = Get-ADGroupMember -Identity $group -Recursive |
                   Where-Object { $_.objectClass -eq 'user' } |
                   Get-ADUser -Properties SamAccountName, DistinguishedName
        
        # Add the group members to the list
        foreach ($member in $members) {
            $MembersList.Add([PSCustomObject]@{
                'GroupName'   = $GroupName
                'GroupPath'   = $GroupPath
                'UserName'    = $member.SamAccountName.ToString()
            })
        }
        
        # Get the nested groups
        $nestedGroups = Get-ADGroupMember -Identity $group |
                        Where-Object { $_.objectClass -eq 'group' }
        
        # Recursively call the function for each nested group
        foreach ($nestedGroup in $nestedGroups) {
            $nestedGroupName = $nestedGroup.Name
            $nestedGroupPath = "$GroupPath\$nestedGroupName"
            
            Get-GroupMembers -GroupName $nestedGroupName -GroupPath $nestedGroupPath -MembersList $MembersList
        }
    }
}

$local_groups = Get-LocalGroupMember -name $local_admin_group_name | where {$_.ObjectClass -eq "Group"} |foreach {$_.name.Split('\')[1]}
#$local_groups = "APJPTKY Service Desk", "APAUMEL Service Desk"

# Create an empty ArrayList to store the results
$allMembers = [System.Collections.ArrayList]::new()

# Call the function to get all group members recursively
foreach ($groupName in $local_groups){
    Get-GroupMembers -GroupName $groupName -GroupPath $groupName -MembersList $allMembers
}

# Output the results
$allMembers | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Group members exported to: $csvPath"