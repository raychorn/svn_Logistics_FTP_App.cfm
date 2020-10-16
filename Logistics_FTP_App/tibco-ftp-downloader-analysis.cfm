<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 5 * 2)#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Tibco FTP Background Job LaunchPad</title>

	<style>
		BODY {
			margin: 0px;
			padding: 0px;
			background-color: white;
			color: black;
			font-family: Verdana, Arial, Helvetica, sans-serif;
			font-size: xx-small;
		}
		
		.textareaClass {
			font-size: 10px;
		}

		.listItemClass {
			font-size: 10px;
		}

		.errorStatusClass {
			font-size: 10px;
			color: red;
		}

		.normalStatusClass {
			font-size: 10px;
			color: blue;
		}
	</style>

</head>

<body>

<cfflush>

<cfinclude template="cfinclude_tibco-ftp-downloader-analysis.cfm">

</body>
</html>
