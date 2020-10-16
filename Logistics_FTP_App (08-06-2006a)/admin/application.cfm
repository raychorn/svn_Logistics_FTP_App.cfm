<cfapplication name="redacted_IML_FTP_XML_Interface_User_Registration" clientmanagement="Yes" sessionmanagement="Yes" sessiontimeout="#CreateTimeSpan(0,8,0,0)#" applicationtimeout="#CreateTimeSpan(1,0,0,0)#" clientstorage="clientvars" scriptprotect="All" loginstorage="Session">

<cfinclude template="../cfinclude_application_const.cfm">

<cfinclude template="../cfinclude_meta_vars.cfm">

<cfinclude template="../cfinclude_commonCode.cfm">

<cfinclude template="../cfinclude_primitiveCode.cfm">

<cfscript>
	Request.const_try_again_btn_label = '[TRY AGAIN]';
	Request.const_submit_btn_label = '[SUBMIT]';

	Request.bool_is_forgotPage = (FindNoCase(Request.const_forgot_cfm_symbol, CGI.SCRIPT_NAME) gt 0);
	Request.bool_is_chgPwdPage = (FindNoCase(Request.const_chgPassword_cfm_symbol, CGI.SCRIPT_NAME) gt 0);
	Request.bool_is_newuserPage = (FindNoCase(Request.const_newuser_cfm_symbol, CGI.SCRIPT_NAME) gt 0);
	
	function is_forgot_page_missing_userName_password(_userName, _password) {
	//	writeOutput('<small>is_forgot_page_missing_userName_password :: (Request.bool_is_forgotPage) = [#(Request.bool_is_forgotPage)#], (Len(_userName) gt 0) = [#(Len(_userName) gt 0)#], (Len(_password) eq 0) = [#(Len(_password) eq 0)#]</small><br>');
		return ((Request.bool_is_forgotPage) AND (Len(_userName) eq 0) AND (Len(_password) eq 0)); // forgot password function requires the lack of a password...
	}

	function is_forgot_page_not_missing_userName_password(_userName, _password) {
	//	writeOutput('<small>is_forgot_page_not_missing_userName_password :: (Request.bool_is_forgotPage) = [#(Request.bool_is_forgotPage)#], (Len(_userName) gt 0) = [#(Len(_userName) gt 0)#], (Len(_password) eq 0) = [#(Len(_password) eq 0)#]</small><br>');
		return ((Request.bool_is_forgotPage) AND (Len(_userName) gt 0) AND (Len(_password) eq 0)); // forgot password function requires the lack of a password...
	}

	function is_chgPwd_page_missing_userName_password(_userName, _password) {
	//	writeOutput('<small>is_chgPwd_page_missing_userName_password :: (Request.bool_is_chgPwdPage) = [#(Request.bool_is_chgPwdPage)#], (Len(_userName) gt 0) = [#(Len(_userName) gt 0)#], (Len(_password) eq 0) = [#(Len(_password) eq 0)#]</small><br>');
		return ((Request.bool_is_chgPwdPage) AND (Len(_userName) eq 0) AND (Len(_password) neq 0)); // change password function requires the presence of a password...
	}

	function is_chgPwd_page_not_missing_userName_password(_userName, _password) {
	//	writeOutput('<small>is_chgPwd_page_not_missing_userName_password :: (Request.bool_is_chgPwdPage) = [#(Request.bool_is_chgPwdPage)#], (Len(_userName) gt 0) = [#(Len(_userName) gt 0)#], (Len(_password) eq 0) = [#(Len(_password) eq 0)#]</small><br>');
		return ((Request.bool_is_chgPwdPage) AND (Len(_userName) gt 0) AND (Len(_password) neq 0)); // change password function requires the presence of a password...
	}
</cfscript>

<cffunction name="UserRegistrationFormTop" access="public" returntype="string">
	<cfargument name="_userName_" type="string" required="yes">
	<cfargument name="_password_" type="string" required="yes">
	<cfargument name="_secretPrompt_" type="string" required="yes">
	<cfargument name="_secretResponse_" type="string" required="yes">
	<cfargument name="_new_password_" type="string" default="">

	<cfset var bool_is_forgot_page_missing_username_password = is_forgot_page_missing_userName_password(_userName_, _password_) OR is_chgPwd_page_missing_userName_password(_userName_, _password_)>
	<cfset var bool_is_forgot_page_not_missing_userName_password = is_forgot_page_not_missing_userName_password(_userName_, _password_) OR is_chgPwd_page_not_missing_userName_password(_userName_, _password_)>
	<cfset var bool_is_chgPwd_page_with_secret_response = "False">
	<cfset var _secretPrompt = "">
	<cfset var html_status_content = "">
	<cfset var ar = ArrayNew(1)>
	<cfset var BTN_SUBMIT = "">
	<cfset var actionVerb = "">
	<cfset var bool_okay_to_change_pwd = "False">

	<cfset Request.bool_process_is_complete = "False">

	<cfset Request.dbError = "False">
	
	<cfif (IsDefined("FORM.BTN_SUBMIT"))>
		<cfset BTN_SUBMIT = FORM.BTN_SUBMIT>
	</cfif>

	<cfscript>
		bool_is_SECRETRESPONSE = false;
		if (IsDefined("FORM.SECRETRESPONSE")) {
			if (Len(Trim(FORM.SECRETRESPONSE)) gt 0) {
				bool_is_SECRETRESPONSE = true;
			}
		}
		bool_is_chgPwd_page_with_secret_response = (Request.bool_is_chgPwdPage) AND (bool_is_SECRETRESPONSE);
		bool_is_chgPwd_page_with_secret_response = false;
	</cfscript>

	<cfif 0>
		<cfoutput>
		<small><b>bool_is_forgot_page_not_missing_userName_password = [#bool_is_forgot_page_not_missing_userName_password#],<br>
		bool_is_chgPwd_page_with_secret_response = [#bool_is_chgPwd_page_with_secret_response#], <br>
		_userName_ = [#_userName_#], _password_ = [#_password_#], _secretPrompt_ = [#_secretPrompt_#], _secretResponse_ = [#_secretResponse_#], _new_password_ = [#_new_password_#]<br>
		BTN_SUBMIT = [#BTN_SUBMIT#]<br>
		(UCASE(CGI.REQUEST_METHOD) neq "GET") = [#(UCASE(CGI.REQUEST_METHOD) neq "GET")#]<br>
		(NOT bool_form_method_is_like_get) = [#(NOT bool_form_method_is_like_get)#]<br>
		 </b></small>
		</cfoutput>
	</cfif>

	<cfif ( (bool_is_forgot_page_not_missing_userName_password) OR (bool_is_chgPwd_page_with_secret_response) ) AND (UCASE(BTN_SUBMIT) neq UCASE(Request.const_try_again_btn_label))>
		<cfscript>
			bool_okay_to_change_pwd = true;
			if ( (Request.bool_is_chgPwdPage) AND (Len(_password_) gt 0) AND (Len(_new_password_) gt 0) AND (_password_ eq _new_password_) ) {
				bool_okay_to_change_pwd = false;
			}
			
			if (bool_okay_to_change_pwd) {
				sql_statement = ReplaceNoCase(Request.sql_qGetSecretsForUser, Request.const_userName_token, UCASE(_userName_));
				qSecrets = Request.primitiveCode.safely_execSQL('qGetSecretsForUser', Request.DSN, sql_statement);
	
			//	writeOutput(Request.primitiveCode.cf_dump(qSecrets, 'qSecrets - [#sql_statement#]', false));
	
				html_status_content = 'ERROR: Unable to validate your credentials for this system.  Kindly retry using the correct credentials.';
				if (NOT Request.dbError) {
					if (IsQuery(qSecrets)) {
						if ( (IsDefined("qSecrets.recordCount")) AND (IsDefined("qSecrets.secretPrompt")) ) {
							if ( (qSecrets.recordCount gt 0) AND (Len(qSecrets.secretPrompt) gt 0) ) {
								if (bool_is_SECRETRESPONSE) {
									ar = Request.commonCode.decodeEncodedEncryptedString(URLDecode(qSecrets.secretResponse));
									if (ArrayLen(ar) eq Request.const_sizeOf_encrypted_encoded_array) {
										_secretResponse = ar[Request.const_sizeOf_encrypted_encoded_array];
	
										ar = Request.commonCode.decodeEncodedEncryptedString(URLDecode(qSecrets.secretPrompt));
										if (ArrayLen(ar) eq Request.const_sizeOf_encrypted_encoded_array) {
											_secretPrompt = ar[Request.const_sizeOf_encrypted_encoded_array];
										}
	
										if (FORM.SECRETRESPONSE eq _secretResponse) {
											// BEGIN: Password reset logic goes here...
											actionVerb = 'reset';
											bool_okay_to_change_pwd = true;
											if (Request.bool_is_forgotPage) {
												new_password = Request.commonCode.generateRandomStrongPassword();
											} else if (Request.bool_is_chgPwdPage) {
												if (_password_ eq _new_password_) {
													bool_okay_to_change_pwd = false;
												}
												new_password = _new_password_; // pull the changed password from the password entry field but compare with the old-password to make sure it is valid to make the change...
												actionVerb = 'changed';
											}
											_new_password = Request.commonCode.encodedEncryptedString(new_password);
	
											if (bool_okay_to_change_pwd) {
												sql_statement = "UPDATE User_Access SET password = '#URLEncodedFormat(_new_password)#' WHERE (activated_dt IS NOT NULL) AND (UPPER(username) = '#UCASE(_userName_)#')";
												qReset = Request.primitiveCode.safely_execSQL('qResetPwdForUser', Request.DSN, sql_statement);
												if (NOT Request.dbError) {
													// BEGIN: Email the password to the user...
													Request.primitiveCode.safely_cfmail(_userName_, Request.const_do_not_reply_symbol, 'Welcome back to the #Request._title_bar# Version #Request.productVersion#, this is your new password.', 'Your new password is (<b>#new_password#</b>) however the "(" and ")" are <b>NOT</b> considered to be part of the password.<br>Please secure your password in a safe place.');
													// END! Email the password to the user...
													if (NOT Request.anError) {
														Request.bool_process_is_complete = true;
														html_status_content = 'Your password has been #actionVerb# and it has been emailed to you.  Your secret prompt and response remains the same as it was.';
													} else {
														Request.dbError = true;
														html_status_content = 'ERROR: Unable to email your new password to you.  Perhaps the email server is down, check with your I.T. Dept then try again later-on.';
													}
												} else {
													Request.dbError = true;
													html_status_content = 'ERROR: Unable to #actionVerb# your password.  Perhaps the database is down, check with your I.T. Dept then try again later-on.';
												}
											} else {
												Request.dbError = true;
												html_status_content = 'ERROR: Unable to #actionVerb# your password because you are trying to make your new password the same as your old password and this is not allowed.';
											}
											// END! Password reset logic goes here...
										} else {
											Request.dbError = true;
											html_status_content = 'ERROR: Unable to validate your secret response.  Please try again using the correct information.';
										}
									} else {
										Request.dbError = true;
										html_status_content = 'ERROR: Unable to retrieve your secret response from this system.  Reason: System error - invalid data - the information may have been tampered with.';
									}
								} else {
									ar = Request.commonCode.decodeEncodedEncryptedString(URLDecode(qSecrets.secretPrompt));
									if (ArrayLen(ar) eq Request.const_sizeOf_encrypted_encoded_array) {
										_secretPrompt = ar[Request.const_sizeOf_encrypted_encoded_array];
										html_status_content = 'Please enter the secret response for the secret prompt you entered when your account was setup.';
									} else {
										Request.dbError = true;
										html_status_content = 'ERROR: Unable to retrieve your secret response from this system.  Reason: System error - invalid data - the information may have been tampered with.';
									}
								}
							} else {
								Request.dbError = true;
							}
						} else {
							Request.dbError = true;
							html_status_content = 'ERROR: Unable to validate your credentials for this system.  Reason: System error - missing data elements from query.';
						}
					} else {
						Request.dbError = true;
						html_status_content = 'ERROR: Unable to validate your credentials for this system.  Reason: System error - invalid query object.';
					}
				}
			} else {
				Request.dbError = true;
				html_status_content = 'ERROR: Unable to change your password because you are trying to make your new password the same as your old password and this is not allowed.';
			}
		</cfscript>
	</cfif>

	<cfsavecontent variable="html_UserRegistrationFormTop">
		<cfoutput>
			<form action="#CGI.SCRIPT_NAME#" method="post" name="myForm" id="myForm">
				<table border="1" width="500" align="center" cellpadding="-1" cellspacing="-1">
					<tr>
						<td>
							<table bgcolor="##FFFFB9" width="100%">
								<tr bgcolor="silver">
									<td align="center">
										<span class="instructionsClass"><BIG><b><cfif (Request.bool_is_forgotPage)>Forgot Password<cfelseif (Request.bool_is_chgPwdPage)>Change Password<cfelse>New User Registration</cfif></b></BIG>&nbsp;<i>(#Request.const_required_marker_symbol# indicates Required fields.)</i></span>
									</td>
								</tr>
								<tr>
									<td>
										<table width="100%">
											<tr>
												<td>
													<NOBR><span class="instructionsClass">User Name:</span></NOBR>
												</td>
												<td>
													<input type="text" class="textClass" <cfif (UCASE(CGI.REQUEST_METHOD) neq "GET") AND (NOT bool_form_method_is_like_get)>disabled</cfif> name="userName" id="userName" value="#_userName_#" size="30" maxlength="255">#Request.const_required_marker_symbol#
												</td>
												<td>
													<span class="instructionsClass">(This is your redacted email address.)</span>
												</td>
											</tr>
											<cfif (NOT Request.bool_is_newuserPage)>
												<cfif (NOT Request.bool_is_forgotPage) OR (Request.bool_is_chgPwdPage)>
													<tr>
														<td>
															<NOBR><span class="instructionsClass"><cfif (Request.bool_is_chgPwdPage)>Old </cfif>Password:</span></NOBR>
														</td>
														<td>
															<input type="password" class="textClass" <cfif ( (Request.bool_is_forgotPage) AND (UCASE(CGI.REQUEST_METHOD) neq "GET") AND (NOT bool_form_method_is_like_get) ) OR ( (Request.bool_is_chgPwdPage) AND (Len(_password_) gt 0) )>disabled</cfif> name="password" id="password" value="#_password_#" size="20" maxlength="50">#Request.const_required_marker_symbol#
														</td>
														<td>
															<span class="instructionsClass">(This is your <cfif (Request.bool_is_chgPwdPage)>old </cfif>password.)</span>
														</td>
													</tr>
													<cfif (Request.bool_is_chgPwdPage)>
														<tr>
															<td>
																<NOBR><span class="instructionsClass">New Password:</span></NOBR>
															</td>
															<td>
																<input type="password" class="textClass" <cfif ( (Request.bool_is_forgotPage) AND (UCASE(CGI.REQUEST_METHOD) neq "GET") AND (NOT bool_form_method_is_like_get) ) OR ( (Request.bool_is_chgPwdPage) AND (Len(_new_password_) gt 0) )>disabled</cfif> name="new_password" id="new_password" value="#_new_password_#" size="20" maxlength="50">#Request.const_required_marker_symbol#
															</td>
															<td>
																<span class="instructionsClass">(This is your new password.)</span>
															</td>
														</tr>
														<cfif (UCASE(CGI.REQUEST_METHOD) neq "GET") AND (NOT bool_form_method_is_like_get)>
															<!--- BEGIN: disabled fields are not passed-thru --->
															<input type="hidden" name="password" value="#_password_#">
															<input type="hidden" name="new_password" value="#_new_password_#">
															<!--- END! disabled fields are not passed-thru --->
														</cfif>
													</cfif>
												</cfif>
											</cfif>

											<cfif (Request.bool_is_forgotPage) OR ( (Request.bool_is_chgPwdPage) AND (Len(_password_) gt 0) AND (Len(_new_password_) gt 0) ) OR (Request.bool_is_newuserPage)>
												<tr>
													<td colspan="3" id="td_forgot_questions" style="<cfif (bool_is_forgot_page_missing_username_password) OR (Request.dbError)>display: none;<cfelse>display: inline;</cfif>">
														<table width="100%">
															<tr>
																<td>
																	<NOBR><span class="instructionsClass">Secret Prompt:</span></NOBR>
																</td>
																<td>
																<cfif (NOT Request.bool_is_forgotPage) AND (NOT Request.bool_is_chgPwdPage)>
																	<input type="text" class="textClass" <cfif (UCASE(CGI.REQUEST_METHOD) neq "GET") AND (NOT bool_form_method_is_like_get)>disabled</cfif> name="secretPrompt" id="secretPrompt" value="#_secretPrompt_#" size="30" maxlength="50">#Request.const_required_marker_symbol#
																<cfelse>
																	<span class="instructionsClass"><NOBR><b>#_secretPrompt#</b></NOBR><br></span>
																</cfif>
																</td>
																<td>
																	<span class="instructionsClass">(This is the prompt for the secret response that will be used to authenticate you in case you have forgotten your password.)<br></span>
																</td>
															</tr>
															<tr>
																<td>
																	<NOBR><span class="instructionsClass">Secret Response:</span></NOBR>
																</td>
																<td>
																	<input type="password" class="textClass" <cfif ( (UCASE(CGI.REQUEST_METHOD) neq "GET") AND (NOT bool_form_method_is_like_get) ) AND ( (Request.dbError) OR (Request.bool_process_is_complete) )>disabled</cfif> name="secretResponse" id="secretResponse" value="#_secretResponse_#" size="20" maxlength="50">#Request.const_required_marker_symbol#
																</td>
																<td>
																	<span class="instructionsClass">(This is the secret response for the secret prompt that will be used to authenticate you in case you have forgotten your password.)<br></span>
																</td>
															</tr>
														</table>
													</td>
												</tr>
											</cfif>
										</table>
									</td>
								</tr>
								<tr>
									<td colspan="2" align="center">
										<cfif (NOT Request.dbError)>
											<span class="normalStatusClass"><big>#html_status_content#</big></span>
										<cfelse>
											<span class="errorStatusBoldClass"><big><i>#html_status_content#</i></big></span>
										</cfif>
									</td>
								</tr>
								<cfif (Request.dbError)>
									<tr>
										<td colspan="2" align="center">
											#Request.commonCode.hiddenInputsUsingStruct(URL)#
											<input type="submit" class="buttonClass" name="btn_submit" id="btn_submit" value="#Request.const_try_again_btn_label#">
										</td>
									</tr>
								</cfif>
		</cfoutput>
	</cfsavecontent>

	<cfreturn html_UserRegistrationFormTop>
</cffunction>

<cfsavecontent variable="html_UserRegistrationFormBottom">
	<cfoutput>
						</table>
					</td>
				</tr>
			</table>
		</form>
	</cfoutput>
</cfsavecontent>
