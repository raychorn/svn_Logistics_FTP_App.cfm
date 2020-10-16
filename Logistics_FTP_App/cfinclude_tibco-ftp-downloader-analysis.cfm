<cfset max_time_to_wait_for_this_page = (60 * 60)>
<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#max_time_to_wait_for_this_page#">

<cfscript>
	function lsFileNameFromId(id) {
		var _lidName = '';
		var _sql_statement_ = "SELECT id, file_name FROM Request.qLsListing WHERE (id = #id#)";
		var _qQLid = Request.primitiveCode.safely_execSQL('QueryFileNameLid#id##Request.commonCode.uniqueTimeBasedUUIDVarName()#', '', _sql_statement_);
		if ( (IsQuery(_qQLid)) AND (_qQLid.recordCount gt 0) AND (NOT Request.dbError) ) {
			_lidName = _qQLid.file_name;
		}
		return _lidName;
	}

	function fullDirFileNameFromId(id) {
		var _fidName = '';
		var _sql_statement_ = "SELECT id, str, file_name FROM Request.qFullDirListing WHERE (id = #id#)";
		var _qQFid = Request.primitiveCode.safely_execSQL('QueryFileNameFid#id##Request.commonCode.uniqueTimeBasedUUIDVarName()#', '', _sql_statement_);
		if ( (IsQuery(_qQFid)) AND (_qQFid.recordCount gt 0) AND (NOT Request.dbError) ) {
			_fidName = _qQFid.str;
		}
		return _fidName;
	}

	function abbrevFullDirName(fName) {
		var const_mailbox_symbol = ' mailbox ';
		var i = -1;
		fName = Trim(fName);
		i = FindNoCase(const_mailbox_symbol, fName);
		if ( (i gt 0) AND (Len(fName) gt Len(const_mailbox_symbol)) ) {
			return Trim(Mid(fName, i + Len(const_mailbox_symbol), Len(fName) - (i + Len(const_mailbox_symbol)) + 1));
		} else {
			return '';
		}
	}

	function insertFullNameIntoDb(fName) {
		var i = -1;
		var _qQ = -1;
		var _qCheck = -1;
		var abbrev = '';
		var _sql_statement_ = '';
		fName = Trim(fName);
		abbrev = abbrevFullDirName(fName);
		if ( (Len(Trim(abbrev)) gt 0) AND (Request.commonCode._GetToken(abbrev, 2, ' ') gt 0) ) {
			_sql_statement_ = "SELECT fid, full_dir_name_abbrev, full_dir_name FROM TIBCO_FTP_FULL_NAMES WHERE (full_dir_name_abbrev = '#abbrev#')";
			_qCheck = Request.primitiveCode.safely_execSQL('qCheckFullNameInDb', Request.DSN, _sql_statement_);
			if ( (IsDefined("_qCheck.fid")) AND (Len(_qCheck.fid) eq 0) ) {
				_sql_statement_ = "INSERT INTO TIBCO_FTP_FULL_NAMES (full_dir_name_abbrev,full_dir_name) VALUES ('#abbrev#','#fName#'); SELECT @@IDENTITY AS 'fid';";
				_qQ = Request.primitiveCode.safely_execSQL('qInsertFullNameIntoDb', Request.DSN, _sql_statement_);
				if ( (Request.dbError) AND (NOT Request.isPKviolation) ) {
					writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span><br>');
				}
				if ( (NOT IsDefined("_qQ.fid")) AND (NOT Request.isPKviolation) ) {
					writeOutput('<span class="errorStatusClass">ERROR: insertFullNameIntoDb(#fName#) failed to store a record using this SQL [#_sql_statement_#].</span><br>');
				}
			}
		}
	}

	function insertShortNameIntoDb(fName) {
		var _qQ = -1;
		var _qCheck = -1;
		var _sql_statement_ = '';
		
		_sql_statement_ = "SELECT lid, short_name FROM TIBCO_FTP_SHORT_NAMES WHERE (short_name = '#Trim(fName)#')";
		_qCheck = Request.primitiveCode.safely_execSQL('qCheckShortNameInDb', Request.DSN, _sql_statement_);
		if ( (IsDefined("_qCheck.lid")) AND (Len(_qCheck.lid) eq 0) ) {
			_sql_statement_ = "INSERT INTO TIBCO_FTP_SHORT_NAMES (short_name) VALUES ('#Trim(fName)#');  SELECT @@IDENTITY AS 'lid';";
			_qQ = Request.primitiveCode.safely_execSQL('qInsertShortNameIntoDb', Request.DSN, _sql_statement_);
			if ( (Request.dbError) AND (NOT Request.isPKviolation) ) {
				writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span><br>');
			}
			if ( (NOT IsDefined("_qQ.lid")) AND (NOT Request.isPKviolation) ) {
				writeOutput('<span class="errorStatusClass">ERROR: insertShortNameIntoDb(#fName#) failed to store a record using this SQL [#_sql_statement_#].</span><br>');
			}
		}
	}

	function getShortIdFromDb(fName) {
		var _sql_statement_ = "SELECT lid FROM TIBCO_FTP_SHORT_NAMES WHERE (short_name = '#Trim(fName)#')";
		var _qQ = Request.primitiveCode.safely_execSQL('qGetShortIdFromDb', Request.DSN, _sql_statement_);

		var lid = -1;
		if (NOT Request.dbError) {
			lid = _qQ.lid;
		} else {
			writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span><br>');
		}
		return lid;
	}

	function getFullIdFromDb(fName) {
		var _sql_statement_ = "SELECT fid FROM TIBCO_FTP_FULL_NAMES WHERE (full_dir_name_abbrev = '#Trim(fName)#')";
		var _qQ = Request.primitiveCode.safely_execSQL('qGetFullIdFromDb', Request.DSN, _sql_statement_);
		var fid = -1;
		if (NOT Request.dbError) {
			fid = _qQ.fid;
		} else {
			writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span><br>');
		}
		return fid;
	}

	function storeShort2FullNameLinkageInDb(sName, fName) {
		var _qQ = -1;
		var lid = getShortIdFromDb(sName);
		var fid = getFullIdFromDb(fName);

		var _sql_statement_ = "SELECT id FROM TIBCO_FTP WHERE (fid = #fid#) AND (lid = #lid#)";
		var _qQi = Request.primitiveCode.safely_execSQL('qGetShort2FullNameLinkageInDb', Request.DSN, _sql_statement_);
		if ( (NOT Request.dbError) AND (_qQi.recordCount eq 0) ) {
			_sql_statement_ = "INSERT INTO TIBCO_FTP (fid, lid) VALUES (#fid#,#lid#);  SELECT @@IDENTITY AS 'id';";
			_qQ = Request.primitiveCode.safely_execSQL('qStoreShort2FullNameLinkageInDb', Request.DSN, _sql_statement_);
			if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span><br>');
			}
			if (NOT IsDefined("_qQ.id")) {
				writeOutput('<span class="errorStatusClass">ERROR: storeShort2FullNameLinkageInDb(#fName#) failed to store a record using this SQL [#_sql_statement_#].</span><br>');
			}
		}
	}

	function countRecsInDbTable(tbName) {
		var _sql_statement_ = "SELECT COUNT(*) as recCount FROM #Trim(tbName)#";
		var _qQ = Request.primitiveCode.safely_execSQL('qCountRecsInDbTable', Request.DSN, _sql_statement_);

		var cnt = -1;
		if (NOT Request.dbError) {
			cnt = _qQ.recCount;
		} else {
			writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span><br>');
		}
		return cnt;
	}

	Request.commonCode.qFileCleanUpQueryInit();

	writeOutput('<table border="0" width="990px" cellpadding="-1" cellspacing="-1">');
	writeOutput('<tr>');
	writeOutput('<td valign="top">');

	temp_folder = GetTempDirectory();

	cmd_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-dir.cmd';
	script_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-script-dir.txt';
	output_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-dir.txt';
	Request.primitiveCode.safely_cffile_write(cmd_file, 'ftp -n -s:#script_file#');
	Request.commonCode.qFileCleanUpAppend(cmd_file);
	Request.primitiveCode.safely_cffile_write(script_file, Request.commonCode.tibco_ftp_command_stream_preamble() & 'dir' & Chr(13) & 'quit' & Chr(13));
	Request.commonCode.qFileCleanUpAppend(script_file);
	
	retVal = Request.primitiveCode.cf_execute(cmd_file, output_file, (60 * 5));
	
	if (Request.anError) {
		writeOutput(Request.verboseErrorMsg);
	}

	Request.commonCode.qFileCleanUpAppend(output_file);
	
	writeOutput('retVal = [#retVal#]<br><br>');

	full_dir_content = Request.primitiveCode.safely_cffile(output_file);
	
	if (Request.anError) {
		writeOutput(Request.verboseErrorMsg);
	}

	writeOutput('Len(full_dir_content) = [#Len(full_dir_content)#]<br>');

//	sample = '-AR--M----TCP A mailbox     13212      358 Jun 09 01:03 SRP911PCD0001M.TXT';
//	llen = ListLen(sample, ' ');
	
	const_eof_symbol = 'quit';
	const_username_symbol = 'Username';

	Request.qFullDirListing = QueryNew('id, str, file_name, abbrev_name', 'integer, varchar, varchar, varchar');
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
				if ( (Len(Trim(s_abbrev)) gt 0) AND (Request.commonCode._GetToken(s_abbrev, 2, ' ') gt 0) ) {
					QueryAddRow(Request.qFullDirListing, 1);
					QuerySetCell(Request.qFullDirListing, 'id', Request.qFullDirListing.recordCount, Request.qFullDirListing.recordCount);
					QuerySetCell(Request.qFullDirListing, 'str', s, Request.qFullDirListing.recordCount);
					fName = Trim(Request.commonCode._GetToken(s, ListLen(s, ' '), ' '));
					QuerySetCell(Request.qFullDirListing, 'file_name', fName, Request.qFullDirListing.recordCount);
					QuerySetCell(Request.qFullDirListing, 'abbrev_name', s_abbrev, Request.qFullDirListing.recordCount);

					insertFullNameIntoDb(s);
				} else {
					k_skipped = k_skipped + 1;
				}
			} else {
				break;
			}
		}
		i = i + 1;
	} while ( (Len(Trim(s)) gt 0) AND (NOT eof) );
	
	writeOutput('There are #Request.qFullDirListing.recordCount# batches.<br>');
	writeOutput(Request.primitiveCode.cf_dump(Request.qFullDirListing, 'Request.qFullDirListing', false));

	writeOutput('</td>');

	writeOutput('<td valign="top">');

	cmd_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-ls.cmd';
	script_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-script-ls.txt';
	output_file = temp_folder & Request.commonCode._uniqueTimeBasedUUID('-') & '_' & 'tibco-ftp-ls.txt';
	Request.primitiveCode.safely_cffile_write(cmd_file, 'ftp -n -s:#script_file#');
	Request.commonCode.qFileCleanUpAppend(cmd_file);
	Request.primitiveCode.safely_cffile_write(script_file, Request.commonCode.tibco_ftp_command_stream_preamble() & 'ls' & Chr(13) & 'quit' & Chr(13));
	Request.commonCode.qFileCleanUpAppend(script_file);

	retVal = Request.primitiveCode.cf_execute(cmd_file, output_file, (60 * 5));
	Request.commonCode.qFileCleanUpAppend(output_file);
	
	writeOutput('retVal = [#retVal#]<br><br>');

	ls_dir_content = Request.primitiveCode.safely_cffile(output_file);

	Request.qLsListing = QueryNew('id, file_name', 'integer, varchar');
	qDirLsLinkage = QueryNew('id, lid, fid', 'integer, integer, integer');
	i = 1;
	do {
		s = Request.commonCode._GetToken(ls_dir_content, i, Chr(13));
		cof = (FindNoCase(script_file, s) gt 0);
		if ( (NOT cof) AND (Len(Trim(s)) gt 0) ) {
			if (LCASE(Trim(Request.commonCode._GetToken(s, 1, ' '))) eq LCASE(Trim(const_username_symbol))) {
				s = Right(s, Len(s) - Len(Trim(const_username_symbol)) - 1);
			}
			_sql_statement_ = "SELECT id, str, file_name, abbrev_name FROM Request.qFullDirListing WHERE (UPPER(abbrev_name) LIKE '%#UCASE(Trim(s))#')";
			_qQ = Request.primitiveCode.safely_execSQL('QueryFileName#i#', '', _sql_statement_);
			if ( (IsQuery(_qQ)) AND (_qQ.recordCount gt 0) AND (IsDefined("_qQ.id")) AND (IsNumeric(_qQ.id)) AND (NOT Request.dbError) ) {
				QueryAddRow(Request.qLsListing, 1);
				QuerySetCell(Request.qLsListing, 'id', Request.qLsListing.recordCount, Request.qLsListing.recordCount);
				QuerySetCell(Request.qLsListing, 'file_name', s, Request.qLsListing.recordCount);
				
				insertShortNameIntoDb(s);

				for (jj = 1; jj lte _qQ.recordCount; jj = jj + 1) {
					QueryAddRow(qDirLsLinkage, 1);
					QuerySetCell(qDirLsLinkage, 'id', qDirLsLinkage.recordCount, qDirLsLinkage.recordCount);
					QuerySetCell(qDirLsLinkage, 'lid', Request.qLsListing.recordCount, qDirLsLinkage.recordCount);
					QuerySetCell(qDirLsLinkage, 'fid', _qQ.id[jj], qDirLsLinkage.recordCount);

					storeShort2FullNameLinkageInDb(s, _qQ.abbrev_name[jj]);
				}
			} else if (Request.dbError) {
				writeOutput('<span class="errorStatusClass">#Request.errorMsg#</span><br>');
			}
		}
		i = i + 1;
	} while (Len(Trim(s)) gt 0);

	writeOutput(Request.primitiveCode.cf_dump(Request.qLsListing, 'Request.qLsListing', false));
	writeOutput(Request.primitiveCode.cf_dump(qDirLsLinkage, 'qDirLsLinkage', false));

	writeOutput('</td>');
	writeOutput('</tr>');

	writeOutput('<tr>');
	writeOutput('<td colspan="2">');
	
	fid_count = countRecsInDbTable('TIBCO_FTP_FULL_NAMES');
	lid_count = countRecsInDbTable('TIBCO_FTP_SHORT_NAMES');
	
	if (qDirLsLinkage.recordCount neq Request.qFullDirListing.recordCount) {
		writeOutput('<span class="errorStatusClass">ERROR: qDirLsLinkage.recordCount (#qDirLsLinkage.recordCount#) is NOT equal to Request.qFullDirListing.recordCount (#Request.qFullDirListing.recordCount#).</span><br>');
	}

	curLID = qDirLsLinkage.lid[1];
	writeOutput('<UL>');
	writeOutput('<LI class="listItemClass">');
	writeOutput(lsFileNameFromId(curLID));
	writeOutput('<OL>');
	for (n = 1; n lte qDirLsLinkage.recordCount; n = n + 1) {
		if (curLID neq qDirLsLinkage.lid[n]) {
			writeOutput('</OL>');
			writeOutput('</UL>');
			curLID = qDirLsLinkage.lid[n];
			writeOutput('<UL>');
			writeOutput('<LI class="listItemClass">');
			writeOutput(lsFileNameFromId(curLID));
			writeOutput('<OL>');
		}
		
		writeOutput('<LI class="listItemClass">');
		writeOutput(fullDirFileNameFromId(qDirLsLinkage.fid[n]));
		writeOutput('</LI>');
	}

	writeOutput('</OL>');
	writeOutput('</UL>');
	
	writeOutput('</td>');
	writeOutput('</tr>');
	
	writeOutput('</table>');

	Request.commonCode.qFileCleanUpProcess();
</cfscript>
