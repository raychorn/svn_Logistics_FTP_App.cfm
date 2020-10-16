<cfscript>
	Request.err_primitiveCode = false;
	Request.err_primitiveCodeMsg = '';
	try {
		Request.primitiveCode = CreateObject("component", "cfc.primitiveCode");
	} catch(Any e) {
		Request.err_primitiveCode = true;
		Request.err_primitiveCodeMsg = 'The primitiveCode component has NOT been created.';
		writeOutput('<font color="red"><b>#err_primitiveCodeMsg#</b></font><br>');
	}
</cfscript>

