<!--- 
	Programmer Notes:
	
		This one file would have been split into several files to allow for error and exception handling
		such as when the user enteres incorrect information and the like.  Reuse has been leveraged to
		save maintenance time later on even though it may take a little more time on the front-end to
		produce the code the savings during periods of maintenance will more than pay for this effort.
 --->
<cfscript>
	if (IsDefined("URL.title_bar")) {
		Request.title_bar = URL.title_bar & ' (New User Account)';
		Request._title_bar = Request.title_bar;
	} else if (IsDefined("FORM.title_bar")) {
		Request.title_bar = FORM.title_bar & ' (Register New User Account)';
		Request._title_bar = Request.title_bar;
	}
	
	if (IsDefined("URL.productVersion")) {
		Request.productVersion = URL.productVersion;
	} else if (IsDefined("FORM.productVersion")) {
		Request.productVersion = FORM.productVersion;
	}

	if (IsDefined("URL.DSN")) {
		Request.DSN = URL.DSN;
	} else if (IsDefined("FORM.productVersion")) {
		Request.DSN = FORM.DSN;
	}
	
//	bool_isLocalServer = Request.commonCode.isServerLocal();
	bool_isLocalServer = false;
</cfscript>

<cfparam name="userName" type="string" default="">
<cfparam name="password" type="string" default="">
<cfparam name="secretPrompt" type="string" default="">
<cfparam name="secretResponse" type="string" default="">

<cfparam name="_persistent_data_list" type="string" default="">

<!--- BEGIN: When doing a POST make sure the URL scope is seeded with the proper values to allow the rest of this code become reusable throughout the lifecycle of this form's use... --->
<cfif (UCASE(CGI.REQUEST_METHOD) neq "GET")>
	<cfscript>
		if ( (IsDefined("URL")) AND (IsStruct(URL)) AND (StructIsEmpty(URL)) AND (ListLen(_persistent_data_list, ',') gt 0) ) {
			m = Request.commonCode.seedStructFromScopeUsingList(URL, FORM, _persistent_data_list, ',');
		}
	</cfscript>
</cfif>
<!--- END! When doing a POST make sure the URL scope is seeded with the proper values to allow the rest of this code become reusable throughout the lifecycle of this form's use... --->

<cfscript>
	bool_form_method_is_like_get = false;
	if (IsDefined("FORM.btn_submit")) {
		if (UCASE(FORM.btn_submit) eq UCASE(Request.const_try_again_btn_label)) {
			bool_form_method_is_like_get = true;
		}
	}
</cfscript>

<cfinclude template="../cfinclude_js_content.cfm">

<cfinclude template="../cfinclude_Header.cfm">

<cfscript>
	userName = Trim(userName);
	password = Request.commonCode.generateRandomStrongPassword();
	secretPrompt = Trim(secretPrompt);
	secretResponse = Trim(secretResponse);
</cfscript>

<cfsavecontent variable="html_NewUserRegistration">
	<cfoutput>
		#UserRegistrationFormTop(userName, password, secretPrompt, secretResponse)#
		<cfif (UCASE(CGI.REQUEST_METHOD) eq "GET") OR (bool_form_method_is_like_get)>
			<tr>
				<td colspan="2" align="center">
					#Request.commonCode.hiddenInputsUsingStruct(URL)#
					<input type="submit" class="buttonClass" name="btn_submit" id="btn_submit" value="#Request.const_submit_btn_label#">
				</td>
			</tr>
		<cfelse>
			<cfscript>
				Request.isPKviolation = false; // this value is needed later-on such as whenever the actual SQL statement is not executed...

				if ( (Len(userName) gt 0) AND (Len(password) gt 0) AND (Len(secretPrompt) gt 0) AND (Len(secretResponse) gt 0) ) {
					if (FindNoCase(Request.const_redacted_email_address_symbol, userName) gt 0) {
						_password = Request.commonCode.encodedEncryptedString(password);
					//	ar_password = Request.commonCode.decodeEncodedEncryptedString(_password);
					//	writeOutput('<small>INFO: _password = [#_password#]</small><br>' & Request.primitiveCode.cf_dump(ar_password, 'ar_password', false));

						_secretPrompt = Request.commonCode.encodedEncryptedString(secretPrompt);
					//	ar_secretPrompt = Request.commonCode.decodeEncodedEncryptedString(_secretPrompt);
					//	writeOutput('<small>INFO: _secretPrompt = [#_secretPrompt#]</small><br>' & Request.primitiveCode.cf_dump(ar_secretPrompt, 'ar_secretPrompt', false));

						_secretResponse = Request.commonCode.encodedEncryptedString(secretResponse);
					//	ar_secretResponse = Request.commonCode.decodeEncodedEncryptedString(_secretResponse);
					//	writeOutput('<small>INFO: _secretResponse = [#_secretResponse#]</small><br>' & Request.primitiveCode.cf_dump(ar_secretResponse, 'ar_secretResponse', false));

						// encrypted password encoding technique - [byte-count][theKey][byte-count][encrypted] where [byte-count] is a single char
						sql_statement = "SELECT rid FROM User_Access_Roles WHERE (UPPER(role_name) = '#UCASE(Request.const_read_only_role_symbol)#')";
						qRid = Request.primitiveCode.safely_execSQL('qGetNewUserRole', Request.DSN, sql_statement);

						if (NOT Request.dbError) {
							if ( (IsQuery(qRid)) AND (IsDefined("qRid.rid")) ) {
								if ( (qRid.recordCount gt 0) AND (IsNumeric(qRid.rid)) ) {
									sql_statement = "INSERT INTO User_Access (username, password, secretPrompt, secretResponse, rid) VALUES ('#Request.commonCode.filterQuotesForSQL(userName)#','#URLEncodedFormat(_password)#','#URLEncodedFormat(_secretPrompt)#','#URLEncodedFormat(_secretResponse)#', #qRid.rid#); SELECT @@IDENTITY as id;";
									qq = Request.primitiveCode.safely_execSQL('qSaveNewUserData', Request.DSN, sql_statement);
								} else {
									qq = -1; // flag this as a failed process...
									Request.dbError = true; // allow the following message to be displayed below...
									Request.errorMsg = 'Programming Error - Unable to Register this user.  Reason: Unable to determine the Users Role Id because of invalid result set (is empty).';
								}
							} else {
								qq = -1; // flag this as a failed process...
								Request.dbError = true; // allow the following message to be displayed below...
								Request.errorMsg = 'Programming Error - Unable to Register this user.  Reason: Unable to determine the Users Role Id because of faulty result set.';
							}
						} else {
							qq = -1; // flag this as a failed process...
							Request.dbError = true; // allow the following message to be displayed below...
							Request.errorMsg = 'Programming Error - Unable to Register this user.  Reason: Unable to determine the Users Role Id.';
						}
					} else {
						qq = -1; // flag this as a failed process...
						Request.dbError = true; // allow the following message to be displayed below...
						Request.errorMsg = 'The username entered is not a valid redacted email address and therefore cannot be used.  Kindly try again using a valid redacted email address for your username.';
					}
				} else {
					qq = -1; // flag this as a failed process...
					Request.dbError = true; // allow the following message to be displayed below...
					Request.errorMsg = 'Unknown or unhandled Error condition that resulted from programming problems.';
					if (Len(userName) eq 0) {
						Request.errorMsg = 'The username cannot be left blank.';
					} else if (Len(password) eq 0) {
						Request.errorMsg = 'The password cannot be left blank.';
					} else if (Len(secretPrompt) eq 0) {
						Request.errorMsg = 'The secret prompt cannot be left blank.';
					} else if (Len(secretResponse) eq 0) {
						Request.errorMsg = 'The secret response cannot be left blank.';
					}
				}
			</cfscript>

			<cfsavecontent variable="html_activateAccountLink">
				<cfscript>
					query_string = '';
					if ( (IsDefined("URL")) AND (IsStruct(URL)) AND (NOT StructIsEmpty(URL)) ) {
						query_string = Request.commonCode.queryStringUsingScope(URL);
					} else if ( (IsDefined("FORM")) AND (IsStruct(FORM)) AND (NOT StructIsEmpty(FORM)) AND (ListLen(_persistent_data_list, ',') gt 0) ) {
						query_string = Request.commonCode.queryStringUsingScopeFromList(FORM, _persistent_data_list, ',');
					}
					_userName = Request.commonCode.encodedEncryptedString(userName);
					query_string = query_string & '&context=' & URLEncodedFormat(_userName);
				</cfscript>

				<cfoutput>
					<cfif (bool_isLocalServer)>
						<span class="instructionsClass"><i>(The following appears ONLY when run on the local dev server otherwise an email is sent.)</i></span><hr width="80%" color="blue">
					</cfif>
					Click <a href="#Request.commonCode.suppressURLSlashSlash(Request.commonCode.fullyQualifiedServerName(), ListDeleteAt(CGI.SCRIPT_NAME, ListLen(CGI.SCRIPT_NAME, "/"), "/"))#/index_activate.cfm?#query_string#" target="_blank">here</a> to Activate your new user account.
					<br>
					<b>INFO:</b> The Process of <b>Activating your new User Account</b> will trigger an email with your <b>password</b> - keep in mind, this password has nothing to do with your Network Password however if you choose to <b>change your password</b> later on you may easily do so.  It is recommended however that you use system generated password only when accessing this system in order to maintain the secrecy of your password.  It is further recommended that you change your password often by clicking on the "forgot your password" link.
				</cfoutput>
			</cfsavecontent>

			<tr>
				<td colspan="2" align="center">
					<i>Saving... Data...</i>
					<cfset bool_successful = "False">
					<cfif (IsQuery(qq))>
						<cfif (qq.recordCount gt 0)>
							<cfset bool_successful = "True">
							<!--- Trigger the email here... --->
							<i>Successful !</i><br>
							<cfif (bool_isLocalServer)>
								#html_activateAccountLink#
							<cfelse>
								<cfscript>
									Request.primitiveCode.safely_cfmail(userName, Request.const_do_not_reply_symbol, 'Welcome to the #Request._title_bar# Version #Request.productVersion#, this is your User Account Acitvation link.', html_activateAccountLink);
									if (NOT Request.anError) {
										writeOutput('<span class="normalStatusBoldClass"><i>Your New User Account Activation email was Successfully sent !</i></span>');
									} else {
										writeOutput('<span class="errorStatusBoldClass"><i>Your New User Account Activation email was <U>NOT</U> Successfully sent !</i></span>');
									}
								</cfscript>
							</cfif>
						<cfelse>
							<span class="errorStatusBoldClass"><big><i>Un-Successful !</i></big></span>
						</cfif>
					<cfelse>
						<span class="errorStatusBoldClass"><big><i>Un-Successful !</i></big></span>
					</cfif>
					<cfif (Request.dbError)>
						<cfif (Request.isPKviolation)>
							<!--- Trigger the email here... --->
							<cfset Request.anError = "False">
							<cfif (NOT bool_isLocalServer)>
								<cfscript>
									Request.primitiveCode.safely_cfmail(userName, Request.const_do_not_reply_symbol, 'Welcome to the #Request._title_bar# Version #Request.productVersion#, this is your User Account Acitvation link.', html_activateAccountLink);
								</cfscript>
							</cfif>
							<br><span class="errorStatusBoldClass"><i>Cannot Register the same user twice.  <cfif (NOT bool_isLocalServer)>Kindly look for the email that was <cfif (Request.anError)>not sent (due to an error)<cfelse>just sent</cfif> to your email address; there is a link you must click on to Activate your user account so you can log-in.</cfif></i></span>
							<cfif (bool_isLocalServer)>
								#html_activateAccountLink#
							</cfif>
						<cfelseif (NOT IsQuery(qq))>
							<br><span class="errorStatusBoldClass"><i>#Request.errorMsg#</i></span>
						<cfelse>
							#Request.fullErrorMsg#
						</cfif>
					</cfif>
				</td>
			</tr>
			<cfif (NOT bool_successful)>
				<tr>
					<td colspan="2" align="center">
						#Request.commonCode.hiddenInputsUsingStruct(URL)#
						<input type="hidden" name="userName" id="userName" value="#userName#">
						<input type="hidden" name="password" id="password" value="#password#">
						<input type="hidden" name="secretPrompt" id="secretPrompt" value="#secretPrompt#">
						<input type="hidden" name="secretResponse" id="secretResponse" value="#secretResponse#">
						<input type="submit" class="buttonClass" name="btn_submit" id="btn_submit" value="#Request.const_try_again_btn_label#">
					</td>
				</tr>
			</cfif>
		</cfif>
		#html_UserRegistrationFormBottom#
	</cfoutput>
</cfsavecontent>

<cfscript>
	writeOutput(Request.html_headerContent & html_NewUserRegistration);
</cfscript>

<cfinclude template="../Footer.cfm">
