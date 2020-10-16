<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="120">

<cfparam name="nocache" type="string" default="">
<cfparam name="recid" type="string" default="-1">
<cfparam name="repName" type="string" default="">
<cfparam name="allow_dl" type="boolean" default="False">
<cfparam name="dm_id" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
		
<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (FTP Datamart Process) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>

	<script language="JavaScript1.2" type="text/javascript" src="js/disable-right-click-script-III.js"></script>
	<script language="JavaScript1.2" type="text/javascript" src="js/MathAndStringExtend.js"></script>

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
				<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj105.id);">
			</td>
			<td width="*" align="center">
				<span class="normalStatusClass">This is a development tool only !</span>
			</td>
			<td width="10%" align="right">
				<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj105.id);">
			</td>
		</tr>
	</table>
	
	<cfoutput>
		<cfset _url = 'ftp-datamart-processor.cfm?nocache=' & URLEncodedFormat(CreateUUID()) & '&recid=' & recid & '&repName=' & URLEncodedFormat(repName) & '&allow_dl=' & allow_dl & '&dm_id=' & URLEncodedFormat(dm_id)>
		<iframe name="myFrame" id="myFrame" src="#_url#" width="100%" height="95%"></iframe>
	</cfoutput>

</body>
</html>


