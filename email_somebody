<#
.SYNOPSIS
Sends email

.DESCRIPTION
sends email

.PARAMETER $SenderEmail
email address of sender

.PARAMETER $RecipientEmail
email address of recipient

.INPUTS
System.String

.OUTPUTS
System.String

.EXAMPLE
.EXAMPLE
.LINK
#>
function Email_Somebody {
	[CmdletBinding()]
	Param(
	[Parameter(Position=0, Mandatory=$true)]
	[System.String]
	$RecipientEmail,
	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$EmailAccount = "tourmalet_sysops@outlook.com",
	[Parameter(Position=3, Mandatory=$false)]
	[System.String]
	$Email_Subject = " ",
	[Parameter(Position=4, Mandatory=$false)]
	[System.String]
	$Email_Message = " "
)
	
	
	begin {
		try {
			Write-Host "in begin"
			
		}
		catch {
			Write-Host "in begin catch"
		}
	}
	process {
		try {
			Write-Host "In process try"
			$Email = New-Object -comcobject "CDO.Message"
			$Server = "smtp-mail.outlook.com" #SMTP server name or IP

			$Email.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
			$Email.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = $Server
			$Email.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
			$Email.Configuration.Fields.Update()

			$Email.From = $EmailAccount
			$Email.To = $RecipientEmail
			$Email.Subject = $Email_Subject
			$Email.Textbody = $Email_Message
			$Email.Send()
			
			$Username = $EmailAccount
			$Sender_Email = $EmailAccount
			$Password = Read-Host -Prompt "Enter password" -AsSecureString
			
			$SMTPServer = "smtp-mail.outlook.com"

			$message = New-Object System.Net.Mail.MailMessage ($SenderEmail, $RecipientEmail)
			$message.Subject = $Email_Subject
			$message.Body = $Email_Message
			$client = New-Object System.Net.Mail.SmtpClient ($SMTPServer)
			$credential = New-Object System.Net.NetworkCredential  
			$credential.UserName = $Username
			$credential.Password = $Password
			$client.Credentials = $credential
			$client.Send($message)	
		}
		catch {
			Write-Host "Didn't work"
		}
	}
	end {
		try {
		}
		catch {
		}
	}

	
}
