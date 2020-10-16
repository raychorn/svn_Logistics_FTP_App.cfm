<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="120">

<cfparam name="nocache" type="string" default="">
<cfparam name="recid" type="string" default="-1">
<cfparam name="repName" type="string" default="">
<cfparam name="sDate" type="string" default="">
<cfparam name="sDataSrc" type="string" default="">
<cfparam name="sFilePath" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
		
<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (FTP Logs Report) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
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

		.buttonClass {
			font-size: 10px;
			font-weight: bold;
		}

	</style>
</head>

<body>

	<table width="100%" align="center" cellpadding="-1" cellspacing="-1">
		<tr>
			<td width="10%" align="left">
				<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj106.id);">
			</td>
			<td width="*" align="center">
				<span class="normalStatusClass"></span>
			</td>
			<td width="10%" align="right">
				<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj106.id);">
			</td>
		</tr>
	</table>
	
	<cfoutput>
		<cfset _url = 'ftp-logs-content.cfm?nocache=' & URLEncodedFormat(CreateUUID()) & '&recid=' & recid & '&repName=' & URLEncodedFormat(repName) & '&sDate=' & sDate & '&sDataSrc=' & sDataSrc & '&sFilePath=' & sFilePath>
		<iframe name="myFrame" id="myFrame" src="#_url#" width="100%" height="95%"></iframe>
	</cfoutput>

</body>
</html>


