<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 60)#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Tibco FTP Background Job LaunchPad</title>
</head>

<body>

<cfdirectory action="LIST" directory="C:\" name="qFileHound" filter="tibco-ftp-runner.exe" recurse="Yes">

<cfscript>
	if (IsQuery(qFileHound)) {
		writeOutput(Request.primitiveCode.cf_dump(qFileHound, 'qFileHound', true));
	} else {
	}
</cfscript>

<cfinclude template="cfinclude_tibco-ftp-downloader-analysis.cfm">

<cfexecute name = "C:\Program Files\tibco-ftp-runner\tibco-ftp-runner.exe"
	arguments = "" 
	outputFile = ""
	timeout = "0">
</cfexecute>

</body>
</html>
