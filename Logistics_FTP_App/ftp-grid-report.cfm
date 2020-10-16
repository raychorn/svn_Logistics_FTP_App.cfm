<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="120">

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
<cfparam name="rec_id" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (FTP Grid Report) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>

	<script language="JScript.Encode" src="js/loadJSCode_.js"></script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
//		loadJSCode("js/disable-right-click-script-III_.js");
		loadJSCode("js/MathAndStringExtend_.js");
	// --> 
	</script>

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

<cfoutput>

<table width="100%" align="center" cellpadding="-1" cellspacing="-1">
	<tr>
		<td width="50%" align="left">
			<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj100.id);">
		</td>
		<td width="50%" align="right">
			<input type="button" id="btn_close_it" value="[Close Window]" class="buttonClass" onClick="parent.DHTMLWindowsObj.closeit(parent.aDHTMLObj100.id);">
		</td>
	</tr>

<cfset bool_usefulData = "False">
<cfinclude template="cfinclude_processRawData.cfm">
</table>

<cfif (bool_usefulData)>
	<cfif (NOT db_err)>
		<cfscript>
			if (Request.commonCode.isServerLocal() AND 0) {
writeOutput('rec_id = [#rec_id#], recid = [#recid#]<br>');
				if (Len(Trim(rec_id)) eq 0) {
					DbSchema = Request.commonCode.QueryObject2DbSchema(repName, qFTPReportData);
					_sql_statement_ = "exec sp_help @objname = #Request.DbSchema_tableName#";
					q = Request.primitiveCode.safely_execSQL('QueryTable_' & Request.DbSchema_tableName, Request.DSN, _sql_statement_);
writeOutput(Request.primitiveCode.cf_dump(q, '#_sql_statement_#', true));
					_required_table_exists = false;
					_okay_to_create_table = true;
					if (NOT Request.dbError) {
						if (LCASE(q.name) eq LCASE(Request.DbSchema_tableName)) {
							_okay_to_create_table = false;
							_required_table_exists = true;
						}
					}
					if (_okay_to_create_table) {
						q = Request.primitiveCode.safely_execSQL('CreateTable_' & Request.DbSchema_tableName, Request.DSN, DbSchema);
						if (Request.dbError) {
							writeOutput(Request.errorMsg & '<br>');
						} else {
							_required_table_exists = true;
						}
writeOutput(DbSchema & '<br>');
					}

					if (_required_table_exists) {
						Request.commonCode.BulkInsertQueryObject(Request.DbSchema_tableName, qFTPReportData, recid);
						_sql_statement_ = "INSERT INTO FTPDataBridge (table_name, ftp_id) VALUES ('#Request.DbSchema_tableName#',#recid#)";
						q = Request.primitiveCode.safely_execSQL('FlagFTPRecordStored_' & Request.DbSchema_tableName, Request.DSN, _sql_statement_);
						if (Request.dbError) {
							writeOutput(Request.errorMsg & '<br>');
						}
					}
				}
			}
//writeOutput(Request.primitiveCode.cf_dump(qFTPReportData, 'qFTPReportData', true));
		</cfscript>
		
		<cfform action="#CGI.SCRIPT_NAME#" method="POST" name="form_data_grid" format="Flash" skin="haloSilver" enctype="application/x-www-form-urlencoded">
			<cfformgroup  type="panel" label="#repName#" visible="Yes" enabled="Yes">
				<cfgrid name="data_grid" query="qFTPReportData" height="420" insert="No" delete="No" sort="Yes" font="Verdana" fontsize="9" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="BROWSE" picturebar="No">
					<cfif (IsDefined("Request.dQ.COLUMNHEADERS"))>
						<cfset i_item = 1>
						<cfgridcolumn name="id" header="##" width="30">
						<cfloop index="_item" list="#Request.dQ.COLUMNHEADERS#" delimiters=",">
							<cfgridcolumn name="#Request.commonCode._GetToken(Request.dQ.COLUMNNAMES, i_item, ',')#" header="#URLDecode(_item)#">
							<cfset i_item = IncrementValue(i_item)>
						</cfloop>
					</cfif>
				</cfgrid>
			</cfformgroup>
		</cfform>
	<cfelse>
		<BIG><span class="errorStatusClass">ERROR: Cannot Query FTP Reports Data because:</span></BIG><br>
		#Request.db_error#
	</cfif>
</cfif>

</cfoutput>

</body>
</html>
