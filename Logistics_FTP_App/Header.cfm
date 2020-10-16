<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfparam name="Request.bool_is_user_logged_in" type="boolean" default="False">

<cfscript>
	function performingHandleUserLogin() {
		if ( (NOT IsDefined("Request.is_handleUserLogin")) OR (NOT Request.is_handleUserLogin) ) {
			Request.is_handleUserLogin = true;
			Request.bool_is_user_logged_in = Request.primitiveCode._handleUserLogin(CGI.SCRIPT_NAME);
			Request.is_handleUserLogin = false;
		}
	}

	performingHandleUserLogin();
</cfscript>

<cfif 0>
	<cfoutput>
		Len(Request.js_content) = [#Len(Request.js_content)#], 
		<cfif (IsDefined("Request.isLoggedIn"))>
			Request.isLoggedIn = [#Request.isLoggedIn#], 
		</cfif>
		Request.bool_is_user_logged_in = [#Request.bool_is_user_logged_in#]<br>
		<cfif (IsDefined("Request.is_handleUserLogin"))>
			(IsDefined("Request.is_handleUserLogin")) = [#(IsDefined("Request.is_handleUserLogin"))#]<br>
		</cfif>
		(NOT Request.is_handleUserLogin) = [#(NOT Request.is_handleUserLogin)#]<br>
		<cfif (Len(Request.js_content))>
			<textarea readonly rows="10" cols="100" class="textClass">#Request.js_content#</textarea>
		</cfif>
	</cfoutput>
</cfif>

<cftry>
	<cflock timeout="300" throwontimeout="No" type="READONLY" scope="SESSION">
		<cfscript>
			if (IsDefined("Session.userParms")) {
				if (IsQuery(Session.userParms)) {
				//	writeOutput(Request.primitiveCode.cf_dump(Session.userParms, 'Session.userParms', false));
				}
			}
		</cfscript>
	</CFLOCK>

	<cfcatch type="Any">
	</cfcatch>
</cftry>

<cfif (Request.bool_is_user_logged_in) OR ( (IsDefined("Request.is_handleUserLogin")) AND (NOT Request.is_handleUserLogin) )>
	<cfif (Request.bool_is_user_logged_in)>
		<cfset Request.js_content = Request.full_js_content>
	</cfif>

	<cfinclude template="cfinclude_Header.cfm">

	<cfscript>
		if ( (IsDefined("Request.html_headerContent")) AND ( (NOT IsDefined("Request.bool_html_headerContent_delivered")) OR (NOT Request.bool_html_headerContent_delivered) ) ) {
			writeOutput(Request.html_headerContent);
			Request.bool_html_headerContent_delivered = true;
		}
	</cfscript>

	<cfif (IsDefined("Request.isLoggedIn"))>
		<cfscript>
			if (NOT Request.isLoggedIn) {
				_password = '';
				html_status_content = '';
			//	writeOutput('Request.isLoggedIn = [#Request.isLoggedIn#]<br>');
				if ( (UCASE(CGI.REQUEST_METHOD) eq "POST") AND (IsDefined("FORM.USERNAME")) AND (IsDefined("FORM.PASSWORD")) ) {
					if ( (Len(FORM.USERNAME) gt 0) AND (Len(FORM.PASSWORD) gt 0) ) {
					//	writeOutput('<small>FORM.USERNAME = [#FORM.USERNAME#], FORM.PASSWORD = [#FORM.PASSWORD#]</small><br>');
	
						sql_statement = ReplaceNoCase(Request.sql_qGetSecretsForUser, Request.const_userName_token, UCASE(FORM.USERNAME));
						qSecrets = Request.primitiveCode.safely_execSQL('qGetSecretsForUserLogin', Request.DSN, sql_statement);
	
						if (NOT Request.dbError) {
							if (IsQuery(qSecrets)) {
								if ( (IsDefined("qSecrets.recordCount")) AND (IsDefined("qSecrets.secretPrompt")) ) {
									if ( (qSecrets.recordCount gt 0) AND (Len(qSecrets.secretPrompt) gt 0) ) {
										ar = Request.commonCode.decodeEncodedEncryptedString(URLDecode(qSecrets.password));
										if (ArrayLen(ar) eq Request.const_sizeOf_encrypted_encoded_array) {
											_password = ar[Request.const_sizeOf_encrypted_encoded_array];
											
											if (FORM.PASSWORD eq _password) {
												// BEGIN: Flag the user logged-in here.
												if (Request.primitiveCode._flagUserLoggedIn()) {
													Request.dbError = false;
													html_status_content = 'INFO: Welcome to being logged-in successfully.';
													Request.primitiveCode.cf_location('http://' & CGI.SERVER_NAME & CGI.SCRIPT_NAME & '?nocache=' & CreateUUID());
												} else {
													Request.dbError = true;
													html_status_content = 'ERROR: Unable to complete the log-in process due to a system error.';
												}
												// END! Flag the user logged-in here.
											} else {
												Request.dbError = true;
												html_status_content = 'ERROR: Unable to authenticate your user credentials because the password you entered is not valid for the user account specified.';
											}
										} else {
											Request.dbError = true;
											html_status_content = 'ERROR: Unable to authenticate your user credentials due to a very serious error in the elements returned from the result set from the database.';
										}
									} else {
										Request.dbError = true;
										html_status_content = 'ERROR: Unable to authenticate your user credentials due to a serious error in the elements returned from the result set from the database.';
									}
								} else {
									Request.dbError = true;
									html_status_content = 'ERROR: Unable to authenticate your user credentials due to an error in the elements returned from the result set from the database.';
								}
							} else {
								Request.dbError = true;
								html_status_content = 'ERROR: Unable to authenticate your user credentials due to an error in the result set from the database.';
							}
						} else {
							Request.dbError = true;
							html_status_content = 'ERROR: Unable to authenticate your user credentials due to a database error.';
						}
						if (Request.dbError) {
							writeOutput('<span class="errorStatusClass"><big>#html_status_content#</big></span>');
						} else {
							writeOutput('<span class="normalStatusClass"><big>#html_status_content#</big></span>');
						}
					}
				}
				writeOutput(Request._html_loginForm);
			} else {
				if (IsDefined("URL.action")) {
					if (UCASE(URL.action) eq UCASE('logoff')) {
						Request.primitiveCode._flagUserLoggedOut();
						Request.primitiveCode.cf_location('http://' & CGI.SERVER_NAME & CGI.SCRIPT_NAME & '?nocache=' & CreateUUID());
					}
				}
				writeOutput(Request.html_headerContent);
			}
		</cfscript>
	</cfif>
</cfif>
