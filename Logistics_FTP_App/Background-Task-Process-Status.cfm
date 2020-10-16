<cfsetting enablecfoutputonly="No" showdebugoutput="No">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Tibco FTP Background Job LaunchPad</title>

	<style>
		BODY {
			margin: 0px;
			padding: 0px;
			background-color: #FFFFB9;
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

		.normalClass {
			font-size: 10px;
		}

		.normalBoldClass {
			font-size: 10px;
			font-weight : bold;
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

<cfsavecontent variable="iframe_tags">
	<cfoutput>
		<br>
		<iframe src="tibco-ftp-downloader-process-status2.cfm?nocache=#Request.commonCode.uniqueTimeBasedUUID()#'" name="tibco_frame" id="tibco_frame" width="95%" height="30"></iframe>
	</cfoutput>
</cfsavecontent>

<span class="textClass"><b>Background Task Process Status:</b><br></span>
<cflock timeout="60" throwontimeout="No" name="serviceFactory" type="READONLY">
	<cfscript>
		factory = CreateObject("java", "coldfusion.server.ServiceFactory");
		
		allTasks = factory.CronService.listAll();
		numberOtasks = arraylen(allTasks);
		
		if (numberOtasks eq 0) {
			writeOutput('<span class="textClass">No Background Tasks have been scheduled.<hr color="blue"></span>');
		} else {
			for (i = 1; i lte numberOtasks; i = i + 1) {
				_details = Request.commonCode.schedulerLogLatestInfoFor(allTasks[i].task);
				_details = ReplaceNoCase(_details, 'IML_FTP_DOWNLOAD', Request.const_6_day_symbol & '_FTP_DOWNLOAD', 'all');
				_details = ReplaceNoCase(_details, 'TIBCO FTP DOWNLOADER 2', Request.const_31_day_symbol & ' FTP DOWNLOADER 2', 'all');

				_task_name = ReplaceNoCase(allTasks[i].task, 'IML_FTP_DOWNLOAD', Request.const_6_day_symbol & '_FTP_DOWNLOAD', 'all');
				_task_name = ReplaceNoCase(_task_name, 'TIBCO FTP DOWNLOADER 2', Request.const_31_day_symbol & ' FTP DOWNLOADER 2', 'all');
				
				if (FindNoCase(Request.const_cfprobe_symbol, _task_name) eq 0) {
					writeOutput('<span class="textClass">#_task_name#<br>[#_details#]</span>');
					if (LCASE(allTasks[i].task) eq LCASE('TIBCO FTP DOWNLOADER 2')) {
						writeOutput(iframe_tags);
					}
					writeOutput('<hr color="blue">');
				}
			}
		}
	</cfscript> 
</cflock>

</body>
</html>
