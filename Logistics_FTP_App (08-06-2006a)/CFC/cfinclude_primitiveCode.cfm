<!--- BEGIN: Getting Code Re-Use from including this body of code in two different CFC's stored in two different folders --->
<cfscript>
	const_PK_violation_msg = 'Violation of PRIMARY KEY constraint';

	function _isPKviolation(eMsg) {
		var bool = false;
		if (FindNoCase(const_PK_violation_msg, eMsg) gt 0) {
			bool = true;
		}
		return bool;
	}
</cfscript>

<cffunction name="cf_directory" access="public" returntype="query">
	<cfargument name="_qName_" type="string" required="yes">
	<cfargument name="_path_" type="string" required="yes">
	<cfargument name="_filter_" type="string" required="yes">
	<cfargument name="_recurse_" type="boolean" default="False">

	<cfif (_recurse_)>
		<cfdirectory action="LIST" directory="#_path_#" name="#_qName_#" filter="#_filter_#" recurse="Yes">
	<cfelse>
		<cfdirectory action="LIST" directory="#_path_#" name="#_qName_#" filter="#_filter_#">
	</cfif>

	<cfreturn Evaluate(_qName_)>
</cffunction>

<cffunction name="safely_execSQL" access="public" returntype="query">
	<cfargument name="_qName_" type="string" required="yes">
	<cfargument name="_DSN_" type="string" required="yes">
	<cfargument name="_sql_" type="string" required="yes">
	<cfargument name="_cachedWithin_" type="string" default="">
	
	<cfscript>
		var q = -1;
	</cfscript>

	<cfset Request.errorMsg = "">
	<cfset Request.dbError = "False">
	<cfset Request.isPKviolation = "False">
	<cftry>
		<cfif (Len(Trim(arguments._qName_)) gt 0)>
			<cfif (Len(_DSN_) gt 0)>
				<cfif (Len(_cachedWithin_) gt 0) AND (IsNumeric(_cachedWithin_))>
					<cfquery name="#_qName_#" datasource="#_DSN_#" cachedwithin="#_cachedWithin_#">
						#PreserveSingleQuotes(_sql_)#
					</cfquery>
				<cfelse>
					<cfquery name="#_qName_#" datasource="#_DSN_#">
						#PreserveSingleQuotes(_sql_)#
					</cfquery>
				</cfif>
			<cfelse>
				<cfquery name="#_qName_#" dbtype="query">
					#PreserveSingleQuotes(_sql_)#
				</cfquery>
			</cfif>
		<cfelse>
			<cfset Request.errorMsg = "Missing Query Name which is supposed to be the first parameter.">
			<cfthrow message="#Request.errorMsg#" type="missingQueryName" errorcode="-100">
		</cfif>

		<cfcatch type="Database">
			<cfset Request.dbError = "True">

			<cfsavecontent variable="Request.errorMsg">
				<cfoutput>
					#cfcatch.message#
					#cfcatch.detail#<br>
					[<b>cfcatch.SQLState</b>=#cfcatch.SQLState#]
				</cfoutput>
			</cfsavecontent>

			<cfscript>
				if (Len(_DSN_) gt 0) {
					Request.isPKviolation = _isPKviolation(Request.errorMsg);
				}
			</cfscript>

			<cfset Request.dbErrorMsg = Request.errorMsg>
			<cfsavecontent variable="Request.fullErrorMsg">
				<cfdump var="#cfcatch#" label="cfcatch">
			</cfsavecontent>
			<cfsavecontent variable="Request.verboseErrorMsg">
				<cfif (IsDefined("Request.bool_show_verbose_SQL_errors"))>
					<cfif (Request.bool_show_verbose_SQL_errors)>
						<cfdump var="#cfcatch#" label="cfcatch :: Request.isPKviolation = [#Request.isPKviolation#]" expand="No">
					</cfif>
				</cfif>
			</cfsavecontent>

			<cfscript>
				if ( (IsDefined("Request.bool_show_verbose_SQL_errors")) AND (IsDefined("Request.verboseErrorMsg")) ) {
					if (Request.bool_show_verbose_SQL_errors) {
						if (NOT Request.isPKviolation) 
							writeOutput(Request.verboseErrorMsg);
					}
				}
			</cfscript>
		</cfcatch>
	</cftry>

	<cfscript>
		q = QueryNew('');
		if (NOT Request.dbError) {
			try {
				q = Evaluate(_qName_);
			} catch (Any e) {
			}
		}
	</cfscript>

	<cfreturn q>
</cffunction>

<cffunction name="cf_file_delete" access="public" returntype="boolean">
	<cfargument name="_fname_" type="string" required="yes">

	<cfset Request.fileError = "False">
	<cftry>
		<cffile action="DELETE" file="#_fname_#">

		<cfcatch type="Any">
			<cfset Request.fileError = "True">
			<cfsavecontent variable="Request.verboseFileErrorMsg">
				<cfdump var="#cfcatch#" label="cfcatch - DELETE [#_fname_#]">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfreturn Request.fileError>
</cffunction>

<cffunction name="cf_dump" access="public" returntype="string">
	<cfargument name="_varName_" type="any" required="yes">
	<cfargument name="_label_" type="string" required="yes">
	<cfargument name="_expanded_" type="boolean" required="yes">
	<cfargument name="_output_" type="boolean" default="false">

	<cfset _expFlag = "No">
	<cfif (_expanded_)>
		<cfset _expFlag = "Yes">
	</cfif>

	<cfsavecontent variable="_html">
		<cfdump var="#_varName_#" label="#_label_#" expand="#_expFlag#">
	</cfsavecontent>
	
	<cfscript>
		if (_output_) writeOutput(_html);
		return _html;
	</cfscript>

</cffunction>

<cffunction name="safely_cffile_write" access="public">
	<cfargument name="_fName_" type="string" required="yes">
	<cfargument name="_data_" type="string" required="yes">

	<cfset Request.anError = "False">
	<cftry>
		<cffile action="WRITE" file="#_fName_#" output="#_data_#" attributes="Normal" addnewline="Yes" fixnewline="Yes">

		<cfcatch type="Any">
			<cfset Request.anError = "True">

			<cfsavecontent variable="Request.errorMsg">
				#cfcatch.message#<br>
				#cfcatch.detail#
			</cfsavecontent>
			<cfsavecontent variable="Request.verboseErrorMsg">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
			</cfsavecontent>
		</cfcatch>
	</cftry>

</cffunction>

<cffunction name="safely_cffile" access="public" returntype="string">
	<cfargument name="_fName_" type="string" required="yes">
	<cfargument name="_action_" type="string" default="READ">

	<cfset _fileContents = "">
	<cfset Request.anError = "False">
	<cftry>
		<cfif (UCASE(_action_) eq UCASE("READ"))>
			<cffile action="READ" file="#_fName_#" variable="_fileContents">
		<cfelseif (UCASE(_action_) eq UCASE("DELETE"))>
			<cffile action="DELETE" file="#_fName_#">
		</cfif>

		<cfcatch type="Any">
			<cfset Request.anError = "True">

			<cfsavecontent variable="errorMsg">
				#cfcatch.message#<br>
				#cfcatch.detail#
			</cfsavecontent>
			
			<cfsavecontent variable="Request.verboseErrorMsg">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
			</cfsavecontent>

			<cfset _fileContents = errorMsg>

		</cfcatch>
	</cftry>

	<cfreturn _fileContents>
</cffunction>

<cffunction name="cf_makeDirectory" access="public" returntype="boolean">
	<cfargument name="_path_" type="string" required="yes">

	<cfset dirError = "False">
	<cftry>
		<cfdirectory action="CREATE" directory="#_path_#">

		<cfcatch type="Any">
			<cfset dirError = "True">
			<cfsavecontent variable="Request.dirErrorMsg">
				<cfdump var="#cfcatch#" label="cfcatch" expand="Yes">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfreturn dirError>
</cffunction>

<cffunction name="cf_location" access="public" returntype="any">
	<cfargument name="_url_" type="string" required="yes">

	<cflocation url="#_url_#" addtoken="No">

</cffunction>

<cffunction name="cf_include" access="public" returntype="any">
	<cfargument name="_fName_" type="string" required="yes">

	<cfinclude template="#_fName_#">

</cffunction>

<cffunction name="cf_flush" access="public" returntype="any">
	<cfflush>
</cffunction>

<cffunction name="__debugQueryInTable" access="public" returntype="string">
	<cfargument name="q" type="query" required="yes">
	<cfargument name="qName" type="string" required="yes">
	<cfargument name="isHorz" type="boolean" default="False">
	<cfargument name="_colList_" type="string" default="#q.columnList#">
	
	<cfsavecontent variable="_html">
		<cfoutput>
			<table width="100%" border="1" cellpadding="-1" cellspacing="-1">
				<tr>
					<td bgcolor="silver" class="normalBoldClass">
						(#qName#) #qName#.recordCount = [#q.recordCount#]
					</td>
				</tr>
				<tr>
					<td>
						<table width="100%" border="1" cellpadding="-1" cellspacing="-1">
							<cfif (isHorz)>
								<cfloop index="_i" list="#_colList_#" delimiters=",">
									<tr>
										<td bgcolor="silver" class="normalBoldClass">#LCase(_i)#</td>
										<cfloop query="q" startrow="1" endrow="#q.recordCount#">
											<td class="normalClass">
												<cftry>
													<cfset _val = Evaluate("q.#_i#")>

													<cfcatch type="Any">
														<cfset _val = "">
													</cfcatch>
												</cftry>

												<cfif (Len(Trim(_val)) gt 0)>
													#_val#
												<cfelse>
													&nbsp;
												</cfif>
											</td>
										</cfloop>
									</tr>
								</cfloop>
							<cfelse>
								<tr>
									<cfloop index="_i" list="#_colList_#" delimiters=",">
										<td bgcolor="silver" class="normalBoldClass">#LCase(_i)#</td>
									</cfloop>
								</tr>
								<cfloop query="q" startrow="1" endrow="#q.recordCount#">
									<tr>
										<cfloop index="_i" list="#_colList_#" delimiters=",">
											<td class="normalClass">
												<cftry>
													<cfset _val = Evaluate("q.#_i#")>

													<cfcatch type="Any">
														<cfset _val = "">
													</cfcatch>
												</cftry>

												<cfif (IsSimpleValue(_val))>
													<cfif (Len(Trim(_val)) gt 0)>
														#_val#
													<cfelse>
														&nbsp;
													</cfif>
												<cfelse>
													<small><i>(Too Complex !)</i></small>
												</cfif>
											</td>
										</cfloop>
									</tr>
								</cfloop>
							</cfif>
						</table>
					</td>
				</tr>
			</table>
		</cfoutput>
	</cfsavecontent>
	
	<cfreturn _html>

</cffunction>

<cffunction name="safely_cfmail" access="public" returntype="any">
	<cfargument name="_toAddrs_" type="string" required="yes">
	<cfargument name="_fromAddrs_" type="string" required="yes">
	<cfargument name="_theSubj_" type="string" required="yes">
	<cfargument name="_theBody_" type="string" required="yes">

	<cfset Request.anError = "False">
	<cftry>
		<cfmail to="#_toAddrs_#" from="#_fromAddrs_#" subject="#_theSubj_#" type="HTML">#_theBody_#</cfmail>

		<cfcatch type="Any">
			<cfset Request.anError = "True">

			<cfsavecontent variable="Request.errorMsg">
				<cfoutput>
					#cfcatch.message#<br>
					#cfcatch.detail#
				</cfoutput>
			</cfsavecontent>
		</cfcatch>
	</cftry>

</cffunction>

<cffunction name="cf_execute" access="public" returntype="string">
	<cfargument name="_cmd_" type="string" required="yes">
	<cfargument name="_output_file_" type="string" required="yes">
	<cfargument name="_timeout_" type="numeric" default="60">

	<cfset Request.anError = "False">
	<cftry>
		<cfsavecontent variable="results_content">
			<cftimer label="" type="inline">
				<cfexecute name = "#_cmd_#"
					arguments = "" 
					outputFile = "#_output_file_#"
					timeout = "#_timeout_#">
				</cfexecute>
			</cftimer>
		</cfsavecontent>

		<cfcatch type="Any">
			<cfset Request.anError = "True">

			<cfsavecontent variable="Request.errorMsg">
				<cfoutput>
					#cfcatch.message#<br>
					#cfcatch.detail#
				</cfoutput>
			</cfsavecontent>

			<cfsavecontent variable="Request.verboseErrorMsg">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfscript>
		if (NOT IsDefined("results_content")) {
			results_content = '';
		}
	</cfscript>

	<cfreturn Trim(results_content)>

</cffunction>

<cffunction name="cf_lock" access="public" returntype="any">
	<cfargument name="_myName_" type="string" required="yes">
	<cfargument name="_myFunc_" type="any" required="yes">
	<cfargument name="_myType_" type="string" required="yes">
	<cfargument name="_myScope_" type="string" required="yes">

	<cfif (Len(_myScope_) gt 0)>
		<cfif (LCASE(_myScope_) eq LCASE('APPLICATION')) OR (LCASE(_myScope_) eq LCASE('SESSION')) OR (LCASE(_myScope_) eq LCASE('SERVER'))>
			<cflock timeout="30" throwontimeout="No" type="#_myType_#" scope="#LCASE(_myScope_)#">
				<cfscript>
					if (IsCustomFunction(_myFunc_)) {
						_myFunc_();
					}
				</cfscript>
			</cflock>
		</cfif>
	<cfelse>
		<cflock timeout="30" throwontimeout="No" name="myName" type="#_myType_#">
			<cfscript>
				if (IsCustomFunction(_myFunc_)) {
					_myFunc_();
				}
			</cfscript>
		</cflock>
	</cfif>

</cffunction>

<cffunction name="_handleUserLogin" access="public" returntype="boolean">
	<cfargument name = "_targetPage_" required=true/>

	<cfset Request.bool_dont_auto_adjust_content = "True">
	<cfinclude template="../cfinclude_js_content.cfm">

	<cfset _forgot_cfm_name = ReplaceNoCase(ReplaceNoCase(CGI.SCRIPT_NAME, GetToken(CGI.SCRIPT_NAME, 1, "/"), GetToken(CGI.SCRIPT_NAME, 1, "/") & "/admin"), ".cfm", Request.const_forgot_cfm_symbol)>
	<cfset _newuser_cfm_name = ReplaceNoCase(ReplaceNoCase(CGI.SCRIPT_NAME, GetToken(CGI.SCRIPT_NAME, 1, "/"), GetToken(CGI.SCRIPT_NAME, 1, "/") & "/admin"), ".cfm", Request.const_newuser_cfm_symbol)>
	<cfset _chgPassword_cfm_name = ReplaceNoCase(ReplaceNoCase(CGI.SCRIPT_NAME, GetToken(CGI.SCRIPT_NAME, 1, "/"), GetToken(CGI.SCRIPT_NAME, 1, "/") & "/admin"), ".cfm", Request.const_chgPassword_cfm_symbol)>
	<cfset const_simple_replacement_symbol = "++++">

	<cfsavecontent variable="html_ForgotPasswordLink">
		<cfset variables._url = Request.commonCode.suppressURLSlashSlash(Request.commonCode.fullyQualifiedServerName(), _forgot_cfm_name)>
		<cfoutput>
			<a href="#variables._url#?opt=#Request.const_forgot_password_symbol#&title_bar=#URLEncodedFormat(Request.title_bar)#&productVersion=#URLEncodedFormat(Request.productVersion)#&DSN=#URLEncodedFormat(Request.DSN)#&nocache=#URLEncodedFormat(CreateUUID())#" target="_blank">#const_simple_replacement_symbol#</a>
		</cfoutput>
	</cfsavecontent>

	<cfsavecontent variable="html_NewAccountRegisterLink">
		<cfset variables._url = Request.commonCode.suppressURLSlashSlash(Request.commonCode.fullyQualifiedServerName(), _newuser_cfm_name)>
		<cfoutput>
			<a href="#variables._url#?opt=#Request.const_new_user_account_symbol#&title_bar=#URLEncodedFormat(Request.title_bar)#&productVersion=#URLEncodedFormat(Request.productVersion)#&DSN=#URLEncodedFormat(Request.DSN)#&nocache=#URLEncodedFormat(CreateUUID())#" target="_blank">#const_simple_replacement_symbol#</a>
		</cfoutput>
	</cfsavecontent>

	<cfsavecontent variable="html_ChangePasswordLink">
		<cfset variables._url = Request.commonCode.suppressURLSlashSlash(Request.commonCode.fullyQualifiedServerName(), _chgPassword_cfm_name)>
		<cfoutput>
			<a href="#variables._url#?opt=#Request.const_chg_user_account_password_symbol#&title_bar=#URLEncodedFormat(Request.title_bar)#&productVersion=#URLEncodedFormat(Request.productVersion)#&DSN=#URLEncodedFormat(Request.DSN)#&nocache=#URLEncodedFormat(CreateUUID())#" target="_blank">#const_simple_replacement_symbol#</a>
		</cfoutput>
	</cfsavecontent>

	<cfsavecontent variable="Request._html_loginForm">
		<cfinclude template="../cfinclude_Header.cfm">

		<cfscript>
			if ( (IsDefined("Request.html_headerContent")) AND ( (NOT IsDefined("Request.bool_html_headerContent_delivered")) OR (NOT Request.bool_html_headerContent_delivered) ) ) {
				writeOutput(Request.html_headerContent);
				Request.bool_html_headerContent_delivered = true;
			}
		</cfscript>

		<cfoutput>
			<form action="#CGI.SCRIPT_NAME#" method="post" name="myForm" id="myForm">
				<table width="900" cellpadding="-1" cellspacing="-1">
					<tr>
						<td>
							<table border="1" width="500" align="center">
								<tr>
									<td>
										<table bgcolor="##FFFFB9" width="100%">
											<tr bgcolor="silver">
												<td align="center">
													<span class="instructionsClass"><BIG><b>User Login</b></BIG>&nbsp;<i>(#Request.const_required_marker_symbol# indicates Required fields.)</i></span>
												</td>
											</tr>
											<tr>
												<td>
													<table width="100%">
														<tr>
															<td>
																<span class="instructionsClass">User Name:</span>
															</td>
															<td>
																<input type="text" class="textClass" name="userName" id="userName" size="30" maxlength="255">#Request.const_required_marker_symbol#
															</td>
															<td>
																<span class="instructionsClass">(This is your redacted email address.)</span>
															</td>
														</tr>
														<tr>
															<td>
																<span class="instructionsClass">Password:</span>
															</td>
															<td>
																<input type="password" class="textClass" name="password" id="password" size="20" maxlength="50">#Request.const_required_marker_symbol#
															</td>
															<td>
																<span class="instructionsClass">(This is your password.)</span>
															</td>
														</tr>
													</table>
												</td>
											</tr>
											<tr>
												<td colspan="2" align="center">
													<input type="submit" class="buttonClass" name="btn_submit" id="btn_submit" value="[LOG IN]">
												</td>
											</tr>
											<tr>
												<td align="center">
													<span class="instructionsClass">Click #ReplaceNoCase(html_ForgotPasswordLink, const_simple_replacement_symbol, "here")# if you #ReplaceNoCase(html_ForgotPasswordLink, const_simple_replacement_symbol, "forgot your password")# or need to #ReplaceNoCase(html_NewAccountRegisterLink, const_simple_replacement_symbol, "register for a new user account")#, or need to #ReplaceNoCase(html_ChangePasswordLink, const_simple_replacement_symbol, "change your password")#, a new password will be emailed to you, as-needed.</span>
												</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						</td>
					</tr>
					<cfif 0>
						<tr>
							<td>
								<table width="900px" height="400px">
									<tr>
										<td>
											<iframe width="100%" height="400px" src="http://#CGI.SERVER_NAME#/#GetToken(CGI.SCRIPT_NAME, 1, "/")#/admin/tutorial/IML+FTP+XML Interface Vers 1.0.8 Tutorial.htm"></iframe>
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</cfif>
				</table>
			</form>
		</cfoutput>

		<script language="JavaScript1.2" type="text/javascript">
		<!--
			var aDHTMLObj1 = DHTMLWindowsObj.getInstance();
			var t = aDHTMLObj1.asHTML();
			document.write(t);
		// --> 
		</script>

		<cfinclude template="../Footer.cfm">
	</cfsavecontent>

	<cfset Request.isLoggedIn = "False">
	<cftry>
		<cflock timeout="300" throwontimeout="No" type="READONLY" scope="SESSION">
			<cfscript>
				Request.isLoggedIn = false;
				if (IsDefined("Session.userParms")) {
					if (IsQuery(Session.userParms)) {
						if (Session.userParms.recordCount gt 0) {
							Request.isLoggedIn = true;
						}
					}
				}
			</cfscript>
		</CFLOCK>

		<cfcatch type="Any">
		</cfcatch>
	</cftry>

	<cfreturn Request.isLoggedIn>
</cffunction>

<cffunction name="_flagUserLoggedIn" access="public" returntype="boolean">
	<cfset var _isLoggedIn = "False">

	<cftry>
		<CFLOCK SCOPE="SESSION" TIMEOUT="300" TYPE="EXCLUSIVE">
			<cfscript>
				Session.userParms = QueryNew('id, dt', 'integer, date');
				if (IsQuery(Session.userParms)) {
					QueryAddRow(Session.userParms, 1);
					QuerySetCell(Session.userParms, 'id', Session.userParms.recordCount, Session.userParms.recordCount);
					QuerySetCell(Session.userParms, 'dt', Now(), Session.userParms.recordCount);
					
					_isLoggedIn = true;
				}
			</cfscript>
		</CFLOCK>

		<cfcatch type="Any">
			<cfset _isLoggedIn = "False">
		</cfcatch>
	</cftry>

	<cfreturn _isLoggedIn>
</cffunction>

<cffunction name="_flagUserLoggedOut" access="public" returntype="boolean">
	<cfset var _isLoggedOut = "False">

	<cftry>
		<CFLOCK SCOPE="SESSION" TIMEOUT="300" TYPE="EXCLUSIVE">
			<cfscript>
				Session.userParms = QueryNew('id, dt', 'integer, date');
				if (IsQuery(Session.userParms)) {
					Session.userParms = -1;
					_isLoggedOut = true;
				}
			</cfscript>
		</CFLOCK>

		<cfcatch type="Any">
			<cfset _isLoggedOut = "False">
		</cfcatch>
	</cftry>

	<cfreturn _isLoggedOut>
</cffunction>

<!--- END! Getting Code Re-Use from including this body of code in two different CFC's stored in two different folders --->
