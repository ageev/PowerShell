# Python script allows you to run powershell cmdlets
# This scipt will read user's name from CSV file and enrich it with appropriate Sam account name and email properties

import subprocess

args = ["powershell.exe", "-Command", r"-"]
filename = "c:\\_Python\\lab\\users.csv"
output = []
output_filename = "c:\\_Python\\lab\\users_details.csv"

def main():

    names = (line.rstrip("\n") for line in open(filename))

    for name in names:
        name = "'" + name + "'"
        output.append(name + ";" + get_samname(name) + ";" + get_email(name))

    with open(output_filename, 'w') as of:
        of.write("\n".join(output))

def get_samname(name):
    process = subprocess.Popen(args, stdin = subprocess.PIPE, stdout =   subprocess.PIPE)
    cmdlet = str.encode("Get-ADUser -Filter{displayName -like " + name + "} | select -ExpandProperty SamAccountName\r\n")
    process.stdin.write(cmdlet)
    samname = process.communicate()[0].decode("utf-8").replace("\r\n", "")
    return samname

def get_email(name):
    process = subprocess.Popen(args, stdin = subprocess.PIPE, stdout =   subprocess.PIPE)
    cmdlet = str.encode("Get-ADUser -Filter{displayName -like " + name + "} -Properties EmailAddress | select -ExpandProperty EmailAddress\r\n")
    process.stdin.write(cmdlet)
    email = process.communicate()[0].decode("utf-8").replace("\r\n", "")
    return email

main()
