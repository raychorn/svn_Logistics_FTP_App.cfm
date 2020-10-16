<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<cfparam name="URL.btnId" type="string" default="">
<cfparam name="URL.repType" type="string" default="">

<cfscript>
	if (Len(Trim(URL.repType)) gt 0) {
		Request.commonCode.performFtpServerAnalysis(URL.repType, URL.repType, false);
		
		btn_disabled = '';
		if (NOT IsDefined("Request.thisColor_ftpServerAnalysis")) {
			Request.thisColor_ftpServerAnalysis = 'silver';
			btn_disabled = 'disabled';
		}
		Request.thisColorStyle_ftpServerAnalysis = 'background-color: #Request.thisColor_ftpServerAnalysis#;';
		if (UCASE(Mid(Request.thisColor_ftpServerAnalysis, 2, 2)) eq UCASE('ff')) {
			Request.thisColorStyle_ftpServerAnalysis = 'color: #Request.thisColor_ftpServerAnalysis#;';
		}
	
		if (Len(Trim(URL.btnId)) gt 0) {
			writeOutput('<small>URL.repType = [#URL.repType#], URL.btnId = [#URL.btnId#], const_6_day_symbol = [#Request.const_6_day_symbol#], btn_disabled = [#btn_disabled#], Request.thisColorStyle_ftpServerAnalysis = <font color="#Request.thisColor_ftpServerAnalysis#">[#Request.thisColorStyle_ftpServerAnalysis#]</font></small><br>');
		}
	} else {
		writeOutput('<font color="red"><small><b>ERROR: Programming error...</b></small></font><br>');
	}
</cfscript>

<cfoutput>
	<script language="JavaScript1.2" type="text/javascript">
	<!--
		var _btnId = '#URL.btnId#';
		var _btnDisabled = '#btn_disabled#';
		var _btnStyles = '#Request.thisColorStyle_ftpServerAnalysis#';
		if (parent.callbackNotifyParentServerAnalysis) {
			parent.callbackNotifyParentServerAnalysis(_btnId, _btnDisabled, _btnStyles);
		} else {
			alert('Programming ERROR: This should never happen however if it does and you are reading this message then kindly notify the developer(s) that something terrible just happened. Reason: Cannot find the JavaScript Object named "parent.callbackNotifyParentServerAnalysis".  Thx.');
		}
	// --> 
	</script>
</cfoutput>
