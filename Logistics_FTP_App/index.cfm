<cfsavecontent variable="Request.full_js_content">
	<script language="JScript.Encode" src="js/loadJSCode_.js"></script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		loadJSCode("js/disable-right-click-script-III_.js");
		loadJSCode("js/MathAndStringExtend_.js");
		loadJSCode("js/DHTMLWindows_obj_.js");
	// --> 
	</script>
		
	<script language="JavaScript1.2" type="text/javascript">
	<!--
		function changePage(newLoc) {
			var nextPage = newLoc.options[newLoc.selectedIndex].value
			
			if (nextPage != "") {
				document.location.href = nextPage
			}
		 }

		function enableDisableObj(bool, id) {
			var oObj = getGUIObjectInstanceById(id);
			if (oObj != null) {
				oObj.disabled = (((bool == null) || (bool == false)) ? false : true);
			}
		}

		function enablePNAbtn(bool) {
			enableDisableObj(bool, 'btn_pna');
		}

		function enableOSbtn(bool) {
			enableDisableObj(bool, 'btn_os');
		}
		
		function enableBrowseBtn(bool) {
			enableDisableObj(bool, 'btn_browse_data');
		}
		
		function clickBrowseBtn() {
			var oObj = getGUIObjectInstanceById('btn_browse_data');
			if (oObj != null) {
				oObj.onclick();
			}
		}
		
		function saveSkus(t) {
			alert('saveSkus(t = [' + t + '])');
		}
		
		var _original_document_title = '';
		
		function updTitleBar() {
			var _width = clientWidth();
			var _height = clientHeight();
			if (_original_document_title.length == 0) {
				_original_document_title = window.document.title;
			}
			window.document.title = '(' + _width + ',' + _height + ') ' + _original_document_title;
		}
		
		function callbackNotifyParentServerAnalysis(_btnId, _btnDisabled, _btnStyles) {
			var i = -1;
			var j = -1;
			var aa = [];
			var ab = [];
			var a = _btnStyles.split(';');
			<cfoutput>
			var bool_isLocal = '#(Request.commonCode.isServerLocal())#';
			bool_isLocal = ((bool_isLocal == 'YES') ? true : false);
			</cfoutput>

			enableDisableObj(((_btnDisabled.length > 0) ? true : false), _btnId);

			var oObj = getGUIObjectInstanceById(_btnId);
			if (oObj != null) {
				for (i = 0; i < a.length; i++) {
					aa = a[i].split(':');
					if (aa[0].length > 0) {
						if ( (aa[0] == 'color') || (aa[0] == 'background-color') ) {
							ab = aa[1].split('#');
							for (j = 0; j < ab.length; j++) {
								if (ab[j].length > 1) {
									if (aa[0] == 'color') {
										oObj.style.color = '#' + ab[j];
									} else if (aa[0] == 'background-color') {
										oObj.style.backgroundColor = '#' + ab[j];
									}
									break;
								}
							}
						}
					}
				}
			}
		}
	// --> 
	</script>
</cfsavecontent>

<CFINCLUDE TEMPLATE="Header.cfm">

<cfif (Request.bool_is_user_logged_in)>
	<cfinclude template="cfinclude_tibco_ftp_functions.cfm">

	<cfif (0)>
		<cfif (Len(Trim(nocache)) eq 0)>
			<cflocation url="#CGI.SCRIPT_NAME#?nocache=#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#" addtoken="No">
		</cfif>
	</cfif>
	
	<script language="JavaScript1.2" type="text/javascript">
	<!--
		window.onload = updTitleBar;
		window.onresize = updTitleBar;
	// --> 
	</script>
	
	<cfparam name="noton2" type="string" default="">
	
	<cfoutput>
		<!--- 
		<cfif (Len(Trim(noton2)) eq 0) AND (NOT Request.commonCode.isServerLocalHost()) AND (NOT Request.commonCode.isUserDeveloper())> <!---  (Len(CGI.HTTP_REFERER) eq 0) AND (NOT Request.commonCode.isServerLocalHost()) AND (Request.commonCode.isUserDeveloper()) --->
		 --->
		<cfif (0)>
			<span class="normalStatusClass"><b>*</b></span>
			<cflocation url="http://#Request.const_myVisionDev2_symbol#/#Request.urlPrefix#/#Request.const_index_cfm_symbol#?noton2=1&nocache=#Request.commonCode.uniqueTimeBasedUUID()#">
		<cfelse>
			<table width="990px" cellpadding="-1" cellspacing="-1">
				<tr>
					<td class="paperBgColorClass">
						<span class="instructionsClass"><center><b>Do Not Use the Browser's Navigation buttons to navigate this application, rather use the buttons and controls found within the browser's window.<br>Best when viewed using 1024 x 768 Resolution.  You can see your current browser's displayable area on the Browser's Title Bar (990,575 works well)...</b></center></span>
					</td>
				</tr>
				<tr>
					<td style="padding-top: 10px;">
						<table width="100%" cellpadding="-1" cellspacing="-1">
							<tr>
								<td width="33%">
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<tr>
											<td align="left" valign="top" style="padding-left: 5 px; padding-bottom: 5 px;">
												<span class="instructionsClass">Click on the <b>[PNA Request]</b> button to open the Data Entry form that allows a batch of SKU's to be defined and sent to IML for processing.</span>
											</td>
										</tr>
										<tr>
											<td align="center" style="padding-bottom: 5px;">
												<input type="button" id="btn_pna" value="[PNA Request - SKU's]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj.id,'pna-data-entry.cfm?nocache=' + uuid() + '&pna_method=#URLEncodedFormat(Request.const_pna_method_skus_symbol)#',990,550,5,10);">
											</td>
										</tr>
										<tr>
											<td align="center" style="padding-top: 5px;">
												<input type="button" id="btn_pna" value="[PNA Request - Part No's]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj8.id,'pna-data-entry.cfm?nocache=' + uuid() + '&pna_method=#URLEncodedFormat(Request.const_pna_method_part_nums_symbol)#',990,550,5,10);">
											</td>
										</tr>
									</table>
								</td>
								<td>
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<tr>
											<td>
												<span style="font-size: 10px; padding-left: 20px;"><b>PO:&nbsp;&nbsp;</b></span><input type="text" name="cust_po" id="cust_po" size="20" maxlength="32" value="0080138589" style="font-size: 10px;">&nbsp;<input type="button" id="btn_os" value="[OS Request]" class="buttonClass" onclick="var _cust_po = ''; var oObj = getGUIObjectInstanceById('cust_po'); if (oObj != null) { _cust_po = oObj.value; };  DHTMLWindowsObj.loadwindow(aDHTMLObj2.id,'pna.cfm?nocache=' + uuid() + '&cust_po=' + URLEncode(_cust_po) + '&req_method=#Request.symbol_method_os#',990,550,5,10);">
												<br>
												<span style="font-size: 10px; padding-left: 5px;">PO must be limited to a single PO per request.</span>
											</td>
										</tr>
										<tr>
											<td style="padding-bottom: 5px; padding-top: 10px;">
												<input type="button" id="btn_account_maint" value="[Master Account Partner Credentials]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj7.id,'account-maint.cfm?nocache=' + uuid(),990,550,5,10);">
											</td>
										</tr>
										<tr>
											<td style="padding-top: 5px;">
												<input type="button" id="btn_tibco_reports_maint" value="[Tibco Report Name Definitions]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj10.id,'tibco-reports-maint.cfm?nocache=' + uuid(),990,550,5,10);">
											</td>
										</tr>
									</table>
								</td>
								<td>
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<tr>
											<td>
												<span style="font-size: 10px; padding-left: 20px;">&nbsp;</span><input type="button" id="btn_browse_data" value="[Browse Data]" class="buttonClass" onclick="DHTMLWindowsObj.loadwindow(aDHTMLObj3.id,'browse_data.cfm?nocache=' + uuid(),990,550,5,10);">
											</td>
										</tr>
										<tr>
											<td style="padding-top: 10px;">
												<input type="button" id="btn_ftp_browser" value="[Browse FTP Reports]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj6.id,'ftp-browser.cfm?nocache=' + uuid(),990,550,5,10);">
											</td>
										</tr>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td style="padding-top: 10px; padding-left: 10px;">
						<table width="100%" cellpadding="-1" cellspacing="-1">
							<tr>
								<td valign="middle">
									<table width="100%" height="200px" cellpadding="-1" cellspacing="-1">
										<tr valign="top">
											<td>
												<input type="button" id="btn_batches" value="[Define Batches]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj4.id,'define-batches.cfm?nocache=' + uuid(),990,550,5,10);">
											</td>
											<td>
												<cfsavecontent variable="_run_mode_html">
													<span style="font-size: 10px; padding-right: 5px;">Run Mode:</span>
													<select name="myMode" class="buttonClass" onchange="changePage(this); return false;">
														<option value="##">Choose...</option>
														<cfset _selected = "">
														<cfif (LCASE(Request.system_run_mode) eq LCASE(Request.system_run_mode_test))>
															<cfset _selected = "SELECTED">
														</cfif>
														<option value="#CGI.SCRIPT_NAME#?nocache=#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#&run_mode=#Request.system_run_mode_test#" #_selected#>#Request.system_run_mode_test# Mode</option>
														<cfset _selected = "">
														<cfif (LCASE(Request.system_run_mode) eq LCASE(Request.system_run_mode_prod))>
															<cfset _selected = "SELECTED">
														</cfif>
														<option value="#CGI.SCRIPT_NAME#?nocache=#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#&run_mode=#Request.system_run_mode_prod#" #_selected#>#Request.system_run_mode_prod# Mode</option>
													</select>
													<span style="font-size: 10px; padding-left: 5px;"><NOBR>(This choice is per user and remains in effect for a limited time.)</NOBR></span>
												</cfsavecontent>
						
												<cfscript>
													if (Request.commonCode.isServerLocal()) {
														writeOutput(_run_mode_html);
													} else if (LCASE(Request.system_run_mode) eq LCASE(Request.system_run_mode_test)) {
														Request.primitiveCode.cf_location("#CGI.SCRIPT_NAME#?nocache=#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#&run_mode=#Request.system_run_mode_prod#");
													} else {
														writeOutput(RepeatString('&nbsp;', 80));
													}
												</cfscript>
											</td>
										</tr>
										<cfscript>
											_nRecs = -1;
											mySQL_statement = sql_qGetBruteForceNumRecsFromDb(Request.ftpDownloader_last_touched_dt, CreateDateTime(3999, 12, 31, 23, 59, 59.9));
											qNumRecs = Request.primitiveCode.safely_execSQL('qBruteForceNumRecs', Request.DSN, mySQL_statement);
							
											if (NOT Request.dbError) {
												_nRecs = qNumRecs.recordCount;
											}
										</cfscript>
										<tr valign="bottom">
											<td colspan="2">
												<div style="margin-right: 20px;">
													<span class="normalStatusClass"><p align="justify"><b>(Note: The FTP Downloader has been stable and solid for <span class="errorStatusClass"><b>#(DateDiff("d", Request.ftpDownloader_last_touched_dt, Now()))# days</b></span>, since <span class="errorStatusClass">#DateFormat(Request.ftpDownloader_last_touched_dt, "mm/dd/yyyy")#&nbsp;#TimeFormat(Request.ftpDownloader_last_touched_dt, "hh:mm tt")#</span> and has successfully downloaded <span class="errorStatusClass">#_nRecs#</span> Reports during this time.<br><br>
													Additionally the development server this application runs on "#CGI.SERVER_NAME#" no longer needs to be rebooted once each day at the close of the normal business day or 5 pm.)<br><br>
													The daily maintenance window is 6a - 8a M-F unless otherwise specified via email.
													</b></p></span>
												</div>
											</td>
										</tr>
									</table>
								</td>
								<td>
									<table width="100%" cellpadding="-1" cellspacing="-1">
										<cfif (Request.commonCode.isServerLocal())>
											<tr>
												<td>
													<input type="button" id="btn_ftp_reports" <cfif (NOT Request.commonCode.isServerLocal())>disabled</cfif> value="[Download FTP Reports #Request.const_6_day_symbol#]" class="buttonClass" title="This task runs in the background every 1 hour starting at 5:00 am until 8:00 pm every day...  The IML FTP download job is running in the background as a ColdFusion background process.<cfif (Request.commonCode.isServerLocal())>(This button is enabled only when run on localhost or IP address(es) #Request.ownerIPs#)</cfif>" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj5.id,'#Request.commonCode.fullyQualifiedURLprefix()#ftp-download.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_reports3_process" value="[Tibco FTP Process Analysis]" class="buttonClass" title="This button appears only when run on localhost or IP address(es) #Request.ownerIPs#" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj12.id,'#Request.commonCode.fullyQualifiedURLprefix()#tibco-ftp-downloader-analysis.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_reports4_process" value="[New Tibco FTP Process Init]" class="buttonClass" title="This button appears only when run on localhost or IP address(es) #Request.ownerIPs#" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj13.id,'#Request.commonCode.fullyQualifiedURLprefix()#tibco-ftp-downloader-process-new.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_reports4_status" value="[New Tibco FTP Process Status]" class="buttonClass" title="This button appears only when run on localhost or IP address(es) #Request.ownerIPs#" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj14.id,'#Request.commonCode.fullyQualifiedURLprefix()#tibco-ftp-downloader-status-new.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
										</cfif>
										<tr>
											<td style="padding-top: 10px;">
												<input type="button" id="btn_ftp_validation_status" value="[FTP Process Validation Status]" class="buttonClass" title="This button appears only when run on localhost or IP address(es) #Request.ownerIPs#" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj25.id,'#Request.commonCode.fullyQualifiedURLprefix()#tibco-ftp-downloader-status-new.cfm?opt=#Request.const_opt_101_symbol#&nocache=' + uuid(),990,550,5,10);">
											</td>
										</tr>
										<cfif (Request.commonCode.isServerLocal())>
											<cfif (Request.commonCode.isServerLocalHost()) OR (Request.commonCode.isServerredactedDevHost())>
												<tr>
													<td style="padding-top: 10px;">
														<input type="button" id="btn_reset_app_scope_query0" value="[Reset App Scope Query - #Request.const_localhost_symbol#]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj16.id,'#Request.commonCode.fullyQualifiedURLprefix()#cfinclude_reset_AppScope_qGetFTPReportsData.cfm?nocache=' + uuid(),990,550,5,10);">
													</td>
												</tr>
											</cfif>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_reset_app_scope_query1" value="[Reset App Scope Query - #Request.const_myVisionDev_symbol#]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj19.id,'#Request.commonCode.fullyQualifiedURLprefix()#cfinclude_reset_AppScope_qGetFTPReportsData.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_reset_app_scope_query2" value="[Reset App Scope Query - #Request.const_myVisionDev2_symbol#]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj20.id,'#Request.commonCode.fullyQualifiedURLprefix()#cfinclude_reset_AppScope_qGetFTPReportsData.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_notify_tibco_ftp_crash" value="[Notify Tibco FTP Crash]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj17.id,'tibco-ftp-downloader-abend-new.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
										</cfif>
	
										<cfscript>
											btn_disabled = 'disabled';
											Request.thisColorStyle_ftpServerAnalysis = 'background-color: silver;';
											btn_id = 'btn_perform_download_sys_status_check';
										</cfscript>
	
										<tr>
											<td style="padding-top: 10px;">
												<iframe src="#Request.const_utils_slash_symbol#performFtpServerAnalysis.cfm?btnId=#btn_id#&repType=#URLEncodedFormat(Request.const_6_day_symbol)#&nocache=#URLEncodedFormat(CreateUUID())#" width="400" height="100" style="display: none;"></iframe>
											</td>
										</tr>
										<tr>
											<td style="padding-top: 10px;">
												<input type="button" #btn_disabled# id="#btn_id#" value="[#Request.const_6_day_symbol# FTP System Status Check]" style="font-size: 10px; font-weight: bold; #Request.thisColorStyle_ftpServerAnalysis#" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj21.id,'perform_download_sys_status_check.cfm?nocache=' + uuid() + '&sys=#Request.const_6_day_symbol#',990,550,5,10);">
											</td>
										</tr>
	
										<cfscript>
											btn_disabled = 'disabled';
											Request.thisColorStyle_ftpServerAnalysis = 'background-color: silver;';
											btn_id = 'btn_perform_download_sys_status_check2';
										</cfscript>
	
										<tr>
											<td style="padding-top: 10px;">
												<iframe src="#Request.const_utils_slash_symbol#performFtpServerAnalysis.cfm?btnId=#btn_id#&repType=#URLEncodedFormat(Request.const_31_day_symbol)#&nocache=#URLEncodedFormat(CreateUUID())#" width="400" height="100" style="display: none;"></iframe>
											</td>
										</tr>
										<tr>
											<td style="padding-top: 10px;">
												<input type="button" #btn_disabled# id="btn_perform_download_sys_status_check2" value="[#Request.const_31_day_symbol# FTP System Status Check]" style="font-size: 10px; font-weight: bold; #Request.thisColorStyle_ftpServerAnalysis#" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj22.id,'perform_download_sys_status_check.cfm?nocache=' + uuid() + '&sys=#Request.const_31_day_symbol#',990,550,5,10);">
											</td>
										</tr>
	
										<cfif 0>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_convert_savedQ_recs" value="[Convert Saved Query Rep Type Links]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj18.id,'convert-savedQ-report_types.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_reports4_abend" value="[New Tibco FTP Process Abend]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj15.id,'tibco-ftp-downloader-abend-new.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_reports2_process" value="[Tibco FTP Process Init]" class="buttonClass" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj11.id,'tibco-ftp-downloader-process.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
										<cfelseif (Request.commonCode.isServerLocal())>
											<!--- BEGIN: This process was replaced by a hybrid FTP download process --->
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_reports2" <cfif (NOT Request.commonCode.isServerLocal())>disabled</cfif> value="[Download FTP Reports #Request.const_31_day_symbol#]" class="buttonClass" title="This task runs in the background every 1 hour starting at 5:00 am until 8:00 pm every day... The Tibco FTP Download process CANNOT be run from the web interface however there is a background OS job that performs this process. (No longer used)" onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj9.id,'ftp-download2.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
											<!--- END! This process was replaced by a hybrid FTP download process --->
	
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_analysis1" <cfif (NOT Request.commonCode.isServerLocal())>disabled</cfif> value="[Analysis Job ##1 (Truncated Data)]" class="buttonClass" title="This task looks for truncated data and attempts to fix the problems." onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj23.id,'analysis_missing_tibco_data.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
	
											<tr>
												<td style="padding-top: 10px;">
													<input type="button" id="btn_ftp_analysis2" <cfif (NOT Request.commonCode.isServerLocal())>disabled</cfif> value="[Analysis Job ##2 (Parent-Child Data Fix)]" class="buttonClass" title="This task knits together the parent-child relationships for all batch/sub-batches." onClick="DHTMLWindowsObj.loadwindow(aDHTMLObj24.id,'analysis_parent_tibco_data.cfm?nocache=' + uuid(),990,550,5,10);">
												</td>
											</tr>
										</cfif>
									</table>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td bgcolor="##FFFFB9" style="padding-top: 10px;">
						<iframe src="#Request.commonCode.fullyQualifiedURLprefix()#Background-Task-Process-Status.cfm?nocache=#Request.commonCode.uniqueTimeBasedUUID()#" name="status_frame" id="status_frame" width="100%" height="160"></iframe>
					</td>
				</tr>
				<tr> 
					<td style="padding-top: 10px; padding-left: 10px;">
						<span class="instructionsClass">
							<small><b>Note: This system is able to interface with the IML Production Server...  Please submit a <a href="https://helpdesk.redacted.com" target="_blank">Help Desk Ticket</a> for Ray Horn to report any technical difficulties you may encounter.
							</b></small><br> <!--- <a href="mailto:Ray_Horn@redacted.com?subject=RE: IML/XML CFMX7 Interface"></a> --->
						</span>
						<div id="to-do-list-opener" style="display: inline;">
							<span class="instructionsClass">
							<a href="##" onclick="var oObj = getGUIObjectInstanceById('to-do-list-open'); var oObjO = getGUIObjectInstanceById('to-do-list-opener'); var oObjC = getGUIObjectInstanceById('to-do-list-closer'); if ( (oObj != null) && (oObjC != null) && (oObjO != null) ) { oObj.style.display = const_inline_style; oObjO.style.display = const_none_style; oObjC.style.display = const_inline_style; }"><b>Show To-Do List</b></a>
							</span>
						</div>
						<div id="to-do-list-closer" style="display: none;">
							<span class="instructionsClass">
							<a href="##" onclick="var oObj = getGUIObjectInstanceById('to-do-list-open'); var oObjC = getGUIObjectInstanceById('to-do-list-closer'); var oObjO = getGUIObjectInstanceById('to-do-list-opener'); if ( (oObj != null) && (oObjC != null) && (oObjO != null) ) { oObj.style.display = const_none_style; oObjC.style.display = const_none_style; oObjO.style.display = const_inline_style; }"><b>Hide To-Do List</b></a>
							</span>
						</div>
						<div id="to-do-list-open" style="display: none;">
							<UL class="instructionsClass">
								<LI>To Do List:  (Let me know if any of these are still desired, or suggest different priority structure...)
									<OL>
										<LI class="normalStatusClass">FTP Reports 6-day download code - <b>DONE</b> !</LI>
										<LI class="normalStatusClass">FTP Reports 6-day download Background Job - <b>DONE</b> !</LI>
										<LI class="normalStatusClass">FTP Browser code - per Jessica's request - <b>DONE</b> ! - allows those who would rather not read raw FTP reports see the data elements.</LI>
										<LI class="normalStatusClass">FTP Reports 31-day download code - <b>DONE</b> !</LI>
										<LI class="normalStatusClass">FTP Reports 31-day download Background Job - <b>DONE</b> !</LI>
										<LI class="normalStatusClass">XML Browser code - per Jessica's request - <b>DONE</b> ! - allows those who would rather not read XML see the data elements.</LI>
										<LI class="normalStatusClass">Production Mode is automatic - <b>DONE</b> ! - All users are now running in Prod Mode by default.</LI>
										<LI class="normalStatusClass">FTP Browser code - <b>DONE</b> ! - FTP Reports to be viewable in a Grid.</LI>
										<LI class="normalStatusClass">FTP Browser Queries - <b>DONE</b> ! - Allows a user to specify how the FTP Records are displayed - there will be a lot of records to pick from - Queries need to be run to select which files to view.</LI>
										<LI class="normalStatusClass">Allow user to specify the XML username and password - <b>DONE - Data Entry is Online</b>.</LI>
										<LI class="normalStatusClass">Allow user to specify the Tibco FTP Report Names for each type of Report by Report Name Prefix - <b>DONE - Data Entry is Online</b>.</LI>
										<LI class="normalStatusClass">FTP Report Type Classfication - <b>DONE</b> ! - reports are classified based on the report file name.</LI>
										<LI class="normalStatusClass">Updated Saved Queries for FTP Report Type Selection - <b>DONE</b> ! - FTP Reports can be selected based on Report Type as well as the other paremeters.</LI>
										<LI class="normalStatusClass">FTP Report Presentation (Shipments Detail) - <b>DONE</b> ! - it might not look pretty but the data is visible.</LI>
										<LI class="normalStatusClass">FTP Report Presentation (STOCK STATUS REPORT) - <b>DONE</b> ! - it might not look pretty but the data is visible.</LI>
										<LI class="normalStatusClass">FTP Report Presentation (BACKORDER REPORT) - <b>DONE</b> ! - it might not look pretty but the data is visible.</LI>
										<LI class="normalStatusClass">FTP Report Presentation Receiving Report (daily) - <b>DONE</b> ! - it might not look pretty but the data is visible.</LI>
										<LI class="normalStatusClass">FTP Report Presentation (ORDER DELETE REPORT) - <b>DONE</b> ! - it might not look pretty but the data is visible.</LI>
										<LI class="normalStatusClass">FTP Report Presentation (INVENTORY QUANTITY CHANGE) - <b>DONE</b> ! - it might not look pretty but the data is visible.</LI>
										<LI class="normalStatusClass">FTP Report Presentation Open PO Report (daily) - <b>DONE</b> !</LI>
										<LI class="normalStatusClass">FTP Report Presentation (Proof of Delivery Detail – INFO FOUND FILE) - <b>DONE</b> !</LI>
										<LI class="normalStatusClass">FTP Report Presentation (Proof of Delivery Detail – INFO MISSING FILE) - <b>DONE</b> !</LI>
										<LI class="onholdStatusClass">FTP Report Presentation (ELECTRONIC POINT OF DELVY RPT - NEGATIVE) - <b>ON-HOLD</b> - We are NOT getting any reports like this yet !</LI>
										<LI class="onholdStatusClass">FTP Report Presentation (ELECTRONIC POINT OF DELVY RPT - POSITIVE) - <b>ON-HOLD</b> - We are NOT getting any reports like this yet !</LI>
										<LI class="onholdStatusClass">FTP Report Presentation (SHIPMENT CONFIRMATION) - <b>ON-HOLD</b> - We are NOT getting any reports like this yet !</LI>
										<LI class="normalStatusClass">FTP Report Presentation (REFUSAL REPORT) - <b>DONE</b> - it might not look pretty but the data is visible. !</LI>
										<LI class="onholdStatusClass">XML post-processor code - <b>ON-HOLD</b> ! - stores data from XML into redacted database to be accessed from myVision Portal.</LI>
										<LI class="onholdStatusClass">FTP post-processor code - <b>ON-HOLD</b> ! - stores data from XML into redacted database to be accessed from myVision Portal.</LI>
										<LI class="normalStatusClass">Data Mart Interface for (Shipments Detail) - <b>DONE</b> ! - the table name is <b>dm_SHIPMENTSDETAIL</b>.</LI>
										<LI class="normalStatusClass">Excel Data Viewer Interface - <b>DONE</b> - Just for Jessica !</LI>
										<LI class="normalStatusClass">Raw Data Viewer Interface - <b>DONE</b> - Just for Jessica !</LI>
										<LI class="normalStatusClass">Trash Data Viewer Interface - <b>DONE</b> - Just for Jessica !</LI>
										<LI class="workingStatusClass">Automated Data Mart Interface for (Shipments Detail) - <b>IN-PROCESS</b> ! - a background process needs to be coded to allow the Data Mart table to be processed whenever FTP Raw Data Records appear in the database rather than manually.</LI>
										<LI class="onholdStatusClass">Allow user to specify the XML username and password - <b><i>ON-HOLD - Selection for PNA & OS Requests</i></b>.</LI>
										<LI class="onholdStatusClass">XML Browser code - per Jessica's request - <b>ON-HOLD</b> ! - allows those who would rather not read XML see the data elements in a Grid.</LI>
										<LI class="onholdStatusClass">XML Browser code - <b>ON-HOLD</b> ! - allows the FTP Background Jobs to be self-healing by responding to errors proactively.</LI>
										<LI class="onholdStatusClass">FTP Download Job Error Handler - <b><i>ON-HOLD - Selection for PNA & OS Requests</i></b>.</LI>
										<LI>FTP Reports downloader Background Job Log Viewer - to be done soon...</LI>
										<LI>FTP Reports downloader Background Job Error Log - to be done soon... - Logs Errors encountered by the FTP Reports Downloader code.</LI>
										<LI>FTP Reports downloader Background Job Error Log Viewer - to be done soon...</LI>
										<LI>XML Background Batch Processor code - on-hold per Jessica - this would allow users to batch-up XML requests and run them in the background.</LI>
									</OL>
								</LI>
							</UL>
						</div>
					</td>
				</tr>
			</table>
			
			<cfif 0>
				<cfscript>
					factory = CreateObject("java", "coldfusion.server.ServiceFactory");
					metaData = factory.SchedulerService.getMetaData();
				</cfscript>
				
				<cfdump var="#metaData#" label="coldfusion.server.ServiceFactory.SchedulerService.getMetaData()" expand="No">
				<hr color="blue" width="80%">
				<cfdump var="#factory#" label="coldfusion.server.ServiceFactory" expand="No">
			</cfif>
		</cfif>
		
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			var aDHTMLObj = DHTMLWindowsObj.getInstance();
			var aDHTMLObj2 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj3 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj4 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj5 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj6 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj7 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj8 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj9 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj10 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj11 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj12 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj13 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj14 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj15 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj16 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj17 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj18 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj19 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj20 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj21 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj22 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj23 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj24 = DHTMLWindowsObj.getInstance();
			var aDHTMLObj25 = DHTMLWindowsObj.getInstance();
			var t = aDHTMLObj.asHTML() + aDHTMLObj2.asHTML() + aDHTMLObj3.asHTML() + aDHTMLObj4.asHTML() + aDHTMLObj5.asHTML() + aDHTMLObj6.asHTML() + aDHTMLObj7.asHTML() + aDHTMLObj8.asHTML() + aDHTMLObj9.asHTML() + aDHTMLObj10.asHTML() + aDHTMLObj11.asHTML() + aDHTMLObj12.asHTML() + aDHTMLObj13.asHTML() + aDHTMLObj14.asHTML() + aDHTMLObj15.asHTML() + aDHTMLObj16.asHTML() + aDHTMLObj17.asHTML() + aDHTMLObj18.asHTML() + aDHTMLObj19.asHTML() + aDHTMLObj20.asHTML() + aDHTMLObj21.asHTML() + aDHTMLObj22.asHTML() + aDHTMLObj23.asHTML() + aDHTMLObj24.asHTML() + aDHTMLObj25.asHTML();
			document.write(t);
		// --> 
		</script>
	
	</cfoutput>
	
	<CFINCLUDE template="footer.cfm">
</cfif>
