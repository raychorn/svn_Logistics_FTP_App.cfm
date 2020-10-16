<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 60)#">

<cfscript>
	err_dataResponder = false;
	try {
	   Request.dataResponder = CreateObject("component", "dataResponder");
	} catch(Any e) {
		err_dataResponder = true;
	   writeOutput('<font color="red"><b>dataResponder component has NOT been created.</b></font><br>');
		if (Request.commonCode.isServerLocal()) {
			writeOutput(Request.primitiveCode.cf_dump(e, 'CreateObject("component", "dataResponder")', false));
		}
	}
</cfscript>

<cfparam name="nocache" type="string" default="">
<cfparam name="recid" type="string" default="-1">
<cfparam name="repName" type="string" default="">
<cfparam name="allow_dl" type="boolean" default="False">
<cfparam name="dm_id" type="string" default="">

<cfset const_ShipmentsDetails_report_type = "SRP739PCD0001.">

<cfset candidate_report_type_list = "'#const_ShipmentsDetails_report_type#'">

<cfscript>
	_sql_statement_ = "SELECT IML_FTP.last_modified_dt, IML_FTP.id, FTPDataBridge.ftp_id, TibcoReportNameDefs.report_name, IML_FTP.file_name FROM IML_FTP INNER JOIN TibcoReportNameDefs ON PATINDEX(TibcoReportNameDefs.report_prefix + '%', IML_FTP.file_name) > 0 LEFT OUTER JOIN FTPDataBridge ON IML_FTP.id = FTPDataBridge.ftp_id WHERE (UPPER(TibcoReportNameDefs.report_prefix) IN (#UCASE(candidate_report_type_list)#)) AND (FTPDataBridge.ftp_id IS NULL) ORDER BY IML_FTP.last_modified_dt";
	q = Request.primitiveCode.safely_execSQL('CandidateRecords', Request.DSN, _sql_statement_);
//writeOutput(Request.primitiveCode.cf_dump(q, '#_sql_statement_#', true));
	for (i = 1; l lte q.recordCount; i = i + 1) {
	}
</cfscript>