<cfsavecontent variable="sql_getFTPWorkQueueFromDb">
	SELECT TOP 1 
			TIBCO_FTP_FULL_NAMES.full_dir_name, 
			TIBCO_FTP_SHORT_NAMES.short_name, 
			TIBCO_FTP_SHORT_NAMES.lid, 
	        DATALENGTH(TIBCO_FTP.raw_data) AS byteCount, 
			TIBCO_FTP_FULL_NAMES.fid, 
			CAST(dbo.StrTok(TIBCO_FTP_FULL_NAMES.full_dir_name, 5, ' ') AS int) AS actualByteCount,
                    (SELECT     id
                      FROM          TIBCO_FTP_PROCESS_QUEUE
                      WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)) AS procId,
                    (SELECT     _destFName
                      FROM          TIBCO_FTP_PROCESS_QUEUE
                      WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)) AS _destFName,
                    (SELECT     bool_validated
                      FROM          TIBCO_FTP_PROCESS_VALIDATION
                      WHERE      (_destFName =
                                                 (SELECT     _destFName
                                                   FROM          TIBCO_FTP_PROCESS_QUEUE
                                                   WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) AS bool_validated
	FROM TIBCO_FTP LEFT OUTER JOIN
	     TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid LEFT OUTER JOIN
	     TIBCO_FTP_FULL_NAMES ON TIBCO_FTP.fid = TIBCO_FTP_FULL_NAMES.fid
	WHERE (DATALENGTH(TIBCO_FTP.raw_data) IS NULL OR
	      DATALENGTH(TIBCO_FTP.raw_data) = 0) AND
                 ((SELECT     bool_validated
                     FROM         TIBCO_FTP_PROCESS_VALIDATION
                     WHERE     (_destFName =
                                               (SELECT     _destFName
                                                 FROM          TIBCO_FTP_PROCESS_QUEUE
                                                 WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) IS NULL OR
                 (SELECT     bool_validated
                   FROM          TIBCO_FTP_PROCESS_VALIDATION
                   WHERE      (_destFName =
                                              (SELECT     _destFName
                                                FROM          TIBCO_FTP_PROCESS_QUEUE
                                                WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) = 0)
	ORDER BY bool_validated, byteCount, actualByteCount DESC
</cfsavecontent>

<cfsavecontent variable="sql_getFTPWorkQueueFromDb2">
	SELECT TOP 1 
			TIBCO_FTP_FULL_NAMES.full_dir_name, 
			TIBCO_FTP_SHORT_NAMES.short_name, 
			TIBCO_FTP_SHORT_NAMES.lid, 
	        DATALENGTH(TIBCO_FTP.raw_data) AS byteCount, 
			TIBCO_FTP_FULL_NAMES.fid, 
			CAST(dbo.StrTok(TIBCO_FTP_FULL_NAMES.full_dir_name, 5, ' ') AS int) AS actualByteCount,
			-1 as procId,
			'' as _destFName,
			-1 as bool_validated
	FROM TIBCO_FTP LEFT OUTER JOIN
	     TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid LEFT OUTER JOIN
	     TIBCO_FTP_FULL_NAMES ON TIBCO_FTP.fid = TIBCO_FTP_FULL_NAMES.fid
	WHERE (DATALENGTH(TIBCO_FTP.raw_data) IS NULL OR
	      DATALENGTH(TIBCO_FTP.raw_data) = 0)
	ORDER BY actualByteCount DESC
</cfsavecontent>

<cfsavecontent variable="sql_qGetFileToProcess">
	SELECT TOP 1 TIBCO_FTP_FULL_NAMES.full_dir_name, 
				 TIBCO_FTP_SHORT_NAMES.short_name, 
				 TIBCO_FTP_SHORT_NAMES.lid, 
	             DATALENGTH(TIBCO_FTP.raw_data) AS byteCount, 
				 TIBCO_FTP_FULL_NAMES.fid, 
				 CAST(dbo.StrTok(TIBCO_FTP_FULL_NAMES.full_dir_name, 5, ' ') AS int) AS actualByteCount, 
				 TIBCO_FTP_FULL_NAMES.full_dir_name_abbrev,
	                          (SELECT     id
	                            FROM          TIBCO_FTP_PROCESS_QUEUE
	                            WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)) AS procId,
	                          (SELECT     _destFName
	                            FROM          TIBCO_FTP_PROCESS_QUEUE
	                            WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)) AS _destFName,
	                          (SELECT     bool_validated
	                            FROM          TIBCO_FTP_PROCESS_VALIDATION
	                            WHERE      (_destFName =
	                                                       (SELECT     _destFName
	                                                         FROM          TIBCO_FTP_PROCESS_QUEUE
	                                                         WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) AS bool_validated,
	                          (SELECT     bool_processed
	                            FROM          TIBCO_FTP_PROCESS_VALIDATION
	                            WHERE      (_destFName =
	                                                       (SELECT     _destFName
	                                                         FROM          TIBCO_FTP_PROCESS_QUEUE
	                                                         WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) AS bool_processed
	FROM TIBCO_FTP LEFT OUTER JOIN
	     TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid LEFT OUTER JOIN
	     TIBCO_FTP_FULL_NAMES ON TIBCO_FTP.fid = TIBCO_FTP_FULL_NAMES.fid
	WHERE (DATALENGTH(TIBCO_FTP.raw_data) IS NULL OR DATALENGTH(TIBCO_FTP.raw_data) = 0) 
	AND
          ((SELECT     bool_validated
              FROM         TIBCO_FTP_PROCESS_VALIDATION
              WHERE     (_destFName =
                                        (SELECT     _destFName
                                          FROM          TIBCO_FTP_PROCESS_QUEUE
                                          WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) = 1) AND
          ((SELECT     bool_processed
              FROM         TIBCO_FTP_PROCESS_VALIDATION
              WHERE     (_destFName =
                                        (SELECT     _destFName
                                          FROM          TIBCO_FTP_PROCESS_QUEUE
                                          WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) IS NULL OR
          (SELECT     bool_processed
            FROM          TIBCO_FTP_PROCESS_VALIDATION
            WHERE      (_destFName =
                                       (SELECT     _destFName
                                         FROM          TIBCO_FTP_PROCESS_QUEUE
                                         WHERE      (lid = TIBCO_FTP.lid) AND (fid = TIBCO_FTP.fid) AND (_shortFName = TIBCO_FTP_SHORT_NAMES.short_name) AND (_fullDirName = TIBCO_FTP_FULL_NAMES.full_dir_name)))) = 0)
	ORDER BY byteCount, actualByteCount DESC
</cfsavecontent>

<cfset const_shortName_goes_here_token = "%short-name-goes-here%">

<cfsavecontent variable="sql_getFTPBatches">
	<cfoutput>
		SELECT TIBCO_FTP_SHORT_NAMES.short_name, TIBCO_FTP_FULL_NAMES.full_dir_name_abbrev, TIBCO_FTP_FULL_NAMES.full_dir_name, DATALENGTH(TIBCO_FTP.raw_data) AS byteCount, TIBCO_FTP.fid, TIBCO_FTP.lid, '' as ts
		FROM TIBCO_FTP INNER JOIN
		     TIBCO_FTP_SHORT_NAMES ON TIBCO_FTP.lid = TIBCO_FTP_SHORT_NAMES.lid INNER JOIN
		     TIBCO_FTP_FULL_NAMES ON TIBCO_FTP.fid = TIBCO_FTP_FULL_NAMES.fid
		WHERE (TIBCO_FTP_SHORT_NAMES.short_name = '#const_shortName_goes_here_token#')
	</cfoutput>
</cfsavecontent>

<cfsavecontent variable="sql_qGetBruteForceNumRecs">
	<cfoutput>
		DECLARE @t as datetime
		SELECT @t = GETDATE()
		DECLARE @bt as datetime
		SELECT @bt = CAST('#Request.const_begin_date_symbol#' as datetime)
		DECLARE @et as datetime
		SELECT @et = CAST('#Request.const_end_date_symbol#' as datetime)
		SELECT id, recid, last_modified_dt, file_length, file_name, file_path, file_url, report_name, raw_data, rec_id
		FROM dbo.GetCombinedTerseFTPReportsData(@t,@bt,@et)
		WHERE (file_length IS NOT NULL) AND (file_length > 0)
	</cfoutput>
</cfsavecontent>

<cfscript>
	function sql_qGetBruteForceNumRecsFromDb(beginDt, endDt) {
		var sql = ReplaceNoCase(sql_qGetBruteForceNumRecs, Request.const_begin_date_symbol, DateFormat(beginDt, 'yyyy-mm-dd') & ' ' & Request.const_end_date_time_alpha_symbol);
		sql = ReplaceNoCase(sql, Request.const_end_date_symbol, DateFormat(endDt, 'yyyy-mm-dd') & ' ' & Request.const_end_date_time_omega_symbol);
		
		return sql;
	}

	function timeStampFromAbbrev(s_abbrev) {
		var filemonth = -1;
		var fileday = -1;
		var fileyear = -1;
		var thisMonth = -1;
		var filedate = -1;
		var filetime = -1;
		// 106722 5772 Jul 20 01:11 SRP720PCD0001.TUE
		filemonth = Request.commonCode._GetToken(s_abbrev, 3, ' ');
		fileday = Request.commonCode._GetToken(s_abbrev, 4, ' ');
		fileyear = Year(Now());
		thisMonth = DatePart('m', Now());
		if (FindNoCase(filemonth, MonthAsString(thisMonth)) eq 0) {
			if (thisMonth eq 1) {
				fileyear = DatePart('yyyy', Now()) - 1;
			}
		}
		filedate = filemonth & '-' & fileday;
		filetime = Request.commonCode._GetToken(s_abbrev, 5, ' ');
		return CreateDateTime(fileyear, Request.commonCode.monthNameToNum(filemonth), fileday, Request.commonCode._GetToken(filetime, 1, ':'), Request.commonCode._GetToken(filetime, 2, ':'), 0);
	}

	function sql_getFTPWorkQueueFromDbWhere(b) {
		var bool = false;
		if (IsBoolean(b)) {
			bool = b;
		}

		if (NOT bool) {
			return sql_getFTPWorkQueueFromDb;
		} else {
			return sql_getFTPWorkQueueFromDb2;
		}
	}

	function sql_qGetFileToProcessFromDb() {
		return sql_qGetFileToProcess;
	}

	function sql_getFTPBatchesForShortName(s_shortName) {
		s_shortName = Trim(s_shortName);
		return ReplaceNoCase(sql_getFTPBatches, const_shortName_goes_here_token, s_shortName);
	}

	function getFTPWorkQueueFromDb(sql, b) {
		var i = -1;
		var _sql_statement = '';
		var qGPI = -1;
		var qGDF = -1;
		var qGVF = -1;
		var qQ = -1;
		var bool = false;

		Request.qQ = Request.primitiveCode.safely_execSQL('qGetFTPWorkQueueFromDb', Request.DSN, sql);

		if (IsBoolean(b)) {
			bool = b;
		}

		if (NOT bool) {
			if (Request.dbError) {
				Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<span class="errorStatusClass">getFTPWorkQueueFromDb (qGetFTPWorkQueueFromDb) :: #Request.errorMsg#</span>');
			}
			return Request.qQ;
		} else {
			writeOutput(Request.primitiveCode.cf_dump(Request.qQ, 'A. Request.qQ - [#sql#]', false));

			if (NOT Request.dbError) {
				for (i = 1; i lte Request.qQ.recordCount; i = i + 1) {
					if (Request.qQ.procId[i] eq -1) {
						_sql_statement = "SELECT TOP 1 id FROM TIBCO_FTP_PROCESS_QUEUE WHERE (lid = #Request.qQ.lid[i]#) AND (fid = #Request.qQ.fid[i]#) AND (UPPER(_shortFName) = '#UCASE(Request.qQ.short_name[i])#') AND (UPPER(_fullDirName) = '#UCASE(Request.qQ.full_dir_name[i])#')";
						qGPI = Request.primitiveCode.safely_execSQL('qGetProcId', Request.DSN, _sql_statement);
						if (NOT Request.dbError) {
							Request.qQ.procId[i] = qGPI.id;
	
							if (Len(Trim(Request.qQ._destFName[i])) eq 0) {
								_sql_statement = "SELECT TOP 1 _destFName FROM TIBCO_FTP_PROCESS_QUEUE WHERE (lid = #Request.qQ.lid[i]#) AND (fid = #Request.qQ.fid[i]#) AND (UPPER(_shortFName) = '#UCASE(Request.qQ.short_name[i])#') AND (UPPER(_fullDirName) = '#UCASE(Request.qQ.full_dir_name[i])#')";
								qGDF = Request.primitiveCode.safely_execSQL('qGetDestFName', Request.DSN, _sql_statement);
								if (NOT Request.dbError) {
									Request.qQ._destFName[i] = qGDF._destFName;
									
									if (Request.qQ.bool_validated[i] eq -1) {
										_sql_statement = "SELECT TOP 1 bool_validated FROM TIBCO_FTP_PROCESS_VALIDATION WHERE (UPPER(_destFName) = '#UCASE(Request.qQ._destFName[i])#')";
										qGVF = Request.primitiveCode.safely_execSQL('qGetValidationFlag', Request.DSN, _sql_statement);
										if (NOT Request.dbError) {
											if (Len(Trim(qGVF.bool_validated)) eq 0) {
												Request.qQ.bool_validated[i] = 0;
											} else {
												Request.qQ.bool_validated[i] = qGVF.bool_validated;
											}
										} else {
											Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<span class="errorStatusClass">getFTPWorkQueueFromDb (qGetValidationFlag) :: #Request.errorMsg#</span>');
										}
									}
								} else {
									Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<span class="errorStatusClass">getFTPWorkQueueFromDb (qGetDestFName) :: #Request.errorMsg#</span>');
								}
							}
						} else {
							Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<span class="errorStatusClass">getFTPWorkQueueFromDb (qGetProcId) :: #Request.errorMsg#</span>');
						}
					}
				}
				writeOutput(Request.primitiveCode.cf_dump(Request.qQ, 'B. Request.qQ', false));

				_sql_statement = "SELECT * FROM Request.qQ WHERE (bool_validated IS NULL) OR (bool_validated = 0)";
				qQ = Request.primitiveCode.safely_execSQL('qGetWorkQueue', '', _sql_statement);

				writeOutput(Request.primitiveCode.cf_dump(qQ, 'C. qQ - [#_sql_statement#]', false));

				if (Request.dbError) {
					writeOutput('<font color="red">Request.errorMsg = [#Request.errorMsg#]<br></font>');
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<span class="errorStatusClass">getFTPWorkQueueFromDb (qGetWorkQueue) :: #Request.errorMsg#</span>');
				}
				return qQ;
			} else {
				Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<span class="errorStatusClass">getFTPWorkQueueFromDb (qGetFTPWorkQueueFromDb) :: #Request.errorMsg#</span>');
			}
		}
		return QueryNew('');
	}

	function DayOfWeekAbbrev2Ordinal(s_dow) {
		var i = 1;
		for (i = 1; i lte 7; i = i + 1) {
			if (FindNoCase(s_dow, DayOfWeekAsString(i)) gt 0) {
				return i;
			}
		}
		return -1;
	}

	function batchBytesCountArrayFromQuery(q, theSum, colName, func) {
		var i = -1;
		var j = -1;
		var k = -1;
		var chkSum = 0;
		var varName = '';
		var varVal = '';
		var a = ArrayNew(1);
		var b = ArrayNew(1);

		if (IsQuery(q)) {
			j = 1;
			for (i = 1; i lte q.recordCount; i = i + 1) {
				varName = 'q.' & colName & '[#i#]';
				try {
					varVal = Evaluate(varName);
				} catch (Any e) {
					varVal = '';
				}
				if (IsCustomFunction(func)) {
					b[j] = func(varVal);
					j = j + 1;
				}
			}

			j = -1;
			chkSum = 0;
			for (i = ArrayLen(b); i gte 1; i = i - 1) {
				chkSum = chkSum + b[i];
				if (theSum eq chkSum) {
					j = i;
					break;
				}
			}
			
			k = 1;
			if (j neq -1) {
				for (; j lte ArrayLen(b); j = j + 1) {
					a[k] = b[j];
					k = k + 1;
				}
			}
		}
		return a;
	}
	
	function getByteCountFromAbbrev( s_abbrev) {
		return Trim(Request.commonCode._GetToken(s_abbrev, 2, ' '));
	}
	
	function printCharsAsAsc(s) {
		var i = -1;
		var j = 0;
		var t = '';
		var tt = '';
		var _ch = '';
		j = 0;
		t = t & '#j# :: ';
		for (i = 1; i lte Len(s); i = i + 1) {
			_ch = Mid(s, i, 1);
			t = t & '[#Asc(_ch)#]';
			tt = tt & '[#_ch#]';
			if (i lt Len(s)) {
				j = j + 1;
				if ((j mod 10) eq 0) {
					t = t & '...' & tt;
					t = t & '<br>';
					t = t & '#j# :: ';
					tt = '';
				} else {
					t = t & '&nbsp;';
					tt = tt & '&nbsp;';
				}
			}
		}
		return t;
	}
	
	function countInstancesOfPattern(s, pat) {
		var i = 1;
		var n = 0;
		var p = 0;
		do {
			p = FindNoCase(pat, s, i);
			if (p gt 0) {
				n = n + 1;
				i = i + (p + Len(pat));
			} else {
				break;
			}
		} while (p gt 0);
		return n;
	}

	function trueSizeOfRawBucket(s, bool) {
		var i = -1;
		var t = '';
		var m = 0;
		var a_analysis = ArrayNew(1);
		var a_buffer = -1;
		var lf = Chr(10);
		var a_analSum = 0;

		bool = false; // always choose the faster method.
		if (bool) {
			// BEGIN: This function takes 680 secs to exec for 1 MB of data...
			m = ListLen(s, lf);
			for (i = 1; i lte m; i = i + 1) {
				t = Request.commonCode._GetToken(s, i, lf);
				a_analSum = a_analSum + Len(t);
			}
			// END! This function takes 680 secs to exec for 1 MB of data...
		} else {
			// BEGIN: This function takes 0.094 secs to exec for 8 MB of data...
			a_buffer = ListToArray(s, lf);
			m = ArrayLen(a_buffer);
			for (i = 1; i lte m; i = i + 1) {
				a_analSum = a_analSum + Len(a_buffer[i]);
			}
			// END! This function takes 0.094 secs to exec for 8 MB of data...
		}
		if (NOT Request.bool_inhibit_cfdump_during_process_new) {
			Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), Request.primitiveCode.cf_dump(a_analysis, 'a_analysis', true));
		}
		return a_analSum;
	}

	function splitRawDataIntoBatchesUsing(s_rd, ar, a_analSum, bool_method) {
		var i = -1;
		var t = '';
		var st = '';
		var n = 0;
		var m = 0;
		var mn_per_row = 0;
		var ar_i = 1;
		var bool = false;
		var ar_n = ArrayLen(ar);
		var ar_sum = ArraySum(ar);
		var pat = Chr(13) & Chr(13) & Chr(10);
		var a_batches = ArrayNew(1);
		var a_analTest = ArrayNew(1);
		var hr_color = '';
		var chkSum = -1;
		var lf = Chr(10);
		
		// Begin: new method vars goes here...
		var s_rd_array = -1;
		// End! new method vars goes here...

		bool_method = false; // always choose the faster method.
		if (bool_method) {
			// the original method...
			Request.bool_simpleCase = false;
			Request.bool_simpleCase2 = false;
	
			if (IsArray(ar, 1)) {
				try {
					ArraySet(a_analTest, 1, ar_n, 0);  // pre-initialize this array
				} catch (Any e) {
				}
				
				mn_per_row = -1;
				m = ListLen(s_rd, lf);
				Request.bool_simpleCase = (m eq ar_n);
				Request.bool_simpleCase2 = (ar_sum eq a_analSum);
				chkSum = (Max(ar_sum, a_analSum) - Min(ar_sum, a_analSum));
				Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '0. splitRawDataIntoBatchesUsing :: [Request.bool_simpleCase=#Request.bool_simpleCase#] | [m=#m#] | [ar_n=#ar_n#] | [ar_sum=#ar_sum#] | [a_analSum=#a_analSum#] | [Request.bool_simpleCase2=#Request.bool_simpleCase2#] | [CheckSum=#chkSum#]');
				if (chkSum eq 0) {
					for (i = 1; i lte m; i = i + 1) {
						t = Request.commonCode._GetToken(s_rd, i, lf) & lf;
						n = n + (Len(t) - 1);
						mn_per_row = Max(mn_per_row, Len(t));
						st = st & t;
						if (Request.bool_simpleCase) {
							bool = true; // simple case is simply one row per batch...
						} else if (Request.bool_simpleCase2) {
							a_analTest[ArrayLen(a_batches) + 1] = a_analTest[ArrayLen(a_batches) + 1] + (Len(t) - 1);
							bool = ( (ar[ArrayLen(a_batches) + 1] eq 0) OR (a_analTest[ArrayLen(a_batches) + 1] gte ar[ArrayLen(a_batches) + 1]) ); // simple case 2 is simply perform best fit analysis on row by row basis...
							hr_color = 'blue';
							if (bool) {
								hr_color = 'red';
							}
						} else {
							try {
								bool = (n eq ar[ar_i]);
								// erroneous packaging of data will have to be worked out AFTER the sub-batches have been isolated into separate buckets.
							} catch (Any e) {
								bool = false;
							}
						}
						if (bool) {
							a_batches[ar_i] = st;
							ar_i = ar_i + 1;
							n = 0;
							mn_per_row = -1;
							st = '';
						}
					}
					if (Len(st) gt 0) {
						a_batches[ar_i] = st;
						n = 0;
						mn_per_row = -1;
						st = '';
					}
				} else {
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<font color="red">ERROR: CheckSum is NOT zero (#chkSum#) !  Something is wrong with the way sub-batches are being determined.</font>');
				}
			}
		} else {
			// the new method...
			Request.bool_simpleCase = false;
			Request.bool_simpleCase2 = false;
	
			if (IsArray(ar, 1)) {
				s_rd_array = ListToArray(s_rd, lf);
				try {
					ArraySet(a_analTest, 1, ar_n, 0);  // pre-initialize this array
				} catch (Any e) {
				}
				
				mn_per_row = -1;
				m = ArrayLen(s_rd_array);
				Request.bool_simpleCase = (m eq ar_n);
				Request.bool_simpleCase2 = (ar_sum eq a_analSum);
				chkSum = (Max(ar_sum, a_analSum) - Min(ar_sum, a_analSum));
				Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '0. splitRawDataIntoBatchesUsing :: [Request.bool_simpleCase=#Request.bool_simpleCase#] | [m=#m#] | [ar_n=#ar_n#] | [ar_sum=#ar_sum#] | [a_analSum=#a_analSum#] | [Request.bool_simpleCase2=#Request.bool_simpleCase2#] | [CheckSum=#chkSum#]');
				if (chkSum eq 0) {
					for (i = 1; i lte m; i = IncrementValue(i)) { // i + 1
						t = s_rd_array[i] & lf;
						n = n + (Len(t) - 1);
						mn_per_row = Max(mn_per_row, Len(t));
						st = st & t;
						if (Request.bool_simpleCase) {
							bool = true; // simple case is simply one row per batch...
						} else if (Request.bool_simpleCase2) {
							a_analTest[ArrayLen(a_batches) + 1] = a_analTest[ArrayLen(a_batches) + 1] + (Len(t) - 1);
							bool = ( (ar[ArrayLen(a_batches) + 1] eq 0) OR (a_analTest[ArrayLen(a_batches) + 1] gte ar[ArrayLen(a_batches) + 1]) ); // simple case 2 is simply perform best fit analysis on row by row basis...
						} else {
							try {
								bool = (n eq ar[ar_i]); // erroneous packaging of data will have to be worked out AFTER the sub-batches have been isolated into separate buckets.
							} catch (Any e) {
								bool = false;
							}
						}
						if (bool) {
							a_batches[ar_i] = st;
							ar_i = ar_i + 1;
							n = 0;
							mn_per_row = -1;
							st = '';
						}
					}
					if (Len(st) gt 0) {
						a_batches[ar_i] = st;
						n = 0;
						mn_per_row = -1;
						st = '';
					}
				} else {
					Request.commonCode.appendFTPLogActivityCache(Request._qActivity, Now(), '<font color="red">ERROR: CheckSum is NOT zero (#chkSum#) !  Something is wrong with the way sub-batches are being determined.</font>');
				}
			}
		}
		return a_batches;
	}

	function splitRawDataIntoBatchesUsing2(s_rd, ar) {
		var Cr = Chr(13);
		var Lf = Chr(10);
		var delim = ',';
		var quotes = '"';
		var _qq = -1;
		var dStream = -1;
		var a_batches = ArrayNew(1);

		if (IsArray(ar, 1)) {
			_qq = Request.excelReader.str2Query(s_rd, Cr, Lf);

			dStream = Request.excelReader.query2FlashDataStream(_qq, delim, quotes);

			Request.dataResponder.processDataStream(dStream);
			
			writeOutput(Request.primitiveCode.cf_dump(Request.dQ, 'Request.dQ', true));
			
			if ( (Request.bool_usefulData) AND (NOT Request.db_err) ) {
				writeOutput(Request.primitiveCode.cf_dump(Request.qFTPReportData, 'Request.qFTPReportData', true));
				writeOutput(Request.primitiveCode.cf_dump(Request.qFTPTrashData, 'Request.qFTPTrashData', true));
			}
		}
		return a_batches;
	}
	
	function getProcessableFilesFromTempFolder(tFolder) {
		var i = -1;
		var dirQ = -1;
		var tName = '';
		var tList = '';

		dirQ = Request.primitiveCode.cf_directory('DirQ', tFolder, '*.*', false);
		if (IsQuery(dirQ)) {
			for (i = i; i lte dirQ.recordCount; i = i + 1) {
				tName = dirQ.directory & '\' & dirQ.name;
				if ( (FindNoCase('_tibco-ftp-', tName) eq 0) AND (FindNoCase('.txt', tName) eq 0) ) {
					tList = ListAppend(tList, "'" & tName & "'", ',');
				}
			}
		}
		return tList;
	}

	function GetDownloadedNotYetProcessedQueue(bool_isOpt101, _sql) {
		var qR = -1;

		variables._sql_code = _sql;
		if (bool_isOpt101) {
			variables._sql_code = ReplaceNoCase(variables._sql_code, ' TOP 1 ', ' ');
		}
		qR = getFTPWorkQueueFromDb(variables._sql_code, false);

		return qR;
	}
		
</cfscript>
