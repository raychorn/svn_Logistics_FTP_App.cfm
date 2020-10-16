<!--- BEGIN: Getting Code Re-Use from including this body of code in two different CFC's stored in two different folders --->
<cfscript>
	function _GetToken(str, index, delim) { // this is a faster GetToken() than GetToken()...
		var ar = -1;
		var retVal = '';
		ar = ListToArray(str, delim);
		try {
			retVal = ar[index];
		} catch (Any e) {
		}
		return retVal;
	}
</cfscript>
<!--- END! Getting Code Re-Use from including this body of code in two different CFC's stored in two different folders --->
