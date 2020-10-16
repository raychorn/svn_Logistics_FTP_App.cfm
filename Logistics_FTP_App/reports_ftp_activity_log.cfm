<cfparam name="beginTime" type="string" default="">
<cfparam name="endTime" type="string" default="">

<CFINCLUDE TEMPLATE="Header.cfm">

<cfscript>
	const_beginTime_symbol = '%beginTime%';
	const_endTime_symbol = '%endTime%';
</cfscript>

<cfsavecontent variable="sql_qGetFTPActivityLog">
	SELECT id, the_dt, log_msg
	FROM TIBCO_FTP_LOG
	WHERE (the_dt >= %beginTime%) AND (the_dt <= %endTime%)
	ORDER BY the_dt
</cfsavecontent>

<cfscript>
	if ( (Len(Trim(beginTime)) gt 0) AND (Len(Trim(endTime)) gt 0) AND (IsDate(beginTime)) AND (IsDate(endTime)) ) {
		_beginTime = ParseDateTime(beginTime);
		_endTime = ParseDateTime(endTime);
		fmt_beginTime = DateFormat(_beginTime, "mm/dd/yyyy") & ' ' & TimeFormat(_beginTime, "HH:mm:ss");
		fmt_endTime = DateFormat(_endTime, "mm/dd/yyyy") & ' ' & TimeFormat(_endTime, "HH:mm:ss");
		_sql_statement = ReplaceNoCase(sql_qGetFTPActivityLog, const_beginTime_symbol, "CAST('#fmt_beginTime#' as datetime)");
		_sql_statement = ReplaceNoCase(_sql_statement, const_endTime_symbol, "CAST('#fmt_endTime#' as datetime)");

		qLog = Request.primitiveCode.safely_execSQL('qGetLogData', Request.DSN, _sql_statement);
		if (Request.dbError) {
			writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the data from the database for this request.</span><br>' & Request.fullErrorMsg);
		} else {
			writeOutput('<table>');
			writeOutput('<tr bgcolor="silver">');
			writeOutput('<td align="center">');
			writeOutput('<b>##</b>');
			writeOutput('</td>');
			writeOutput('<td align="center">');
			writeOutput('<b>Date</b>');
			writeOutput('</td>');
			writeOutput('<td align="center">');
			writeOutput('<b>Log Text</b>');
			writeOutput('</td>');
			writeOutput('</tr>');
			for (i = 1; i lte qLog.recordCount; i = i + 1) {
				_bgColor = '##FFFFB9';
				if ((i MOD 2) eq 0) {
					_bgColor = '##B3FFFF';
				}
				writeOutput('<tr bgcolor="' & _bgColor & '">');
				writeOutput('<td align="center">');
				writeOutput('<span class="textClass">' & i & '</span>');
				writeOutput('</td>');
				writeOutput('<td align="center">');
				writeOutput('<span class="textClass">' & DateFormat(qLog.the_dt[i], "mm/dd/yyyy") & ' ' & TimeFormat(qLog.the_dt[i], "HH:mm:ss") & '</span>');
				writeOutput('</td>');
				writeOutput('<td align="left">');
				writeOutput('<span class="textClass">' & qLog.log_msg[i] & '</span>');
				writeOutput('</td>');
				writeOutput('</tr>');
			}
			writeOutput('</table>');
		}
	}
</cfscript>

<CFINCLUDE template="footer.cfm">

