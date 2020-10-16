<cfsetting requesttimeout="#(60 * 60 * 5)#">

<CFINCLUDE TEMPLATE="Header.cfm">

<cfsavecontent variable="sql_qFindMissingData">
	SELECT TIBCO_FTP_SHORT_NAMES.short_name, TIBCO_FTP_FULL_NAMES.full_dir_name_abbrev, TIBCO_FTP_FULL_NAMES.full_dir_name, 
	       DATALENGTH(TIBCO_FTP.raw_data) AS byteCount1, TIBCO_FTP_DATA.the_dt, DATALENGTH(TIBCO_FTP_DATA.raw_data) AS byteCount2,
		   TIBCO_FTP.raw_data as raw_data1, TIBCO_FTP_DATA.raw_data as raw_data2
	FROM TIBCO_FTP INNER JOIN
	     TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid INNER JOIN
	     TIBCO_FTP_FULL_NAMES ON TIBCO_FTP.fid = TIBCO_FTP_FULL_NAMES.fid LEFT OUTER JOIN
	     TIBCO_FTP_DATA ON TIBCO_FTP.lid = TIBCO_FTP_DATA.lid
	/*
	WHERE (TIBCO_FTP_FULL_NAMES.full_dir_name_abbrev = '93203    94454 Sep 23 06:01 SRP600PCD0001.THU')
	*/
	ORDER BY TIBCO_FTP_DATA.the_dt DESC, TIBCO_FTP_SHORT_NAMES.short_name
</cfsavecontent>

<cfscript>
	qAnalysis = Request.primitiveCode.safely_execSQL('qFindMissingData', Request.DSN, sql_qFindMissingData);
	if (Request.dbError) {
		writeOutput('<span class="errorStatusClass">ERROR: Cannot fetch the data from the database for this request.</span><br>' & Request.fullErrorMsg);
	} else {
		writeOutput('<span class="normalStatusClass">There are #qAnalysis.recordCount# records to analyze.</span>');

		beginTime = Now();
		writeOutput('<span class="normalStatusClass">BEGIN: #beginTime#</span>');
		
		// Get a List of days...
		for (i = 1; i lte qAnalysis.recordCount; i = i + 1) {
			break;
		}

		endTime = Now();
		writeOutput('<span class="normalStatusClass">END: #endTime#</span><br>');

		_elapsedTime = endTime - beginTime;
		fmt_elapsedTime = TimeFormat(_elapsedTime, "HH:mm:ss");
		writeOutput('<span class="normalStatusClass">Elapsed Time: #fmt_elapsedTime#</span><br>');
	}
</cfscript>

<CFINCLUDE template="footer.cfm">
