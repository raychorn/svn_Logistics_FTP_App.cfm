<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 60)#">

<cfparam name="nocache" type="string" default="">
<cfparam name="last_id" type="string" default="-1">

<cffunction name="sqlSaveFTPdataCheck" access="private" returntype="string">
	<cfargument name="_qFiles_" type="query" required="yes">

	<cfsavecontent variable="_sql_statement">
		<cfoutput>
			SELECT id, last_modified_dt, file_length, file_name, file_path, file_url 
			FROM IML_FTP 
			WHERE (CAST(STR(Month(last_modified_dt)) + '/' + STR(Day(last_modified_dt)) + '/' + STR(Year(last_modified_dt)) as datetime) = #CreateODBCDate(_qFiles_.lastmodified)#) AND (UPPER(file_name) = '#UCASE(_qFiles_.name)#')
		</cfoutput>
	</cfsavecontent>

	<cfreturn _sql_statement>
</cffunction>

<cffunction name="StoreDataInDb" access="private" returntype="boolean">
	<cfargument name="_qFiles_" type="query" required="yes">
	<cfargument name="_next_file_" type="string" required="yes">
	<cfargument name="_raw_data_" type="string" required="yes">
	<cfargument name="_okay_to_save_" type="boolean" required="yes">

	<cfset dbErrMsg = "">
	<cfset db_err = "False">

	<cfif (_okay_to_save_)>
		<cfsavecontent variable="_sql_">
			<cfoutput>
				INSERT INTO IML_FTP
						(last_modified_dt, file_length, file_name, file_path, file_url, local_temp_file, raw_data)
				VALUES (#_qFiles_.lastmodified#,#_qFiles_.length#,'#_qFiles_.name#','#_qFiles_.path#','#_qFiles_.url#','#_next_file_#','#URLEncodedFormat(Request.commonCode.filterQuotesForSQL(_raw_data_))#');
				SELECT @@IDENTITY AS 'id';
			</cfoutput>
		</cfsavecontent>
	<cfelse>
		<cfset _sql_ = sqlSaveFTPdataCheck(_qFiles_)>
	</cfif>

	<cftry>
		<cfquery name="SaveFTPdata" datasource="#Request.DSN#">
			<cfoutput>
				#PreserveSingleQuotes(_sql_)#
			</cfoutput>
		</cfquery>
		<cfscript>
			Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action GETFILE/READBINARY</b> :: [<b>Stored FTP Data in Db</b> [#_next_file_#] as id [#SaveFTPdata.id#]]');
		</cfscript>
	
		<cfcatch type="Database">
			<cfset db_err = "True">
			<cfsavecontent variable="dbErrMsg">
				<cfdump var="#cfcatch#" label="Database - SaveFTPdata Query." expand="No">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfscript>
		if (NOT db_err) {
			last_id = -1;
			if (IsDefined("SaveFTPdata.id")) {
				last_id = SaveFTPdata.id;
			}
			Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action SaveFTPdata</b> :: <b>Stored FTP Data in Db</b> [#_next_file_#] as id [#SaveFTPdata.id#] [#dbErrMsg#]');
			
			_bool_processed = 0;
			if (last_id gt 0) {
				_bool_processed = 1;
			}
	
			_sql_statement = "UPDATE IML_FTP_PROCESS_VALIDATION SET lid = #last_id#, bool_processed = #_bool_processed#, dt_processed = GetDate(), bool_bytesValidated = #_bool_bytesValidated#, dt_bytesValidated = GetDate() WHERE (UPPER(_destFName) = '#UCASE(_next_file_)#')";
			qSPF = Request.primitiveCode.safely_execSQL('qStoreProcessedFlag', Request.DSN, _sql_statement);
			if (Request.dbError) {
				writeOutput(Request.fullErrorMsg);
			}
		}
	</cfscript>
	
	<cfreturn db_err>
</cffunction>

<cffunction name="ReadRawDataBinary" access="private" returntype="any">
	<cfargument name="_next_file_" type="string" required="yes">

	<cfset Request.fileIOerr = "False">
	<cftry>
		<cffile action="READBINARY" file="#_next_file_#" variable="_raw_data">

		<cfcatch type="Any">
			<cfset Request.fileIOerr = "True">

			<cfsavecontent variable="Request.fileIOerrMsg">
				<cfdump var="#cfcatch#" label="cfcatch" expand="Yes">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfreturn _raw_data>
</cffunction>

<cfscript>
	function validateRawData(r_str, qFiles) {
		var cnt_array = -1;
		var actual_length = -1;
		var n = -1;
		var z = -1;
		var ij = -1;
		var _bool_bytesValidated = -1;
		// perform checks to ensure the file is valid before saving it in the Db...
		cnt_array = ListToArray(s_raw_data, Request.Lf);
		actual_length = 0;
		n = ArrayLen(cnt_array);
		for (ij = 1; ij lte n; ij = ij + 1) {
			z = 0;
			if (ij lt n) {
				z = 1;
			}
			actual_length = actual_length + Len(cnt_array[ij]) + z;
		}
		_bool_bytesValidated = 0;
		if (qFiles.length eq actual_length) {
			_bool_bytesValidated = 1;
		}
		writeOutput('validateRawData() :: [#Now()#] _bool_bytesValidated = [#_bool_bytesValidated#], qFiles.length = [#qFiles.length#], actual_length = [#actual_length#]<br>');
		return _bool_bytesValidated;
	}

	function storeRawData(qFiles, next_file, s_raw_data, _bool_bytesValidated, _okay_to_save) {
		var _sql_statement = '';
		var qGPF = -1;
		var _bool_can_store_data_in_db = -1;

		_sql_statement = "SELECT id, _destFName, lid, dt_validated, bool_validated FROM IML_FTP_PROCESS_VALIDATION WHERE (bool_validated = 1) AND (UPPER(_destFName) = '#UCASE(next_file)#')";
		qGPF = Request.primitiveCode.safely_execSQL('qGetProcessableFlag', Request.DSN, _sql_statement);
		if (Request.dbError) {
			writeOutput(Request.fullErrorMsg);
		}
		
		_bool_can_store_data_in_db = false;
		if ( (_bool_bytesValidated) AND (IsQuery(qGPF)) ) {
			if (qGPF.recordCount gt 0) {
				_bool_can_store_data_in_db = true;
			}
		}
		
		if (_bool_can_store_data_in_db) {
			StoreDataInDb(qFiles, next_file, s_raw_data, _okay_to_save);
		}
	}
</cfscript>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (FTP Download) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>

	<script language="JScript.Encode" src="js/loadJSCode_.js"></script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		loadJSCode("js/disable-right-click-script-III_.js");
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
	</style>

</head>

<body>

<cfflush>

<cfoutput>

<cfscript>
	_qActivity = Request.commonCode.initCachedLog();
</cfscript>

<cfscript>
	// check the validation queue to see if there were any files that downloaded but failed to post to the Db ?!?

	_sql_statement = "SELECT id, _destFName, bool_validated, bool_processed, bool_bytesValidated FROM IML_FTP_PROCESS_VALIDATION WHERE (bool_validated = 1) AND ( (bool_processed = 0) OR (bool_processed IS NULL) ) AND ( (bool_bytesValidated = 0) OR (bool_bytesValidated IS NULL) )";
	qGPFs = Request.primitiveCode.safely_execSQL('qGetProcessableFiles', Request.DSN, _sql_statement);
	if (Request.dbError) {
		writeOutput(Request.fullErrorMsg);
	} else {
		writeOutput(Request.primitiveCode.cf_dump(qGPFs, 'qGPFs - [#_sql_statement#]', false));
		for (i = 1; i lte qGPFs.recordCount; i = i + 1) {
			raw_data = ReadRawDataBinary(qGPFs._destFName[i]);
			s_raw_data = ToString(raw_data);
			qFiles = QueryNew('id,ATTRIBUTES,ISDIRECTORY,LASTMODIFIED,LENGTH,MODE,NAME,PATH,URL', 'integer,varchar,bit,date,integer,varchar,varchar,varchar,varchar');
			qF = Request.primitiveCode.cf_directory('qGetFiles', GetDirectoryFromPath(qGPFs._destFName[i]), GetFileFromPath(qGPFs._destFName[i]), false);
			qi = FindNoCase('_', qF.NAME);
			fName = qF.NAME;
			if (qi gt 0) {
				qi = qi + 1;
				fName = Right(qF.NAME, Len(qF.NAME) - qi + 1);
			}
			QueryAddRow(qFiles, 1);
			QuerySetCell(qFiles, 'id', qFiles.recordCount, qFiles.recordCount);
			QuerySetCell(qFiles, 'ATTRIBUTES', qF.ATTRIBUTES, qFiles.recordCount);
			QuerySetCell(qFiles, 'ISDIRECTORY', false, qFiles.recordCount);
			QuerySetCell(qFiles, 'LASTMODIFIED', qF.DATELASTMODIFIED, qFiles.recordCount);
			QuerySetCell(qFiles, 'LENGTH', qF.SIZE, qFiles.recordCount);
			QuerySetCell(qFiles, 'MODE', qF.MODE, qFiles.recordCount);
			QuerySetCell(qFiles, 'NAME', fName, qFiles.recordCount);
			QuerySetCell(qFiles, 'PATH', Request.ftp_folder & '/' & fName, qFiles.recordCount);
			QuerySetCell(qFiles, 'URL', 'ftp://' & Request.ftp_server & Request.ftp_folder & '/' & fName, qFiles.recordCount);

			okay_to_save = false;
			action_verb = 'Storing/Validating';

			_sql_statement = "SELECT id, last_modified_dt, file_length, file_name, file_path, file_url FROM IML_FTP WHERE (CAST(STR(Month(last_modified_dt)) + '/' + STR(Day(last_modified_dt)) + '/' + STR(Year(last_modified_dt)) as datetime) = #CreateODBCDate(qFiles.lastmodified)#) AND (UPPER(file_name) = '#UCASE(qFiles.name)#')";
			CheckFTPfile = Request.primitiveCode.safely_execSQL('qCheckFTPfile', Request.DSN, _sql_statement);

			writeOutput(Request.primitiveCode.cf_dump(CheckFTPfile, 'CheckFTPfile - [#_sql_statement#]', false));

			if (Request.dbError) {
				writeOutput(Request.fullErrorMsg);
			} else {
				okay_to_save = true;
				if (IsDefined("CheckFTPfile.id")) {
					if (Len(Trim(CheckFTPfile.id)) gt 0) {
						okay_to_save = false;
						action_verb = 'Validating';
					}
				}
			}
			try {
				writeOutput('[#qGPFs._destFName[i]#] ');
				_bool_bytesValidated = validateRawData(s_raw_data, qFiles);
				writeOutput(action_verb & ' "#qGPFs._destFName[i]#" in Db since it was not processed the last time files were processed.<br>');
				storeRawData(qFiles, qGPFs._destFName[i], s_raw_data, _bool_bytesValidated, okay_to_save);
			} catch (Any e) {
				writeOutput(Request.primitiveCode.cf_dump(e, 'e - Could not store the file named "#qGPFs._destFName[i]#"', false));
			}
		}
	}
</cfscript>

<cfif (Request.commonCode.isServerLocal()) OR 1>
	<cfset ftpErrMsg = "">
	<cfset ftpErr = "False">
	<cftry>
		<cfftp action = "open" username = "#Request.ftp_username#" connection = "myFTP" password = "#Request.ftp_password#" server = "#Request.ftp_server#" stopOnError = "No">
	
		<cfcatch type="Any">
			<cfset ftpErr = "True">
			<cfsavecontent variable="ftpErrMsg">
				<cfoutput>
					#cfcatch.message#<br>
					#cfcatch.detail#
				</cfoutput>
			</cfsavecontent>
			<cfdump var="#cfcatch#" label="cfcatch">
		</cfcatch>
	</cftry>
	
	<cfscript>
		Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action OPEN</b> :: [#ftpErrMsg#]');
	</cfscript>

	<cfif (NOT ftpErr)>
		<cfdump var="#cfftp#" label="cfftp">

		<cfif (cfftp.succeeded)>
			<cfif 0>
				<cfset ftpErrMsg = "">
				<cfset ftpErr = "False">
				<cftry>
					<cfftp action = "LISTDIR" stopOnError = "No" name = "qListFiles" directory = "#Request.ftp_folder#" connection = "myFTP">
				
					<cfcatch type="Any">
						<cfset ftpErr = "True">
						<cfsavecontent variable="ftpErrMsg">
							<cfoutput>
								#cfcatch.message#<br>
								#cfcatch.detail#<br>
								#cfcatch.type#
							</cfoutput>
						</cfsavecontent>
						<cfdump var="#cfcatch#" label="cfcatch" expand="No">
					</cfcatch>
				</cftry>
	
				<cfscript>
					Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action LISTDIR</b> :: [#Request.ftp_folder#] [#ftpErrMsg#]');
				</cfscript>
			</cfif>
		
			<cfscript>
				function abbrevFullDirName(fName) {
					var const_group_symbol = ' group ';
					var i = -1;
					fName = Trim(fName);
					i = FindNoCase(const_group_symbol, fName);
					if ( (i gt 0) AND (Len(fName) gt Len(const_group_symbol)) ) {
						return Trim(Mid(fName, i + Len(const_group_symbol), Len(fName) - (i + Len(const_group_symbol)) + 1));
					} else {
						return '';
					}
				}

				function timeStampFromAbbrev(s_abbrev) {
					var filemonth = -1;
					var fileday = -1;
					var fileyear = -1;
					var thisMonth = -1;
					var filedate = -1;
					var filetime = -1;
					// 27998 May 20 5:58 CONPCU0.FRI
					filemonth = Request.commonCode._GetToken(s_abbrev, 2, ' ');
					fileday = Request.commonCode._GetToken(s_abbrev, 3, ' ');
					fileyear = Year(Now());
					thisMonth = DatePart('m', Now());
					if (FindNoCase(filemonth, MonthAsString(thisMonth)) eq 0) {
						if (thisMonth eq 1) {
							fileyear = DatePart('yyyy', Now()) - 1;
						}
					}
					filedate = filemonth & '-' & fileday;
					filetime = Request.commonCode._GetToken(s_abbrev, 4, ' ');
					return CreateDateTime(fileyear, Request.commonCode.monthNameToNum(filemonth), fileday, Request.commonCode._GetToken(filetime, 1, ':'), Request.commonCode._GetToken(filetime, 2, ':'), 0);
				}

				if (NOT IsDefined("qListFiles")) {
					Request.commonCode.qFileCleanUpQueryInit();

					temp_folder = GetTempDirectory();
			
					cmd_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'iml-ftp-dir.cmd';
					script_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'iml-ftp-script-dir.txt';
					output_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'iml-ftp-dir.txt';
					Request.primitiveCode.safely_cffile_write(cmd_file, 'ftp -n -s:#script_file#');
					Request.commonCode.qFileCleanUpAppend(cmd_file);
					Request.primitiveCode.safely_cffile_write(script_file, Request.commonCode.iml_ftp_command_stream_preamble() & 'dir' & Chr(13) & 'quit' & Chr(13));
					Request.commonCode.qFileCleanUpAppend(script_file);

					retVal = Request.primitiveCode.cf_execute(cmd_file, output_file, (60 * 5));
					Request.commonCode.qFileCleanUpAppend(output_file);

					if (Request.anError) {
						writeOutput(Request.verboseErrorMsg);
					}
					
					full_dir_content = Request.primitiveCode.safely_cffile(output_file);

					const_eof_symbol = 'quit';
					const_username_symbol = 'Username';

					qListFiles = QueryNew('id,ATTRIBUTES,ISDIRECTORY,LASTMODIFIED,LENGTH,MODE,NAME,PATH,URL', 'integer,varchar,bit,date,integer,varchar,varchar,varchar,varchar');
					// 27998 May 20 5:58 CONPCU0.FRI] [ -r-xr-xr-x 1 owner group 27998 May 20 5:58 CONPCU0.FRI
					i = 1;
					k_skipped = 0;
					do {
						s = Request.commonCode._GetToken(full_dir_content, i, Chr(13));
						eof = (FindNoCase(const_eof_symbol, s) gt 0);
						cof = (FindNoCase(script_file, s) gt 0);
						if ( (NOT cof) OR (eof) ) {
							if (NOT eof) {
								if (LCASE(Trim(Request.commonCode._GetToken(s, 1, ' '))) eq LCASE(Trim(const_username_symbol))) {
									s = Right(s, Len(s) - Len(Trim(const_username_symbol)) - 1);
								}
								s_abbrev = abbrevFullDirName(s);
								if ( (Len(Trim(s_abbrev)) gt 0) AND (FindNoCase(' owner ', s) gt 0) AND (FindNoCase(' group ', s) gt 0) ) {
									QueryAddRow(qListFiles, 1);
									QuerySetCell(qListFiles, 'id', qListFiles.recordCount, qListFiles.recordCount);
									QuerySetCell(qListFiles, 'LENGTH', Trim(Request.commonCode._GetToken(s_abbrev, 1, ' ')), qListFiles.recordCount);
									QuerySetCell(qListFiles, 'LASTMODIFIED', timeStampFromAbbrev(s_abbrev), qListFiles.recordCount);
									QuerySetCell(qListFiles, 'NAME', Trim(Request.commonCode._GetToken(s_abbrev, ListLen(s_abbrev, ' '), ' ')), qListFiles.recordCount);
									QuerySetCell(qListFiles, 'ISDIRECTORY', false, qListFiles.recordCount);
									QuerySetCell(qListFiles, 'ATTRIBUTES', Trim(Request.commonCode._GetToken(s, 1, ' ')), qListFiles.recordCount);
									QuerySetCell(qListFiles, 'MODE', 'not currently supported', qListFiles.recordCount);
									QuerySetCell(qListFiles, 'PATH', Request.ftp_folder & '/' & qListFiles.NAME[qListFiles.recordCount], qListFiles.recordCount);
									QuerySetCell(qListFiles, 'URL', 'ftp://' & Request.ftp_server & Request.ftp_folder & '/' & qListFiles.NAME[qListFiles.recordCount], qListFiles.recordCount);
								} else {
									k_skipped = k_skipped + 1;
								}
							} else {
								break;
							}
						}
						i = i + 1;
					} while ( (Len(Trim(s)) gt 0) AND (NOT eof) );
					
					writeOutput('There are #qListFiles.recordCount# files.<br>');
//					writeOutput(Request.primitiveCode.cf_dump(qListFiles, 'qListFiles', false));

					Request.commonCode.qFileCleanUpProcess();
				}
			</cfscript>

			<!--- BEGIN: The CONPCU0.* files are ZIP'd archives we are not now processing... --->
			<cfquery name="qFiles" dbtype="query" debug>
				SELECT * FROM qListFiles
				WHERE (UPPER(name) not like '%.ZIP') AND (UPPER(name) not like 'CONPCU0%') AND (length > 0)
			</cfquery>
			<!--- END! The CONPCU0.* files are ZIP'd archives we are not now processing... --->

			<cfscript>
				Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action LISTDIR</b> :: [#Request.commonCode.getListFromQueryColumn(qFiles, 'name', ',')#]');
			</cfscript>
			
			<cfset okay_to_save = "False">
			
			<cfset temp_folder = GetTempDirectory() & Request.const_6_day_symbol & '\'>
			<cftry>
				<cfdirectory action="CREATE" directory="#temp_folder#">

				<cfcatch type="Any">
				</cfcatch>
			</cftry>
			<cfloop query="qFiles" startrow="1" endrow="#qFiles.recordCount#">
				<cfset next_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & qFiles.name>
				
				<cfset dbErrMsg = "">
				<cfset db_err = "False">
				<cftry>
					<cfset _sql_statement = sqlSaveFTPdataCheck(qFiles)>

					<cfquery name="CheckFTPfile" datasource="#Request.DSN#">
						#PreserveSingleQuotes(_sql_statement)#
					</cfquery>
					
					<cfset okay_to_save = "True">
					<cfif (IsDefined("CheckFTPfile.id"))>
						<cfif (Len(Trim(CheckFTPfile.id)) gt 0)>
							<cfset okay_to_save = "False">
						</cfif>
					</cfif>
				
					<cfcatch type="Database">
						<cfset db_err = "True">
						<cfsavecontent variable="dbErrMsg">
							<cfdump var="#cfcatch#" label="Database - CheckFTPfile Query." expand="No">
						</cfsavecontent>
					</cfcatch>
				</cftry>
				
				<cfscript>
					_s_ = '(#CGI.SCRIPT_NAME#) <b>FTP Action CheckFTPfile</b> :: [okay_to_save = #okay_to_save#] [id=#Request.commonCode.getListFromQueryColumn(CheckFTPfile, 'id', ',')#] [last_modified_dt=#Request.commonCode.getListFromQueryColumn(CheckFTPfile, 'last_modified_dt', ',')#] [file_length=#Request.commonCode.getListFromQueryColumn(CheckFTPfile, 'file_length', ',')#] [file_name=#Request.commonCode.getListFromQueryColumn(CheckFTPfile, 'file_name', ',')#] [file_path=#Request.commonCode.getListFromQueryColumn(CheckFTPfile, 'file_path', ',')#] [file_url=#Request.commonCode.getListFromQueryColumn(CheckFTPfile, 'file_url', ',')#] [#dbErrMsg#]';
					Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), _s_);
				</cfscript>

				<cfif (okay_to_save)>
					<cfset raw_data = "">
					<cfset dbErrMsg = "">
					<cfset db_err = "False">
					<cftry>
						<cfftp action="GETFILE" stoponerror="Yes" localfile="#next_file#" remotefile="#qFiles.path#" transfermode="BINARY" failifexists="Yes" connection="myFTP">
						<cfscript>
							Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action GETFILE/READBINARY</b> :: [Attempt to Downloaded Temp File [#next_file#] (FileExists(next_file))=[#(FileExists(next_file))#], qFiles.length=[#qFiles.length#]]');
						</cfscript>
						<cfif (FileExists(next_file))>
							<cfscript>
								Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action GETFILE/READBINARY</b> :: [Downloaded Temp File [#next_file#]]');
							</cfscript>
							<cffile action="READBINARY" file="#next_file#" variable="raw_data">
						</cfif>
						<cfscript>
							Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action GETFILE/READBINARY</b> :: [Downloadeded Temp File qFiles.length=[#qFiles.length#], Len(raw_data)=[#Len(raw_data)#]]');
						</cfscript>
					
						<cfcatch type="Database">
							<cfset db_err = "True">
							<cfsavecontent variable="dbErrMsg">
								<cfdump var="#cfcatch#" label="FTP - GETFILE/READBINARY." expand="No">
							</cfsavecontent>
						</cfcatch>
					</cftry>
		
					<cfscript>
						Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action GETFILE/READBINARY</b> :: [#dbErrMsg#]');
					</cfscript>

					<cfscript>
						s_raw_data = ToString(raw_data);

						writeOutput('[#next_file#] ');
						_bool_bytesValidated = validateRawData(s_raw_data, qFiles);

						storeRawData(qFiles, next_file, s_raw_data, _bool_bytesValidated, okay_to_save);
					</cfscript>
				</cfif>
		
				<cfscript>
					if (IsDefined("SaveFTPdata.id")) {
						_qActivity = Request.commonCode.dumpCachedLog2DbLog(_qActivity, 'IML_FTP_LOG');
					}
				</cfscript>

				<cfflush>
				
			</cfloop>
		
			<cfset ftpErrMsg = "">
			<cfset ftpErr = "False">
			<cftry>
				<cfftp action = "close" connection = "myFTP" stopOnError = "Yes">
		
				<cfcatch type="Any">
					<cfset ftpErr = "True">
					<cfsavecontent variable="ftpErrMsg">
						<cfdump var="#cfcatch#" label="cfcatch - cfftp action close connection." expand="No">
					</cfsavecontent>
				</cfcatch>
			</cftry>
			
			<cfscript>
				Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action Close</b> :: [#ftpErrMsg#]');
				_qActivity = Request.commonCode.dumpCachedLog2DbLog(_qActivity, 'IML_FTP_LOG');
			</cfscript>
		<cfelse>
			<!--- Log an error here... someday... --->
		</cfif>
		
		<h4 align="center">Processing Completed !  If no new files were available then none were reported as having been processed - Check back later.</h4>
	</cfif>
</cfif>

</cfoutput>

</body>
</html>
