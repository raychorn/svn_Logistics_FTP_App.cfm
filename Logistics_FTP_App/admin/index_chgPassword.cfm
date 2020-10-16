<cfscript>
	if (IsDefined("URL.title_bar")) {
		Request.title_bar = URL.title_bar & ' (Change Password)';
		Request._title_bar = Request.title_bar;
	} else if (IsDefined("FORM.title_bar")) {
		Request.title_bar = FORM.title_bar & ' (Change Password)';
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
</cfscript>

<cfparam name="userName" type="string" default="">
<cfparam name="password" type="string" default="">
<cfparam name="new_password" type="string" default="">
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

<cfsavecontent variable="html_ChangePasswordForm">
	<cfoutput>
		#UserRegistrationFormTop(userName, password, secretPrompt, secretResponse, new_password)#
		<cfif (NOT Request.bool_process_is_complete)>
			<cfif (UCASE(CGI.REQUEST_METHOD) eq "GET") OR (bool_form_method_is_like_get)>
				<tr>
					<td colspan="2" align="center">
						#Request.commonCode.hiddenInputsUsingStruct(URL)#
						<input type="submit" class="buttonClass" name="btn_submit" id="btn_submit" value="#Request.const_submit_btn_label#">
					</td>
				</tr>
			<cfelseif (NOT Request.dbError)>
				<tr>
					<td colspan="2" align="center">
						#Request.commonCode.hiddenInputsUsingStruct(URL)#
						<input type="hidden" name="userName" id="userName" value="#userName#">
						<input type="submit" class="buttonClass" name="btn_submit" id="btn_submit" value="#Request.const_submit_btn_label#">
					</td>
				</tr>
			</cfif>
		</cfif>

		#html_UserRegistrationFormBottom#
	</cfoutput>
</cfsavecontent>

<cfscript>
	writeOutput(Request.html_headerContent & html_ChangePasswordForm);
</cfscript>

<cfinclude template="../Footer.cfm">
