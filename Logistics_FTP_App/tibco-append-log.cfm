<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 60)#">

<cfparam name="nocache" type="string" default="">
<cfparam name="log_msg" type="string" default="">

<cfset is_running_detached = (Len(Trim(CGI.HTTP_REFERER)) eq 0)>

<cfif (NOT is_running_detached)>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
	<head>
		<cfoutput>
			<title>#Request.title_bar# (Tibco Append Log) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
			#Request.meta_vars#
		</cfoutput>
	
		<script language="JScript.Encode" src="js/loadJSCode_.js"></script>
	
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			loadJSCode("js/disable-right-click-script-III_.js");
			loadJSCode("js/MathAndStringExtend_.js");
		// --> 
		</script>
	
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
	
	<cfflush>
	
	<body>
</cfif>

<cfoutput>

	<cfscript>
		if (Len(Trim(log_msg)) gt 0) {
			Request.commonCode.appendFTPLogActivity('TIBCO_FTP_LOG', Now(), log_msg);
		}
	</cfscript>

</cfoutput>

<cfif (NOT is_running_detached)>
	</body>
	</html>
</cfif>
