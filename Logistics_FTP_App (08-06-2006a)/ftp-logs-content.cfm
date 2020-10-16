<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="120">

<cfparam name="nocache" type="string" default="">
<cfparam name="recid" type="string" default="-1">
<cfparam name="repName" type="string" default="">
<cfparam name="sDate" type="date">
<cfparam name="sDataSrc" type="string" default="">
<cfparam name="sFilePath" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (FTP Process Activity Logs) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>

	<style>
		BODY {
			margin: 0px;
			padding: 0px;
			background-color: white;
			color: black;
			font-family: Verdana, Arial, Helvetica, sans-serif;
			font-size: xx-small;
		}
		
		.textareaClass {
			font-size: 10px;
		}

		.errorStatusClass {
			font-size: 10px;
			color: red;
		}

		.normalStatusClass {
			font-size: 10px;
			color: blue;
		}

		.buttonClass {
			font-size: 10px;
			font-weight: bold;
		}
	</style>

</head>

<body>

<cfflush>

	<cfoutput>
		<cfset bool_usefulData = "False">
		
		<cfscript>
			_sql_statement = "SELECT id, report_prefix, report_name FROM TibcoReportNameDefs WHERE (UPPER(report_name) = '#UCASE(repName)#')";
			qRepFilePrefix = Request.primitiveCode.safely_execSQL('qGetRepFilePrefix', Request.DSN, _sql_statement);
			if ( (NOT Request.dbError) AND (qRepFilePrefix.recordCount gt 0) ) {
				_repDate = ParseDateTime(sDate);
				_beginDate = ParseDateTime(DateFormat(_repDate, 'mm/dd/yyyy') & ' ' & '00:00:00');
				Request.fmt_beginDate = DateFormat(_beginDate, 'mm/dd/yyyy') & ' ' & TimeFormat(_beginDate, 'HH:mm:ss');
				_endDate = ParseDateTime(DateFormat(_repDate, 'mm/dd/yyyy') & ' ' & '23:59:59');
				Request.fmt_endDate = DateFormat(_endDate, 'mm/dd/yyyy') & ' ' & TimeFormat(_endDate, 'HH:mm:ss');
		
				_repFileName = qRepFilePrefix.report_prefix;
				Request._repDesc = qRepFilePrefix.report_name;

				Request._fName = Request.commonCode._GetToken(sFilePath, ListLen(sFilePath, '/'), '/');

				_log_table_name = 'IML_FTP_LOG';
				_sql_statement = "SELECT id, the_dt, log_msg FROM #_log_table_name# WHERE (the_dt >= CAST('#Request.fmt_beginDate#' as datetime)) AND (the_dt <= CAST('#Request.fmt_endDate#' as datetime)) AND (log_msg like '%#Request._fName#%') ORDER BY the_dt";
				if (UCASE(sDataSrc) eq UCASE(Request.const_31_day_symbol)) {
					_log_table_name = 'TIBCO_FTP_LOG';
					_sql_statement = "SELECT id, the_dt, log_msg FROM #_log_table_name# WHERE (the_dt >= CAST('#Request.fmt_beginDate#' as datetime)) AND (the_dt <= CAST('#Request.fmt_endDate#' as datetime)) AND (log_msg like '%(#_repFileName#%') ORDER BY the_dt";
				}

				qLog = Request.primitiveCode.safely_execSQL('qGetFTPLogs', Request.DSN, _sql_statement);
				if (NOT Request.dbError) {
					if (qLog.recordCount gt 0) {
						filter_beginDate = ParseDateTime(DateFormat(qLog.the_dt[1], 'mm/dd/yyyy') & ' ' & TimeFormat(qLog.the_dt[1], 'HH:00:00'));
						filter_endDate = ParseDateTime(DateFormat(qLog.the_dt[qLog.recordCount], 'mm/dd/yyyy') & ' ' & TimeFormat(qLog.the_dt[qLog.recordCount], 'HH:59:59'));

						Request.fmt_beginDate = DateFormat(filter_beginDate, 'mm/dd/yyyy') & ' ' & TimeFormat(filter_beginDate, 'HH:mm:ss');
						Request.fmt_endDate = DateFormat(filter_endDate, 'mm/dd/yyyy') & ' ' & TimeFormat(filter_endDate, 'HH:mm:ss');

						_ts = DateFormat(sDate, 'yyyy-mm-dd') & ' ' & TimeFormat(sDate, 'HH:mm:ss.0'); // 2005-07-22 05:49:00.0

						_sql_statement = "SELECT id, the_dt, log_msg FROM #_log_table_name# WHERE (the_dt >= CAST('#Request.fmt_beginDate#' as datetime)) AND (the_dt <= CAST('#Request.fmt_endDate#' as datetime)) AND ( ( (log_msg like '%#sFilePath#%') AND (log_msg like '%last_modified_dt=#_ts#%') ) OR (log_msg like '%FTP Action GETFILE/READBINARY%') AND (log_msg like '%#Request._fName#]%') ) ORDER BY id, the_dt";
						if (UCASE(sDataSrc) eq UCASE(Request.const_31_day_symbol)) {
							if (Request.commonCode.isServerLocal()) {
								_sql_statement = "SELECT id, the_dt, log_msg FROM #_log_table_name# WHERE (the_dt >= CAST('#Request.fmt_beginDate#' as datetime)) AND (the_dt <= CAST('#Request.fmt_endDate#' as datetime)) AND ( (log_msg like '%<--%') OR (log_msg like '%INFO:%') OR (log_msg like '%About%') OR (log_msg like '%qB.%') OR (log_msg like '%0. splitRawDataIntoBatchesUsing%') ) ORDER BY the_dt";
							} else {
								_sql_statement = "SELECT id, the_dt, log_msg FROM #_log_table_name# WHERE (the_dt >= CAST('#Request.fmt_beginDate#' as datetime)) AND (the_dt <= CAST('#Request.fmt_endDate#' as datetime)) AND ( (log_msg like '%<--%') OR (log_msg like '%INFO:%') OR (log_msg like '%About%') OR (log_msg like '%qB.%') ) ORDER BY the_dt";
							}
						}

						qLog2 = Request.primitiveCode.safely_execSQL('qGetFTPLogs2', Request.DSN, _sql_statement);

						if (UCASE(sDataSrc) neq UCASE(Request.const_31_day_symbol)) {
//							writeOutput('qLog2.recordCount = [#qLog2.recordCount#]<br>');
//							writeOutput(Request.primitiveCode.cf_dump(qLog2, 'qLog2 [#_sql_statement#]', false));
						}

						if (NOT Request.dbError) {
							// find the first "About to fetch (#_repFileName#"
							i = 1;
							if (UCASE(sDataSrc) eq UCASE(Request.const_31_day_symbol)) {
								_str2Find = 'About to fetch (#_repFileName#';
								for (i = 1; i lte qLog2.recordCount; i = i + 1) {
									if (FindNoCase(_str2Find, qLog2.log_msg[i]) gt 0) {
										break;
									}
								}
							}
							if (i lte qLog2.recordCount) {
								// qB.FULL_DIR_NAME_ABBREV[6] = [133922 88247 Jul 26 04:29 SRP600PCD0001.MON] 
								_str2Find_1 = '[Deleted Temp File';
								_str2Find_2 = '#Request._fName#]';
								if (UCASE(sDataSrc) eq UCASE(Request.const_31_day_symbol)) {
									_str2Find_1 = 'qB.FULL_DIR_NAME_ABBREV[';
									_str2Find_2 = _repFileName;
								}

								for (j = qLog2.recordCount; j gte 1; j = j - 1) {
									if ( (FindNoCase(_str2Find_1, qLog2.log_msg[j]) gt 0) AND (FindNoCase(_str2Find_2, qLog2.log_msg[j]) gt 0) ) {
										break;
									}
								}

								if (j lt 1) {
									j = qLog2.recordCount;
								}

								Request.qLog2 = qLog2;
								_sql_statement = "SELECT id, the_dt, log_msg FROM Request.qLog2 WHERE (id >= #qLog2.id[i]#) AND (id < #qLog2.id[j]#) ORDER BY the_dt";
								if (UCASE(sDataSrc) eq UCASE(Request.const_31_day_symbol)) {
									_sql_statement = "SELECT id, the_dt, log_msg FROM Request.qLog2 WHERE (id >= #qLog2.id[i]#) AND (id <= #qLog2.id[j]#) ORDER BY the_dt";
								}
								Request.qLog2a = Request.primitiveCode.safely_execSQL('qGetFTPLogs2a', '', _sql_statement);

								if (NOT Request.dbError) {
//									writeOutput('Request.qLog2a.recordCount = [#Request.qLog2a.recordCount#] records of [#qLog2.recordCount#]<br>');
//									writeOutput(Request.primitiveCode.cf_dump(Request.qLog2a, 'Request.qLog2a [#_sql_statement#]', false));
									
									// BEGIN: GUI goes here...
									Request.primitiveCode.cf_include('../cfinclude_ftp_logs_content_GUI.cfm');
									// END! GUI goes here...
								} else {
									writeOutput('<span class="errorStatusClass">ERROR: F. Programming error of some kind - see the error details...</span><br>' & Request.errorMsg);
								}
							} else {
								writeOutput('<span class="errorStatusClass">WARNING: E. No Logs to View for the date range of :: #Request.fmt_beginDate# to #Request.fmt_endDate# for the "#_repFileName#" report.</span><br>');
							}
						} else {
							writeOutput('<span class="errorStatusClass">ERROR: C. Cannot Retrieve the FTP Download Process Activity Logs for Report Named "#repName#" on #sDate# due to an error:</span><br>' & Request.errorMsg);
						}
					} else {
						Request.fmt_beginDate = DateFormat(_beginDate, 'mm/dd/yyyy') & ' ' & TimeFormat(_beginDate, 'HH:mm:ss');
						Request.fmt_endDate = DateFormat(_endDate, 'mm/dd/yyyy') & ' ' & TimeFormat(_endDate, 'HH:mm:ss');
						writeOutput('<span class="errorStatusClass">WARNING: D. No Logs to View for the date range of :: #Request.fmt_beginDate# to #Request.fmt_endDate# for the "#_repFileName#" report.</span><br>');
					}
				} else {
					writeOutput('<span class="errorStatusClass">ERROR: B. Cannot Retrieve the FTP Download Process Activity Logs for Report Named "#repName#" on #sDate# due to an error:</span><br>' & Request.errorMsg);
				}
			} else {
				writeOutput('<span class="errorStatusClass">ERROR: A. Cannot Retrieve the FTP Report File Prefix for Report Named "#repName#" on #sDate# due to an error:</span><br>' & Request.errorMsg);
			}
		</cfscript>
	
		<cfif (bool_usefulData)>
			<cfif (NOT db_err)>
			<cfelse>
				<BIG><span class="errorStatusClass">ERROR: Cannot Query FTP Download Process Logs because:</span></BIG><br>
				#Request.db_error#
			</cfif>
		</cfif>
	</cfoutput>

</body>
</html>

