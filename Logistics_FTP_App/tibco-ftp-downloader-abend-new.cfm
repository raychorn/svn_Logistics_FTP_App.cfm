<cfsetting enablecfoutputonly="No" showdebugoutput="No">

<cfscript>
	toAddrs = 'Ray_Horn@redacted.com';
	fromAddrs = Request.const_do_not_reply_symbol;
	theSubj = 'The Tibco FTP Download Process has abended - however this simply means it ran out of work to do until next time.';
</cfscript>

<cfset mailErr = "False">
<cftry>
	<cfmail to="#toAddrs#" from="#fromAddrs#" subject="#theSubj#" type="HTML">
		<b>#DateFormat(Now(), "mm/dd/yyyy")# #TimeFormat(Now(), "HH:mm:ss tt")#</b><br>
		<b>#theSubj#</b>
	</cfmail>

	<cfcatch type="Any">
		<cfset mailErr = "True">
	</cfcatch>
</cftry>

<cfscript>
	if (NOT mailErr) {
		writeOutput('<font color="blue"><b>Your Email was sent...</b></font>');
	} else {
		writeOutput('<font color="red"><b>Your Email was not sent...</b></font>');
	}
</cfscript>
