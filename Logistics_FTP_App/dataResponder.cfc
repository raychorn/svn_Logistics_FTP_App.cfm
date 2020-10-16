<cfcomponent name="dataResponder" description="Responds to Flash load vars requests">

	<cffunction name="getData" output="true" description="Returns the data in a flash load vars format" access="remote" returntype="void">
		<cfargument name="trans_id" required="false" type="string" default=""/>

		<cfset const_Cr = Chr(13)>
		
		<cfset errorMsg = "">
		<cfset _xml_envelope_data = "">
		<cfset _raw_xml_data = "">
		<cfset _trans_id = "Trans ID ## #arguments.trans_id#">

		<cfsavecontent variable="_sql_statement">
			<cfoutput>
				SELECT proc_dt, trans_id, xml_envelope, method_name, raw_xml, parms, run_mode
				FROM IML_XML
				WHERE (trans_id = '#arguments.trans_id#')
			</cfoutput>
		</cfsavecontent>

		<cfscript>
			q = Request.primitiveCode.safely_execSQL('GetXMLRecord', Request.DSN, _sql_statement);
			
			if (NOT Request.dbError) {
				myDoc = XMLParse(q.xml_envelope, false);
				_xml_envelope_data = _xml_envelope_data & const_Cr & Request.commonCode.xmlNodeWalker(myDoc.xmlRoot.xmlNodes, 1, false);

				myDoc = XMLParse(q.raw_xml, false);
				_raw_xml_data = _raw_xml_data & const_Cr & Request.commonCode.xmlNodeWalker(myDoc.xmlRoot.xmlNodes, 1, false);
			} else {
				_xml_envelope_data = "#_xml_envelope_data##Request.errorMsg#";
			}
		</cfscript>

		<!--- make a string that flash can read --->
		<cfscript>
			writeOutput('&trans_id=' & URLEncodedFormat(_trans_id) & '&xml_envelope=' & URLEncodedFormat(_xml_envelope_data) & '&raw_xml=' & URLEncodedFormat(_raw_xml_data) & '&loaded=true');
		</cfscript>
	</cffunction>

	<cfscript>
		function read_qGetFTPReportsData() { if (IsDefined("Session.qGetFTPReportsData")) { Request.qGetFTPReportsData = Session.qGetFTPReportsData; } else { writeOutput('<font color="red"><b>WARNING: Your Session has timed-out due to inactivity. PLS refresh your FTP Reports Query by exiting back to the Home Page and then click on the appropriate button.</b></font>'); }; }
	</cfscript>

	<cffunction name="_getFTPData" access="public" returntype="string">
		<cfargument name="recid" type="string" required="yes">
		<cfargument name="delim" type="string" default=",">
		<cfargument name="quotes" type="string" default='"'>

		<cfscript>
			Request.primitiveCode.cf_lock('LOCK_qGetFTPReportsData', read_qGetFTPReportsData, 'READONLY', 'Session');
			
			// /*IML_FTP*/
		</cfscript>

		<cfsavecontent variable="_sql_statement">
			<cfoutput>
				SELECT id, last_modified_dt, file_length, file_name, file_path, file_url, raw_data
				FROM Request.qGetFTPReportsData
				WHERE <cfif (ListLen(recid, ",") eq 1)>(id = #recid#)<cfelse>(id in (#recid#))</cfif>
			</cfoutput>
		</cfsavecontent>

		<cfscript>
			Cr = Chr(13);
			Lf = Chr(10);
			CrLf = Cr & Lf;

			if (IsDefined("Request.qGetFTPReportsData")) {
				q = Request.primitiveCode.safely_execSQL('GetFTPRecord', '', _sql_statement);
			} else {
				q = Request.primitiveCode.safely_execSQL('GetFTPRecord', Request.DSN, _sql_statement);
			}
			
			if (NOT Request.dbError) {
				_raw_data = '';
				for (i = 1; i lte q.recordCount; i = i + 1) {
					_raw_data = _raw_data & Trim(URLDecode(q.raw_data[i]));
				}

				_qq = Request.excelReader.str2Query(_raw_data, Cr, Lf);

				dStream = Request.excelReader.query2FlashDataStream(_qq, delim, quotes);
			} else {
				writeOutput('<font color="red">#Request.errorMsg#</font><br>');
			}

			if (NOT IsDefined("Request._ftp_schema_map")) {
				Request._ftp_schema_map = ArrayNew(1);
			}
			
			if (NOT IsDefined("Request._ftp_schema")) {
				Request._ftp_schema = ArrayNew(1);
			}

			return '&recid=' & URLEncodedFormat(recid) & '&columnNames=' & URLEncodedFormat(ArrayToList(Request._ftp_schema_map, ',')) & '&columnHeaders=' & URLEncodedFormat(ArrayToList(Request._ftp_schema, ',')) & dStream & '&raw_data=' & URLEncodedFormat(_raw_data) & '&loaded=true';
		</cfscript>
	</cffunction>

	<cffunction name="getFTPData" description="Returns the data in a flash load vars format" access="remote" returntype="void">
		<cfargument name="recid" required="false" type="string" default=""/>

		<cfscript>
			writeOutput(_getFTPData(recid));
		</cfscript>
	</cffunction>

	<cffunction name="getSavedQueryText" description="Returns the data in a flash load vars format" access="remote" returntype="void">
		<cfargument name="recKey" required="false" type="string" default=""/>

		<cfscript>
			var i = -1;
			var q = -1;
			var _sql_statement = -1;
			var _begin_date = '';
			var _end_date = '';
			var _ftp_source = '';
			var _reportType = '';
			var _parameters = '';
		</cfscript>

		<cfsavecontent variable="_sql_statement">
			<cfoutput>
				SELECT SavedQueries.id, SavedQueries.qry_name, SavedQueries.begin_date, SavedQueries.end_date, SavedQueries.ftp_source, 
				       TibcoReportNameDefs.report_name AS reportType, SavedQueries.parameters
				FROM TibcoReportNameDefs INNER JOIN
				     SavedQueryReportType ON TibcoReportNameDefs.id = SavedQueryReportType.rep_id RIGHT OUTER JOIN
				     SavedQueries ON SavedQueryReportType.sqid = SavedQueries.id
				WHERE (UPPER(SavedQueries.qry_name) = '#UCASE(recKey)#')
			</cfoutput>
		</cfsavecontent>

		<cfscript>
			q = Request.primitiveCode.safely_execSQL('GetSavedQuery', Request.DSN, _sql_statement);

			_begin_date = '';
			_end_date = '';
			_ftp_source = '';
			_reportType = '';
			_parameters = '';
			if (NOT Request.dbError) {
				_begin_date = DateFormat(q.begin_date, 'mm/dd/yyyy');
				_end_date = DateFormat(q.end_date, 'mm/dd/yyyy');
				_ftp_source = q.ftp_source;
				_reportType = '';
				for (i = 1; i lte q.recordCount; i = i + 1) {
					_reportType = ListAppend(_reportType, q.reportType[i], ',');
				}
				_parameters = q.parameters;
			}

			writeOutput('&recKey=' & URLEncodedFormat(recKey) & '&begin_date=' & URLEncodedFormat(_begin_date) & '&end_date=' & URLEncodedFormat(_end_date) & '&ftp_source=' & URLEncodedFormat(_ftp_source) & '&reportType=' & URLEncodedFormat(_reportType) & '&parameters=' & URLEncodedFormat(_parameters) & '&loaded=true');
		</cfscript>
	</cffunction>

	<cffunction name="getFTPSavedQueries" description="Returns the data in a flash load vars format" access="remote" returntype="void">

		<cfscript>
			_sql_statement = "SELECT id, qry_name FROM SavedQueries ORDER BY qry_name";
			q = Request.primitiveCode.safely_execSQL('GetSavedQueryList', Request.DSN, _sql_statement);

			writeOutput('&cnt_list=#q.recordCount#');
			if (NOT Request.dbError) {
				for (i = 1; i lte q.recordCount; i = i + 1) {
					writeOutput('&cnt_list#i#=#q.qry_name[i]#');
				}
			}

			writeOutput('&loaded=true');
		</cfscript>
	</cffunction>

	<cfscript>
		function processDataStream(dStream) {
			var i = -1;
			var j = -1;
			var db_err = false;
			var numCols_headers = -1;
			var numCols_names = -1;
			var numRows = -1;
			var numUsefulRows = -1;
			var bool_usefulData = -1;
			var _sql_statement = '';
			var _varName = -1;
			var _data = -1;
			var _data_cols = -1;
			var _safe_to_proceed = -1;
			var qFTPReportData = -1;
			var qFTPTrashData = -1;
			var rowNum = -1;
			var _data_array = -1;
			var is_repeated_headers = -1;
			var _reason_for_trash = -1;

			Request.dQ = Request.excelReader.DataStreamToQueryObject(dStream);
	
			numCols_headers = -1;
			numCols_names = -1;
			numRows = -1;
			numUsefulRows = 0;
			bool_usefulData = true;

			if (IsQuery(Request.dQ)) {
				if (IsDefined("Request.dQ.COLUMNHEADERS")) {
					numCols_headers = ListLen(Request.dQ.COLUMNHEADERS, ',');
				}
				if (IsDefined("Request.dQ.COLUMNNAMES")) {
					numCols_names = ListLen(Request.dQ.COLUMNNAMES, ',');
				}
				if (IsDefined("Request.dQ.ROWCOUNT")) {
					numRows = Request.dQ.ROWCOUNT;
					for (i = 1; i lte numRows; i = i + 1) {
						_sql_statement = "SELECT Row#i# FROM Request.dQ";
						q = Request.primitiveCode.safely_execSQL('GetARecord', '', _sql_statement);
						if (NOT Request.dbError) {
							_varName = 'q.Row#i#';
							try {
								_data = Evaluate(_varName);
							} catch (Any e) {
								_data = '';
							}
							_data_cols = ListLen(_data, ',');
							if ( (Len(Trim(_data)) gt 0) AND (_data_cols eq numCols_headers) AND (_data_cols eq numCols_names) ) {
								numUsefulRows = numUsefulRows + 1;
							}
						}
					}
				}
	
				if ( (numCols_headers eq -1) OR (numCols_names eq -1) OR (numCols_headers neq numCols_names) ) { //  OR (numRows lte 0) OR (numRows neq numUsefulRows)
					bool_usefulData = false;
					writeOutput('<tr>');
					writeOutput('<td align="center" colspan="2">');
					writeOutput('<span class="errorStatusClass"><b>ERROR: Invalid FTP Data Record or No Useful Data Present.</b> <i>(The most likely cause of this error is missing headers in the raw data which means the parser is NOT able to resolve columns from the raw data stream.)</i></span>');
					writeOutput('</td>');
					writeOutput('</tr>');
				}
	
				if (IsDefined("Request.dQ.COLUMNNAMES")) {
					_safe_to_proceed = true;
					try {
						qFTPReportData = QueryNew('id,' & Request.dQ.COLUMNNAMES);
						qFTPTrashData = QueryNew('id,' & Request.dQ.COLUMNNAMES);
					} catch (Any e) {
						_safe_to_proceed = false;
					}
	
					if ( (_safe_to_proceed) AND (IsDefined("Request.dQ.ROWCOUNT")) ) {
						rowNum = 1;
						numRows = Request.dQ.ROWCOUNT;
						for (i = 1; i lte numRows; i = i + 1) {
							_sql_statement = "SELECT Row#i# FROM Request.dQ";
							q = Request.primitiveCode.safely_execSQL('GetARecord', '', _sql_statement);
							if (NOT Request.dbError) {
								_varName = 'q.Row#i#';
								try {
									_data = Evaluate(_varName);
								} catch (Any e) {
									_data = '';
								}
								_data_array = ListToArray(_data, ',');
								_data_cols = ArrayLen(_data_array);
			
								is_repeated_headers = false;
								for (j = 1; j lte _data_cols; j = j + 1) {
									if (URLDecode(Request.commonCode._GetToken(Request.dQ.COLUMNHEADERS, j, ',')) eq URLDecode(_data_array[j])) {
										is_repeated_headers = true;
										break;
									}
								}
	
								if ( (Len(Trim(_data)) gt 0) AND (_data_cols eq numCols_headers) AND (_data_cols eq numCols_names) AND (NOT is_repeated_headers) ) {
									QueryAddRow(qFTPReportData, 1);
									QuerySetCell(qFTPReportData, 'id', rowNum, qFTPReportData.recordCount);
									for (j = 1; j lte _data_cols; j = j + 1) {
										QuerySetCell(qFTPReportData, Request.commonCode._GetToken(Request.dQ.COLUMNNAMES, j, ','), URLDecode(_data_array[j]), qFTPReportData.recordCount);
									}
									rowNum = rowNum + 1;
								} else {
									QueryAddRow(qFTPTrashData, 1);
									QuerySetCell(qFTPTrashData, 'id', rowNum, qFTPTrashData.recordCount);
									for (j = 1; j lte _data_cols; j = j + 1) {
										try {
											QuerySetCell(qFTPTrashData, Request.commonCode._GetToken(Request.dQ.COLUMNNAMES, j, ','), URLDecode(_data_array[j]), qFTPTrashData.recordCount);
										} catch (Any e) {
										}
									}
									_reason_for_trash = 'This trash row of data appeared on row ## #i# within the raw data stream. ';
									if (_data_cols neq numCols_headers) {
										_reason_for_trash = _reason_for_trash & 'Number of data cols (#_data_cols#) was NOT equal to the number of header cols (#numCols_headers#). ';
									}
									if (_data_cols neq numCols_names) {
										_reason_for_trash = _reason_for_trash & 'Number of data cols (#_data_cols#) was NOT equal to the number of column names (#numCols_names#). ';
									}
									if (is_repeated_headers) {
										_reason_for_trash = _reason_for_trash & 'This is a repeated header row and is therefore redundant. ';
									}
									if ( (i eq 1) AND (is_repeated_headers) ) {
										_reason_for_trash = _reason_for_trash & 'This row of data was actually not trashed however it was also not processed as "data".  Most likely this is the actual row of headers. ';
									}
									QuerySetCell(qFTPTrashData, 'ID', _reason_for_trash, qFTPTrashData.recordCount);
								}
							}
						}
					}
					Request.qFTPReportData = qFTPReportData;
					Request.qFTPTrashData = qFTPTrashData;
				}
			}
			Request.bool_usefulData = bool_usefulData;
			Request.db_err = db_err;
		}

		function processRawData(recid, repName) {
			var dStream = -1;
			
			if (FindNoCase('Proof of Delivery Detail', repName) gt 0) {
				dStream = _getFTPData(recid, '~', '');
			} else {
				dStream = _getFTPData(recid);
			}

			processDataStream(dStream);
		}
	</cfscript>

</cfcomponent>
