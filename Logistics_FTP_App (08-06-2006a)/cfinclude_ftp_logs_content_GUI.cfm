<cfscript>
	if (UCASE(sDataSrc) neq UCASE(Request.const_31_day_symbol)) {
//		writeOutput(Request.primitiveCode.cf_dump(Request.qLog2a, 'Request.qLog2a', false));

		for (k = 1; k lte Request.qLog2a.recordCount; k = k + 1) {
			_strA = Right(Request.qLog2a.log_msg[k], (Len(Request.qLog2a.log_msg[k]) - FindNoCase(' :: ', Request.qLog2a.log_msg[k])) - 3);
			_str2 = Request.commonCode._GetToken(_strA, 2, '[');
			_str3 = Request.commonCode._GetToken(_str2, ListLen(_str2, '\'), '\');
			_str4 = Request.commonCode._GetToken(_str3, 2, '_') & '_' & Request.commonCode._GetToken(_str3, 3, '_');
			_strZ = Request.commonCode._GetToken(_str4, 1, ']');
			QuerySetCell(Request.qLog2a, 'log_msg', Request.commonCode.stripHTML(Request.commonCode._GetToken(_strA, 1, '[') & '-->' & _strZ), k);
		}
	}
</cfscript>

<cfoutput>
	<cfform action="#CGI.SCRIPT_NAME#" method="POST" name="myForm" height="480" format="Flash" skin="haloBlue">
		<cfformgroup  type="panel" label="FTP Logs for #Request._repDesc# (#Request._fName#) on #Request.fmt_beginDate# to #Request.fmt_endDate#" height="450" visible="Yes" enabled="Yes">
			<cfgrid name="ftpLogsGrid" query="Request.qLog2a" width="880" height="410" font="Verdana" fontsize="9" insert="No" delete="No" sort="Yes" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="BROWSE" picturebar="No"> <!---  onchange="#ftpGrid_action##txt_record_info_onchange#" --->
				<cfgridcolumn name="id" header="##" headeralign="CENTER" dataalign="LEFT" width="60" bold="No" italic="No" select="No" display="Yes" type="NUMERIC" headerbold="No" headeritalic="No">
				<cfgridcolumn name="the_dt" header="Date/Time" headeralign="CENTER" dataalign="LEFT" width="120" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
				<cfgridcolumn name="log_msg" header="Log Message" headeralign="CENTER" dataalign="LEFT" width="#(850 - 120 + 60)#" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
			</cfgrid>
		</cfformgroup>
	</cfform>
</cfoutput>
