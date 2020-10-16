<cfscript>
	_basePath = '';
	if (NOT IsDefined("Request.bool_dont_auto_adjust_content")) {
		Request.bool_dont_auto_adjust_content = false;
	}
	if (NOT Request.bool_dont_auto_adjust_content) {
		_basePath = Request.commonCode.dotDotPrefixForFileNamed(CGI.CF_TEMPLATE_PATH, 'js/loadJSCode_.js');
	}
</cfscript>

<cfsavecontent variable="Request.js_content">
	<cfoutput>
		<script language="JScript.Encode" src="#_basePath#js/loadJSCode_.js"></script>
	
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			loadJSCode("#_basePath#js/disable-right-click-script-III_.js");
			loadJSCode("#_basePath#js/MathAndStringExtend_.js");
			loadJSCode("#_basePath#js/DHTMLWindows_obj_.js");
		// --> 
		</script>
	</cfoutput>
</cfsavecontent>
