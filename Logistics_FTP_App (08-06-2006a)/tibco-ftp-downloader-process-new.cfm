<cfset max_time_to_wait_for_this_page = (60 * 60) * 2>
<cfsetting showdebugoutput="No" requesttimeout="#max_time_to_wait_for_this_page#">

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

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Tibco FTP Background Job LaunchPad</title>

	<link href="StyleSheet.css" rel="stylesheet" type="text/css"> 
	<cfif 0>
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
	
			.listItemClass {
				font-size: 10px;
			}
	
			.normalClass {
				font-size: 10px;
			}
	
			.normalBoldClass {
				font-size: 10px;
				font-weight : bold;
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
	</cfif>
</head>

<body>

<cfflush>

<cfinclude template="cfinclude_tibco_ftp_functions.cfm">

<cfscript>
	Request.bool_show_verbose_SQL_errors = ((Request.commonCode.isServerLocalHost()) OR (Request.commonCode.isServerredactedDevHost()));

	Request._qActivity = Request.commonCode._initCachedLog('TIBCO_FTP_LOG');

	bool_successfulDownload = false;

	beginTime = Now();
	writeOutput('<span class="normalStatusClass">BEGIN: #beginTime#</span>');
	
	beginMemoryMetrics = Request.commonCode.captureMemoryMetrics();
	writeOutput(Request.primitiveCode.cf_dump(beginMemoryMetrics, 'beginMemoryMetrics', false));

	temp_folder = GetTempDirectory();
	
//	bool_successfulDownload = true; // fake out the loop to avoid infinity and beyond...
	do {
		_sql = sql_getFTPWorkQueueFromDbWhere(false);
		qW = getFTPWorkQueueFromDb(_sql, false); // get the next biggest downloadable file from the work queue that has not been validated...
		writeOutput(Request.primitiveCode.cf_dump(qW, 'qW [#_sql#]', true));

		if ( (IsQuery(qW)) AND (IsDefined("qW.short_name")) AND (Len(qW.short_name) gt 0) ) {
			_fullDirName = Trim(qW.FULL_DIR_NAME);
			_shortFName = Trim(qW.short_name);

			Request._lid = Trim(qW.lid);
			Request._fid = Trim(qW.fid);
	
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), Request.primitiveCode.__debugQueryInTable(qW, 'qW', true, qW.ColumnList));
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'About to fetch (#_shortFName#)');
			
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'temp_folder = [#temp_folder#]<br>');
	
			cmd_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-get.cmd';
			script_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-script-get.txt';
			output_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-get.txt';
			_destFName = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & _shortFName;
			
			// look for the cmd-exec.exe file on the local hard drive...
			dirQ = Request.primitiveCode.cf_directory('qDirQ', Request.const_begin_dir_cmd_exec_exe_symbol, Request.const_cmd_exec_exe_symbol, true);
		//	writeOutput(Request.primitiveCode.cf_dump(dirQ, 'dirQ', false));
			bool_dirQ_isValid = false;
			if (IsQuery(dirQ)) {
				if ( (dirQ.recordCount gt 0) AND (IsDefined("dirQ.DIRECTORY")) AND (IsDefined("dirQ.NAME")) ) {
					bool_dirQ_isValid = true;
					Request.actual_path_cmd_exec_exe_symbol = ReplaceNoCase(dirQ.DIRECTORY & '\' & dirQ.NAME, '\\', '\', 'all');
				}
			}
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'Request.actual_path_cmd_exec_exe_symbol = [#Request.actual_path_cmd_exec_exe_symbol#]');
			if (FileExists(Request.actual_path_cmd_exec_exe_symbol)) {
				_sql_statement = "INSERT INTO TIBCO_FTP_PROCESS_QUEUE (fid, lid, _destFName, _shortFName, _fullDirName, dt_downLoad) VALUES (#qW.fid#,#qW.lid#,'#_destFName#','#_shortFName#','#_fullDirName#',GETDATE()); SELECT @@IDENTITY AS 'id';";
				qSPS = Request.primitiveCode.safely_execSQL('qSaveProcessState', Request.DSN, _sql_statement);
				writeOutput('Request.isPKviolation = [#Request.isPKviolation#]<br>');
				if (Request.isPKviolation) {
					// this is a dupe download - so write over the values for those fields that are updated...
					_sql_statement = "UPDATE TIBCO_FTP_PROCESS_QUEUE SET _destFName = '#_destFName#', _shortFName = '#_shortFName#', _fullDirName = '#_fullDirName#', dt_downLoad = GETDATE(); SELECT @@IDENTITY AS 'id';";
					qSPS = Request.primitiveCode.safely_execSQL('qSaveProcessState2', Request.DSN, _sql_statement);
				}
				writeOutput(Request.primitiveCode.cf_dump(qSPS, 'qSPS [#_sql_statement#]', false));
				writeOutput('Request.dbError = [#Request.dbError#]<br>');
				if (Request.dbError) {
					_err_msg = '<span class="errorStatusClass">_destFName = [#_destFName#], _shortFName = [#_shortFName#] Reason: "#Request.errorMsg#" (Request.isPKviolation=#Request.isPKviolation#)</span>';
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);

					bool_successfulDownload = true; // this is a fail-safe to make sure the process doesn't go infinite loop...
					break;
				} else if ( (IsQuery(qSPS)) AND (IsDefined("qSPS.recordCount")) ) {
					// The FTP Download process is asynchronous which means the file is still in-bound AFTER the command has finished executing especially true for large files.
					Request.primitiveCode.safely_cffile_write(cmd_file, 'ftp -n -s:#script_file#');
					Request.commonCode.qFileCleanUpAppend(cmd_file);
					Request.primitiveCode.safely_cffile_write(script_file, Request.commonCode.tibco_ftp_command_stream_preamble() & 'get ' & _shortFName & ' ' & _destFName & Chr(13) & 'quit' & Chr(13));
					Request.commonCode.qFileCleanUpAppend(script_file);
			
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'cmd_file = [#cmd_file#]');
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'script_file = [#script_file#]');
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'output_file = [#output_file#]');
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '_destFName = [#_destFName#]');

					cmdExec_command = Request.actual_path_cmd_exec_exe_symbol & ' "' & cmd_file & '" "' & _destFName & '" ' & Request.const_delay_cmd_exec_exe_symbol;
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'cmdExec_command = [#cmdExec_command#]');
		
					new_cmd_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & '+tibco-ftp-get.cmd';
					Request.primitiveCode.safely_cffile_write(new_cmd_file, cmdExec_command & Chr(13));
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'new_cmd_file = [#new_cmd_file#]');
					Request.commonCode.qFileCleanUpAppend(new_cmd_file);
		
				//	retVal = Request.primitiveCode.cf_execute(new_cmd_file, output_file, max_time_to_wait_for_this_page);
					retVal = Request.primitiveCode.cf_execute(cmd_file, output_file, max_time_to_wait_for_this_page);
					Request.commonCode.qFileCleanUpAppend(output_file);

					writeOutput('Request.anError = [#Request.anError#]<br>');
					if (Request.anError) {
						writeOutput(Request.verboseErrorMsg);
					}

					// BEGIN: Comment out this next line of code to allow this process to be free-running without stopping after each successfully downloaded file...
					bool_successfulDownload = (qSPS.recordCount gt 0); // this forces the process to download exactly one file per trip in keeping with the architecture of the overall process flow...
					// END! Comment out this next line of code to allow this process to be free-running without stopping after each successfully downloaded file...
				}
			} else {
				_err_msg = '<span class="errorStatusClass">ERROR: The ftpUtil known as cmd-exec.exe was NOT available on the local hard drive - better look into this a.s.a.p. !</span>';
				Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
			}
		} else {
			_err_msg = '<span class="onholdStatusClass">INFO: Breaking out of loop !</span>';
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);

			// BEGIN: Conserve RAM by dumping these objects to their respective destinations at the bottom of each loop...
			Request._qActivity = Request.commonCode.dumpCachedLog2DbLog(Request._qActivity, 'TIBCO_FTP_LOG');
			Request.commonCode.qFileCleanUpProcess();
			// END! Conserve RAM by dumping these objects to their respective destinations at the bottom of each loop...
			
			bool_successfulDownload = true; // this logic works... verified !
			break; // break out of loop rather than doing this forever...
		}
		// BEGIN: Conserve RAM by dumping these objects to their respective destinations at the bottom of each loop...
		Request._qActivity = Request.commonCode.dumpCachedLog2DbLog(Request._qActivity, 'TIBCO_FTP_LOG');
		Request.commonCode.qFileCleanUpProcess();
		// END! Conserve RAM by dumping these objects to their respective destinations at the bottom of each loop...
	} while (NOT bool_successfulDownload);

	variables.msMax = (60 * 1000 * 15); // it can take 15 mins to get a large file so wait for it...
	variables.msBegin = GetTickCount();
	_sql_qGetFileToProcess = sql_qGetFileToProcessFromDb();
	do {
		variables.msEnd = GetTickCount();
		variables.msElapsed = (variables.msEnd - variables.msBegin);
		// BEGIN: Determine if any files have been validated and are therefore ready to process...
		if ((variables.msElapsed MOD 1000) eq 0) { // hammer on the Db once per second... this is lame but that's life...
		//	qSPSitem = Request.primitiveCode.safely_execSQL('qGetFileToProcess', Request.DSN, sql_qGetFileToProcess);
			qSPSitem = GetDownloadedNotYetProcessedQueue(false, sql_qGetFileToProcessFromDb());
			// END! Determine if any files have been validated and are therefore ready to process...
			if ( (NOT Request.dbError) AND (IsQuery(qSPSitem)) AND (IsDefined("qSPSitem.procid")) AND (IsDefined("qSPSitem._destFName")) AND (IsDefined("qSPSitem.short_name")) ) {
				if (qSPSitem.recordCount gt 0) {
					writeOutput('qSPSitem while() loop running for #variables.msElapsed# ms - breaking because query has returned #qSPSitem.recordCount# records.<br>');
					break; // this means we have a response we like from the Db so stop it already...
				}
			}
		}
	} while (variables.msElapsed lte variables.msMax); // wait a max of variables.msMax ms but hammer on the Db until we get a response we like...

	writeOutput(Request.primitiveCode.cf_dump(qSPSitem, 'qSPSitem [#_sql_qGetFileToProcess#]', false));

	_err_msg = '<span class="normalStatusClass">INFO: bool_successfulDownload = [#bool_successfulDownload#]</span>';
	Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);

	// BEGIN: Look at the TIBCO_FTP_PROCESS_QUEUE looking for any previously downloaded files that should be processed because 60 mins have elapsed since the download event...
	if (1) { // this conditional test is here to allow the two parts of the process to be debugged separately...
		// Note: The SQL Statement appears at the bottom of the while loop for a reason - just letting you know...
		if ( (Request.dbError) OR (NOT IsQuery(qSPSitem)) OR (NOT IsDefined("qSPSitem.procid")) OR (NOT IsDefined("qSPSitem._destFName")) OR (NOT IsDefined("qSPSitem.short_name")) ) {
			// Note: The Error message was emitted where the SQL Statement was executed... this is left here to maintain the logic flow...
			writeOutput('The system did not find anything to do just now... [(Request.dbError)=#(Request.dbError)#], [IsQuery(qSPSitem)=#IsQuery(qSPSitem)#], [IsDefined("qSPSitem.procid")=#IsDefined("qSPSitem.procid")#], [IsDefined("qSPSitem._destFName")=#IsDefined("qSPSitem._destFName")#], [IsDefined("qSPSitem.short_name")=#IsDefined("qSPSitem.short_name")#]<br>');
		} else {
			_destFName = qSPSitem._destFName;
			_shortFName = qSPSitem.short_name;

			writeOutput('A. _destFName = [#_destFName#] (#(FileExists(_destFName))#)<br>');

			if (NOT FileExists(_destFName)) { // Allow the files from one server to be migrated to another...
				_destFName = GetTempDirectory() & GetFileFromPath(_destFName);
			}

			writeOutput('B. _destFName = [#_destFName#] (#(FileExists(_destFName))#)<br>');
			
			if (FileExists(_destFName)) {
				_sql_ = sql_getFTPBatchesForShortName(_shortFName);
				Request.qB = getFTPWorkQueueFromDb(_sql_, false);

				writeOutput(Request.primitiveCode.cf_dump(Request.qB, 'Request.qB [#_sql_#]', false));
				
				if (IsQuery(Request.qB)) {
					// BEGIN: This acts on a single record however the code allows for many records if necessary...
					Request.msBegin = GetTickCount();
					for (i = 1; i lte Request.qB.recordCount; i = i + 1) {
						QuerySetCell(Request.qB, 'ts', timeStampFromAbbrev(Request.qB.full_dir_name_abbrev[i]), i);
					}
					Request.msEnd = GetTickCount();
					// END! This acts on a single record however the code allows for many records if necessary...

					Request.msElapsed = (Request.msEnd - Request.msBegin) / 1000;
					writeOutput('<span class="onholdStatusClass">DEBUG: "timeStampFromAbbrev()" executes in #Request.commonCode.secondsToHHMMSS(Request.msElapsed)#.</span><br>');
		
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), Request.primitiveCode.__debugQueryInTable(Request.qB, 'Request.qB [#_sql_#]', true, Request.qB.ColumnList));
		
					_sql_statement = "SELECT short_name, full_dir_name_abbrev, full_dir_name, byteCount, fid, lid, ts FROM Request.qB ORDER BY ts";
					_qB = Request.primitiveCode.safely_execSQL('qSortSubBatches', '', _sql_statement);
		
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), Request.primitiveCode.__debugQueryInTable(_qB, '_qB [#_sql_statement#] (#Request.dbError#) (#Request.errorMsg#)', true, _qB.ColumnList));
					
					Request.msBegin = GetTickCount();
					Request.qB = _qB;
					Request.msEnd = GetTickCount();
		
					Request.msElapsed = (Request.msEnd - Request.msBegin) / 1000;
					writeOutput('<span class="onholdStatusClass">DEBUG: "Request.qB = _qB" executes in #Request.commonCode.secondsToHHMMSS(Request.msElapsed)#.</span><br>');

					Request.msBegin = GetTickCount();
					raw_ftp_data = Request.primitiveCode.safely_cffile(_destFName);
					Request.msEnd = GetTickCount();
		
					Request.msElapsed = (Request.msEnd - Request.msBegin) / 1000;
					writeOutput('<span class="onholdStatusClass">DEBUG: Request.primitiveCode.safely_cffile executes in #Request.commonCode.secondsToHHMMSS(Request.msElapsed)#.</span><br>');

					if (Len(Trim(raw_ftp_data)) gt 0) {
						nLenRawData = Len(raw_ftp_data);
						// store raw data in the raw data store...
						// DECLARE @dtNow as datetime; SELECT @dtNow = CAST('2005-09-09 11:42:50' as datetime); 
						_sql_statement = "INSERT INTO TIBCO_FTP_DATA (the_dt, lid, raw_data) VALUES (GetDate(),#qSPSitem.lid#,'#URLEncodedFormat(raw_ftp_data)#'); SELECT @@IDENTITY AS id;";
						qR = Request.primitiveCode.safely_execSQL('qStoreRawData', Request.DSN, _sql_statement);
		
						if ( (Request.dbError) OR (NOT IsDefined("qR.id")) ) {
							_err_msg = '<span class="errorStatusClass">[Len(_sql_statement) = #Len(_sql_statement)#] #Request.errorMsg#</span>';
							Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
		
							Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<hr width="80%" color="blue">');
						} else {
							Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), ' <-- STORED Raw Data [#nLenRawData# bytes] as ID (#qR.id#) in TIBCO_FTP_DATA !' & '<br>');

							// BEGIN: Here we need to flag the file as having been processed...
							_sql_statement = "UPDATE TIBCO_FTP_PROCESS_VALIDATION SET bool_processed = 1, dt_processed = GetDate() WHERE (UPPER(_destFName) = '#UCASE(qSPSitem._destFName)#')";
							qSPF = Request.primitiveCode.safely_execSQL('qStoreProcessedFlag', Request.DSN, _sql_statement);
							if (Request.dbError) {
								writeOutput(Request.fullErrorMsg);
							}
							// END! Here we need to flag the file as having been processed...

							// BEGIN: This is the faster method !
							Request.msBegin = GetTickCount();
							a_analSum = trueSizeOfRawBucket(raw_ftp_data, false);
							Request.msEnd = GetTickCount();

							Request.msElapsed = (Request.msEnd - Request.msBegin) / 1000;
							writeOutput('<span class="onholdStatusClass">DEBUG: trueSizeOfRawBucket (a_analSum=#a_analSum#) executes in #Request.commonCode.secondsToHHMMSS(Request.msElapsed)#.</span><br>');
							// END! This is the faster method !
							
							Request.msBegin = GetTickCount();
							aa = batchBytesCountArrayFromQuery(Request.qB, a_analSum, 'full_dir_name_abbrev', getByteCountFromAbbrev);
							Request.msEnd = GetTickCount();

							Request.msElapsed = (Request.msEnd - Request.msBegin) / 1000;
							writeOutput('<span class="onholdStatusClass">DEBUG: batchBytesCountArrayFromQuery executes in #Request.commonCode.secondsToHHMMSS(Request.msElapsed)#.</span><br>');

							sum_byte_counts = ArraySum(aa) + ArrayLen(aa);

							if (NOT Request.bool_inhibit_cfdump_during_process_new) {
								if (Request.bool_inhibit_writeOutput_during_process_new) {
									Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), Request.primitiveCode.cf_dump(aa, 'aa [sum_byte_counts=#sum_byte_counts#] versus [#nLenRawData#]', true));
								} else {
									writeOutput(Request.primitiveCode.cf_dump(aa, 'aa [sum_byte_counts=#sum_byte_counts#] versus [#nLenRawData#]', true));
								}
							}

							beginMemoryMetrics1 = Request.commonCode.captureMemoryMetrics();
							writeOutput(Request.primitiveCode.cf_dump(beginMemoryMetrics1, 'beginMemoryMetrics1', false));
							
							Request.msBegin = GetTickCount();
							the_batches = splitRawDataIntoBatchesUsing(raw_ftp_data, aa, a_analSum, false);
							Request.msEnd = GetTickCount();

							Request.msElapsed = (Request.msEnd - Request.msBegin) / 1000;
							writeOutput('<span class="onholdStatusClass">DEBUG: splitRawDataIntoBatchesUsing(false) executes in #Request.commonCode.secondsToHHMMSS(Request.msElapsed)#.</span><br>');

							endMemoryMetrics2 = Request.commonCode.captureMemoryMetrics();
							writeOutput(Request.primitiveCode.cf_dump(endMemoryMetrics2, 'endMemoryMetrics2', false));

							if (NOT Request.bool_inhibit_cfdump_during_process_new) {
								if (Request.bool_inhibit_writeOutput_during_process_new) {
									_ss = '<table width="100%" cellpadding="-1" cellspacing="-1"><tr><td>' & Request.primitiveCode.cf_dump(the_batches, 'the_batches [#(ArrayLen(the_batches) eq Request.qB.recordCount)#]', true) & '</td><td>';
									if (IsDefined("the_batches2")) {
										_ss = _ss & Request.primitiveCode.cf_dump(the_batches2, 'the_batches2 [#(ArrayLen(the_batches2) eq Request.qB.recordCount)#]', true);
									}
									_ss = _ss & '</td></tr></table>';
									Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _ss);
								} else {
									writeOutput('<table width="100%" cellpadding="-1" cellspacing="-1">');
									writeOutput('<tr>');
									writeOutput('<td>');
									writeOutput(Request.primitiveCode.cf_dump(the_batches, 'the_batches [#(ArrayLen(the_batches) eq Request.qB.recordCount)#]', true));
									writeOutput('</td>');
									writeOutput('<td>');
									if (IsDefined("the_batches2")) {
										writeOutput(Request.primitiveCode.cf_dump(the_batches2, 'the_batches2 [#(ArrayLen(the_batches2) eq Request.qB.recordCount)#]', true));
									}
									writeOutput('</td>');
									writeOutput('</tr>');
									writeOutput('</table>');
								}
							}
							
							if (ArrayLen(the_batches) eq ArrayLen(aa)) {
								Cr = Chr(13);
								Lf = Chr(10);
								CrLf = Cr & Lf;
				
								ij = 1;
								Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'INFO: Request.qB.recordCount = [#Request.qB.recordCount#], ArrayLen(the_batches) = [#ArrayLen(the_batches)#]');
								for (i = 1 + (Request.qB.recordCount - ArrayLen(the_batches)); i lte Request.qB.recordCount; i = i + 1) {
									Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'INFO: i = [#i#], ij = [#ij#]');
		
									Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), 'Request.qB.FULL_DIR_NAME_ABBREV[#i#] = [#Request.qB.FULL_DIR_NAME_ABBREV[i]#]');
				
									_sql_statement = "UPDATE TIBCO_FTP SET raw_data = '#URLEncodedFormat(the_batches[ij])#' WHERE (lid = #Request.qB.lid[i]#) AND (fid = #Request.qB.fid[i]#)";
									Request.primitiveCode.safely_execSQL('qStoreRawDataSubBatch#i#', Request.DSN, _sql_statement);
									
									// BEGIN: Come up with a way to store the split apart files to save time having to do this again...
									// Note: Pick a folder other than one below the temp folder...
									// Request.primitiveCode.safely_cffile_write(_destFName & '_' & Request.qB.lid[i] & '_' & Request.qB.fid[i], the_batches[ij]);
									// END! Come up with a way to store the split apart files to save time having to do this again...

									if (Request._lid eq -1) {
										Request._lid = Request.qB.lid[i];
									}
									if (Request._fid eq -1) {
										Request._fid = Request.qB.fid[i];
									}

									if (Request.dbError) {
										_err_msg = '<span class="errorStatusClass">#Request.errorMsg#</span>';
										Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
				
										Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<hr width="80%" color="blue">');
									} else {
										Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), ' <-- STORED !'); //  & ' [#_sql_statement#]'
									}
									ij = ij + 1;
								}
								
								// here we can declare success - the byte counts are valid...
								// BEGIN: Here we need to flag the file as having been byte count validated...
								_sql_statement = "UPDATE TIBCO_FTP_PROCESS_VALIDATION SET bool_bytesValidated = 1, dt_bytesValidated = GetDate() WHERE (UPPER(_destFName) = '#UCASE(qSPSitem._destFName)#')";
								qSBV = Request.primitiveCode.safely_execSQL('qStoreBytesValidatedFlag', Request.DSN, _sql_statement);
								if (Request.dbError) {
									writeOutput(Request.fullErrorMsg);
								}
								// END! Here we need to flag the file as having been byte count validated...
							} else {
								// Note - Here we need to cause the download to happen again because we are missing some data...
								_err_msg = '<span class="errorStatusClass">ERROR: The number of batches derived from the byte counts on each batch full dir listing (#ArrayLen(the_batches)#) does NOT match the number of expected batches (#Request.qB.recordCount#) !</span>';
								Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);

								Request._qActivity = Request.commonCode.dumpCachedLog2DbLog(Request._qActivity, 'TIBCO_FTP_LOG');
								Request.commonCode.qFileCleanUpProcess();
								
								// here we cannot declare success - the byte counts are invalid...
								// BEGIN: Here we need to flag the file as having been byte count NOT validated...
								_sql_statement = "UPDATE TIBCO_FTP_PROCESS_VALIDATION SET bool_bytesValidated = 0, dt_bytesValidated = GetDate() WHERE (UPPER(_destFName) = '#UCASE(qSPSitem._destFName)#')";
								qSBV = Request.primitiveCode.safely_execSQL('qStoreBytesValidatedFlag', Request.DSN, _sql_statement);
								if (Request.dbError) {
									writeOutput(Request.fullErrorMsg);
								}
								// END! Here we need to flag the file as having been byte count NOT validated...
							}
						}
					} else {
						_err_msg = '<span class="normalStatusClass">INFO: The variable (raw_ftp_data) has an empty value - is this really a problem or not ?!?</span>';
						Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
					}
				} else {
					_err_msg = '<span class="errorStatusClass">ERROR: Unable to resolve the item at the top of the Work Queue to a series of sub-batches !</span>';
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
				}
			} else {
				_err_msg_ = 'ERROR: The requested file (#_destFName#) was NOT available on the local hard drive - better look into this a.s.a.p. !';
				_err_msg = '<span class="errorStatusClass">#_err_msg_#</span>';
				Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
				writeOutput(Request.primitiveCode.cf_dump(qSPSitem, 'qSPSitem [#_err_msg_#]', true));
			}
		}
	}
	// END! Look at the TIBCO_FTP_PROCESS_QUEUE looking for any previously downloaded files that should be processed because 60 mins have elapsed since the download event...

	Request._fid_ = Request._fid;
	Request._lid_ = Request._lid;

	Request._qActivity = Request.commonCode.dumpCachedLog2DbLog(Request._qActivity, 'TIBCO_FTP_LOG');
	Request.commonCode.qFileCleanUpProcess();

	Request._fid = Request._fid_;
	Request._lid = Request._lid_;

	endMemoryMetrics = Request.commonCode.captureMemoryMetrics();
	writeOutput(Request.primitiveCode.cf_dump(endMemoryMetrics, 'endMemoryMetrics', false));

	endTime = Now();
	writeOutput('<span class="normalStatusClass">END: #endTime#</span><br>');

	_elapsedTime = endTime - beginTime;
	fmt_elapsedTime = TimeFormat(_elapsedTime, "HH:mm:ss");
	writeOutput('<span class="normalStatusClass">Elapsed Time: #fmt_elapsedTime#</span><br>');

	try {
		_sql_statement = "INSERT INTO TIBCO_FTP_PROCESS_METRICS (fid, lid, beginTime, endTime, elapsedTime, freeMemoryBegin, totalMemoryBegin, maxMemoryBegin, percentFreeAllocatedBegin, percentAllocatedBegin, freeMemoryEnd, totalMemoryEnd, maxMemoryEnd, percentFreeAllocatedEnd, percentAllocatedEnd) VALUES (#Request._fid#,#Request._lid#,#beginTime#,#endTime#,#_elapsedTime#,#beginMemoryMetrics.freeMemory#,#beginMemoryMetrics.totalMemory#,#beginMemoryMetrics.maxMemory#,#beginMemoryMetrics.percentFreeAllocated#,#beginMemoryMetrics.percentAllocated#,#endMemoryMetrics.freeMemory#,#endMemoryMetrics.totalMemory#,#endMemoryMetrics.maxMemory#,#endMemoryMetrics.percentFreeAllocated#,#endMemoryMetrics.percentAllocated#); SELECT @@IDENTITY as 'id';";
		qMetrics = Request.primitiveCode.safely_execSQL('qStoreMetrics', Request.DSN, _sql_statement);
		if ( (Request.dbError) OR (NOT IsQuery(qMetrics)) ) {
			_err_msg = '<span class="errorStatusClass">Cannot save FTP Process Metrics.  Reason: "#Request.errorMsg#" OR No query object was returned. IsQuery(qMetrics)=(#IsQuery(qMetrics)#) [#_sql_statement#]</span>';
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
		} else {
			_err_msg = '<span class="onholdStatusClass">Successfully saved FTP Process Metrics.</span>';
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
		}
	} catch (Any e) {
		_err_msg = '<span class="errorStatusClass">Cannot save FTP Process Metrics.  Reason: "#Request.commonCode.explainError(e)#"</span>';
		Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), _err_msg);
	}

	_url = Request.commonCode.fullyQualifiedURLprefix() & 'reports_ftp_activity_log.cfm?nocache=' & URLEncodedFormat(CreateUUID()) & '&beginTime=' & URLEncodedFormat(DateFormat(beginTime, "mm/dd/yyyy") & ' ' & TimeFormat(beginTime, "HH:mm:ss")) & '&endTime=' & URLEncodedFormat(DateFormat(endTime, "mm/dd/yyyy") & ' ' & TimeFormat(endTime, "HH:mm:ss"));
	writeOutput('<span class="normalStatusClass"><a href="#_url#" target="_blank">Display FTP Log for this Processing Session</a></span>');
</cfscript>

</body>
</html>
