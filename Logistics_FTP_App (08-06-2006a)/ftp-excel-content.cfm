<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="120">

<cfparam name="nocache" type="string" default="">
<cfparam name="recid" type="string" default="-1">
<cfparam name="repName" type="string" default="">
<cfparam name="rec_id" type="string" default="">
<cfparam name="allow_dl" type="boolean" default="False">
<cfparam name="bool" type="boolean" default="False">

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

<cfscript>
	err_excelWriter = false;
	try {
	   Request.excelWriter = CreateObject("component", "cfc.excelWriter");
	} catch(Any e) {
		err_excelWriter = true;
	   writeOutput('<font color="red"><b>The excelWriter component has NOT been created.</b></font><br>');
		if (Request.commonCode.isServerLocal()) {
			writeOutput(Request.primitiveCode.cf_dump(e, 'CreateObject("component", "cfc.excelWriter")', false));
		}
	}
</cfscript>

<cfoutput>
	<cfset bool_usefulData = "False">
	<cfinclude template="cfinclude_processRawData.cfm">
	<cfif 0>
		bool_usefulData = [#bool_usefulData#]<br>
	</cfif>
	<cfif (bool_usefulData)>
		<cfif (NOT db_err)>
			<cfscript>
				fName = Request.excelReader.filterAlphaNumeric(repName);
			</cfscript>

			<cfscript>
//					tName = Request.excelWriter.writeExcelCSVFromQuery(qGetFTPReportData, fName);

				tName = Request.excelWriter.writeExcelCSVFromRawData(URLDecode(qGetFTPReportData.RAW_DATA), fName);
				
//					writeOutput('tName = [#tName#]<br>');
				uName = Request.commonCode._GetToken(tName, ListLen(tName, '\'), '\');
				writeOutput('Click the link to view your report. ');
				writeOutput('<a href="#Request.const_excel_data_symbol#/#uName#">#repName#</a><br>');
			</cfscript>

			<cfif 0>
				<cfif (allow_dl)>
					<cfheader name="Content-Disposition" value="inline; filename=#fName#_#recid#.csv">
				</cfif>
				<cfcontent type="application/vnd.ms-excel" file="#tName#" deletefile="Yes">
			</cfif>
		<cfelse>
			<BIG><span class="errorStatusClass">ERROR: Cannot Query FTP Reports Raw Data because:</span></BIG><br>
			#Request.db_error#
		</cfif>
	</cfif>
</cfoutput>
