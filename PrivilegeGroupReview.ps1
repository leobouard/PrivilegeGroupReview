param(
    [Parameter(Mandatory)][string]$SearchBase,
    [ValidateSet('Base', 'OneLevel', 'Subtree')][string]$SearchScope = 'Subtree',
    [string[]]$TestRecipient
)

$groups = Get-ADGroup -SearchBase $SearchBase -SearchScope $SearchScope -LDAPFilter '(&(objectClass=Group)(managedBy=*))' -Properties ManagedBy, Description
$managers = $groups.ManagedBy | Sort-Object -Unique | ForEach-Object { Get-ADUser $_ -Properties EmailAddress }
$managers = $managers | Where-Object { $_.EmailAddress }
$baseBody = Get-Content -Path $PSScriptRoot\body.html -Encoding UTF8

$managers | ForEach-Object {
    $dn = $_.DistinguishedName
    $body = $baseBody
    $groups | Sort-Object Name | Where-Object { $_.ManagedBy -eq $dn } | ForEach-Object {
        $members = Get-ADGroupMember -Identity $_ -Recursive | ForEach-Object { Get-ADUser $_ -Properties LastLogonDate }
        $members = $members | Sort-Object Name | Select-Object Name, UserPrincipalName, Enabled, LastLogonDate
        if ($members) { $body += "<h3>$($_.Name)</h3><span>$($_.Description)</span>$($members | ConvertTo-Html -Fragment)" }
    }

    if ($body -like '*<h3>*') { 
        $body += "</body></html>"
        $splat = @{
            Body       = $body
            BodyAsHtml = $true
            Encoding   = 'UTF8'
            From       = 'noreply@domain.com'
            SmtpServer = 'smtp.domain.com'
            Subject    = '[IT] Privilege group review'
            To         = $_.EmailAddress
        }
        if ($TestRecipient) { $splat.To = $TestRecipient }
        Send-MailMessage @splat
    }
}
