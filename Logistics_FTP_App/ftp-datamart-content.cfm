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
<cfparam name="allow_dl" type="boolean" default="False">
<cfparam name="dm_id" type="string" default="">
<cfparam name="repType" type="string" default="">
<cfparam name="filePath" type="string" default="">

<cfoutput>
	<cfset bool_usefulData = "False">
	<cfinclude template="cfinclude_processRawData.cfm">
	
	<cfif (bool_usefulData)>
		<cfif (NOT db_err)>
			<cfscript>
writeOutput('dm_id = [#dm_id#], recid = [#recid#]<br>');
				if (Len(Trim(dm_id)) eq 0) {
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

writeOutput(Request.primitiveCode.cf_dump(qFTPReportData, 'qFTPReportData', true));
					if ( (_required_table_exists) AND (qFTPReportData.recordCount gt 0) ) {
						_src_table_name = '';
						if (UCASE(repType) eq UCASE(Request.const_6_day_symbol)) {
							_src_table_name = 'IML_FTP';
							_sql_statement2_ = "SELECT id FROM IML_FTP WHERE (file_path = '#filePath#')";
						} else {
							_src_table_name = 'TIBCO_FTP';
							_sql_statement2_ = "SELECT TIBCO_FTP.id FROM TIBCO_FTP_FULL_NAMES INNER JOIN TIBCO_FTP ON TIBCO_FTP_FULL_NAMES.fid = TIBCO_FTP.fid WHERE (TIBCO_FTP_FULL_NAMES.full_dir_name_abbrev = '#filePath#')";
						}
						qID = Request.primitiveCode.safely_execSQL('QueryFTPID_' & Request.DbSchema_tableName, Request.DSN, _sql_statement2_);
						if (NOT Request.dbError) {
							_sql_statement2a_ = "SELECT id FROM FTPDataSourceTables WHERE (table_name = '#_src_table_name#')";
							qSrcId = Request.primitiveCode.safely_execSQL('QuerySrcID_' & Request.DbSchema_tableName, Request.DSN, _sql_statement2a_);
							if (NOT Request.dbError) {
								_sql_statement3a_ = "SELECT id FROM FTPDataBridge WHERE (table_name = '#Request.DbSchema_tableName#') AND (ftp_id = #qID.id#) AND (src_id = #qSrcId.id#)";
								qBridgeId = Request.primitiveCode.safely_execSQL('qGetFTPRecordStored_' & Request.DbSchema_tableName, Request.DSN, _sql_statement3a_);
								_okay_to_insert_bridgeData = true;
								if ( (NOT Request.dbError) AND (IsDefined("qBridgeId.id")) ) {
									if (qBridgeId.id gt 0) {
										_okay_to_insert_bridgeData = false;
									}
								}

								if (_okay_to_insert_bridgeData) {
									Request.commonCode.BulkInsertQueryObject(Request.DbSchema_tableName, qFTPReportData, recid);
									_sql_statement_ = "INSERT INTO FTPDataBridge (table_name, ftp_id, src_id) VALUES ('#Request.DbSchema_tableName#',#qID.id#,#qSrcId.id#)";
									q = Request.primitiveCode.safely_execSQL('FlagFTPRecordStored_' & Request.DbSchema_tableName, Request.DSN, _sql_statement_);
									if (Request.dbError) {
										writeOutput(Request.errorMsg & '<br>');
									}
								}
							}
						}
					}
				}
			</cfscript>
		<cfelse>
			<BIG><span class="errorStatusClass">ERROR: Cannot Query FTP Reports Data because:</span></BIG><br>
			#Request.db_error#
		</cfif>
	</cfif>
</cfoutput>
