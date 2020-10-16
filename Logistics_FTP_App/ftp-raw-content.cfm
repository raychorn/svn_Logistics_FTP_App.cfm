<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="120">

<cfparam name="nocache" type="string" default="">
<cfparam name="recid" type="string" default="-1">
<cfparam name="repName" type="string" default="">
<cfparam name="rec_id" type="string" default="">
<cfparam name="allow_dl" type="boolean" default="False">
<cfparam name="bool" type="boolean" default="False">

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

			<cfif (allow_dl) AND 1>
				<cfheader name="Content-Disposition" value="inline; filename=#fName#_#ReplaceNoCase(recid, ',', '+', 'all')#.txt">
			</cfif>

			<cfscript>
				s_data = '';
			//	writeOutput('recid = [#recid#], (IsDefined("qGetFTPReportData")) = [#(IsDefined("qGetFTPReportData"))#], (IsQuery(qGetFTPReportData)) = [#(IsQuery(qGetFTPReportData))#]<br>');
				if ( (IsDefined("qGetFTPReportData")) AND (IsQuery(qGetFTPReportData)) ) {
				//	writeOutput('qGetFTPReportData.recordCount = [#qGetFTPReportData.recordCount#]<br>');
					for (i = 1; i lte qGetFTPReportData.recordCount; i = i + 1) {
						s_data = s_data & qGetFTPReportData.raw_data[i];
					}
				}
				
				s_tdata = URLDecode(s_data);
			</cfscript>

			<cfif 1>
				<cfcontent type="text/plain" variable="#ToBinary(ToBase64(URLDecode(s_data)))#">
			<cfelseif 0>
				#s_data#
			<cfelseif 0>
				<cfdump var="#qGetFTPReportData#" label="qGetFTPReportData" expand="Yes">
			<cfelseif 0>
				Len(s_data) = [#Len(s_data)#]<br>
				Len(s_tdata) = [#Len(s_tdata)#]<br>
				<textarea readonly rows="25" cols="120" style="font-size: 11px;">#s_data#</textarea>
			</cfif>
		<cfelse>
			<BIG><span class="errorStatusClass">ERROR: Cannot Query FTP Reports Raw Data because:</span></BIG><br>
			#Request.db_error#
		</cfif>
	</cfif>
</cfoutput>
