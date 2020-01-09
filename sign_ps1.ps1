# which file to sign?
$ToSignFile = "c:\Temp\MyScript"

$CertificateName = "Artyom's Signing Certificate"
$MyStrongPassword = ConvertTo-SecureString -String "<password>" -Force -AsPlainText
$CertFile = "C:\Temp\MyNewSigningCertificate.pfx"

$MyCertFromPfx = Get-PfxCertificate -FilePath $CertFile

# generate cert
New-SelfSignedCertificate -subject $CertificateName -Type CodeSigning  | Export-PfxCertificate -FilePath $CertFile -password $MyStrongPassword 
Write-Output "PFX Certificate `"$CertificateName`" exported: $CertFile"

# sign file
Set-AuthenticodeSignature -PSPath $ToSignFile -Certificate $MyCertFromPfx

# import cert to certificate store (root is enough, trustedpublisher to supress warning)
Import-PfxCertificate -FilePath $OutPutPFXFilePath -CertStoreLocation "cert:\LocalMachine\Root" -Password $MyStrongPassword 
Import-PfxCertificate -FilePath $OutPutPFXFilePath -CertStoreLocation "cert:\LocalMachine\TrustedPublisher" -Password $MyStrongPassword