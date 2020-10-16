<cfset Request.ownerIP1 = "192.168.100.235">
<cfset Request.ownerIP2 = "">

<cfset Request.ownerIPs = Request.ownerIP1 & "," & Request.ownerIP2>

<cfset Cr = Chr(13)>
<cfset Lf = Chr(10)>

<cfset Request.Cr = Cr>
<cfset Request.Lf = Lf>

<cfset Request.const_redacted_email_address_symbol = '@hotmail.com'>

<!--- BEGIN: Define this just in case the variable listed below fails to exists when it might be referenced... --->
<cfparam name="REQUEST.FULL_JS_CONTENT" type="string" default="">
<!--- END! Define this just in case the variable listed below fails to exists when it might be referenced... --->

<cfscript>
	Request.const_sizeOf_encrypted_encoded_array = 5;

	Request.const_localhost_symbol = 'localhost';
	
	Request.const_do_not_reply_symbol = 'do-not-reply@ez-ajax.com';
	
	Request.const_read_only_role_symbol = 'Read-Only';

	Request.const_forgot_cfm_symbol = '_forgot.cfm';
	Request.const_newuser_cfm_symbol = '_newuser.cfm';
	Request.const_chgPassword_cfm_symbol = '_chgPassword.cfm';

	Request.const_userName_token = '%userName%';
	
	Request.const_index_cfm_symbol = 'index.cfm';

	Request.const_required_marker_symbol = '<span class="errorStatusBoldClass">*</span>';

	function reseedRandomizer(bool) {
		msTC = GetTickCount();
		if (bool) {
			ms = msTC / (2147483647 / 32768);
			ms_ar = ListToArray(ms, '.');
			ms = ms_ar[1];
		} else {
			ms = msTC;
		}
	//	writeOutput('ms = [#ms#]<br>');
		try {
			Randomize(ms, 'SHA1PRNG');
		} catch (Any e) {
			if (NOT bool) { // do not allow this to get itself into an infinite loop...
				return reseedRandomizer(true); // retry using the laternate approach to rescale the seed value.
			}
		}
	}
	
	reseedRandomizer(false);
</cfscript>

<cfsavecontent variable="Request.sql_qGetSecretsForUser">
	<cfoutput>
		SELECT User_Access.id, User_Access.password, User_Access.secretPrompt, User_Access.secretResponse, 
		       User_Access.activated_dt, User_Access.rid, User_Access_Roles.role_name, User_Access_Roles.role_desc
		FROM User_Access INNER JOIN
		     User_Access_Roles ON User_Access.rid = User_Access_Roles.rid
		WHERE (User_Access.activated_dt IS NOT NULL) AND (UPPER(User_Access.username) = '#Request.const_userName_token#')
	</cfoutput>
</cfsavecontent>

<cfsavecontent variable="Request._html_logoutForm">
	<cfoutput>
		<span class="normalStatusClass">
		<a href="http://#CGI.SERVER_NAME#/#GetToken(CGI.SCRIPT_NAME, 1, "/")#/#Request.const_index_cfm_symbol#?nocache=#CreateUUID()#&action=logoff" target="_top"><b>Log-Off</b></a>
		</span>
	</cfoutput>
</cfsavecontent>
