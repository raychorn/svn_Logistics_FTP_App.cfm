<cfscript>
	if (IsDefined("URL.title_bar")) {
		Request.title_bar = URL.title_bar & ' (Activate New User Account)';
		Request._title_bar = Request.title_bar;
	}
	
	if (IsDefined("URL.productVersion")) {
		Request.productVersion = URL.productVersion;
	}

	if (IsDefined("URL.DSN")) {
		Request.DSN = URL.DSN;
	}
</cfscript>

<cfparam name="context" type="string" default="">

<!--- BEGIN: This simply assumes the user who got the email is the user who should have gotten the email and therefore the user account is simply activated without question... --->
<cfscript>
//	context = Trim(context);
	Request.errorMsg = '<span class="errorStatusBoldClass">ERROR ##101: Invalid use !  Processing stops...</span>';
	if (Len(context) gt 0) {
		ar_context = Request.commonCode.decodeEncodedEncryptedString(context);
	//	writeOutput(Request.primitiveCode.cf_dump(ar_context, 'ar_context', false));
		if (ArrayLen(ar_context) eq Request.const_sizeOf_encrypted_encoded_array) {
			if (FindNoCase(Request.const_redacted_email_address_symbol, ar_context[Request.const_sizeOf_encrypted_encoded_array]) gt 0) {
				sql_statement = "SELECT activated_dt FROM User_Access WHERE (username = '#ar_context[5]#')";
				qChk = Request.primitiveCode.safely_execSQL('qCheckNewUserAcctActivation', Request.DSN, sql_statement);
				if ( (NOT Request.dbError) AND (IsQuery(qChk)) ) {
					if ( (qChk.recordCount gt 0) AND (IsDefined("qChk.activated_dt")) ) {
						bool_is_activated_dt_valid = true;
						try {
							if (IsDate(qChk.activated_dt)) { // fail if the date already exists !
								bool_is_activated_dt_valid = false;
								_activated_dt = ParseDateTime(qChk.activated_dt);
							}
						} catch (Any e) {
							bool_is_activated_dt_valid = false;
						}
						if (bool_is_activated_dt_valid) {
							// BEGIN: Perform the SQL here to flag this user account as having been activated...
							sql_statement = "UPDATE User_Access SET activated_dt = GetDate() WHERE (username = '#ar_context[5]#')";
							qq = Request.primitiveCode.safely_execSQL('qActivateNewUserAcct', Request.DSN, sql_statement);
							// END! Perform the SQL here to flag this user account as having been activated...
							if (NOT Request.dbError) {
								Request.errorMsg = '<span class="normalStatusClass">Confirmed, your new user account has been activated.</span>';

								// BEGIN: Send an email to the user to notify them of their password - the normal notification mechanism seems to be flawed...
								sql_statement = ReplaceNoCase(Request.sql_qGetSecretsForUser, Request.const_userName_token, UCASE(ar_context[5]));
								qSecrets = Request.primitiveCode.safely_execSQL('qGetSecretsForUser', Request.DSN, sql_statement);
								// END! Send an email to the user to notify them of their password - the normal notification mechanism seems to be flawed...
								if (NOT Request.dbError) {
									if (IsQuery(qSecrets)) {
										if ( (IsDefined("qSecrets.recordCount")) AND (IsDefined("qSecrets.secretPrompt")) ) {
											if ( (qSecrets.recordCount gt 0) AND (Len(qSecrets.secretPrompt) gt 0) ) {
												ar = Request.commonCode.decodeEncodedEncryptedString(URLDecode(qSecrets.password));
												if (ArrayLen(ar) eq Request.const_sizeOf_encrypted_encoded_array) {
													_password = ar[Request.const_sizeOf_encrypted_encoded_array];
													// BEGIN: Email the password to the user...
													Request.primitiveCode.safely_cfmail(ar_context[5], Request.const_do_not_reply_symbol, 'Welcome to the #Request._title_bar# Version #Request.productVersion#, this is your password.', 'Your password is (<b>#_password#</b>) however the "(" and ")" are <b>NOT</b> considered to be part of the password.<br>Please secure your password in a safe place.');
													// END! Email the password to the user...
													if (NOT Request.anError) {
														Request.bool_process_is_complete = true;
														html_status_content = 'Your password has been created and it has been emailed to you.  Your secret prompt and response remains the same as it was.';
														Request.errorMsg = Request.errorMsg & '<span class="normalStatusClass">' & html_status_content & '</span>';
													} else {
														Request.dbError = true;
														html_status_content = 'ERROR: Unable to email your password to you.  Perhaps the email server is down, check with your I.T. Dept then try again later-on.';
														Request.errorMsg = Request.errorMsg & '<span class="errorStatusBoldClass">' & html_status_content & '</span>';
													}
												}
											}
										}
									}
								}
							} else {
								Request.errorMsg = '<span class="errorStatusBoldClass">ERROR ##102: Invalid use !  Processing stops...</span>';
							}
						} else {
							Request.errorMsg = '<span class="normalStatusBoldClass">Your user account has already been activated - you may log-in at your liesure.</span>';
						}
					} else {
						Request.errorMsg = '<span class="errorStatusBoldClass">ERROR ##101.2: Invalid use !  Processing stops...</span>';
					}
				} else {
					Request.errorMsg = '<span class="errorStatusBoldClass">ERROR ##101.1: Invalid use !  Processing stops...</span>';
				}
			}
		}
	}
</cfscript>
<!--- END! This simply assumes the user who got the email is the user who should have gotten the email and therefore the user account is simply activated without question... --->

<cfinclude template="../cfinclude_Header.cfm">

<cfscript>
	writeOutput(Request.html_headerContent);

	writeOutput(Request.errorMsg);
</cfscript>

<cfinclude template="../Footer.cfm">
