<cfscript>
	Request.DSN = Request.const_big_data_DSN; // this Data Source retrieves ALL the data from a Query.
</cfscript>

<cfoutput>
	<cfif 1>
		<cfif (FindNoCase('ftp-raw-content.cfm', CGI.SCRIPT_NAME) gt 0) OR (FindNoCase('ftp-excel-content.cfm', CGI.SCRIPT_NAME) gt 0)>
			<cfscript>
				function read_qGetFTPReportsData() { if (IsDefined("Session.qGetFTPReportsData")) { Request.qGetFTPReportsData = Session.qGetFTPReportsData; if (0) writeOutput(Request.primitiveCode.cf_dump(Request.qGetFTPReportsData, 'Request.qGetFTPReportsData', false)); } else { writeOutput('<font color="red"><b>WARNING: Your Session has timed-out due to inactivity. PLS refresh your FTP Reports Query by exiting back to the Home Page and then click on the appropriate button.</b></font>'); }; };
				Request.primitiveCode.cf_lock('LOCK_qGetFTPReportsData', read_qGetFTPReportsData, 'READONLY', 'SESSION');
			</cfscript>

			<cfsavecontent variable="sql_query_code">
				<cfif (IsDefined("Request.qGetFTPReportsData"))>
					<cfoutput>
						SELECT recid, last_modified_dt, file_length, file_name, file_path, file_url, raw_data
						FROM Request.qGetFTPReportsData
						WHERE <cfif (ListLen(recid, ",") eq 1)>(recid = #recid#)<cfelse>(recid in (#recid#))</cfif>
					</cfoutput>
				<cfelse>
					<!--- BEGIN: This assumes there was no result set to pick a record from so we have to figure this out if necessary... --->
					<!--- END! This assumes there was no result set to pick a record from so we have to figure this out if necessary... --->
				</cfif>
			</cfsavecontent>

			<cfset db_err = "False">
			<cfset bool_usefulData = "True">
			<cftry>
				<cfif (NOT IsDefined("Request.qGetFTPReportsData"))>
					<cfquery name="qGetFTPReportData" datasource="#Request.DSN#">
						#PreserveSingleQuotes(sql_query_code)#
					</cfquery>
				<cfelse>
					<cfquery name="qGetFTPReportData" dbtype="query">
						#PreserveSingleQuotes(sql_query_code)#
					</cfquery>
				</cfif>
			
				<cfcatch type="Database">
					<cfset db_err = "True">
					<cfset bool_usefulData = "False">
					<cfsavecontent variable="Request.db_error">
						<cfdump var="#cfcatch#" label="qGetFTPReportData dbError" expand="No">
					</cfsavecontent>
				</cfcatch>
			</cftry>
			
			<cfscript>
			//	writeOutput(Request.primitiveCode.cf_dump(qGetFTPReportData, 'qGetFTPReportData - [#sql_query_code#]', true));
				if (db_err) {
					writeOutput(Request.db_error);
				} else {
					for (zi = 1; zi lte qGetFTPReportData.recordCount; zi = zi + 1) {
						if (Request.DSN eq Request.const_big_data_DSN) {
							qGetFTPReportData.RAW_DATA[zi] = ''; // force the data to be retrieved from the alternate DSN that fetchs large data blocks...
						}
						if (Len(Trim(qGetFTPReportData.RAW_DATA[zi])) eq 0) {
							// fetch the raw data from the physical Db...
							_sql = '';
							if (LCase(qGetFTPReportData.FILE_URL[zi]) neq LCase(Request.const_31_day_symbol)) {
								// 6-day
								_sql = "SELECT raw_data FROM IML_FTP WHERE (UPPER(file_path) = '#UCASE(qGetFTPReportData.FILE_PATH[zi])#') AND (last_modified_dt = CAST('#qGetFTPReportData.LAST_MODIFIED_DT[zi]#' AS datetime))";
							} else {
								// 31-day
								_sql = "SELECT TIBCO_FTP_FULL_NAMES.full_dir_name_abbrev, TIBCO_FTP_SHORT_NAMES.short_name, TIBCO_FTP.raw_data FROM TIBCO_FTP_FULL_NAMES INNER JOIN TIBCO_FTP ON TIBCO_FTP_FULL_NAMES.fid = TIBCO_FTP.fid INNER JOIN TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid WHERE (UPPER(TIBCO_FTP_SHORT_NAMES.short_name) = '#UCASE(qGetFTPReportData.FILE_NAME[zi])#')";
								arToks = ListToArray(qGetFTPReportData.FILE_PATH[zi], ' ');
								nList = ArrayLen(arToks);
								_key = '';
								for (i = 1; i lte nList; i = i + 1) {
									_item = Trim(arToks[i]);
									if (i gt 1) {
										_key = ' ';
									}
									_key = _key & _item;
									if (i lt nList) {
										_key = _key & ' ';
									}
									_sql = _sql & " AND (PATINDEX('%#UCASE(_key)#%', UPPER(TIBCO_FTP_FULL_NAMES.full_dir_name_abbrev)) > 0)";
								}
							}
							// exec the sql and grab the raw_data
							qQq = Request.primitiveCode.safely_execSQL('qGetRawDataFromDb', Request.DSN, _sql);
	
							if ( (NOT Request.dbError) AND (IsQuery(qQq)) AND (IsDefined("qQq.RAW_DATA")) ) {
								qGetFTPReportData.RAW_DATA[zi] = URLDecode(qQq.RAW_DATA);
							} else {
								writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span>');
							}
						}
					}
				}
			</cfscript>
		<cfelse>
			<cfscript>
				Request.dataResponder.processRawData(recid, repName);
				if (IsDefined("Request.qFTPReportData")) {
					qFTPReportData = Request.qFTPReportData;
				}
				if (IsDefined("Request.bool_usefulData")) {
					bool_usefulData = Request.bool_usefulData;
				}
				if (IsDefined("Request.db_err")) {
					db_err = Request.db_err;
				}
				if (IsDefined("Request.qFTPTrashData")) {
					qFTPTrashData = Request.qFTPTrashData;
				}
			</cfscript>
		</cfif>
	<cfelse>
		<tr>
			<td align="center" colspan="2">
				<span class="normalStatusClass"><b>WARING: The FTP Report named #repName# has not yet been implemented - check back later.</b></span>	
			</td>
		</tr>
	</cfif>
</cfoutput>

<cfscript>
	Request.DSN = Request.const_normal_data_DSN; // this Data Source throttles back the data from a Query...
</cfscript>
