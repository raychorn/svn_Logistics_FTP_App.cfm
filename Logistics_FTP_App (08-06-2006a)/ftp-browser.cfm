<cfsetting enablecfoutputonly="No" showdebugoutput="#Request.commonCode.isServerLocal()#" requesttimeout="#(5 * 60)#">

<cfset const_yes_symbol = "yes">
<cfset const_ftpGridPage = "ftpGridPage">
<cfset const_ftpQueryPage = "ftpQueryPage">

<cfset const_ChooseQuery_symbol = "Choose a Query...">

<cfparam name="nocache" type="string" default="">
<cfparam name="myQryName" type="string" default="">
<cfparam name="page" type="string" default="#const_ftpGridPage#">
<cfif (IsDefined("form.page"))>
	<cfset page = form.page>
</cfif>
<cfparam name="showAll" type="string" default="">
<cfparam name="showLast30" type="string" default="">
<cfparam name="showeom" type="string" default="">
<cfparam name="showpreveom" type="string" default="">

<cfparam name="_begin_date" type="string" default="">
<cfparam name="_end_date" type="string" default="">
<cfparam name="_myQryName" type="string" default="">
<cfparam name="_newQryName" type="string" default="">
<cfparam name="_ftpSource" type="string" default="">
<cfparam name="_myReportType" type="string" default="">
<cfparam name="_qryParameter_keyword" type="string" default="">

<cfset bool_showGrid = (page eq const_ftpGridPage)>

<cfinclude template="cfinclude_tibco_ftp_functions.cfm">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (FTP Browser) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>

	<script language="JavaScript1.2" type="text/javascript" src="js/disable-right-click-script-III.js"></script>
	<script language="JavaScript1.2" type="text/javascript" src="js/MathAndStringExtend.js"></script>
	<script language="JavaScript1.2" type="text/javascript" src="js/DHTMLWindows_obj.js"></script>

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

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		function redirectBrowserTo(_url) {
			window.location.href = _url;
		}
	// --> 
	</script>

</head>

<body>

<cfif 0>
	<cfdump var="#form#" label="form scope">
</cfif>

<cfflush>

<cfoutput>

<cfif (Request.bool_use_SQL_Server_Query_Aggregator)>
	<cfsavecontent variable="_sql_query_code">
		DECLARE @t as datetime
		SELECT @t = GETDATE()
		SELECT id, recid, last_modified_dt, file_length, file_name, file_path, file_url, report_name, raw_data, rec_id
		FROM dbo.GetCombinedTerseFTPReportsData(@t)
		WHERE (file_length IS NOT NULL) AND (file_length > 0)
		<!--- Note: Be sure no SQL code falls after the WHERE clause and that the WHERE clause does NOT end with an AND as the last token in the statement... --->
	</cfsavecontent>
<cfelseif (NOT Request.bool_use_SQL_Server_Query_Aggregator)>
	<cfsavecontent variable="_sql_query_code">
		DECLARE @t as datetime
		SELECT @t = GETDATE()
		DECLARE @bt as datetime
		SELECT @bt = CAST('#Request.const_begin_date_symbol#' as datetime)
		DECLARE @et as datetime
		SELECT @et = CAST('#Request.const_end_date_symbol#' as datetime)
		SELECT id, recid, last_modified_dt, file_length, file_name, file_path, file_url, report_name, raw_data, rec_id
		FROM dbo.GetCombinedTerseFTPReportsData(@t,@bt,@et)
	</cfsavecontent>
</cfif>

<cfif (UCASE(page) eq UCASE(const_ftpGridPage))>
	<cfscript>
		if (IsDefined("form.begin_date")) {
			_begin_date = form.begin_date;
		}

		if (IsDefined("form.end_date")) {
			_end_date = form.end_date;
		}
		
		if (IsDefined("form.myQryName")) {
			_myQryName = form.myQryName;
		}
		
		if (IsDefined("form.newQryName")) {
			_newQryName = form.newQryName;
		}
		
		if (IsDefined("form.ftpSource")) {
			_ftpSource = form.ftpSource;
		}
		
		if (IsDefined("form.myReportType")) {
			_myReportType = form.myReportType;
		}

		if (IsDefined("form.qryParameter_keyword")) {
			_qryParameter_keyword = form.qryParameter_keyword;
		}

		if (Len(Trim(_qryParameter_keyword)) gt 0) {
			_qryParameter_keyword = Request.excelReader.filterAlphaNumeric(_qryParameter_keyword);
		}
		if (UCASE(showAll) eq UCASE(const_yes_symbol)) {
			Client._myQryName = '';
		}

		Request.commonCode.determineFormDates(_begin_date, _end_date);
		form_begin_date = Request.form_begin_date;
		form_end_date = Request.form_end_date;

		if ( (UCASE(showAll) neq UCASE(const_yes_symbol)) AND (UCASE(showLast30) neq UCASE(const_yes_symbol)) AND (UCASE(showeom) neq UCASE(const_yes_symbol)) AND (UCASE(showpreveom) neq UCASE(const_yes_symbol)) ) {
			if ( (IsDefined("_myQryName")) AND (IsDefined("_newQryName")) ) {
				if ( (Len(Trim(_newQryName)) gt 0) AND (FindNoCase(const_ChooseQuery_symbol, _newQryName) eq 0) ) {
					_newQryName = Request.commonCode.filterQuotesForSQL(_newQryName);
					Client._myQryName = _newQryName;

					_sql_statement = "SELECT id FROM SavedQueries WHERE (qry_name = '#_newQryName#')";
					q = Request.primitiveCode.safely_execSQL('GetNamedQuery', Request.DSN, _sql_statement);

					if (q.recordCount eq 0) {
						_sql_statement = "INSERT INTO SavedQueries (qry_name";
						bool_begin_date = false;
						if ( (IsDefined("form_begin_date")) AND (IsNumericDate(form_begin_date)) ) {
							bool_begin_date = true;
							_sql_statement = _sql_statement & ", begin_date";
						}
						bool_end_date = false;
						if ( (IsDefined("form_end_date")) AND (IsNumericDate(form_end_date)) ) {
							bool_end_date = true;
							_sql_statement = _sql_statement & ", end_date";
						}
						bool_ftpSource = false;
						if ( (IsDefined("_ftpSource")) AND (Len(Trim(_ftpSource)) gt 0) ) {
							bool_ftpSource = true;
							_sql_statement = _sql_statement & ", ftp_source";
						}
						bool_parameters = false;
						if ( (IsDefined("_qryParameter_keyword")) AND (Len(Trim(_qryParameter_keyword)) gt 0) ) {
							bool_parameters = true;
							_sql_statement = _sql_statement & ", parameters";
						}
						_sql_statement = _sql_statement & ") VALUES ('#_newQryName#'";
						if (bool_begin_date) {
							_sql_statement = _sql_statement & "," & CreateODBCDate(ParseDateTime(form_begin_date));
						}
						if (bool_end_date) {
							_sql_statement = _sql_statement & "," & CreateODBCDate(ParseDateTime(form_end_date));
						}
						if (bool_ftpSource) {
							_sql_statement = _sql_statement & ", '#_ftpSource#'";
						}
						if (bool_parameters) {
							_sql_statement = _sql_statement & ", 'keyword=#Request.commonCode.filterQuotesForSQL(Request.commonCode.filterListVerbsForSQL(_qryParameter_keyword))#'";
						}
						_sql_statement = _sql_statement & "); SELECT @@IDENTITY AS 'id';";
						q = Request.primitiveCode.safely_execSQL('SaveNamedQuery', Request.DSN, _sql_statement);
		
						if (Request.dbError) {
							writeOutput('ERROR: Not able to Insert the Query !<br>');
						}
					} else {
						_sql_statement = "UPDATE SavedQueries SET ";
						_sql_statement = _sql_statement & "begin_date = " & CreateODBCDate(ParseDateTime(form_begin_date));
						_sql_statement = _sql_statement & ", ";
						_sql_statement = _sql_statement & "end_date = " & CreateODBCDate(ParseDateTime(form_end_date));
						_sql_statement = _sql_statement & ", ";
						_sql_statement = _sql_statement & "ftp_source = '#_ftpSource#'";
						_sql_statement = _sql_statement & ", ";
						_sql_statement = _sql_statement & "parameters = 'keyword=#Request.commonCode.filterQuotesForSQL(Request.commonCode.filterListVerbsForSQL(_qryParameter_keyword))#'";
						_sql_statement = _sql_statement & " WHERE (id = #q.id#)";
	
						Request.primitiveCode.safely_execSQL('UpdateNamedQuery', Request.DSN, _sql_statement);
	
						if (Request.dbError) {
							writeOutput('ERROR: Not able to Update the Query !<br>');
						}
					}

					if ( (NOT Request.dbError) AND (IsDefined("q.id")) AND (Len(q.id) gt 0) ) {
						_sql_statement_dropLinks = "DELETE FROM SavedQueryReportType WHERE (sqid = #q.id#);";
						q_dropLinks = Request.primitiveCode.safely_execSQL('qDropCurrentQueryLinkage', Request.DSN, _sql_statement_dropLinks);

						rt_list_len = ListLen(_myReportType, ',');
						for (rt_j = 1; rt_j lte rt_list_len; rt_j = rt_j + 1) {
							rt_tok = Trim(ReplaceNoCase(Request.commonCode._GetToken(_myReportType, rt_j, ','), '"', '', 'all'));
							if (Len(rt_tok) gt 0) {
								_sql_statement_repType = "SELECT id, report_prefix, report_name FROM TibcoReportNameDefs WHERE (UPPER(report_name) = '#UCASE(rt_tok)#')";
								qRepType = Request.primitiveCode.safely_execSQL('GetRepTypeFromNamedQuery#rt_j#', Request.DSN, _sql_statement_repType);
								if (NOT Request.dbError) {
									_sql_statement_insertLink = "INSERT INTO SavedQueryReportType (rep_id, sqid) VALUES (#qRepType.id#,#q.id#); SELECT @@IDENTITY AS 'id';";
									q_insertLink = Request.primitiveCode.safely_execSQL('qSaveLinkage#rt_j#', Request.DSN, _sql_statement_insertLink);
								}
							}
						}
					} else {
						writeOutput('ERROR: Not able to Update the Query Linkage to the Report Type(s) !<br>');
					}
				}
			}
		}
//writeOutput('C. Client._myQryName = [#Client._myQryName#]<br>');

		_myReportType = '';
		if (IsDefined("Client._myQryName")) {
			if (Len(Trim(Client._myQryName)) gt 0) {
				_myQryName = Client._myQryName;

				_sql_statement_ = "SELECT SavedQueries.id, SavedQueries.qry_name, SavedQueries.begin_date, SavedQueries.end_date, SavedQueries.ftp_source, TibcoReportNameDefs.report_name AS reportType, SavedQueries.parameters FROM SavedQueries INNER JOIN SavedQueryReportType ON SavedQueries.id = SavedQueryReportType.sqid INNER JOIN TibcoReportNameDefs ON SavedQueryReportType.rep_id = TibcoReportNameDefs.id WHERE (SavedQueries.qry_name = '#Request.commonCode.filterQuotesForSQL(_myQryName)#')";
				_qNamed = Request.primitiveCode.safely_execSQL('GetNamedQuery', Request.DSN, _sql_statement_);
//writeOutput(Request.primitiveCode.cf_dump(_qNamed, '_qNamed [#_sql_statement_#]', false));
				if ( (IsQuery(_qNamed)) AND (_qNamed.recordCount gt 0) AND (NOT Request.dbError) ) {
					_begin_date = _qNamed.begin_date;
					_end_date = _qNamed.end_date;
					Request.commonCode.determineFormDates(_begin_date, _end_date);
					form_begin_date = Request.form_begin_date;
					form_end_date = Request.form_end_date;
					_ftpSource = _qNamed.ftp_source;
					for (_qNamed_i = 1; _qNamed_i lte _qNamed.recordCount; _qNamed_i = _qNamed_i + 1) {
						_myReportType = ListAppend(_myReportType, _qNamed.reportType[_qNamed_i], ',');
					}
					_newQryName = _qNamed.qry_name;
					_parameters = _qNamed.parameters;
				}
			}
		}		
//writeOutput('D. Client._myQryName = [#Client._myQryName#]<br>');

	</cfscript>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		function popUpFTPReport(id, repName, rec_id) {
			DHTMLWindowsObj.loadwindow(aDHTMLObj100.id,'ftp-grid-report.cfm?nocache=' + uuid() + '&recid=' + id + '&repName=' + repName + '&rec_id=' + rec_id,950,500,10,10);
		}
	
		function popUpFTPReportInExcel(id, repName, rec_id, allow_dl, bool) {
			DHTMLWindowsObj.loadwindow(aDHTMLObj101.id,'ftp-excel-report.cfm?nocache=' + uuid() + '&recid=' + id + '&repName=' + repName + '&rec_id=' + rec_id + '&allow_dl=' + allow_dl + '&bool=' + bool,950,500,10,10);
		}
	
		function popUpFTPReportRaw(id, repName, rec_id, allow_dl, bool) {
			DHTMLWindowsObj.loadwindow(aDHTMLObj102.id,'ftp-raw-report.cfm?nocache=' + uuid() + '&recid=' + id + '&repName=' + repName + '&rec_id=' + rec_id + '&allow_dl=' + allow_dl + '&bool=' + bool,950,500,10,10);
		}
		
		function popUpFTPReportTrash(id, repName, rec_id, allow_dl) {
			DHTMLWindowsObj.loadwindow(aDHTMLObj103.id,'ftp-trash-report.cfm?nocache=' + uuid() + '&recid=' + id + '&repName=' + repName + '&rec_id=' + rec_id + '&allow_dl=' + allow_dl,950,500,10,10);
		}
		
		function popUpFTPReport2DataMart(recid, repName, dm_id, allow_dl, repType, filePath) {
//			alert(999);
//			alert('popUpFTPReport2DataMart(recid=' + recid + ', repName=' + repName + ', dm_id=' + dm_id + ', allow_dl=' + allow_dl + ', repType=' + repType + ')');
			DHTMLWindowsObj.loadwindow(aDHTMLObj104.id,'ftp-to-datamart.cfm?nocache=' + uuid() + '&recid=' + recid + '&repName=' + repName + '&dm_id=' + dm_id + '&allow_dl=' + allow_dl + '&repType=' + repType + '&filePath=' + filePath,950,500,10,10);
		}
		
		function popUpFTPDataMartProcess(id, repName, allow_dl, dm_id) {
			DHTMLWindowsObj.loadwindow(aDHTMLObj105.id,'ftp-datamart-process.cfm?nocache=' + uuid() + '&recid=' + id + '&repName=' + repName + '&allow_dl=' + allow_dl + '&dm_id=' + dm_id,950,500,10,10);
		}
	
		function popUpFTPLogsReport(id, repName, sDate, sDataSrc, sFilePath) {
			DHTMLWindowsObj.loadwindow(aDHTMLObj106.id,'ftp-logs-report.cfm?nocache=' + uuid() + '&recid=' + id + '&repName=' + repName + '&sDate=' + sDate + '&sDataSrc=' + sDataSrc + '&sFilePath=' + sFilePath,950,500,10,10);
		}

		function popUpQueryBuilder() {
			DHTMLWindowsObj.loadwindow(aDHTMLObj107.id,'#CGI.SCRIPT_NAME#?page=#const_ftpQueryPage#&nocache=' + uuid(),950,500,10,10);
		}

	// --> 
	</script>

	<cfsavecontent variable="js_link">
		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>

		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].id;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var rec_id = ftpGrid.dataProvider[ftpGrid.selectedIndex].rec_id;
		getURL("javascript:popUpFTPReport(" + stripTickMarks(recid) + ",'" + stripTickMarks(repName) + "','" + ((rec_id == null) ? '' : stripTickMarks(rec_id)) + "')");
	</cfsavecontent>

	<cfsavecontent variable="js_bool_aggregate_onclick">
//		alert('js_bool_aggregate_onclick');
		var bool = myForm.bool_aggregate;

		btn_view_excel.enabled = ((bool) ? false : true);
		btn_view_raw.enabled = true;
		btn_view_trash.enabled = ((bool) ? false : true);
		btn_data_mart.enabled = ((bool) ? false : true);
		btn_view_logs.enabled = ((bool) ? false : true);
		btn_data_mart_process.enabled = ((bool) ? false : true);
	</cfsavecontent>

	<cfsavecontent variable="js_excel_link">
		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>

		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].recid;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var rec_id = ftpGrid.dataProvider[ftpGrid.selectedIndex].rec_id;
		var bool = myForm.bool_aggregate;
		var allow_dl = true;
		if (bool) {
			var i = -1;
			recid = '';
			for (i = 0; i < ftpGrid.dataProvider.length; i++) {
				recid += ftpGrid.dataProvider[i].id;
				if (i < (ftpGrid.dataProvider.length - 1)) {
					recid += '|';
				}
			}
		}
		if (ftpGrid.selectedIndex != null) {
//			alert('recid = [' + recid + ']');
			getURL("javascript:popUpFTPReportInExcel('" + recid + "','" + stripTickMarks(repName) + "','" + ((rec_id == null) ? '' : stripTickMarks(rec_id)) + "'," + allow_dl + "," + bool + ")");
		} else {
			alert('PLS click on a row in the grid before clicking on the buttons.  Thx.');
		}
	</cfsavecontent>
	
	<cfsavecontent variable="js_raw_link">
		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>

		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].recid;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var rec_id = ftpGrid.dataProvider[ftpGrid.selectedIndex].rec_id;
		var allow_dl = true;
		var bool = myForm.bool_aggregate;
		if (bool) {
			var i = -1;
			recid = '';
			for (i = 0; i < ftpGrid.dataProvider.length; i++) {
				recid += ftpGrid.dataProvider[i].recid;
				if (i < (ftpGrid.dataProvider.length - 1)) {
					recid += '|';
				}
			}
		}
		if (ftpGrid.selectedIndex != null) {
//			alert('recid = [' + recid + ']');
			getURL("javascript:popUpFTPReportRaw('" + recid + "','" + stripTickMarks(repName) + "','" + ((rec_id == null) ? '' : stripTickMarks(rec_id)) + "'," + allow_dl + "," + bool + ")");
		} else {
			alert('PLS click on a row in the grid before clicking on the buttons.  Thx.');
		}
	</cfsavecontent>
	
	<cfsavecontent variable="js_trash_link">
		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>

		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].recid;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var rec_id = ftpGrid.dataProvider[ftpGrid.selectedIndex].rec_id;
		var allow_dl = true;
		if (ftpGrid.selectedIndex != null) {
			getURL("javascript:popUpFTPReportTrash(" + recid + ",'" + stripTickMarks(repName) + "','" + ((rec_id == null) ? '' : stripTickMarks(rec_id)) + "'," + allow_dl + ")");
		} else {
			alert('PLS click on a row in the grid before clicking on the buttons.  Thx.');
		}
	</cfsavecontent>
	
	<cfsavecontent variable="js_dataMart_link">
		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>

		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].recid;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var dm_id = ftpGrid.dataProvider[ftpGrid.selectedIndex].rec_id;
		var repType = ftpGrid.dataProvider[ftpGrid.selectedIndex].file_url;
		var file_path = ftpGrid.dataProvider[ftpGrid.selectedIndex].file_path;
		var allow_dl = true;
		if (ftpGrid.selectedIndex != null) {
//			alert('+++');
			getURL("javascript:popUpFTPReport2DataMart(" + recid + ",'" + stripTickMarks(repName) + "','" + ((dm_id == null) ? '' : dm_id) + "'," + allow_dl + ",'" + ((repType == null) ? '' : stripTickMarks(repType)) + "','" + ((file_path == null) ? '' : stripTickMarks(file_path)) + "')");
		} else {
			alert('PLS click on a row in the grid before clicking on the buttons.  Thx.');
		}
	</cfsavecontent>
	
	<cfsavecontent variable="js_dataMart_process_link">
		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>

		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].id;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var dm_id = ftpGrid.dataProvider[ftpGrid.selectedIndex].rec_id;
		var allow_dl = true;
		getURL("javascript:popUpFTPDataMartProcess(" + recid + ",'" + stripTickMarks(repName) + "'," + stripTickMarks(allow_dl) + ",'" + ((dm_id == null) ? '' : stripTickMarks(dm_id)) + "')");
	</cfsavecontent>
	
	<cfsavecontent variable="js_logs_link">
		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>

		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].id;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var sDate = ftpGrid.dataProvider[ftpGrid.selectedIndex].last_modified_dt;
		var sDataSrc = ftpGrid.dataProvider[ftpGrid.selectedIndex].file_url;
		var sFilePath = ftpGrid.dataProvider[ftpGrid.selectedIndex].file_path;
		if (ftpGrid.selectedIndex != null) {
			getURL("javascript:popUpFTPLogsReport(" + recid + ",'" + stripTickMarks(repName) + "','" + stripTickMarks(sDate) + "','" + stripTickMarks(sDataSrc) + "','" + stripTickMarks(sFilePath) + "')");
		} else {
			alert('PLS click on a row in the grid before clicking on the buttons.  Thx.');
		}
	</cfsavecontent>
	
	<cfsavecontent variable="ftpGrid_action">
		var id = ftpGrid.dataProvider[ftpGrid.selectedIndex].id;
		var recid = ftpGrid.dataProvider[ftpGrid.selectedIndex].recid;
		var repName = ftpGrid.dataProvider[ftpGrid.selectedIndex].report_name;
		var dm_id = ftpGrid.dataProvider[ftpGrid.selectedIndex].rec_id;
		btn_view_excel.label = '[View Excel Data ##' + id + ' ' + repName + ']';
		btn_view_excel.enabled = true;
		btn_view_raw.label = '[View Raw Data ##' + id + ' ' + repName + ']';
		btn_view_raw.enabled = true;
		btn_view_trash.label = '[View Trash Data ##' + id + ' ' + repName + ']';
		btn_view_trash.enabled = true;
		btn_data_mart.label = '[Data Mart It ##' + id + ']';
		btn_data_mart.enabled = ((dm_id == null) ? true : false);
		btn_view_logs.label = '[View Process Logs for ##' + id + ' ' + repName + ']';
		btn_view_logs.enabled = true;
		bool_aggregate.enabled = true;
	</cfsavecontent>

	<cfsavecontent variable="txt_record_info_onchange">
		txt_record_info.editable = false;
	</cfsavecontent>
	
	<cfsavecontent variable="restore_records_click">
	//	btn_restore_default_records.enabled = false;
		btn_restore_month_records.enabled = false;
		btn_restore_eom_records.enabled = false;
		btn_restore_preveom_records.enabled = false;
		btn_show_query_page.enabled = false;
		getURL("javascript:redirectBrowserTo('#CGI.SCRIPT_NAME#?showAll=#const_yes_symbol#&nocache=' + uuid())");
	</cfsavecontent>

	<cfsavecontent variable="showmonth_records_click">
	//	btn_restore_default_records.enabled = false;
		btn_restore_month_records.enabled = false;
		btn_restore_eom_records.enabled = false;
		btn_restore_preveom_records.enabled = false;
		btn_show_query_page.enabled = false;
		getURL("javascript:redirectBrowserTo('#CGI.SCRIPT_NAME#?showLast30=#const_yes_symbol#&nocache=' + uuid())");
	</cfsavecontent>

	<cfsavecontent variable="showeom_records_click">
	//	btn_restore_default_records.enabled = false;
		btn_restore_month_records.enabled = false;
		btn_restore_eom_records.enabled = false;
		btn_restore_preveom_records.enabled = false;
		btn_show_query_page.enabled = false;
		getURL("javascript:redirectBrowserTo('#CGI.SCRIPT_NAME#?showeom=#const_yes_symbol#&nocache=' + uuid())");
	</cfsavecontent>

	<cfsavecontent variable="showpreveom_records_click">
	//	btn_restore_default_records.enabled = false;
		btn_restore_month_records.enabled = false;
		btn_restore_eom_records.enabled = false;
		btn_restore_preveom_records.enabled = false;
		btn_show_query_page.enabled = false;
		getURL("javascript:redirectBrowserTo('#CGI.SCRIPT_NAME#?showpreveom=#const_yes_symbol#&nocache=' + uuid())");
	</cfsavecontent>

	<cfsavecontent variable="show_query_page_click">
		getURL("javascript:popUpQueryBuilder()");
	</cfsavecontent>

	<cfsavecontent variable="trigger_onLoad">
	</cfsavecontent>
	
	<cfsavecontent variable="onLoad_event_binding">
		{(trigger.text != '') ? trigger.dispatchEvent({type:'change'}) : 'init'}
	</cfsavecontent>

	<cfscript>
	//	_params = StructNew();
	//	s_sendData = Request.flashCallCFC('dataResponder.cfc', 'getFTPData', _params, '_root.receiveData', 'recid=ftpGrid.dataProvider[ftpGrid.selectedIndex].id');
		s_sendData = '';
		s_sendData = s_sendData & js_link;
	</cfscript>

	<cfsavecontent variable="receiveCall">
		myForm.ftp_data = 'Accessing Database... PLS Stand-by...';
		
		myForm.ftp_report_data = 'Accessing Database... PLS Stand-by...';
		
		_root.receiveData = function(obj:Object) {
			//in this case, the cfc returns a variable called time, so we will get it in the parameter (obj) of this callback function    
			//we will simply use it to show it in the input control display     
			myForm.ftp_data = 'Record ##: ' + obj.recid + '\n' + 'rowCount = [' + obj.rowCount + ']' + '\n' + obj.ftp_data;
			myForm.ftp_data += '\n';
			myForm.ftp_data += '\n';
	
			var a = obj.columnNames.split(',');
			for (var i = 0; i < a.length; i++) {
	//			if (i < ftpDataGrid.columns.length) {
	//				ftpDataGrid.columns[i + 1].columnName = a[i];
	//			} else {
	//				break;
	//			}
			}
	
			var font_char_width = 5;
	
			var total_width = 0;
			var h = obj.columnHeaders.split(',');
			for (var i = 0; i < a.length; i++) {
	//			if (i < ftpDataGrid.columns.length) {
	//				ftpDataGrid.columns[i + 1].headerText = h[i];
	//				ftpDataGrid.columns[i + 1].width = (a[i].length * font_char_width);
	//				myForm.ftp_data += 'ftpDataGrid.columns[' + (i + 1) + '].width = [' + ftpDataGrid.columns[i + 1].width + ']' + '\n'; //  + ', ftpDataGrid.columns[' + (i + 1) + '].wordWrap = [' + ftpDataGrid.columns[i + 1].wordWrap + ']'
	//				total_width += ftpDataGrid.columns[i + 1].width;
	//			} else {
	//				break;
	//			}
			}
			myForm.ftp_data += 'total_width = [' + total_width + ']' + '\n';
	
	//		for (var j = i; j < ftpDataGrid.columns.length; j++) {
	//			ftpDataGrid.columns[j + 1].headerText = '';
	//			ftpDataGrid.columns[j + 1].width = -1;
	//		}
			
			var t = '';
	
			myForm.ftp_report_data = 'Displaying ' + obj.rowCount + ' line items.' + '\n' + '\n';
	
	//		myForm.ftp_report_data += obj.columnHeaders + '\n' + '\n';
	
			var data = '';
			for (var k = 1; k <= obj.rowCount; k++) {
				try {
					t = 'obj.row' + k;
					data = Eval(t);
					myForm.ftp_data += 't = [' + t + ']' + '\n';
					myForm.ftp_data += 'data = [' + data + ']' + '\n' + '\n';
	
					myForm.ftp_report_data += '##' + k + ' :: ' + '\n';
	
					var n_chars = 0;
					var s_data = '';
					var aa = data.split(',');
					for (var n = 0; n < a.length; n++) {
						s_data = h[n] + ' :: ' + ((aa[n] == null) ? '' : aa[n]);
						n_chars += s_data.length;
						myForm.ftp_report_data += s_data;
						if (n_chars > 80) {
							myForm.ftp_report_data += '\n';
							n_chars = 0;
						} else {
							myForm.ftp_report_data += ' | ';
						}
					}
					myForm.ftp_data += '\n';
					myForm.ftp_report_data += '\n' + ((n_chars > 0) ? '\n' : '');
				} catch (e) {
					alert('Programming Error: Something wrong with ' + 'obj.row' + k);
					break;
				}
			}
	//alert(ftpDataGrid.columnNames.length + ', ' + ftpDataGrid.columns[1].columnName + ', ' + a.length);
		}
	</cfsavecontent>

	<cfscript>
		qGetFTPReportsData = QueryNew('id, recid, last_modified_dt, file_length, file_url, file_path');
	</cfscript>
	
	<cfif (bool_showGrid)>
		<cfset db_err = "False">
		<cftry>
			<cfscript>
				function read_AppScope_qGetFTPReportsDataCached() { Request._qGetFTPReportsData = -1; if ( (IsDefined("Application._qGetFTPReportsData")) AND (IsQuery(Application._qGetFTPReportsData)) ) { Request._qGetFTPReportsData = Application._qGetFTPReportsData; } else { writeOutput('<font color="blue"><b>INFO: This SQL Query may take some additional time to process due to recent updates within the database in which you may be interested.</b></font>'); }; }
				function read_AppScope_qGetFTPReportsDataNoCache() { Request._qGetFTPReportsData = -1; if ( (IsDefined("Application._qGetFTPReportsData")) AND (IsQuery(Application._qGetFTPReportsData)) ) { Request._qGetFTPReportsData = QueryNew(''); } else {  }; }

				if (Request.bool_inhibit_database_cache) {
					Request.primitiveCode.cf_lock('LOCK_read_AppScope_qGetFTPReportsData', read_AppScope_qGetFTPReportsDataNoCache, 'READONLY', 'Application');
				} else {
					Request.primitiveCode.cf_lock('LOCK_read_AppScope_qGetFTPReportsData', read_AppScope_qGetFTPReportsDataCached, 'READONLY', 'Application');
				}
				_qGetFTPReportsData = Request._qGetFTPReportsData;
			</cfscript>

			<cfset _signal_dataSourceIsCached = "False">
			<cfif (NOT Request.bool_inhibit_database_cache)>
				<cfif (NOT IsQuery(_qGetFTPReportsData)) OR (_qGetFTPReportsData.recordCount eq 0)>
					<!--- BEGIN: Think about caching this Query whenever the background process is NOT running - Perhaps place a begin_flag/end_flag in the Application Scope such that when the current time falls between begin_flag/end_flag it tells this Query to be not cached --->
					<cfif (Request.bool_inhibit_database_cache)>
						<cfquery name="_qGetFTPReportsData" datasource="#Request.DSN#">
							#PreserveSingleQuotes(_sql_query_code)#
						</cfquery>
					<cfelse>
						<cfscript>
							_qGetFTPReportsData = Request.primitiveCode.safely_execSQL('qGetFTPReportsDataQ', Request.DSN, _sql_query_code);
	
							if ( (NOT IsQuery(_qGetFTPReportsData)) OR (Request.dbError) ) {
								writeOutput(Request.fullErrorMsg);
							} else if ( (IsQuery(_qGetFTPReportsData)) AND (_qGetFTPReportsData.recordCount eq 0) ) {
								writeOutput('_qGetFTPReportsData.recordCount = [#_qGetFTPReportsData.recordCount#], _sql_query_code = [#_sql_query_code#]<br>');
							}
						</cfscript>
					</cfif>

					<!--- END! Think about caching this Query whenever the background process is NOT running - Perhaps place a begin_flag/end_flag in the Application Scope such that when the current time falls between begin_flag/end_flag it tells this Query to be not cached --->
	
					<cfscript>
						function write_AppScope_qGetFTPReportsDataCached() { if (IsDefined("Request._qGetFTPReportsData")) { Application._qGetFTPReportsData = Request.commonCode.filterRawDataOutOfQuery(Request._qGetFTPReportsData, 'raw_data'); } else { writeOutput('<font color="red"><b>ERROR: Programming error - the system is not behaving correctly - kindly notify the developer(s).</b></font>'); }; }
						function write_AppScope_qGetFTPReportsDataNoCache() { if (IsDefined("Request._qGetFTPReportsData")) { Application._qGetFTPReportsData = QueryNew(''); } else { writeOutput('<font color="red"><b>ERROR: Programming error - the system is not behaving correctly - kindly notify the developer(s).</b></font>'); }; }
						// writeOutput(Request.primitiveCode.cf_dump(Application._qGetFTPReportsData, 'Application._qGetFTPReportsData', false));
	
						if (IsQuery(_qGetFTPReportsData)) {
							// BEGIN: - Ensure all the raw data elements are decoded as they are encoded when stored to avoid a SQL Error that should not be happening...
							for (ij = 1; ij lte _qGetFTPReportsData.recordCount; ij = ij + 1) {
								_qGetFTPReportsData.raw_data[ij] = URLDecode(_qGetFTPReportsData.raw_data[ij]);
							}
							// END! - Ensure all the raw data elements are decoded as they are encoded when stored to avoid a SQL Error that should not be happening...
						}
	
						if (Request.bool_inhibit_database_cache) {
							Request.primitiveCode.cf_lock('LOCK_write_AppScope_qGetFTPReportsData', write_AppScope_qGetFTPReportsDataNoCache, 'EXCLUSIVE', 'Application');
						} else {
							Request._qGetFTPReportsData = _qGetFTPReportsData; // prepare to store this query object in the app scope...
							Request.primitiveCode.cf_lock('LOCK_write_AppScope_qGetFTPReportsData', write_AppScope_qGetFTPReportsDataCached, 'EXCLUSIVE', 'Application');
						}
					</cfscript>
				</cfif>
			</cfif>

			<cfif (NOT Request.bool_inhibit_database_cache)>
				<cfset Request.qGetFTPReportsData = Request._qGetFTPReportsData>
				<cfset _signal_dataSourceIsCached = "True">
				<!--- BEGIN: Recode this Query to leverage the cached Query Object instead of hitting the Db --->
				<cfsavecontent variable="_sql_query_code">
					SELECT id, recid, last_modified_dt, file_length, file_name, file_path, file_url, report_name, raw_data, rec_id
					FROM Request.qGetFTPReportsData
				</cfsavecontent>
				<!--- BEGIN: Recode this Query to leverage the cached Query Object instead of hitting the Db --->
			<cfelse>
				<!--- Note: Because there is no caching at this point there is no need to reconstruct the same SQL Statement we previously created... --->
			</cfif>
		
			<cfcatch type="Database">
				<cfset db_err = "True">
				<cfsavecontent variable="Request.db_error">
					<cfdump var="#cfcatch#" label="qGetReportTypes dbError">
				</cfsavecontent>
			</cfcatch>
		</cftry>

		<cfscript>
			if (UCASE(showLast30) eq UCASE(const_yes_symbol)) {
				one_month_ago_date = DateAdd('d', -30, Now());
				form_begin_date = DateFormat(one_month_ago_date, 'mm/dd/yyyy');
				form_end_date = DateFormat(Now(), 'mm/dd/yyyy');
				_myQryName = 'Show Most Recent 30 Days';
				_newQryName = _myQryName;
			} else if ( (UCASE(showeom) eq UCASE(const_yes_symbol)) OR (UCASE(showpreveom) eq UCASE(const_yes_symbol)) ) { 
				month_delta = -1;
				if (Day(Now()) lte 15) {
					month_delta = 0;
				}
				one_month_ago_date = DateAdd('m', month_delta, Now());
				_myQryName = 'Show Current End Of Month';
				if (UCASE(showpreveom) eq UCASE(const_yes_symbol)) {
					_myQryName = 'Show Previous End Of Month';
					one_month_ago_date = DateAdd('m', -1, one_month_ago_date);
				}
				form_begin_date = DateFormat(CreateDate(Year(one_month_ago_date), Month(one_month_ago_date), 1), 'mm/dd/yyyy');
				form_end_date = DateFormat(CreateDate(Year(one_month_ago_date), Month(one_month_ago_date), DaysInMonth(one_month_ago_date)), 'mm/dd/yyyy');
				_newQryName = _myQryName;
			}

			_where_clause = '';
			_where_clause_explained = '';
			if ( (IsDefined("_myQryName")) AND (IsDefined("_newQryName")) ) {
				if ( (Len(Trim(_myQryName)) gt 0) AND (Len(Trim(_newQryName)) gt 0) ) {
					if (FindNoCase(const_ChooseQuery_symbol, _newQryName) eq 0) {
						if ( (IsNumericDate(form_begin_date)) AND (IsNumericDate(form_end_date)) ) {
							if (IsNumericDate(form_begin_date)) {
								if (FindNoCase(' WHERE ', _where_clause) eq 0) {
									_where_clause = _where_clause & ' WHERE ';
								}
								if ( (IsDefined("Application._qGetFTPReportsData")) AND (IsQuery(Application._qGetFTPReportsData)) ) {
									_where_clause = _where_clause & " (last_modified_dt >= #CreateODBCDateTime(ParseDateTime(form_begin_date))#) ";
								} else {
									_where_clause = _where_clause & " (last_modified_dt >= CAST('#form_begin_date#' AS datetime)) ";
								}
								form_begin_date = DateFormat(ParseDateTime(form_begin_date), 'mm/dd/yyyy') & ' 00:00:00.0';
							}
							if (IsNumericDate(form_end_date)) {
								if (FindNoCase(' WHERE ', _where_clause) eq 0) {
									_where_clause = _where_clause & ' WHERE ';
								}
								if ( (FindNoCase(' (', _where_clause) gt 0) AND (FindNoCase(') ', _where_clause) gt 0) ) {
									_where_clause = _where_clause & ' AND ';
								}
								if ( (IsDefined("Application._qGetFTPReportsData")) AND (IsQuery(Application._qGetFTPReportsData)) ) {
									_where_clause = _where_clause & " (last_modified_dt <= #CreateODBCDateTime(ParseDateTime(form_end_date))#) ";
								} else {
									_where_clause = _where_clause & " (last_modified_dt <= CAST('#form_end_date#' AS datetime)) ";
								}
								form_end_date = DateFormat(ParseDateTime(form_end_date), 'mm/dd/yyyy') & ' 23:59:59.9';
							}
							_where_clause_explained = _where_clause_explained & ' from #DateFormat(form_begin_date, 'mm/dd/yyyy')# to #DateFormat(form_end_date, 'mm/dd/yyyy')#';
						}
						if (IsDefined("_ftpSource")) {
							if (LCASE(_ftpSource) neq 'all') {
								if (FindNoCase(' WHERE ', _where_clause) eq 0) {
									_where_clause = _where_clause & ' WHERE ';
								}
								if ( (FindNoCase(' (', _where_clause) gt 0) AND (FindNoCase(') ', _where_clause) gt 0) ) {
									_where_clause = _where_clause & ' AND ';
								}
								if (LCASE(_ftpSource) eq LCASE(Request.const_31_day_symbol)) {
									_where_clause = _where_clause & " (UPPER(file_url) like UPPER('%#Request.const_31_day_symbol#%')) ";
									_where_clause_explained = _where_clause_explained & ' like #Request.const_31_day_symbol#';
								} else if (Len(_ftpSource) gt 0) {
									_where_clause = _where_clause & " (UPPER(file_url) NOT like UPPER('%#Request.const_31_day_symbol#%')) ";
									_where_clause_explained = _where_clause_explained & ' not like #Request.const_31_day_symbol#';
								}
							} else {
								_where_clause_explained = _where_clause_explained & ' like ALL';
							}
						}
						if ( (IsDefined("_qryParameter_keyword")) AND (Len(Trim(_qryParameter_keyword)) gt 0) ) {
							if (FindNoCase(' WHERE ', _where_clause) eq 0) {
								_where_clause = _where_clause & ' WHERE ';
							}
							if ( (FindNoCase(' (', _where_clause) gt 0) AND (FindNoCase(') ', _where_clause) gt 0) ) {
								_where_clause = _where_clause & ' AND ';
							}
							_where_clause = _where_clause & " (raw_data like '%#_qryParameter_keyword#%') ";
						}
						if ( (Request.commonCode.isServerLocal()) AND 0) {
							writeOutput('_where_clause = [#_where_clause#]<br>');
						}
					}
				}
			}

			if (Len(Trim(_newQryName)) gt 0) {
				_myReportType_explained = '';
				if (Len(Trim(_myReportType)) gt 0) {
					_myReportType_explained = _myReportType_explained & ' for (#_myReportType#)';
				}
				writeOutput('Using Query Named "#_newQryName#"#_where_clause_explained##_myReportType_explained#');
			}

		</cfscript>

		<cfset db_err = "False">
		<cfif (Len(Trim(_where_clause)) gt 0) OR (UCASE(showAll) eq UCASE(const_yes_symbol)) OR (UCASE(showLast30) eq UCASE(const_yes_symbol))>
			<cfif (Request.bool_use_SQL_Server_Query_Aggregator)>
				<cfsavecontent variable="sql_query_code">
					<cfoutput>
						#_sql_query_code#
						<cfif (FindNoCase("WHERE ", _sql_query_code) gt 0)>
							<cfset _where_clause = ReplaceNoCase(_where_clause, "WHERE ", "AND ")>
						</cfif>
						#_where_clause#
						ORDER BY last_modified_dt DESC
					</cfoutput>
				</cfsavecontent>
			<cfelseif (NOT Request.bool_use_SQL_Server_Query_Aggregator)>
				<cfsavecontent variable="sql_query_code">
					<cfoutput>
						#ReplaceNoCase(ReplaceNoCase(ReplaceNoCase(_sql_query_code, Request.const_report_type_symbol, _myReportType), Request.const_end_date_symbol, ReplaceNoCase(form_end_date, Request.const_end_date_time_alpha_symbol, Request.const_end_date_time_omega_symbol)), Request.const_begin_date_symbol, form_begin_date)#
						<cfif (UCASE(showLast30) eq UCASE(const_yes_symbol))>
						ORDER BY last_modified_dt DESC
						</cfif>
					</cfoutput>
				</cfsavecontent>
			</cfif>

			<cfscript>
			//	writeOutput('showLast30 = [#showLast30#], _where_clause = [#_where_clause#], [#sql_query_code#]<br>');
			</cfscript>
			
			<cfset db_err = "False">
			<cfset Client.sql_query_code = PreserveSingleQuotes(sql_query_code)>
			<cftry>
				<cfif (_signal_dataSourceIsCached)>
					<cfquery name="qGetFTPReportsData" dbtype="query">
						#PreserveSingleQuotes(sql_query_code)#
					</cfquery>
				<cfelse>
					<cfquery name="qGetFTPReportsData" datasource="#Request.DSN#">
						#PreserveSingleQuotes(sql_query_code)#
					</cfquery>
				</cfif>
				
				<cfscript>
					Request.qGetFTPReportsData = qGetFTPReportsData;
					function save_qGetFTPReportsData2() { if (IsDefined("Request.qGetFTPReportsData")) Session.qGetFTPReportsData = Request.qGetFTPReportsData; if (0) writeOutput(Request.primitiveCode.cf_dump(Session.qGetFTPReportsData, 'Session.qGetFTPReportsData', false)); };
					Request.primitiveCode.cf_lock('LOCK_qGetFTPReportsData', save_qGetFTPReportsData2, 'EXCLUSIVE', 'SESSION');
				</cfscript>
				
				<cfif (IsDefined("_myReportType")) AND (Len(Trim(_myReportType)) gt 0)>
					<cfsavecontent variable="sql_qqGetFTPReportsData">
						<cfoutput>
							SELECT id, recid, last_modified_dt, file_length, file_name, file_path, file_url, raw_data, rec_id, report_name
							FROM qGetFTPReportsData
							WHERE 0=0<cfif (Len(Trim(ReplaceNoCase(_myReportType, '"', '', 'all'))) gt 0)><cfif (ListLen(_myReportType, ',') gt 1)>AND (UPPER(report_name) in (#UCASE(Request.commonCode.listToSQL_inClause(_myReportType, ','))#))<cfelse>AND (UPPER(report_name) = '#UCASE(_myReportType)#')</cfif></cfif>
							ORDER BY last_modified_dt DESC
						</cfoutput>
					</cfsavecontent>
			
					<cfquery name="qqGetFTPReportsData" dbtype="query">
						#PreserveSingleQuotes(sql_qqGetFTPReportsData)#
					</cfquery>
				</cfif>

				<cfcatch type="Database">
					<cfset db_err = "True">
					<cfsavecontent variable="Request.db_error">
						<cfdump var="#cfcatch#" label="qGetFTPReportsData dbError">
					</cfsavecontent>
				</cfcatch>
			</cftry>
		
			<cfif (NOT db_err)>
				<cfscript>
					function postProcessFTPdata(q) {
						var i = -1;
						var d = '';
						
						if (IsQuery(q)) {
							for (i = 1; i lte q.recordCount; i = i + 1) {
								try {
									d = q.raw_data[i];
								} catch(Any e) {
									d = '';
								}
								QuerySetCell(q, 'id', i, i);
								QuerySetCell(q, 'raw_data', URLDecode(d), i);
							}
						}
					}
					
					function save_qGetFTPReportsData() { if (IsDefined("qGetFTPReportsData")) Session.qGetFTPReportsData = qGetFTPReportsData; };
			
					if (IsDefined("qqGetFTPReportsData")) {
						postProcessFTPdata(qqGetFTPReportsData);
						qGetFTPReportsData = qqGetFTPReportsData;
						Request.primitiveCode.cf_lock('LOCK_qGetFTPReportsData', save_qGetFTPReportsData, 'EXCLUSIVE', 'SESSION');
					} else {
						postProcessFTPdata(qGetFTPReportsData);
						Request.primitiveCode.cf_lock('LOCK_qGetFTPReportsData', save_qGetFTPReportsData, 'EXCLUSIVE', 'SESSION');
					}
				</cfscript>
			</cfif>
		</cfif>
	</cfif>
<cfelse>
	<cfsavecontent variable="begin_date_onchange">
		##include "format_Date.as"

		myForm.myBeginDate = format_Date(begin_date.selectedDate);
		
//		alert('A. begin_date = [' + fmt_bdt + ']' + ' (' + myForm.myBeginDate + ') ');
	</cfsavecontent>
	
	<cfsavecontent variable="end_date_onchange">
		##include "format_Date.as"

		myForm.myEndDate = format_Date(end_date.selectedDate);

//		alert('B. end_date = [' + fmt_edt + ']' + ' (' + myForm.myEndDate + ') ');
	</cfsavecontent>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		function dismissPopUp107(beginDate, endDate, qryName, newQryName, ftpSrc, repType, keyword) {
			parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj107.id);
//			alert('beginDate=[' + beginDate + '], endDate=[' + endDate + '], qryName=[' + qryName + '], newQryName=[' + newQryName + '], ftpSrc=[' + ftpSrc + '], repType=[' + repType + '], keyword=[' + keyword + ']');
			parent.redirectBrowserTo('#CGI.SCRIPT_NAME#?_begin_date=' + URLEncode(beginDate) + '&_end_date=' + URLEncode(endDate) + '&_myQryName=' + URLEncode(qryName) + '&_newQryName=' + URLEncode(newQryName) + '&_ftpSource=' + URLEncode(ftpSrc) + '&_myReportType=' + URLEncode(repType) + '&_qryParameter_keyword=' + URLEncode(keyword) + '&_page=#URLEncodedFormat(const_ftpGridPage)#' + '&nocache=' + uuid());
		}
	// --> 
	</script>

	<cfsavecontent variable="js_submit_link">
		##include "format_Date.as"

		<cfoutput>
			#Request.AS_stripTickMarks#
		</cfoutput>
		var ss = '';
		var sels = myForm.myReportType.getSelectedItems();
		for (var i = 0; i < sels.length; i++) {
			ss += sels[i].data + ((i < (sels.length - 1)) ? ',' : '');
		}

		myForm.myBeginDate = ((begin_date.selectedDate != null) ? format_Date(begin_date.selectedDate) : myForm.myBeginDate);
		myForm.myEndDate = ((end_date.selectedDate != null) ? format_Date(end_date.selectedDate) : myForm.myEndDate);
//		alert('begin_date=[' + begin_date.selectedDate + ']' + ' (' + myForm.myBeginDate + ') ' + ', end_date=[' + end_date.selectedDate + ']' + ' (' + myForm.myEndDate + ') ' + ', ss = [' + ss + ']');
		<cfif (Request.bool_inhibit_use_of_step3)>
			getURL("javascript:dismissPopUp107('" + stripTickMarks(myForm.myBeginDate) + "','" + stripTickMarks(myForm.myEndDate) + "','" + stripTickMarks(myForm.myQryName.value) + "','" + stripTickMarks(myForm.newQryName) + "','" + '' + "','" + stripTickMarks(ss) + "','" + stripTickMarks(myForm.qryParameter_keyword) + "')");
		<cfelse>
			getURL("javascript:dismissPopUp107('" + stripTickMarks(myForm.myBeginDate) + "','" + stripTickMarks(myForm.myEndDate) + "','" + stripTickMarks(myForm.myQryName.value) + "','" + stripTickMarks(myForm.newQryName) + "','" + stripTickMarks(myForm.ftpSource) + "','" + stripTickMarks(ss) + "','" + stripTickMarks(myForm.qryParameter_keyword) + "')");
		</cfif>
	</cfsavecontent>

	<cfscript>
		trigger_params = StructNew();
		trigger_sendData = Request.flashCallCFC('dataResponder.cfc', 'getFTPSavedQueries', trigger_params, '_root.receiveSavedQueriesData', '');
	</cfscript>
	
	<cfsavecontent variable="refresh_click">
		_root.receiveSavedQueriesData = function(obj:Object) {
			var i = -1;
			var _item = '';
			myForm.myQryName.dataProvider.removeAll();
			for (i = 1; i <= obj.cnt_list; i++) {
				_item = Eval('obj.cnt_list' + i);
				myForm.myQryName.dataProvider.addItemAt(i - 1, _item, _item);
			}
			myForm.myQryName.enabled = true;
			begin_date.enabled = true;
			end_date.enabled = true;
			newQryName.enabled = true;
			<cfif (NOT Request.bool_inhibit_use_of_step3)>
				ftpSource.enabled = true;
			</cfif>
			myForm.myReportType.enabled = true;
			submit_query.enabled = false;
		}
	
		myQryName.enabled = false;
		begin_date.enabled = false;
		end_date.enabled = false;
		newQryName.enabled = false;
		<cfif (NOT Request.bool_inhibit_use_of_step3)>
			ftpSource.enabled = false;
		</cfif>
		myReportType.enabled = false;
		submit_query.enabled = false;
		#trigger_sendData#
	</cfsavecontent>

	<cfsavecontent variable="query_event_binding">
		{(qtrigger.text != '') ? qtrigger.dispatchEvent({type:'change'}) : 'init'}
	</cfsavecontent>

	<cfsavecontent variable="submit_enabled">
		submit_query.enabled = true;
	</cfsavecontent>

	<cfscript>
		_params = StructNew();
		myQryName_sendData = Request.flashCallCFC('dataResponder.cfc', 'getSavedQueryText', _params, '_root.myQryName_receiveData', 'recKey=myQryName.value');
	</cfscript>

	<cfsavecontent variable="myQryName_receiveCall">
		myForm.myHiddenQueryText = 'Accessing Database... PLS Stand-by...';
	
		_root.selectThisItem = function(oObj, itemValue) {
			var a = oObj.dataProvider.slice(0);

			var a_items:Array = [];
			var aa = itemValue.split(',');
			if ( (oObj.multipleSelection) && (aa.length > 1) ) {
				for (var i = 0; i < aa.length; i++) {
					if (aa[i].length > 0) {
						for (var ii = 0; ii < a.length; ii++) {
							if (a[ii].data == aa[i]) {
								a_items.push(ii);
								break;
							}
						}
					}
				}
				oObj.selectedIndices = a_items;
			} else {
				for (var i = 0; i < a.length; i++) {
					if (a[i].data == itemValue) {
						oObj.selectedIndex = i;
						break;
					}
				}
				if (oObj.selectedIndex <> i) {
					oObj.selectedIndex = a.length - 1;
				}
			}
		}
	
		_root.showAlert = function(_msg, _width, _height) {
			var myClickHandler = function (evt) {
		        if (evt.detail == mx.controls.Alert.YES) {		
	//				alert("Records deleted","Completed");
		        }
			}
			
			//set the font color and button labels of all alerts
			_global.styles.Alert.setStyle("color", 0x0066CC);
			mx.controls.Alert.cancelLabel = "[Cancel]";
			mx.controls.Alert.yesLabel = "";
			mx.controls.Alert.buttonWidth = 100;
			
			//set the style of the title only with a named style declaration
			mx.controls.Alert.titleStyleDeclaration = "windowStyles";
		
			//create the alert
	//		var myAlert = mx.controls.Alert.show("(The size and style of this alert have been manually set) \nAre you sure you want to remove all records?", "Warning", mx.controls.Alert.YES | mx.controls.Alert.CANCEL, this, myClickHandler);
			var myAlert = mx.controls.Alert.show(_msg, "Warning", mx.controls.Alert.CANCEL, this, myClickHandler);
			
			//change the size
			myAlert.width = 700;
			myAlert.height = 300;
			
			//change this alert's style only
			myAlert.setStyle("fontStyle", "italic");
			myAlert.setStyle("panelBorderStyle","default");
			myAlert.setStyle("cornerRadius","0");
		}
	
		_root.myQryName_receiveData = function(obj:Object) {
			myForm.myBeginDate = obj.begin_date;
			myForm.myEndDate = obj.end_date;
			<cfif (NOT Request.bool_inhibit_use_of_step3)>
				ftpSource.selectedData = obj.ftp_source;
			</cfif>
//alert('obj.reportType = [' + obj.reportType + ']');
			_root.selectThisItem(myForm.myReportType, obj.reportType);
			var p = obj.parameters;
			var pa = p.split('=');
			if (pa.length == 2) { // this will have to change as more parameters are added...
				myForm.myQryParameter_keyword = pa[1];
			}
	
			var msg = 'obj.recKey = [' + obj.recKey + '], obj.begin_date = [' + obj.begin_date + '], obj.end_date = [' + obj.end_date + '], obj.ftp_source = [' + obj.ftp_source + '], obj.reportType = [' + obj.reportType + ']';
			if (0) {
				var alertSettings:Object = {title:'Debug Info', message: msg, width:650, x: 60, y: 10, headerHeight: 27};
				var errorpopup = mx.managers.PopUpManager.createPopUp(_root, FormErrorException, true, alertSettings);
				errorpopup.centerPopUp(_root);
			} else if (0) {
				alert(msg);
			} else if (0) {
				_root.showAlert(msg);
			}
		}
	</cfsavecontent>

	<cfsavecontent variable="qtrigger_onLoad">
	//	alert('qtrigger_onLoad');
	
	//	myQryName.enabled = false;
	//	var a = myQryName.dataProvider.slice(0);
	//	myQryName.dataProvider.removeAll();
	//	for (var i = 0; i < a.length; i++) {
	//		myQryName.dataProvider.addItemAt(i + 1, a[i].data, a[i].data);
	//	}
	//	myQryName.enabled = true;
	</cfsavecontent>

	<cfset db_err = "False">
	<cftry>
		<cfquery name="qGetSavedQueries" datasource="#Request.DSN#">
			SELECT id, qry_name, begin_date, end_date, ftp_source
			FROM SavedQueries
			ORDER BY qry_name
		</cfquery>
	
		<cfcatch type="Database">
			<cfset db_err = "True">
			<cfsavecontent variable="Request.db_error">
				<cfdump var="#cfcatch#" label="qGetSavedQueries dbError">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfif (db_err)>
		#Request.db_error#
	<cfelseif (IsDefined("qGetSavedQueries")) AND 0>
		<cfdump var="#qGetSavedQueries#" label="qGetSavedQueries - [#db_err#]" expand="No">
	</cfif>

	<cfif (NOT db_err)>
		<cfset ftpSource_Tibco = "No">
		<cfset ftpSource_IML = "No">
		<cfset ftpSource_All = "No">
		<cfif (Len(Trim(qGetSavedQueries.ftp_source)) gt 0)>
			<cfif (LCASE(qGetSavedQueries.ftp_source) eq Request.const_31_day_symbol)>
				<cfset ftpSource_Tibco = "Yes">
			<cfelseif (LCASE(qGetSavedQueries.ftp_source) eq 'all')>
				<cfset ftpSource_All = "Yes">
			<cfelse>
				<cfset ftpSource_IML = "Yes">
			</cfif>
		</cfif>
	</cfif>

	<cfscript>
		function rebuildQueryAfterInsert(q, s_array) {
			var i = -1;
			var j = -1;
			var k = -1;
			var varName = '';
			var varVal = '';
			var colName = '';
			var qQ = QueryNew(q.columnList);
			
			if (IsQuery(q)) {
				if (IsArray(s_array)) {
					QueryAddRow(qQ, 1);
					for (k = 1; k lte ArrayLen(s_array); k = k + 1) {
						colName = Request.commonCode._GetToken(s_array[k], 1, '=');
						varVal = Request.commonCode._GetToken(s_array[k], 2, '=');
						QuerySetCell(qQ, colName, varVal, qQ.recordCount);
					}
				}
				for (i = 1; i lte q.recordCount; i = i + 1) {
					QueryAddRow(qQ, 1);
					for (j = 1; j lte ListLen(q.columnList, ','); j = j + 1) {
						colName = Request.commonCode._GetToken(q.columnList, j, ',');
						varName = 'q.#colName#[#i#]';
						try {
							varVal = Evaluate(varName);
						} catch (Any e) {
							varVal = '';
						}
						QuerySetCell(qQ, colName, varVal, qQ.recordCount);
					}
				}
			}
			return qQ;
		}
	
		_array = ArrayNew(1);
		_array[1] = 'BEGIN_DATE=';
		_array[2] = 'END_DATE=';
		_array[3] = 'FTP_SOURCE=';
		_array[4] = 'ID=-1';
		_array[5] = 'QRY_NAME=#const_ChooseQuery_symbol#';
	
		if (IsDefined("qGetSavedQueries")) {
			qGetSavedQueries = rebuildQueryAfterInsert(qGetSavedQueries, _array);
		}
	</cfscript>
	
	<cfset db_err = "False">
	<cftry>
		<cfquery name="qGetReportTypes" datasource="#Request.DSN#">
			SELECT DISTINCT report_name
			FROM TibcoReportNameDefs
			ORDER BY report_name
		</cfquery>
	
		<cfcatch type="Database">
			<cfset db_err = "True">
			<cfsavecontent variable="Request.db_error">
				<cfdump var="#cfcatch#" label="qGetReportTypes dbError">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<table width="100%" align="center" cellpadding="-1" cellspacing="-1">
		<tr>
			<td width="10%" align="left">
				<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj107.id);">
			</td>
			<td width="*" align="center">
				<span class="normalStatusClass"></span>
			</td>
			<td width="10%" align="right">
				<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj107.id);">
			</td>
		</tr>
	</table>

	<cfscript>
		_default_beginDate = Request.commonCode._GetToken(Request.commonCode.defaultBeginDateString(), 1, ' ');
		if ( (IsDefined("qGetSavedQueries.begin_date")) AND (IsNumericDate(qGetSavedQueries.begin_date)) ) {
			_default_beginDate = DateFormat(qGetSavedQueries.begin_date, 'mm/dd/yyyy');
		}

		_default_endDate = Request.commonCode._GetToken(Request.commonCode.defaultEndDateString(), 1, ' ');
		if ( (IsDefined("qGetSavedQueries.end_date")) AND (IsNumericDate(qGetSavedQueries.end_date)) ) {
			_default_endDate = DateFormat(qGetSavedQueries.end_date, 'mm/dd/yyyy');
		}
	</cfscript>
</cfif>

<cfif (NOT db_err)>
	<cftry>
		<cfset nRecs = qGetFTPReportsData.recordCount>

		<cfcatch type="Any">
			<cfset nRecs = -1>

			<cfsavecontent variable="errMsg">
				<cfif (IsDefined("qGetFTPReportsData"))>
					<cfdump var="#qGetFTPReportsData#" label="qGetFTPReportsData [?!?]">
				</cfif>
				<cfdump var="#cfcatch#" label="cfcatch [?!?]">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cftry>
		<cfset _nRecs = -1>
		<cfif (IsDefined("_qGetFTPReportsData.recordCount"))>
			<cfset _nRecs = _qGetFTPReportsData.recordCount>
		</cfif>

		<cfcatch type="Any">
			<cfset _nRecs = -1>

			<cfsavecontent variable="errMsg">
				<cfif (IsDefined("errMsg"))>
					<cfoutput>
						#errMsg#
					</cfoutput>
				</cfif>
				<cfif (IsDefined("_qGetFTPReportsData"))>
					<cfdump var="#_qGetFTPReportsData#" label="_qGetFTPReportsData [?!?]">
				</cfif>
				<cfdump var="#cfcatch#" label="cfcatch [?!?]">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfscript>
//		writeOutput(errMsg);
	</cfscript>

	<cfform name="myForm" method="POST" action="ftp-browser.cfm" height="700" format="Flash" skin="haloOrange">
		<cfsavecontent variable="ftpQueryPage">
			<cfif (NOT bool_showGrid)>
				<cfinput type="Hidden" name="myBeginDate" value="#_default_beginDate#">
				<cfinput type="Hidden" name="myEndDate" value="#_default_endDate#">
				<cfformgroup  type="panel" height="450" label="FTP Queries (Queries are saved for later use - make sure your Query Names are unique to avoid overwriting existing Queries)" visible="Yes" enabled="Yes">
					<cfformgroup  type="tabnavigator" visible="Yes" enabled="Yes">
						<cfformgroup  type="page" label="Step 1 (Date Range)" width="800" visible="Yes" enabled="Yes">
							<cfinput type="DateField" name="begin_date" bind="{myForm.myBeginDate}" width="100" firstdayofweek="0" label="Begin Date:" validate="date" required="No" visible="Yes" enabled="Yes" onchange="#begin_date_onchange#">
							<cfinput type="DateField" name="end_date" width="100" bind="{myForm.myEndDate}" firstdayofweek="0" label="End Date:" validate="date" required="No" visible="Yes" enabled="Yes" onchange="#end_date_onchange#">
							<cfformitem  type="html" width="500" height="20" visible="Yes" enabled="Yes" style="fontSize: 7; borderStyle:solid;">
								The Begin Date is always taken to be the date that falls before the other Date.
							</cfformitem>
						</cfformgroup>
						<cfformgroup  type="page" label="Step 2 (Report Types)" visible="Yes" enabled="Yes">
							<cfset size_of_select = Request.commonCode._GetToken(Int(Min(11, qGetReportTypes.recordCount)), 1, ".")>
							<cfselect name="myReportType" size="#size_of_select#" style="fontFamily:'Verdana';fontSize:9;fontStyle:normal;fontWeight:normal;" label="Choose Report Type(s):" queryposition="below" query="qGetReportTypes" value="report_name" visible="Yes" enabled="Yes" multiple="Yes">
							</cfselect>
						</cfformgroup>
						<cfif (NOT Request.bool_inhibit_use_of_step3)>
							<cfformgroup  type="page" label="Step 3 of 3 (#Request.const_6_day_symbol# or #Request.const_31_day_symbol#)" visible="No" enabled="No">
								<cfformitem  type="html" width="130" visible="Yes" enabled="Yes" style="fontFamily: Verdana; fontSize: 8;">Source of FTP Data:</cfformitem>
								<cfinput type="Radio" name="ftpSource" label="#Request.const_31_day_symbol#" checked="#ftpSource_Tibco#" value="#Request.const_31_day_symbol#" visible="Yes" enabled="Yes">
								<cfinput type="Radio" name="ftpSource" label="#Request.const_6_day_symbol#" checked="#ftpSource_IML#" value="#Request.const_6_day_symbol#" visible="Yes" enabled="Yes">
								<cfinput type="Radio" name="ftpSource" label="All" checked="#ftpSource_All#" value="All" visible="Yes" enabled="Yes">
							</cfformgroup>
						</cfif>
					</cfformgroup>

					<cfformgroup  type="vertical" visible="Yes" enabled="Yes">
						<cfselect name="myQryName" label="Run this Named Query:" query="qGetSavedQueries" value="qry_name" visible="Yes" enabled="Yes" tooltip="This list contains the List of Queries that you and other users have used previously.  Choose a Query from this list OR make a query by entering a unique query name in the appropriate entry field." onchange="#myQryName_receiveCall##myQryName_sendData##submit_enabled#">
						</cfselect>
						<cfformgroup  type="horizontal" visible="Yes" enabled="Yes" style="margin-left: -145;">
							<cfinput type="Text" name="newQryName" label="OR Enter a New Query Name:" required="No" visible="Yes" enabled="Yes" size="45" maxlength="50" onchange="#submit_enabled#" bind="{myQryName.value}">
							<cfinput type="Button" name="btn_update_query_list" value="[Refresh Query List]" width="150" visible="Yes" enabled="Yes" tooltip="Because all users share the same List of Saved Queries you may wish to click this button to Refresh the list of Queries to obtain the most up to date list of available queries." onclick="#refresh_click#">
						</cfformgroup>
						<cfinput type="Hidden" name="myQryParameter_keyword" value="">
						<cfif (Request.commonCode.isServerLocal()) AND 0>
							<cfinput type="Text" name="qryParameter_keyword" label="Keyword to Search for:" required="No" visible="Yes" enabled="Yes" size="40" maxlength="50" bind="{myForm.myQryParameter_keyword}">
						</cfif>
					</cfformgroup>

					<!--- I made the "trigger" input invisible with width and height equal to 0 because it can not be hidden--->
					<cfinput  type="text" visible="false" height='0' width="0" name="qtrigger" value="init" onchange="#qtrigger_onLoad#" bind="#query_event_binding#">

					<cfformgroup  type="horizontal" height="80" visible="Yes" enabled="Yes"> <!---  style="borderStyle: solid;" --->
						<cfinput type="Button" name="submit_query" value="[Submit Query]" visible="Yes" enabled="No" onmousedown="#js_submit_link#">
						<cfformitem  type="html" width="600" visible="Yes" enabled="Yes">
							The Submit button is disabled UNTIL you select a Query Name from the List of Queries OR Choose a Report Type OR Change the Query Name such as when defining a new Query.
						</cfformitem>
					</cfformgroup>
<cfif 0>
					<cfformgroup  type="horizontal" width="900" height="220" visible="Yes" enabled="Yes" style="fontSize: 8; borderStyle: solid;">
						<cfif Request.commonCode.isServerLocal()>
							<cfformitem  type="html" visible="Yes" enabled="Yes">
								<b>Directions:</b> (This Ad-Hoc Query Builder is as Easy as 1...2...3...4...5 !)<br>
								(1). Select the Date Range.<br>
								(2). Select the Report Type<br>
								(3). Select the FTP Data Source (#Request.const_31_day_symbol# or #Request.const_6_day_symbol#)<br>
								(4). Type in the Name or Description text for this Query<br>
								(5). Type in an optional Keyword to search for, this can be any keyword such as 'STROBE XP 450 PDF'; a record matches if the keyword is found in the raw data. (Keyword searches might take a while due to the volume of data to search.)<br>
								<br>
								Then just click the [Submit Query] button.<br>
								<br>
								You may return later to rerun your Query by simply choosing the Query Name from the Pull-Down List. 
								Then just click the [Submit Query] button.<br>
								<br>
								Click the [Refresh Query List] button to see the latest Query Names from the database - this is a handy button to click whenever you know someone who has just saved a Query you want to run but that Query Name is not yet on the list.
							</cfformitem>
						<cfelse>
							<cfformitem  type="html" visible="Yes" enabled="Yes">
								<b>Directions:</b> (This Ad-Hoc Query Builder is as Easy as 1...2...3...4 !)<br>
								(1). Select the Date Range.<br>
								(2). Select the Report Type<br>
								(3). Select the FTP Data Source (#Request.const_31_day_symbol# or #Request.const_6_day_symbol#)<br>
								(4). Type in the Name or Description text for this Query<br>
								<br>
								Then just click the [Submit Query] button.<br>
								<br>
								You may return later to rerun your Query by simply choosing the Query Name from the Pull-Down List. 
								Then just click the [Submit Query] button.<br>
								<br>
								Click the [Refresh Query List] button to see the latest Query Names from the database - this is a handy button to click whenever you know someone who has just saved a Query you want to run but that Query Name is not yet on the list.
							</cfformitem>
						</cfif>
					</cfformgroup>
</cfif>

					<cfinput type="Hidden" name="myHiddenQueryText" value="">
					<cfinput type="Hidden" name="page" value="#const_ftpGridPage#">

					<cfif 0>
						<cfformgroup  type="panel" label="SQL Statement" visible="#Request.commonCode.isServerLocal() AND 0#" enabled="Yes">
							<cfformitem  type="html" width="800" height="200" visible="Yes" enabled="Yes" bind="{myForm.myHiddenQueryText}" style="borderStyle:solid;">
							</cfformitem>
						</cfformgroup>
					</cfif>
				</cfformgroup>
			</cfif>
		</cfsavecontent>

		<cfsavecontent variable="ftpGridPage">
			<cfif (bool_showGrid)>
				<cfformgroup  type="page" label="FTP Data (use FTP Queries to choose the subset of data records you want to see)" visible="#(bool_showGrid)#" enabled="Yes">
					<cfformgroup  type="hbox" visible="Yes" enabled="Yes">
						<cfformgroup  type="vbox" visible="Yes" enabled="Yes">
							<cfformgroup  type="horizontal" visible="Yes" enabled="Yes" style="margin-left: 0;">
								<cfinput type="Button" name="btn_view_excel" value="[View Excel Data]" visible="Yes" enabled="No" tooltip="Click this button to view the parsed data in Excel via a .CSV format." onclick="#js_excel_link#">
								<cfinput type="Button" name="btn_view_raw" value="[View Raw Data]" visible="Yes" enabled="No" tooltip="Click this button to view the raw unparsed data." onclick="#js_raw_link#">
								<cfinput type="Button" name="btn_view_logs" value="[View Process Logs]" visible="Yes" enabled="No" tooltip="Click this button to view the FTP Download Process Activity Logs." onclick="#js_logs_link#">
							</cfformgroup>

							<cfformgroup  type="horizontal" visible="Yes" enabled="Yes" style="margin-left: 0;">
								<cfinput type="Checkbox" name="bool_aggregate" label="Aggregate the Whole Grid as One Report for View Raw Data (only one Report Type at a time)" value="Yes" visible="#(ListLen(_myReportType, ",") eq 1)#" enabled="No" tooltip="Check this item to treat all the reports shown in the Grid as a single report for View Raw Data.  This option is disabled for View Excel due to possible performance problems.  You may export data from View Raw Data to Excel - see the instructions after clicking the apropriate button." onclick="#js_bool_aggregate_onclick#">
							</cfformgroup>

							<cfformgroup  type="horizontal" visible="#Request.commonCode.isServerLocal()#" enabled="#Request.commonCode.isServerLocal()#" style="margin-left: 0;">
								<cfinput type="Button" name="btn_view_trash" value="[View Trash Data]" visible="#Request.commonCode.isServerLocal()#" enabled="No" tooltip="Click this button to view the trash data the parser threw away with the analysis and reasoning." onclick="#js_trash_link#">
								<cfinput type="Button" name="btn_data_mart" value="[Data Mart It]" visible="#Request.commonCode.isServerLocal()#" enabled="#( (Request.commonCode.isServerLocal()) AND (qGetFTPReportsData.recordCount gt 0) )#" tooltip="Click this button to store the data for the selected record in the Data Mart." onclick="#js_dataMart_link#">
								<cfinput type="Button" name="btn_data_mart_process" value="[Data Mart Process]" visible="#Request.commonCode.isServerLocal()#" enabled="#( (Request.commonCode.isServerLocal()) AND (qGetFTPReportsData.recordCount gt 0) )#" tooltip="Click this button to intiate the Data Mart Process." onclick="#js_dataMart_process_link#">
							</cfformgroup>
						</cfformgroup>
					</cfformgroup>


					<cfinput type="Text" name="txt_record_info" label="Source File Name:" width="780" required="No" visible="Yes" enabled="Yes" readonly bind="{ftpGrid.dataProvider[ftpGrid.selectedIndex].file_path}">
					<!--- I made the "trigger" input invisible with width and height equal to 0 because it can not be hidden--->
					<cfinput  type="text" visible="false" height='0' width="0" name="trigger" value="init" onchange="#trigger_onLoad#" bind="#onLoad_event_binding#">

					<cfif (_nRecs lt 1)>
						<cfif 0>
							<cfsavecontent variable="sql_qBruteForceNumRecs">
								DECLARE @t as datetime
								SELECT @t = GETDATE()
								DECLARE @bt as datetime
								SELECT @bt = CAST('1900-01-01 00:00:00.0' as datetime)
								DECLARE @et as datetime
								SELECT @et = CAST('3999-12-31 23:59:59.9' as datetime)
								SELECT id, recid, last_modified_dt, file_length, file_name, file_path, file_url, report_name, raw_data, rec_id
								FROM dbo.GetCombinedTerseFTPReportsData(@t,@bt,@et)
								WHERE (file_length IS NOT NULL) AND (file_length > 0)
							</cfsavecontent>
						</cfif>
					</cfif>

					<cfscript>
						// BEGIN: If the total recs could not be determined from the cache then use this method that simply brute forces the computation...
						if (_nRecs lt 1) {
							mySQL_statement = sql_qGetBruteForceNumRecsFromDb(CreateDateTime(1900, 1, 1, 0, 0, 0.0), CreateDateTime(3999, 12, 31, 23, 59, 59.9));
							qNumRecs = Request.primitiveCode.safely_execSQL('qBruteForceNumRecs', Request.DSN, mySQL_statement);
			
							if (NOT Request.dbError) {
								_nRecs = qNumRecs.recordCount;
							}
						}
						// END! If the total recs could not be determined from the cache then use this method that simply brute forces the computation...
					</cfscript>

					<cfformgroup  type="hbox" visible="Yes" enabled="Yes" width="800">
						<cfformgroup  type="horizontal" visible="Yes" enabled="Yes">
							<cfformitem  type="text" width="200" visible="Yes" enabled="Yes">
								Displaying #nRecs# of #_nRecs# records.
							</cfformitem>
							<cfif 0>
								<cfinput type="Button" name="btn_restore_default_records" value="[Show ALL Records]" visible="No" enabled="No" tooltip="Click this button to show all the records, this button is disabled whenever all the records are being shown.  Note: This button is no longer available and will be removed from the GUI soon.  PLS use the [FTP Data Query Builder] button to Query the database because doing so is more efficient." onclick="#restore_records_click#"> <!--- enabled="#(nRecs neq _nRecs)#" --->
							</cfif>
							<cfinput type="Button" name="btn_restore_preveom_records" value="[Show Prev EOM]" visible="Yes" enabled="Yes" tooltip="Click this button to show records for the previous End Of Month Period. (If today is after the 15th of the month then this shows the previous month otherwise it shows the month before that.)" onclick="#showpreveom_records_click#">
							<cfinput type="Button" name="btn_restore_eom_records" value="[Show EOM]" visible="Yes" enabled="Yes" tooltip="Click this button to show records for the most recent End Of Month Period. (If today is after the 15th of the month then this shows the current month otherwise it shows the previous month.)" onclick="#showeom_records_click#">
							<cfinput type="Button" name="btn_restore_month_records" value="[Show 30 Days]" visible="Yes" enabled="Yes" tooltip="Click this button to show records for the most recent 30 days." onclick="#showmonth_records_click#">
							<cfinput type="Button" name="btn_show_query_page" value="[FTP Data Query Builder]" visible="Yes" enabled="Yes" tooltip="Click this button to Query the FTP Data using an Ad-Hoc Query." onclick="#show_query_page_click#">
						</cfformgroup>
					</cfformgroup>

					<cfset ftpGrid_page_height = 300>
					<cfformgroup  type="page" label="FTP Records" width="910" height="#ftpGrid_page_height#" visible="Yes" enabled="Yes">
						<cfgrid name="ftpGrid" query="qGetFTPReportsData" width="885" height="#(ftpGrid_page_height - 25)#" font="Verdana" fontsize="9" insert="No" delete="No" sort="Yes" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="BROWSE" picturebar="No" onchange="#ftpGrid_action##txt_record_info_onchange#">  <!--- #receiveCall# #s_sendData# --->
							<cfgridcolumn name="id" header="##" width="40" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
							<cfif (IsDefined("qGetFTPReportsData.recid"))>
								<cfgridcolumn name="recid" header="##" width="40" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="No" headerbold="No" headeritalic="No">
							</cfif>
							<cfif (IsDefined("qGetFTPReportsData.rec_id"))>
								<cfgridcolumn name="rec_id" header="Data Mart Id" width="80" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
							</cfif>
							<cfgridcolumn name="last_modified_dt" header="Date" width="140" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
							<cfgridcolumn name="file_length" header="Bytes" width="80" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
							<cfif (IsDefined("qGetFTPReportsData.report_name"))>
								<cfgridcolumn name="report_name" header="Report Name" width="250" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
							</cfif>
							<cfgridcolumn name="file_url" header="Data Source" width="80" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
							<cfset _remaining_width = (1040 - (40 + 80 + 140 + 80 + 250 + 80))>
							<cfgridcolumn name="file_path" header="Source File Name" width="#_remaining_width#" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="No" headeritalic="No">
							<cfif (Request.commonCode.isServerLocal()) AND 0>
								<cfset _remaining_width = (1500 - (40 + 40 + 140 + 60 + 200 + 50))>
								<cfgridcolumn name="raw_data" header="" width="0" headeralign="LEFT" dataalign="LEFT" bold="No" italic="No" select="No" display="No" headerbold="No" headeritalic="No">
							</cfif>
						</cfgrid>
					</cfformgroup>
				</cfformgroup>
			</cfif>
		</cfsavecontent>

		<cfif (page eq const_ftpGridPage)>
			#ftpGridPage#
		<cfelse>
			#ftpQueryPage#
		</cfif>
	</cfform>
<cfelse>
	<BIG><span class="errorStatusClass">ERROR: Cannot Query FTP Reports Data because:</span></BIG><br>
	#Request.db_error#
</cfif>

<cfif (Request.commonCode.isServerLocal()) AND (IsDefined("errMsg"))>
	#errMsg#
</cfif>

</cfoutput>

<script language="JavaScript1.2" type="text/javascript">
<!--
	var aDHTMLObj100 = DHTMLWindowsObj.getInstance();
	var aDHTMLObj101 = DHTMLWindowsObj.getInstance();
	var aDHTMLObj102 = DHTMLWindowsObj.getInstance();
	var aDHTMLObj103 = DHTMLWindowsObj.getInstance();
	var aDHTMLObj104 = DHTMLWindowsObj.getInstance();
	var aDHTMLObj105 = DHTMLWindowsObj.getInstance();
	var aDHTMLObj106 = DHTMLWindowsObj.getInstance();
	var aDHTMLObj107 = DHTMLWindowsObj.getInstance();
	var t = aDHTMLObj100.asHTML() + aDHTMLObj101.asHTML() + aDHTMLObj102.asHTML() + aDHTMLObj103.asHTML() + aDHTMLObj104.asHTML() + aDHTMLObj105.asHTML() + aDHTMLObj106.asHTML() + aDHTMLObj107.asHTML();
	document.write(t);
// --> 
</script>

</body>
</html>
