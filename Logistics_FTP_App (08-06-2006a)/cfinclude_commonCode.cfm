<cfscript>
	Request.err_commonCode = false;
	Request.err_commonCodeMsg = '';
	try {
	   Request.commonCode = CreateObject("component", "cfc.commonCode");
	} catch(Any e) {
		Request.err_commonCode = true;
		Request.err_commonCodeMsg = 'The commonCode component has NOT been created.';
		writeOutput('<font color="red"><b>#Request.err_commonCodeMsg#</b></font><br>');
	}

	Request.urlPrefix = Request.commonCode._GetToken(CGI.SCRIPT_NAME, 1, '/');
	if (FindNoCase('.cfm', Request.urlPrefix) gt 0) {
		Request.urlPrefix = ListDeleteAt(Request.urlPrefix, ListLen(Request.urlPrefix, '/'), '/');
	}
</cfscript>
