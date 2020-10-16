<cfsetting requesttimeout="#(60 * 60 * 5)#">

<CFINCLUDE TEMPLATE="Header.cfm">

<cfsavecontent variable="sql_qDataChildren">
	<cfoutput>
		SELECT TIBCO_FTP_SHORT_NAMES.lid, TIBCO_FTP_SHORT_NAMES.short_name, TIBCO_FTP_DATA.id, TIBCO_FTP_DATA.the_dt, TIBCO_FTP_DATA.raw_data, 
		       DATALENGTH(TIBCO_FTP_DATA.raw_data) AS byteCount
		FROM TIBCO_FTP_DATA INNER JOIN
		     TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP_DATA.lid = TIBCO_FTP_SHORT_NAMES.lid
		WHERE (DATALENGTH(TIBCO_FTP_DATA.raw_data) IS NOT NULL) AND (DATALENGTH(TIBCO_FTP_DATA.raw_data) > 0)#Request.const_where_clause_token#
		ORDER BY TIBCO_FTP_SHORT_NAMES.lid, TIBCO_FTP_DATA.the_dt
	</cfoutput>
</cfsavecontent>

<cfsavecontent variable="sql_qParentData">
	<cfoutput>
		SELECT TOP 1 TIBCO_FTP_FULL_NAMES.full_dir_name, TIBCO_FTP_SHORT_NAMES.short_name, TIBCO_FTP_SHORT_NAMES.lid, 
		       DATALENGTH(TIBCO_FTP.raw_data) AS byteCount, TIBCO_FTP.raw_data, TIBCO_FTP_FULL_NAMES.fid, TIBCO_FTP_PROCESS_VALIDATION.bool_validated, 
		       CAST(dbo.StrTok(TIBCO_FTP_FULL_NAMES.full_dir_name, 5, ' ') AS int) AS actualByteCount, TIBCO_FTP_PROCESS_QUEUE.id AS procId, 
		       TIBCO_FTP_PROCESS_VALIDATION.dt_validated, TIBCO_FTP_PROCESS_VALIDATION.dt_processed, 
		       TIBCO_FTP_PROCESS_VALIDATION.dt_bytesValidated
		FROM TIBCO_FTP LEFT OUTER JOIN
		     TIBCO_FTP_PROCESS_QUEUE ON TIBCO_FTP.lid = TIBCO_FTP_PROCESS_QUEUE.lid AND 
		     TIBCO_FTP.fid = TIBCO_FTP_PROCESS_QUEUE.fid LEFT OUTER JOIN
		     TIBCO_FTP_PROCESS_VALIDATION ON 
		     TIBCO_FTP_PROCESS_QUEUE._destFName = TIBCO_FTP_PROCESS_VALIDATION._destFName LEFT OUTER JOIN
		     TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid LEFT OUTER JOIN
		     TIBCO_FTP_FULL_NAMES ON TIBCO_FTP.fid = TIBCO_FTP_FULL_NAMES.fid
		WHERE (DATALENGTH(TIBCO_FTP.raw_data) IS NOT NULL) AND (TIBCO_FTP_PROCESS_VALIDATION.bool_validated = 1) AND 
		      (TIBCO_FTP_PROCESS_QUEUE.id IS NOT NULL) AND (DATALENGTH(TIBCO_FTP.raw_data) > 0) AND (DATALENGTH(TIBCO_FTP.raw_data) IS NOT NULL)
		ORDER BY procId, TIBCO_FTP_PROCESS_VALIDATION.bool_validated, byteCount, actualByteCount DESC
	</cfoutput>
</cfsavecontent>

<!--- 
	Find children for each parent...
 --->

<cfinclude template="cfinclude_tibco_ftp_functions.cfm">

<cfscript>
	function queryAsTable(q) {
		var _html = '';
		var colName = '';
		var ar = -1;
		var i = -1;
		var n = -1;
		var j = -1;
		var m = -1;
		var cellColor = '';
		var color1 = '##FFFFB0';
		var color2 = '##C1FFFF';

		if (IsQuery(q)) {
			_html = _html & '<table>';
			_html = _html & '<tr bgcolor="silver">';
			ar = ListToArray(q.columnList, ',');
			n = ArrayLen(ar);
			for (i = 1; i lte n; i = i + 1) {
				colName = ar[i];
				_html = _html & '<td align="center">';
				_html = _html & '<span style="font-size: 11px;">' & colName & '</span>';
				_html = _html & '</td>';
			}
			_html = _html & '</tr>';
			m = q.recordCount;
			for (j = 1; j lte m; j = j + 1) {
				cellColor = color1;
				if ((j MOD 2) eq 0) {
					cellColor = color2;
				}
				_html = _html & '<tr bgcolor="' & cellColor & '">';
				for (i = 1; i lte n; i = i + 1) {
					colName = ar[i];
					_html = _html & '<td align="left">';
					if (UCASE(colName) neq UCASE('raw_data')) {
						_html = _html & '<span style="font-size: 11px;">' & q[colName][j] & '</span>';
					} else {
						_html = _html & '&nbsp;';
					}
					_html = _html & '</td>';
				}
				_html = _html & '</tr>';
			}
			_html = _html & '</table>';
		}
		return _html;
	}
</cfscript>

<cfflush>
 
<cfscript>
	qAnalysis = Request.primitiveCode.safely_execSQL('qFindParentData', Request.DSN, sql_qParentData);
	if (Request.dbError) {
		writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the data from the database for this request.</span><br>' & Request.fullErrorMsg);
	} else {
		writeOutput('<span class="normalStatusClass">There are #qAnalysis.recordCount# records to analyze.</span>');

		beginTime = Now();
		writeOutput('<span class="normalStatusClass">BEGIN: #beginTime#</span>');
		
	//	writeOutput(Request.primitiveCode.cf_dump(qAnalysis, 'qAnalysis - [#sql_qParentData#]', true));
		writeOutput(queryAsTable(qAnalysis));
		
		s_raw_data = URLDecode(qAnalysis.raw_data);
		writeOutput('Len(qAnalysis.raw_data) = [#Len(qAnalysis.raw_data)#], Len(s_raw_data) = [#Len(s_raw_data)#]<br>');

		writeOutput('<textarea readonly cols="120" rows="20" style="font-size: 11px;">' & s_raw_data & '</textarea>');

		// Get a List of days...
		for (i = 1; i lte qAnalysis.recordCount; i = i + 1) {
			_sql = ReplaceNoCase(sql_qDataChildren, Request.const_where_clause_token, " AND (TIBCO_FTP_SHORT_NAMES.lid = #qAnalysis.lid[i]#)");
			qW = Request.primitiveCode.safely_execSQL('qFindChildren', Request.DSN, _sql);
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the child data from the database for this parent.</span><br>' & Request.fullErrorMsg);
			} else {
			//	writeOutput(Request.primitiveCode.cf_dump(qW, 'qW - [#_sql#]', true));
				writeOutput(queryAsTable(qW));
			}
		}

		endTime = Now();
		writeOutput('<span class="normalStatusClass">END: #endTime#</span><br>');

		_elapsedTime = endTime - beginTime;
		fmt_elapsedTime = TimeFormat(_elapsedTime, "HH:mm:ss");
		writeOutput('<span class="normalStatusClass">Elapsed Time: #fmt_elapsedTime#</span><br>');
	}
</cfscript>

<CFINCLUDE template="footer.cfm">
