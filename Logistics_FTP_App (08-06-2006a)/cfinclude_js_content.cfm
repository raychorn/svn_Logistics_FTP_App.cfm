<cfscript>
	_basePath = '';
	if (NOT IsDefined("Request.bool_dont_auto_adjust_content")) {
		Request.bool_dont_auto_adjust_content = false;
	}
	if (NOT Request.bool_dont_auto_adjust_content) {
		_basePath = Request.commonCode.dotDotPrefixForFileNamed(CGI.CF_TEMPLATE_PATH, 'js/disable-right-click-script-III.js');
	}
</cfscript>

<cfsavecontent variable="Request.js_content">
	<cfoutput>
		<script language="JavaScript1.2" type="text/javascript" src="#_basePath#js/disable-right-click-script-III.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="#_basePath#js/MathAndStringExtend.js"></script>
		<script language="JavaScript1.2" type="text/javascript" src="#_basePath#js/DHTMLWindows_obj.js"></script>
	</cfoutput>
</cfsavecontent>
