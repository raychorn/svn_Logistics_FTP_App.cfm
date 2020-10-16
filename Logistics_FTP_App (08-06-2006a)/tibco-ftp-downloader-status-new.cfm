<cfparam name="URL.opt" type="string" default="">

<cfparam name="html_Opt101" type="string" default="">

<cfsetting enablecfoutputonly="No" showdebugoutput="No">

<cfinclude template="cfinclude_tibco_ftp_functions.cfm">

<cfscript>
	function performDupesAnalysisUsing(qT, qS) {
		var i = -1;
		var n = -1;
		var _sql = '';
		var lst = '';
		var ar_lid_fid = ArrayNew(1);
		var qR = QueryNew('');

		if ( (IsQuery(qT)) AND (IsQuery(qS)) ) {
			variables.qT = qT;

			n = qS.recordCount;
			for (i = 1; i lte n; i = i + 1) {
				_sql = "SELECT #variables.qT.columnList# FROM variables.qT WHERE (lid = #qS.lid[i]#) AND (fid = #qS.fid[i]#)";
				qR = Request.primitiveCode.safely_execSQL('qGetMatchingRecs', '', _sql);
				if (Request.dbError) {
					qR = QueryNew('');
					break;
				} else {
					ar_lid_fid[ArrayLen(ar_lid_fid) + 1] = qR.lid & '+' & qR.fid;
				}
			}
			variables._sql = '';
			if (ArrayLen(ar_lid_fid) gt 0) {
				lst = Request.commonCode.arrayToSQL_inClause(ar_lid_fid, ',');
				variables._sql = "SELECT #variables.qT.columnList# FROM variables.qT WHERE (STR(lid) + '+' + STR(fid) NOT IN (#lst#))";
				qR = Request.primitiveCode.safely_execSQL('qGetNotMatchingRecs', '', variables._sql);
				if (Request.dbError) {
					qR = QueryNew('');
				}
			}
		}

		return qR;
	}
	
	function prepareWorkQueueForDisplay(q) {
		var i = -1;
		var n = -1;
		var ar = -1;
		var _sql = '';
		var qR = QueryNew('');

		if (IsQuery(q)) {
			n = q.recordCount;
			ar = ArrayNew(1);
			for (i = 1; i lte n; i = i + 1) {
				try {
					_sql = "SELECT id, report_prefix, report_name FROM TibcoReportNameDefs WHERE (PATINDEX ( '%' + report_prefix + '%' , '#q.SHORT_NAME[i]#') > 0)";
					qGRT = Request.primitiveCode.safely_execSQL('qGetReportType', Request.DSN, _sql);
					if (NOT Request.dbError) {
						ar[i] = qGRT.report_name;
					}
				} catch (Any e) {
				}
			}
			QueryAddColumn(q, 'ReportType', 'varchar', ar);

			Request.qTemp = q;
			_sql = "SELECT FULL_DIR_NAME, ACTUALBYTECOUNT, ReportType FROM Request.qTemp";
			qR = Request.primitiveCode.safely_execSQL('qGetMatchingRecs', '', _sql);
			if (Request.dbError) {
				qR = QueryNew('');
			}
		}

		return qR;
	}
	
	function displayQueueForUsers(q, s_info) {
		var i = -1;
		var n = -1;
		var c = '';
		var color1 = '##FFFFB9';
		var color2 = '##B3FFFF';

		if (IsQuery(q)) {
			writeOutput('<table>');
			writeOutput('<tr bgcolor="silver">');
			writeOutput('<td>');
			writeOutput('<span class="instructionsClass">');
			writeOutput("<b>FTP Server's File Descriptor</b> <i>" & s_info & "</i>");
			writeOutput('</span>');
			writeOutput('</td>');
			writeOutput('<td>');
			writeOutput('<span class="instructionsClass">');
			writeOutput('<b>Report Type</b>');
			writeOutput('</span>');
			writeOutput('</td>');
			writeOutput('<td>');
			writeOutput('<span class="instructionsClass">');
			writeOutput('<b>Estimated Byte Count for Report</b>');
			writeOutput('</span>');
			writeOutput('</td>');
			writeOutput('</tr>');
			n = q.recordCount;
			for (i = 1; i lte n; i = i + 1) {
				c = color1;
				if (i MOD 2) {
					c = color2;
				}
				writeOutput('<tr bgcolor="#c#">');
				writeOutput('<td>');
				writeOutput('<span class="instructionsClass">');
				writeOutput(q.FULL_DIR_NAME[i]);
				writeOutput('</span>');
				writeOutput('</td>');
				writeOutput('<td>');
				writeOutput('<span class="instructionsClass">');
				writeOutput(q.REPORTTYPE[i]);
				writeOutput('</span>');
				writeOutput('</td>');
				writeOutput('<td align="center">');
				writeOutput('<span class="instructionsClass">');
				writeOutput(q.ACTUALBYTECOUNT[i]);
				writeOutput('</span>');
				writeOutput('</td>');
				writeOutput('</tr>');
			}
			writeOutput('</table>');
		}
	}
</cfscript>

<cfscript>
	Request._qActivity = Request.commonCode._initCachedLog('TIBCO_FTP_LOG');

	isOpt101 = false;
	if (UCASE(URL.opt) eq UCASE(Request.const_opt_101_symbol)) {
		isOpt101 = true;
	}

	_sql_statement_qW = sql_getFTPWorkQueueFromDbWhere(false);
	if (isOpt101) {
		_sql_statement_qW = ReplaceNoCase(_sql_statement_qW, ' TOP 1 ', ' ');
	}
	qW = getFTPWorkQueueFromDb(_sql_statement_qW, false);

	if (0) {
		_sql_statement_qW2 = sql_getFTPWorkQueueFromDbWhere(true);
		if (isOpt101) {
			_sql_statement_qW2 = ReplaceNoCase(_sql_statement_qW2, ' TOP 1 ', ' ');
		}
		qW2 = getFTPWorkQueueFromDb(_sql_statement_qW2, true);
	}

	if (isOpt101) {
		qP = GetDownloadedNotYetProcessedQueue(isOpt101, sql_qGetFileToProcessFromDb());
	}

	_shortName = '';
	if ( (IsQuery(qW)) AND (IsDefined("qW.short_name")) AND (Len(qW.short_name) gt 0) ) {
		_shortName = qW.short_name;
	} else if (NOT isOpt101) {
		// if there is nothing to download is there something to process ?
		qP = GetDownloadedNotYetProcessedQueue(isOpt101, sql_qGetFileToProcessFromDb());
		_shortName = '';
		if ( (IsQuery(qP)) AND (IsDefined("qP.short_name")) AND (Len(qP.short_name) gt 0) ) {
			_shortName = qP.short_name;
		}
	}
</cfscript>

<cfif (isOpt101)>
	<cfsavecontent variable="html_Opt101">
		<cfoutput>
			<h3 align="center">FTP Process Validation Status</h3>
			<table width="95%">
				<tr>
					<td>
						<p align="justify">
						<span class="instructionsClass">
						The purpose of this display is to allow the user to quickly "see" whether or not the FTP Downloader Process has become stuck or backlogged and otherwise unable to keep-up with the number of FTP Reports this system is called upon to download in a timely manner.
						<br><br>
						When this system is working correctly and there are no real problems with the FTP Downloader Process the user will not see any files displayed below.
						<br><br>
						Files are downloaded and then processed using two separate queues and thus the reason for two separate lists or tables of files.
						</span>
						</p>
					</td>
				</tr>
			</table>
		</cfoutput>
	</cfsavecontent>
</cfif>

<cfif (isOpt101)>
	<CFINCLUDE TEMPLATE="Header.cfm">
</cfif>

<cfscript>
	if (NOT isOpt101) {
		writeOutput('&_shortName=' & _shortName);
	} else {
		writeOutput(html_Opt101);

		// BEGIN: qW has the Work Queue - these are files yet to be downloaded...
		qWr = prepareWorkQueueForDisplay(qW);
		displayQueueForUsers(qWr, 'Work Queue - these are files yet to be downloaded.');
		// END! qW has the Work Queue - these are files yet to be downloaded...

		// BEGIN: qP has the Process Queue - these are files yet to be processed however they were downloaded...
		qPr = prepareWorkQueueForDisplay(qP);
		displayQueueForUsers(qPr, 'Process Queue - these are files yet to be processed.');
		// END! qP has the Process Queue - these are files yet to be processed however they were downloaded...
		
	//	qT = performDupesAnalysisUsing(qW, qP);
	//	writeOutput(Request.primitiveCode.cf_dump(qT, 'qT - [#variables._sql#]', false));
	}
</cfscript>

<cfif (isOpt101)>
	<CFINCLUDE template="footer.cfm">
</cfif>
