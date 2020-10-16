<cfcomponent>
	<cfscript>
		function explainData(d, suppressList) {
			var _db = '';
			var item = '';

			for (item in d) {
				if (ListFindNoCase(suppressList, item, ',') eq 0) {
					try {
						_db = _db & '[#item#=#d[item]#], ';
					} catch (Any e) {
					}
				}
			}
			return _db;
		}
		
		function onAdd(CFEvent) {
			var i = -1;
			var s = '';
			var qPid = -1;
			var _err_msg = '';
			var _destFName = '';
			var fName = '';
			var fName_prefix = '';
			var shortName = '';
			var fPath = '';
			var tName = '';
			var tbName = '';
			var _sql_statement = '';
			var bool_make_shortname_linkage = false;
			var bool_is_6_day = false;
			var data_lastmodified = -1;
			var data = CFEvent.data;

			bool_is_6_day = false;
			tbName = 'TIBCO_FTP_PROCESS_VALIDATION';

			if (FindNoCase('\' & Request.const_6_day_symbol & '\', data.filename) gt 0) {
				bool_is_6_day = true;
				tbName = 'IML_FTP_PROCESS_VALIDATION';
			}

			_sql_statement = "SELECT id, report_prefix, report_name FROM TibcoReportNameDefs WHERE (PATINDEX ( '%' + report_prefix + '%' , '#data.filename#') > 0)";
			qVPid = Request.primitiveCode.safely_execSQL('qVerifyProcessId', Request.DSN, _sql_statement);
			if (Request.dbError) {
				_err_msg = ' ERROR: _destFName = [#data.filename#] Reason: "#Request.errorMsg#" [#_sql_statement#]';
			} else if ( (Len(Trim(qVPid.id)) gt 0) AND (IsNumeric(qVPid.id)) ) {
				_destFName = data.filename;
				_sql_statement = "SELECT id FROM #tbName# WHERE (bool_validated = 0) AND (_destFName = '#_destFName#')";
				qPid = Request.primitiveCode.safely_execSQL('qGetProcessId', Request.DSN, _sql_statement);
				_err_msg = ' *NOTHING TO REPORT* qPid.recordCount = [#qPid.recordCount#], [#_sql_statement#]';
				if (Request.dbError) {
					_err_msg = ' ERROR: _destFName = [#_destFName#] Reason: "#Request.errorMsg#" [#_sql_statement#]';
				} else if (IsQuery(qPid)) {
					if ((Len(Trim(qPid.id)) gt 0) AND (IsNumeric(qPid.id))) {
						_sql_statement = "UPDATE #tbName# SET bool_validated = 1, bool_processed = 0, dt_validated = GetDate() WHERE (id = #qPid.id#)";
					} else {
						_sql_statement = "INSERT INTO #tbName# (_destFName, dt_validated, bool_validated, bool_processed) VALUES ('#_destFName#',GetDate(),1,0); SELECT @@IDENTITY as 'id'";
					}
					qPidFlag = Request.primitiveCode.safely_execSQL('qFlagProcessId', Request.DSN, _sql_statement);
					if (Request.dbError) {
						_err_msg = ' ERROR: _destFName = [#_destFName#] Reason: "#Request.errorMsg#" [#_sql_statement#]';
					} else {
						if (IsDefined("qPidFlag.id")) {
							_err_msg = 'INFO: qPidFlag.id = [#qPidFlag.id#] - Inserted Flag !';
						} else {
							_err_msg = 'INFO: qPid.recordCount = [#qPid.recordCount#] - Updated Flag !';
						}
						// BEGIN: Now we need to perform a sanity check on the validation queue to ensure it is correct and up to date...
						// Sanity Check:
						// (1) Do all files still exist on the physical device ?
						_sql_statement = "SELECT #tbName#.id, #tbName#._destFName, #tbName#.lid, TIBCO_FTP_SHORT_NAMES.short_name, #tbName#.dt_validated, #tbName#.bool_validated, #tbName#.bool_processed, #tbName#.dt_processed, #tbName#.bool_bytesValidated, #tbName#.dt_bytesValidated FROM #tbName# LEFT OUTER JOIN TIBCO_FTP_SHORT_NAMES ON #tbName#.lid = TIBCO_FTP_SHORT_NAMES.lid ORDER BY #tbName#.dt_validated";
						if (bool_is_6_day) {
							_sql_statement = "SELECT id, _destFName, dt_validated, bool_validated, bool_processed, dt_processed, bool_bytesValidated, dt_bytesValidated FROM #tbName# ORDER BY dt_validated";
						}
						qSCVQ = Request.primitiveCode.safely_execSQL('qSanityCheckValidationQ', Request.DSN, _sql_statement);
						if (Request.dbError) {
							_err_msg = _err_msg & ' ERROR: Cannot perform qSanityCheckValidationQ Reason: "#Request.errorMsg#" [#_sql_statement#]';
						} else {
							for (i = 1; i lte qSCVQ.recordCount; i = i + 1) {
								if (NOT FileExists(qSCVQ._destFName[i])) {
									// Drop the item from the Db Validation Queue because the file is gone and cannot now be processed...
									_sql_statement = "DELETE FROM #tbName# WHERE (id = #qSCVQ.id[i]#)";
									qSCDVQI = Request.primitiveCode.safely_execSQL('qSanityCheckDropValidationQitem', Request.DSN, _sql_statement);
									if (Request.dbError) {
										_err_msg = _err_msg & ' ERROR: Cannot perform qSanityCheckDropValidationQitem Reason: "#Request.errorMsg#" [#_sql_statement#]';
									}
									_sql_statement = "DELETE FROM TIBCO_FTP_PROCESS_QUEUE WHERE (_destFName = #qSCVQ._destFName[i]#)";
									qSCDPQI = Request.primitiveCode.safely_execSQL('qSanityCheckDropProcessQitem', Request.DSN, _sql_statement);
									if (Request.dbError) {
										_err_msg = _err_msg & ' ERROR: Cannot perform qSanityCheckDropProcessQitem Reason: "#Request.errorMsg#" [#_sql_statement#]';
									}
								}
								if (NOT bool_is_6_day) {
									// (2) Make sure all short names have been parsed from the physical file names.
									bool_make_shortname_linkage = false;
									fName = GetFileFromPath(qSCVQ._destFName[i]);
									shortName = Request._GetToken(fName, 2, '_');
									if (Len(Trim(qSCVQ.short_name[i])) gt 0) {
										// there seems to be a short_name so make sure it is correct.
										if (UCASE(qSCVQ.short_name[i]) neq UCASE(shortName)) {
											// the shortname is not correct so make it correct...
											bool_make_shortname_linkage = true;
										}
									} else {
										// there is no short_name so create the linkage for this item...
										bool_make_shortname_linkage = true;
									}
									if (bool_make_shortname_linkage) {
										_sql_statement = "SELECT lid FROM TIBCO_FTP_SHORT_NAMES WHERE (UPPER(short_name) = '#UCASE(shortName)#')";
										qGSCSL = Request.primitiveCode.safely_execSQL('qGetSanityCheckShortNameLinkage', Request.DSN, _sql_statement);
										if (Request.dbError) {
											_err_msg = _err_msg & ' ERROR: Cannot perform qGetSanityCheckShortNameLinkage Reason: "#Request.errorMsg#" [#_sql_statement#]';
										} else {
											_sql_statement = "UPDATE #tbName# SET lid = #qGSCSL.lid# WHERE (id = #qSCVQ.id[i]#)";
											qSSCSL = Request.primitiveCode.safely_execSQL('qSetSanityCheckShortNameLinkage', Request.DSN, _sql_statement);
											if (Request.dbError) {
												_err_msg = _err_msg & ' ERROR: Cannot perform qSetSanityCheckShortNameLinkage Reason: "#Request.errorMsg#" [#_sql_statement#]';
											}
										}
									}
								}
							}
						}
						// remove any left-over process files that have scripts and things...
						fName = GetFileFromPath(_destFName);
						fName_prefix = '*'; // this should simply delete any files that match this pattern... because processing is over since the downloaded file has arrived...
						fPath = GetDirectoryFromPath(_destFName);
						dirQ = Request.cf_directory('DirQ', fPath, fName_prefix & '-ftp-*.txt', false);
						if (IsQuery(dirQ)) {
							for (i = 1; i lte dirQ.recordCount; i = i + 1) {
								tName = dirQ.directory[i] & '\' & dirQ.name[i];
							//	_err_msg = _err_msg & ' INFO: Async-DELETE ? = [#tName#] !';
								if ( (UCASE(tName) neq UCASE(_destFName)) AND (FileExists(tName)) ) {
									_err_msg = _err_msg & ' INFO: Async-DELETE = [#tName#] !';
									Request.cf_file_delete(tName);
									if (Request.fileError) {
										_err_msg = _err_msg & ' Error Msg = [#Request.terseFileErrorMsg#] !';
									}
								}
							}
						}

						// check all the files in the folder and delete those files that are not in the validation table...
						fName = '*.*';
						fPath = GetDirectoryFromPath(_destFName);
						dirQ = Request.cf_directory('DirQ', fPath, fName, false);
						if (IsQuery(dirQ)) {
							_err_msg = _err_msg & ' INFO: dirQ.recordCount = [#dirQ.recordCount#]';
							for (i = 1; i lte dirQ.recordCount; i = i + 1) {
								tName = dirQ.directory[i] & '\' & dirQ.name[i];
								_sql_statement = "SELECT id FROM #tbName# WHERE (UPPER(_destFName) = '#UCASE(tName)#')";
								qGVid = Request.primitiveCode.safely_execSQL('qGetValidationId', Request.DSN, _sql_statement);
							//	_err_msg = _err_msg & ' INFO: tName = [#tName#], qGVid.recordCount = [#qGVid.recordCount#] FileExists() = [#(FileExists(tName))#]';
								if (Request.dbError) {
									_err_msg = _err_msg & ' ERROR: tName = [#tName#] Reason: "#Request.errorMsg#" [#_sql_statement#]';
								} else if ( (qGVid.recordCount eq 0) AND (FileExists(tName)) ) {
									_err_msg = _err_msg & ' INFO: Auto-DELETE Cluttered = [#tName#] !';
									Request.cf_file_delete(tName);
									if (Request.fileError) {
										_err_msg = _err_msg & ' Error Msg = [#Request.terseFileErrorMsg#] !';
									}
								}
							}
						}

						// (3) Duplicate short names means the latest dupe is the one we wish to keep so delete the old one.
						// Better just process everything because there would be no way to be sure that a later validated file should not also be processed sinply because it is another instance...
						if ( (NOT bool_is_6_day) AND (0) ) { // Keep this code around just in case it becomes useful however ignore it for now...
							_sql_statement = "SELECT DISTINCT #tbName#.lid, TIBCO_FTP_SHORT_NAMES.short_name FROM #tbName# LEFT OUTER JOIN TIBCO_FTP_SHORT_NAMES ON #tbName#.lid = TIBCO_FTP_SHORT_NAMES.lid WHERE (#tbName#.lid IS NOT NULL) ORDER BY #tbName#.lid";
							qSCUNDVQ = Request.primitiveCode.safely_execSQL('qSanityCheckUniqueNoDupesValidationQ', Request.DSN, _sql_statement);
							if (Request.dbError) {
								_err_msg = _err_msg & ' ERROR: Cannot perform qSanityCheckNoDupesValidationQ Reason: "#Request.errorMsg#" [#_sql_statement#]';
							} else if (qSCUNDVQ.recordCount gt 0) {
								_sql_statement = "SELECT #tbName#.lid, TIBCO_FTP_SHORT_NAMES.short_name, #tbName#.bool_validated, #tbName#.bool_processed, #tbName#.dt_validated FROM #tbName# LEFT OUTER JOIN TIBCO_FTP_SHORT_NAMES ON #tbName#.lid = TIBCO_FTP_SHORT_NAMES.lid WHERE (#tbName#.lid IS NOT NULL) AND (#tbName#.bool_processed IS NOT NULL) ORDER BY #tbName#.dt_validated DESC";
								Request.qSCNDVQ = Request.primitiveCode.safely_execSQL('qSanityCheckNoDupesValidationQ', Request.DSN, _sql_statement);
								if (Request.dbError) {
									_err_msg = _err_msg & ' ERROR: Cannot perform qSanityCheckNoDupesValidationQ Reason: "#Request.errorMsg#" [#_sql_statement#]';
								} else if (Request.qSCNDVQ.recordCount gt 0) {
									for (i = 1; i lte qSCUNDVQ.recordCount; i = i + 1) {
										_sql_statement = "SELECT lid FROM Request.qSCNDVQ WHERE (lid = #qSCUNDVQ.lid[i]#)";
										qSCIDVQ = Request.primitiveCode.safely_execSQL('qSanityCheckIsDupesValidationQ', '', _sql_statement);
										if (Request.dbError) {
											_err_msg = _err_msg & ' ERROR: Cannot perform qSanityCheckIsDupesValidationQ Reason: "#Request.errorMsg#" [#_sql_statement#]';
										} else if (qSCIDVQ.recordCount gt 1) {
											// Keep the item at the top of the query but drop the rest because they are unprocessed dupes...
										}
									}
								}
							}
						}
						// END! Now we need to perform a sanity check on the validation queue to ensure it is correct and up to date...
					}
				}
			} else {
				_err_msg = ' WARNING: _destFName = [#data.filename#] [#_sql_statement#] Reason: "This is NOT a valid FTP download file so skip it."';
			}

			data_lastmodified = '** Undefined **';
			if (IsDefined("data.lastmodified")) {
				data_lastmodified = timeFormat(data.lastmodified);
			}
			s = "ACTION: #data.type#;  FILE: #data.filename#; {#explainData(data, 'type,filename')#} TIME: #data_lastmodified#";
			if (Len(_err_msg) gt 0) {
				s = s & _err_msg;
			}
			Request.cf_log(s);
		}

		function onDelete(CFEvent) {
			var s = '';
			var data = CFEvent.data;

			s = "ACTION: #data.type#;  FILE: #data.filename#; {#explainData(data, 'type,filename,lastmodified')#} TIME: #timeFormat(Now())#";
			Request.cf_log(s);
		}

		function onChange(CFEvent) {
			var s = '';
			var _err_msg = '';
			var data_lastmodified = -1;
			var data = CFEvent.data;

			Request.fileError = false;
			if ( (FindNoCase('_tibco-ftp-', GetFileFromPath(data.filename)) gt 0) AND (FindNoCase('.txt', GetFileFromPath(data.filename)) gt 0) ) {
				_err_msg = ' INFO: Async-DELETE = [#data.filename#] !';
				if (Request.fileError) {
					_err_msg = _err_msg & ' Error Msg = [#Request.terseFileErrorMsg#] !';
				}
			}

			data_lastmodified = '** Undefined **';
			if (IsDefined("data.lastmodified")) {
				data_lastmodified = timeFormat(data.lastmodified);
			}
			s = "ACTION: #data.type#;  FILE: #data.filename#; {#explainData(data, 'type,filename')#} TIME: #data_lastmodified#" & _err_msg;
			Request.cf_log(s);
		}
	</cfscript>

</cfcomponent>