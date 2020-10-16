<cfsetting requesttimeout="#(60 * 60 * 5)#">

<CFINCLUDE TEMPLATE="Header.cfm">

<cfsavecontent variable="sql_qDataLinkage">
	SELECT TIBCO_FTP_PROCESS_QUEUE.id, TIBCO_FTP_PROCESS_QUEUE.fid, TIBCO_FTP_PROCESS_QUEUE.lid, 
	       TIBCO_FTP_PROCESS_QUEUE._destFName, TIBCO_FTP_PROCESS_QUEUE._shortFName, TIBCO_FTP_PROCESS_QUEUE._fullDirName, 
	       TIBCO_FTP_PROCESS_QUEUE.dt_downLoad, TIBCO_FTP_PROCESS_VALIDATION.dt_validated, TIBCO_FTP_PROCESS_VALIDATION.bool_validated, 
	       TIBCO_FTP_PROCESS_VALIDATION.bool_processed, TIBCO_FTP.raw_data, DATALENGTH(TIBCO_FTP.raw_data) AS byteCount
	FROM TIBCO_FTP_PROCESS_VALIDATION INNER JOIN
	     TIBCO_FTP_PROCESS_QUEUE ON TIBCO_FTP_PROCESS_VALIDATION._destFName = TIBCO_FTP_PROCESS_QUEUE._destFName INNER JOIN
	     TIBCO_FTP ON TIBCO_FTP_PROCESS_QUEUE.fid = TIBCO_FTP.fid AND TIBCO_FTP_PROCESS_QUEUE.lid = TIBCO_FTP.lid
	WHERE (TIBCO_FTP_PROCESS_VALIDATION.bool_validated = 1) AND (TIBCO_FTP_PROCESS_VALIDATION.bool_processed = 1)
		 AND (PATINDEX('%25425    93868 Sep 29 04:52 SRP600PCD0001.WED', TIBCO_FTP_PROCESS_QUEUE._fullDirName) > 0)
	ORDER BY TIBCO_FTP_PROCESS_VALIDATION.bool_validated DESC, TIBCO_FTP_PROCESS_QUEUE.dt_downLoad, 
	      TIBCO_FTP_PROCESS_VALIDATION.dt_validated
</cfsavecontent>

<!--- 
	Truncated data analysis - Find raw data that has any rows with columns less than the other rows...
 --->

<cfscript>
	qAnalysis = Request.primitiveCode.safely_execSQL('qFindMissingData', Request.DSN, sql_qDataLinkage);
	if (Request.dbError) {
		writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the data from the database for this request.</span><br>' & Request.fullErrorMsg);
	} else {
		writeOutput('<span class="normalStatusClass">There are #qAnalysis.recordCount# records to analyze.</span>');

		beginTime = Now();
		writeOutput('<span class="normalStatusClass">BEGIN: #beginTime#</span>');
		
		// Get a List of days...
		for (i = 1; i lte qAnalysis.recordCount; i = i + 1) {
			qAnalysis.raw_data[i] = URLDecode(qAnalysis.raw_data[i]);
		}
		writeOutput(Request.primitiveCode.cf_dump(qAnalysis, 'qAnalysis', false));

		endTime = Now();
		writeOutput('<span class="normalStatusClass">END: #endTime#</span><br>');

		_elapsedTime = endTime - beginTime;
		fmt_elapsedTime = TimeFormat(_elapsedTime, "HH:mm:ss");
		writeOutput('<span class="normalStatusClass">Elapsed Time: #fmt_elapsedTime#</span><br>');
	}
</cfscript>

<CFINCLUDE template="footer.cfm">
