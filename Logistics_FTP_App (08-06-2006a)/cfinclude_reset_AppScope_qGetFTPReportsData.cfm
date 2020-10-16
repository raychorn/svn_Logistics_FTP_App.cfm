<cfset db_err = "False">
<cftry>
	<cfquery name="qDetermineTimeToBreakCache" datasource="#Request.DSN#">
		DECLARE @totRecs as int;
		DECLARE @numRecs as int;
		SELECT @totRecs = 0;
		
		SELECT @numRecs = (SELECT COUNT(IML_FTP.id) as num FROM IML_FTP);
		SELECT @totRecs = @totRecs + @numRecs;
		
		SELECT @numRecs = (
			SELECT COUNT(TIBCO_FTP.id) as num
			FROM TIBCO_FTP INNER JOIN
				TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid INNER JOIN
				TIBCO_FTP_FULL_NAMES ON TIBCO_FTP.fid = TIBCO_FTP_FULL_NAMES.fid
		);
		
		SELECT @totRecs = @totRecs + @numRecs;
		
		SELECT @totRecs as totalRecs;
	</cfquery>

	<cfcatch type="Database">
		<cfset db_err = "True">
		<cfsavecontent variable="Request.db_error">
			<cfdump var="#cfcatch#" label="qGetReportTypes dbError">
		</cfsavecontent>
	</cfcatch>
</cftry>

<cfif (NOT db_err)>
	<cfscript>
		function read_AppScope_qGetFTPReportsData() { Request._qGetFTPReportsData = -1; if ( (IsDefined("Application._qGetFTPReportsData")) AND (IsQuery(Application._qGetFTPReportsData)) ) { Request._qGetFTPReportsData = Application._qGetFTPReportsData; } else {  }; }
	
		Request.primitiveCode.cf_lock('LOCK_read_AppScope_qGetFTPReportsData', read_AppScope_qGetFTPReportsData, 'READONLY', 'Application');
	</cfscript>
	
	<cfif (IsQuery(Request._qGetFTPReportsData))>
		<cfoutput>
			(Request._qGetFTPReportsData.recordCount neq qDetermineTimeToBreakCache.totalRecs) = [#(Request._qGetFTPReportsData.recordCount neq qDetermineTimeToBreakCache.totalRecs)#]<br>
		</cfoutput>

		<cfif (Request._qGetFTPReportsData.recordCount neq qDetermineTimeToBreakCache.totalRecs) OR (Request.commonCode.isServerLocalHost()) OR (Request.commonCode.isServerredactedDevHost())>
			<cfscript>
				function reset_AppScope_qGetFTPReportsData() { if (IsDefined("Request._qGetFTPReportsData")) { Application._qGetFTPReportsData = Request._qGetFTPReportsData; } else { writeOutput('<font color="red"><b>ERROR: Programming error - the system is not behaving correctly - kindly notify the developer(s).</b></font>'); }; }
			
				Request._qGetFTPReportsData = -1;
				Request.primitiveCode.cf_lock('LOCK_reset_AppScope_qGetFTPReportsData', reset_AppScope_qGetFTPReportsData, 'EXCLUSIVE', 'Application');
				
				if ( (Request.commonCode.isServerLocalHost()) OR (Request.commonCode.isServerredactedDevHost()) ) {
					writeOutput('Forced this action by developer request.<br>');
				}
			</cfscript>
		</cfif>
	</cfif>
</cfif>
