<cfcomponent name="commonCode">
	<cfinclude template="cfinclude_commonCode.cfm">

	<cfscript>
		function isServerLocalHost() {
			return (LCASE(CGI.SERVER_NAME) eq LCASE(Request.const_localhost_symbol));
		}

		function isServerredactedDevHost() {
			return (LCASE(CGI.SERVER_NAME) eq LCASE(Request.const_redacted_dev_symbol));
		}

		function isUserDeveloper() {
			return (ListFindNoCase(Request.ownerIPs, CGI.REMOTE_ADDR, ",") gt 0);
		}

		function isServerLocal() {
			return ( (Request.commonCode.isServerLocalHost()) OR (LCASE(CGI.SERVER_NAME) eq LCASE('127.0.0.1')) OR (Request.commonCode.isUserDeveloper()) );
		}

		function fullyQualifiedURLprefix() {
			var s = CGI.SERVER_NAME;
			return 'http://' & s & '/' & Request.urlPrefix & '/';
		}

		function fullyQualifiedServerName() {
			var s = CGI.SERVER_NAME;
			return 'http://' & s & '/';
		}

		function suppressURLSlashSlash(urlA, urlB) {
			var _url = urlA;

			if ( (Right(_url, 1) eq '/') AND (Left(urlB, 1) eq '/') ) {
				_url = Left(_url, Len(_url) - 1);
			}
			return _url & urlB;
		}

		function filterCrLf(s) {
			return ReplaceList(s, '#Chr(13)#,#Chr(10)#', ',');
		}
	
		function filterQuotesForSQL(s) {
			return ReplaceNoCase(s, "'", "''", 'all');
		}
	
		function filterListVerbsForSQL(s) {
			return ReplaceNoCase(ReplaceNoCase(s, "=", "", 'all'), ",", "", 'all');
		}

		function hiddenInputsUsingStruct(stru) {
			var _html = '';
			var _item = '';
			var _value = '';
			var _list = '';

			for (_item in stru) {
				if (UCASE(_item) eq 'NOCACHE') {
					_value = CreateUUID();
				} else {
					_value = stru[_item];
				}
				_list = ListAppend(_list, _item, ',');
				_html = _html & '<input type="hidden" name="#_item#" value="#_value#">' & Request.Cr;
			}
			_html = _html & '<input type="hidden" name="_persistent_data_list" value="#_list#">' & Request.Cr;

			return _html;
		}

		function encodedEncryptedString(plainText) {
			var theKey = generateSecretKey('BLOWFISH');
			var _encrypted = encrypt(plainText, theKey, 'BLOWFISH', 'Hex');
			return chr(Len(theKey)) & theKey & chr(Len(_encrypted)) & _encrypted;
		}

		function decodeEncodedEncryptedString(eStr) {
			var ar = ArrayNew(1);
			var keyLen = Asc(Mid(eStr, 1, 1));
			var theKey = Mid(eStr, 2, keyLen);
			var encLen = Asc(Mid(eStr, keyLen + 2, 1));
			var encrypted = Mid(eStr, keyLen + 2 + 1, encLen);
			ar[1] = keyLen;
			ar[2] = theKey;
			ar[3] = encLen;
			ar[4] = encrypted;
			try {
				ar[5] = Decrypt(ar[4], ar[2], 'BLOWFISH', 'Hex');
			} catch (Any e) {
				ar[5] = 'ERROR - cannot decrypt your encrypted data.';
				writeOutput(Request.primitiveCode.cf_dump(ar, 'ar', false));
			}

			return ar;
		}

		function seedStructFromScopeUsingList(str, sco, lst, delim) {
			var i = -1;
			var ar = ListToArray(lst, delim);
			var n = ArrayLen(ar);
			var m = -1;
			var bool = false;

			if ( (IsStruct(str)) AND (n gt 0) ) {
				m = 0;
				for (i = 1; i lte n; i = i + 1) {
					bool = false;
					try {
						str[ar[i]] = sco[ar[i]];
					} catch (Any e) {
						bool = true;
					}
					if (NOT bool) {
						m = m + 1;
					}
				}
			}
			return m;
		}

		function generateRandomStrongPassword() {
			var lc_chars = 'aBCdefghkmn0pqrStUVWXYZ';  // 30%
			var uc_chars = UCASE(lc_chars);            // 25%
			var num_chars = '123456789';               // 30%
			var spec_chars = '@$%&*';                  // 15%
			var lenT = RandRange(8, 14, 'SHA1PRNG');
			var new_pwd = '';
			var i = -1;
			var coin_toss = -1;
			var len_toss = -1;

			for (i = 1; i lte lenT; i = i + 1) {
				coin_toss = RandRange(1, 100, 'SHA1PRNG');
				if (coin_toss lte 30) {
					len_toss = RandRange(1, Len(lc_chars), 'SHA1PRNG');
					new_pwd = new_pwd & Mid(lc_chars, len_toss, 1);
				} else if ( (coin_toss gt 30) AND (coin_toss lte 55) ) {
					len_toss = RandRange(1, Len(uc_chars), 'SHA1PRNG');
					new_pwd = new_pwd & Mid(uc_chars, len_toss, 1);
				} else if ( (coin_toss gt 55) AND (coin_toss lte 85) ) {
					len_toss = RandRange(1, Len(num_chars), 'SHA1PRNG');
					new_pwd = new_pwd & Mid(num_chars, len_toss, 1);
				} else if (coin_toss gt 85) {
					len_toss = RandRange(1, Len(spec_chars), 'SHA1PRNG');
					new_pwd = new_pwd & Mid(spec_chars, len_toss, 1);
				}
			}

			return new_pwd;
		}

		function queryStringUsingScope(sco) {
			var _item = '';
			var _value = '';
			var qS = '';

			if ( (IsStruct(sco)) AND (NOT StructIsEmpty(sco)) ) {
				for (_item in sco) {
					if (UCASE(_item) eq 'NOCACHE') {
						_value = CreateUUID();
					} else {
						_value = sco[_item];
					}
					qS = ListAppend(qS, _item & '=' & _value, '&');
				}
			}
			return qS;
		}

		function queryStringUsingScopeFromList(sco, lst, delim) {
			var qS = '';
			var i = -1;
			var _item = '';
			var _value = '';
			var ar = ListToArray(lst, delim);
			var n = ArrayLen(ar);

			if (n gt 0) {
				for (i = 1; i lte n; i = i + 1) {
					if (UCASE(_item) eq 'NOCACHE') {
						_value = CreateUUID();
					} else {
						try {
							_value = sco[_item];
						} catch (Any e) {
							_value = '';
						}
					}
					qS = ListAppend(qS, _item & '=' & _value, '&');
				}
			} else {
				return queryStringUsingScope(sco);
			}
			return qS;
		}

		function dotDotPrefixForFileNamed(_baseDir, _fileName) {
			var _basePath = '';
			var qQ = -1;
			var i = -1;

			_baseDir = ListDeleteAt(_baseDir, ListLen(_baseDir, '\'), '\');
			qQ = Request.primitiveCode.cf_directory('qCheckForFileName', _baseDir, _fileName);
			if (IsQuery(qQ)) {
				if (qQ.recordCount eq 0) {
					for (i = ListLen(_baseDir, '\'); i gt 0; i = i - 1) {
						_basePath = '../';
						_baseDir = ListDeleteAt(_baseDir, ListLen(_baseDir, '\'), '\');
						qQ = Request.primitiveCode.cf_directory('qCheckForFileName#i#', _baseDir, _fileName);
						if (IsQuery(qQ)) {
							if (qQ.recordCount gt 0) {
								break;
							}
						}
					}
				}
			}
			return _basePath;
		}

		function arrayToSQL_inClause(ar, delim) {
			var i = -1;
			var n = ArrayLen(ar);
			
			for (i = 1; i lte n; i = i + 1) {
				ar[i] = "'" & ar[i] & "'";
			}
			return ArrayToList(ar, delim);
		}
	
		function listToSQL_inClause(s, delim) {
			return arrayToSQL_inClause(ListToArray(s, delim), delim);
		}
	
		function _uniqueTimeBasedUUID(sep_ch) {
			return 	DateFormat(Now(), 'yyyymmdd') & sep_ch & TimeFormat(Now(), 'HHmmss') & sep_ch & GetTickCount();
		}

		function uniqueTimeBasedUUID() {
			return 	_uniqueTimeBasedUUID('.');
		}

		function uniqueTimeBasedUUIDVarName() {
			return 	_uniqueTimeBasedUUID('_');
		}

		function makeListIntoSQLList(_list) {
			var ar = ListToArray(_list, ',');
			var i = -1;
			var n = -1;

			n = ArrayLen(ar);
			for (i = 1; i lte n; i = i + 1) {
				ar[i] = "'" & ar[i] & "'";
			}
			
			return ArrayToList(ar, ',');
		}

		function captureMemoryMetrics() {
			var qMetrics = QueryNew('id, freeMemory, totalMemory, maxMemory, percentFreeAllocated, percentAllocated');
			var runtime = CreateObject('java','java.lang.Runtime').getRuntime();
			var freeMemory = runtime.freeMemory() / 1024 / 1024;
			var totalMemory = runtime.totalMemory() / 1024 / 1024;
			var maxMemory = runtime.maxMemory() / 1024 / 1024;
			var percentFreeAllocated = Round((freeMemory / totalMemory) * 100);
			var percentAllocated = Round((totalMemory / maxMemory ) * 100);
			
			QueryAddRow(qMetrics, 1);
			QuerySetCell(qMetrics, 'freeMemory', Round(freeMemory), qMetrics.recordCount);
			QuerySetCell(qMetrics, 'totalMemory', Round(totalMemory), qMetrics.recordCount);
			QuerySetCell(qMetrics, 'maxMemory', Round(maxMemory), qMetrics.recordCount);
	
			QuerySetCell(qMetrics, 'percentFreeAllocated', percentFreeAllocated, qMetrics.recordCount);
			QuerySetCell(qMetrics, 'percentAllocated', percentAllocated, qMetrics.recordCount);
			
			return qMetrics;
		}

		function myCreateODBCDateTime(dt) {
			var dt_mask = 'yyyy-mm-dd';
			var tm_mask = 'HH:mm:ss';
			return "CAST('#DateFormat(dt, dt_mask)# #TimeFormat(dt, tm_mask)#' as datetime)";
		}

		function secondsToHHMMSS(secs) {
			var hh = -1;
			var mm = -1;
			var ss = -1;
			var _secs = -1;
			var m = -1;
	
			m = (60 * 60);
			hh = Int(secs / m);
			_secs = secs - (hh * m);
			if (hh lt 10) {
				hh = '0' & hh;
			}
	
			m = 60;
			mm = Int(_secs / m);
			_secs = _secs - (mm * m);
			if (mm lt 10) {
				mm = '0' & mm;
			}
	
			ss = _secs;
			if (ss lt 10) {
				ss = '0' & ss;
			}
	
			return hh & ':' & mm & ':' & ss & ' (#secs# secs)';
		}

		function monthNameToNum(monthName) {
			var i = -1;
			
			for (i = 1; i lte 12; i = i + 1) {
				if (FindNoCase(monthName, MonthAsString(i)) gt 0) {
					return i;
				}
			}
			return -1;
		}

		function determineFormDates(bd, ed) {
			var t_date = -1;
	
			Request.form_begin_date = defaultBeginDateString();
			if (IsNumericDate(bd)) {
				Request.form_begin_date = bd;
			}
			Request._form_begin_date = ParseDateTime(Request.form_begin_date);
			Request.form_end_date = defaultEndDateString();
			if (IsNumericDate(ed)) {
				Request.form_end_date = ed;
			}
			Request._form_end_date = ParseDateTime(Request.form_end_date);
			if (DateCompare(Request._form_begin_date, Request._form_end_date) gt 0) {
				t_date = Request.form_begin_date;
				Request.form_begin_date = Request.form_end_date;
				Request.form_end_date = t_date;
			}
		}

		function explainError(_error) {
			var e = '';
			var v = '';
			var vn = '';
			var i = -1;
			var k = -1;
			var sCurrent = -1;
			var sId = -1;
			var sLine = -1;
			var sColumn = -1;
			var sTemplate = -1;
			var nTagStack = -1;
			var _content = '<ul>';
			var _ignoreList = '<remoteAddress>, <browser>, <dateTime>, <HTTPReferer>, <diagnostics>, <TagContext>';
			var _specialList = '<StackTrace>';
			var content_specialList = '';
			var aToken = '';
			var special_templatesList = ''; // comma-delimited list or template keywords
			
			for (e in _error) {
				if (FindNoCase('<#e#>', _ignoreList) eq 0) {
					v = '--- UNKNOWN --';
					vn = "_error." & e;
	
					if (IsDefined(vn)) {
						v = Evaluate(vn);
					}
	
					if (FindNoCase('<#e#>', _specialList) neq 0) {
						v = '<textarea cols="100" rows="20" readonly style="font-size: 10px;">#v#</textarea>';
						content_specialList = content_specialList & '<li><b>#e#</b>&nbsp;#v#</li>';
					} else {
						_content = _content & '<li><b>#e#</b>&nbsp;#v#</li>';
					}
				}
			}
			nTagStack = ArrayLen(_error.TAGCONTEXT);
			_content = _content &	'<li><p><b>The contents of the tag stack are: nTagStack = [#nTagStack#] </b>';
			try {
				for (i = 1; i neq nTagStack; i = i + 1) {
					sCurrent = _error.TAGCONTEXT[i];
					sId = sCurrent["ID"];
					sLine = sCurrent["LINE"];
					sColumn = sCurrent["COLUMN"];
					sTemplate = sCurrent["TEMPLATE"];
					Request.isSpecialTemplate = false;
					for (k = 1; k lte ListLen(special_templatesList, ','); k = k + 1) {
						aToken = Request.commonCode._GetToken(special_templatesList, k, ',');
						if (FindNoCase(aToken, sTemplate) gt 0) {
							Request.isSpecialTemplate = true;
						}
					}
					_content = _content &	'<br>#i# #sId#' &  '(#sLine#,#sColumn#)' & '#sTemplate#' & '.';
				}
			} catch (Any ee) {
			}
			_content = _content & '</p></li>';
			_content = _content & content_specialList;
			_content = _content & '</ul>';
			
			return _content;
		}

		function filterRawDataOutOfQuery(q, colName) {
			var i = -1;

			if ( (isServerLocalHost()) OR (isServerredactedDevHost()) ) {
				if ( (IsQuery(q)) AND (Len(Trim(colName)) gt 0) ) {
					for (i = 1; i lte q.recordCount; i = i + 1) {
						try {
							if (Len(Trim(q[colName][i])) gt 0) {
								q[colName][i] = '';
							}
						} catch (Any e) {
						}
					}
				}
			}
			return q;
		}

		function debugArray(a) {
			var t = '';
	
			t = t & '[';
			for (n = 1; n lte ArrayLen(a); n = n + 1) {
				t = t & '(' & a[n] & ')';
				if (n lt ArrayLen(a)) {
					t = t & ', ';
				}
			}
			t = t & ']' & Chr(13);
			return t;
		}

		function searchInQueryForString(q, str, str2, member, bool_direction) {
			var i = -1;
			var d = -1;
			var bool = false;
			var varName = '';
			var varVal = '';
			
			if (IsQuery(q)) {
				if (bool_direction) {
					for (i = 1; i lte q.recordCount; i = i + 1) {
						varName = 'q.' & member & '[#i#]';
						try {
							varVal = Evaluate(varName);
						} catch (Any e) {
							varVal = '';
						}
						bool = false;
						if ( (Len(str) gt 0) AND (Len(str2) gt 0) ) {
							bool = ( (FindNoCase(str, varVal) gt 0) AND (FindNoCase(str2, varVal) gt 0) );
						} else {
							bool = (FindNoCase(str, varVal) gt 0);
						}
						if (bool) {
							return varVal;
						} else {
							varVal = ''; // flag the response to return nothing...
						}
					}
				} else {
					for (i = q.recordCount; i gte 1; i = i - 1) {
						varName = 'q.' & member & '[#i#]';
						try {
							varVal = Evaluate(varName);
						} catch (Any e) {
							varVal = '';
						}
						bool = false;
						if ( (Len(str) gt 0) AND (Len(str2) gt 0) ) {
							bool = ( (FindNoCase(str, varVal) gt 0) AND (FindNoCase(str2, varVal) gt 0) );
						} else {
							bool = (FindNoCase(str, varVal) gt 0);
						}
						if (bool) {
							return varVal;
						} else {
							varVal = ''; // flag the response to return nothing...
						}
					}
				}
			}
			return varVal;
		}

		function filterOutCharsNotOneOfThese(s, chSet) {
			var i = -1;
			var n = -1;
			var t = '';
			var _ch = '';
			
			s = Trim(s);
			n = Len(s);
			for (i = 1; i lte n; i = i + 1) {
				_ch = Mid(s, i, 1);
				if (FindOneOf(chSet, _ch) gt 0) {
					t = t & _ch;
				}
			}
			return t;
		}

		function countCharsFromSet(s, chSet) {
			var i = 1;
			var j = 1;
			var n = -1;
			var numCh = -1;
			var a = ArrayNew(1);
			
			s = Trim(s);
			n = Len(s);
			while (i lte n) {
				numCh = Len(s) - j;
				if (numCh gt 0) {
					i = FindOneOf(chSet, Mid(s, j, numCh));
					if (i eq 0) {
						break;
					} else {
						a[ArrayLen(a) + 1] = i;
					}
					j = j + i + 1;
				} else {
					break;
				}
			}
			return a;
		}

		function fixupArrayItems(a, delim, xCnt) {
			var i = -1;
			var j = -1;
			var n = -1;
			var _item = -1;
			var newArray = ArrayNew(1);
			
			for (i = 1; i lte ArrayLen(a); i = i + 1) {
				n = ListLen(a[i], delim);
				if (n eq xCnt) {
					for (j = 1; j lte n; j = j + 1) {
						_item = Request.commonCode._GetToken(a[i], j, delim);
						newArray[i + j - 1] = _item;
					}
					break;
				}
				newArray[i] = a[i];
			}
			return newArray;
		}

		function xmlNodeWalker(xml_nodes, _tabsCount, bool_output) {
			var i = -1;
			var isError = false;
			var _xmlText = '';
			var _xmlText_ = '';
			var _xmlParent_flag = '';
			var s_output = '';
			var _tabs = '';
			var ch_tabs = '&nbsp;';
			var ch_Cr = '<br>';
			
			if (NOT IsBoolean(bool_output)) {
				bool_output = false;
			}
			
			if (NOT bool_output) {
				ch_tabs = ' ';
				ch_Cr = Chr(13);
			}
			
			_tabs = RepeatString(ch_tabs, Max(_tabsCount, 1));
			
			if (IsArray(xml_nodes)) {
				for (i = 1; i lte ArrayLen( xml_nodes); i = i + 1) {
					isError = false;
					try {
						if (IsArray( xml_nodes[i].xmlNodes)) {
							if (Len(Trim(xml_nodes[i].XmlText)) eq 0) {
								if (bool_output) {
									writeOutput(_tabs & '<span class="normalStatusClass">' & '[#xml_nodes[i].XmlName#]' & '</span>' & ch_Cr);
								} else {
									s_output = s_output & _tabs & '[#xml_nodes[i].XmlName#]' & ch_Cr;
								}
							}
							s_output = s_output & xmlNodeWalker(xml_nodes[i].xmlNodes, _tabsCount + 8, bool_output);
						}
					} catch (Any e) {
						isError = true;
					}
					if (NOT isError) {
						_xmlText = '';
						_xmlText_ = '';
						_xmlParent_flag = '';
						if (Len(Trim(xml_nodes[i].XmlText)) gt 0) {
							_xmlText_ = xml_nodes[i].XmlText;
							_xmlText = ' = [#_xmlText_#]';
						} else {
							_xmlParent_flag = '**';
						}
						if (Len(Trim(_xmlParent_flag)) eq 0) {
							if (bool_output) {
								writeOutput(_tabs & '<span class="boldStatusClass">' & '[#xml_nodes[i].XmlName#]#_xmlText#' & '</span>' & ch_Cr);
							} else {
								s_output = s_output & _tabs & '[#xml_nodes[i].XmlName#]#_xmlText#' & ch_Cr;
							}
						}
					}
				}
			}
			return s_output;
		}
	
		function appendFTPLogActivity(tbName, the_dt, log_msg) {
			var sql_statement = '';
			var qq = -1;
			
			sql_statement = "INSERT INTO #tbName# (fid, lid, the_dt, log_msg) VALUES (#Request._fid#,#Request._lid#,#CreateODBCDateTime(the_dt)#,'#ReplaceNoCase(log_msg, "'", "''", 'all')#')";
			qq = Request.primitiveCode.safely_execSQL('AppendFTPLog', Request.DSN, sql_statement);
			return qq;
		}
	
		function appendFTPLogActivityCache(q, the_dt, log_msg) {
			if (IsQuery(q)) {
				if ( (NOT Request.bool_inhibit_logfile_cache_during_process_new) OR ( (Request._lid eq -1) AND (Request._fid eq -1) ) ) {
					QueryAddRow(q, 1);
					QuerySetCell(q, 'id', q.recordCount, q.recordCount);
					QuerySetCell(q, 'the_dt', the_dt, q.recordCount);
					QuerySetCell(q, 'log_msg', log_msg, q.recordCount);
				} else if (Len(Trim(Request.tbName)) gt 0) {
					appendFTPLogActivity(Request.tbName, the_dt, log_msg);
				}
				if (NOT Request.bool_inhibit_writeOutput_during_process_new) {
					writeOutput(log_msg & '<br>');
					Request.primitiveCode.cf_flush();
				}
				return true;
			}
			return false;
		}

		function initCachedLog() {
			return QueryNew('id, the_dt, log_msg', 'integer, date, varchar');
		}

		function _initCachedLog(tbName) {
			Request.tbName = tbName;
			return Request.commonCode.initCachedLog();
		}

		function dumpCachedLog2DbLog(q, tbName) {
			var i = -1;
			
			if (IsQuery(q)) {
				if ( (NOT Request.bool_inhibit_logfile_cache_during_process_new) OR (q.recordCount gt 0) ) {
					for (i = 1; i lte q.recordCount; i = i + 1) {
						appendFTPLogActivity(tbName, q.the_dt[i], q.log_msg[i]);
					}
				}
			}
			if (Len(Trim(Request.tbName)) gt 0) {
				return _initCachedLog(Request.tbName);
			} else {
				return initCachedLog();
			}
		}
	
		function getListFromQueryColumn(q, colName, delim) {
			var i = -1;
			var _list = '';
			
			if (IsQuery(q)) {
				for (i = 1; i lte q.recordCount; i = i + 1) {
					try {
						varVal = Evaluate('q.#colName#[i]');
					} catch (Any e) {
						varVal = '';
					}
					_list = ListAppend(_list, varVal, delim);
				}
			}
			return _list;
		}
	
		function tohex(inval) {
			var hexchars = "0123456789ABCDEF";
			return Mid(hexchars, Int(inval/16) + 1, 1) & Mid(hexchars, (inval mod 16) + 1, 1);
		}

		function anchor_pre(_name, _title) {
			return '<a id="' & _name & '" title="' & _title & '" onmouseover="this.style.cursor = const_cursor_hand;" onmouseout="this.style.cursor = const_cursor_default;">';
		}

		function describeQuery(q, i) {
			var j = -1;
			var cols = -1;
			var nCols = -1;
			var t = '';
	
			if (IsQuery(q)) {
				cols = ListToArray(q.columnList, ',');
				nCols = ArrayLen(cols);
				t = t & '<table width="100%" border="1" cellpadding="-1" cellspacing="-1">';
				t = t & '<tr>';
				t = t & '<td>';
				t = t & '<table width="100%" cellpadding="-1" cellspacing="-1">';
				t = t & '<tr bgcolor="silver" valign="top">';
				for (j = 1; j lte nCols; j = j + 1) {
					t = t & '<td class="listItemClass">';
					t = t & cols[j];
					t = t & '</td>';
				}
				t = t & '</tr>';
				t = t & '<tr valign="top">';
				for (j = 1; j lte nCols; j = j + 1) {
					t = t & '<td class="listItemClass">';
					t = t & q[cols[j]][i];
					t = t & '</td>';
				}
				t = t & '</tr>';
				t = t & '</table>';
				t = t & '</td>';
				t = t & '</tr>';
				t = t & '</table>';
			}
			return t;
		}

		function describeStatsArray(q, lDate, a, k, bool, dDays, _bool) {
			var j = -1;
			var n = -1;
			var jj = -1;
			var kk = -1;
			var nn = -1;
			var aa = -1;
			var ch = '';
			var ex = 0;
			var aDate = '';
			var fmtDate = '';
			var dowStr = '';
			var bool_isDate = false;
			var firstDate = '';
			var skippingDays = '';
			var a_skippingDays = -1;
			var _chColor = '';
			var _noDataColor = 'red';
			var _hasDataColor = 'lime';
			var _chNBSP = '&nbsp;';
			var bool_firstGreen = false;
			var _fgColor = '';
			var _fgColor_pre = '';
			var _fgColor_post = '';
			var _anchor_post = '</a>';
			var _status = '';
			var _styleClass = '';
			var bgWashOut = -1;
			var thisHour = -1;
			var nAfterThisHour = -1;
			var pAfterThisHour = -1;
			var _pAfterThisHour = -1;
			var rowColor = -1;
			var footerColor = '##FFFFB9';
			var rangeColor = '##B46767';
			var ca = ArrayNew(1);
	
			if (IsArray(a)) {
				thisHour = Hour(Now());
				thisColor = '##00ff00'; // has happened - happy color... (green)
				if (NOT bool) {
					thisColor = '##ff0000'; // has NOT happened - sad color... (red)
					// compute the percentage of instances that have happened historically after thisHour
					// use the percentage to increase the blue/green to wash out the red a bit...
					nAfterThisHour = 0;
					n = ArrayLen(a);
					for (j = 1; j lte n; j = j + 1) {
						aa = a[j];
						nn = ArrayLen(aa);
						if (j lte dDays) {
							for (jj = thisHour + 1; jj lte nn; jj = jj + 1) {
								if (aa[jj] gt -1) {
									nAfterThisHour = nAfterThisHour + aa[jj];
								}
							}
						}
					}
					_pAfterThisHour = (nAfterThisHour / k);
					pAfterThisHour = _pAfterThisHour * 100.0;
					bgWashOut = Request.commonCode.tohex(Int(_pAfterThisHour * 255));
					thisColor = '##ff#bgWashOut##bgWashOut#'; // has NOT happened - sad color... (redish)
				}
				Request.thisColor_ftpServerAnalysis = thisColor; // expose the color so it can be used on the home page, for isntance...
	
				if (_bool) writeOutput('<table width="100%" border="1" cellpadding="-1" cellspacing="-1">');
				if (_bool) writeOutput('<tr>');
				if (_bool) writeOutput('<td>');
				n = ArrayLen(a);
				if (_bool) writeOutput('<table width="100%" border="1" cellpadding="-1" cellspacing="-1">');
				if (_bool) writeOutput('<tr bgcolor="silver">');
				aa = a[1]; // sample the structure of the inner array...
				nn = ArrayLen(aa);
				if (_bool) writeOutput('<td bgcolor="#footerColor#" width="25px" align="center" class="listItemClass">' & 'Day' & '</td>');
				for (jj = 1; jj lte nn; jj = jj + 1) {
					ca[jj] = 0;
					ch = '&nbsp;Hour<br>' & jj;
					if (_bool) {
						_chColor = '';
						_styleClass = 'listItemClass';
						if (jj eq thisHour) {
							_chColor = ' bgcolor="' & thisColor & '"';
							_styleClass = 'listItemBorderedClass';
							ch = '<b>' & ch & '</b>';
						}
						writeOutput('<td width="20px"' & _chColor & ' align="center" class="' & _styleClass & '">' & ch & '</td>');
					}
				}
				if (_bool) writeOutput('</tr>');
				skippingDays = '';
				bool_firstGreen = false;
				a_skippingDays = ArrayNew(1);
				for (j = 1; j lte n; j = j + 1) {
					aa = a[j];
					nn = ArrayLen(aa);
					rowColor = '';
					if (j gt dDays) {
						rowColor = rangeColor;
					}
					if (_bool) writeOutput('<tr bgcolor="#rowColor#">');
					ch = '';
					for (jj = 1; jj lte nn; jj = jj + 1) {
						if (aa[jj] gt -1) {
							ch = aa[jj];
							break;
						}
					}
					_status = '';
					_chColor = _hasDataColor;
					_fgColor = '';
					_fgColor_pre = '';
					_fgColor_post = '';
					if (Len(ch) eq 0) {
						_chColor = _noDataColor;
						_status = ' NOT';
						_fgColor = 'white';
						_fgColor_pre = '<font color="#_fgColor#">';
						_fgColor_post = '</font>';
						if (j gt dDays) {
							_chColor = rowColor;
							_status = '';
						}
					} else {
						bool_firstGreen = true;
					}
					if (_bool) {
						aDate = DateAdd('d', (-j + 1), lDate);
						dowStr = DateFormat(aDate, 'ddd');
						fmtDate = DateFormat(aDate, 'mm/dd/yyyy') & ' ' & dowStr;
						if (_chColor neq rowColor) {
							fmtDate = fmtDate & ' FTP Download did' & _status & ' happen.';
							if (bool_firstGreen) {
								if ( (Len(_status) gt 0) AND (FindNoCase(dowStr, skippingDays) eq 0) ) {
									skippingDays = skippingDays & dowStr & ',';
								}
								a_skippingDays[ArrayLen(a_skippingDays) + 1] = aDate;
							}
						} else if (_chColor eq rowColor) {
							fmtDate = fmtDate & ' Date out of range - no historical FTP Download Activity for this date.';
						}
						writeOutput('<td bgcolor="#_chColor#" align="center" class="listItemClass">' & Request.commonCode.anchor_pre('anchor_row_tooltip_#j#', fmtDate) & _fgColor_pre & (-j + 1) & _fgColor_post & _anchor_post & '</td>');
					}
					for (jj = 1; jj lte nn; jj = jj + 1) {
						ch = _chNBSP;
						if (aa[jj] gt -1) {
							ch = aa[jj];
							ex = ex + ch;
							ca[jj] = ca[jj] + ch;
						}
						bgColor = '';
						_styleClass = 'listItemClass';
						if (jj eq thisHour) {
							bgColor = thisColor;
							ch = '<b>' & ch & '</b>';
							_styleClass = 'listItemBorderedClass';
						} else if (ch neq _chNBSP) {
							bgColor = _hasDataColor;
						}
						if (Len(rowColor) gt 0) {
							bgColor = '';
						}
						if (_bool) {
							if ( (ch neq _chNBSP) AND (jj neq thisHour) ) {
								fmtDate = ' Download was successful ' & ch & ' time(s) during this hour which could mean a total of ' & ch & ' file(s) were downloaded at this time.';
								ch = Request.commonCode.anchor_pre('anchor_download_instance_tooltip_#j#', fmtDate) & ch & _anchor_post;
							}
							writeOutput('<td bgcolor="#bgColor#" align="center" class="' & _styleClass & '">' & ch & '</td>');
						}
					}
					if (_bool) writeOutput('</tr>');
				}
				if (_bool) writeOutput('<tr bgcolor="#footerColor#">');
				if (_bool) writeOutput('<td align="center" class="listItemClass">' & _chNBSP & '</td>');
				for (jj = 1; jj lte nn; jj = jj + 1) {
					ch = _chNBSP;
					if (ca[jj] gt 0) {
						ch = ca[jj];
					}
					if (_bool) {
						if (ch neq _chNBSP) {
							fmtDate = ' Download was successful ' & ch & ' time(s) during this hour as a total value of all activity for all days shown.';
							ch = Request.commonCode.anchor_pre('anchor_download_total_tooltip_#j#', fmtDate) & ch & _anchor_post;
						}
						_styleClass = 'listItemClass';
						if (jj eq thisHour) {
							_styleClass = 'listItemBorderedClass';
							if (ch neq _chNBSP) {
								ch = '<b>' & ch & '</b>';
							}
						}
						writeOutput('<td align="center" class="' & _styleClass & '">' & ch & '</td>');
					}
				}
				if (_bool) writeOutput('</tr>');
				if (_bool) writeOutput('</table>');
				if (_bool) writeOutput('</td>');
				if (_bool) writeOutput('</tr>');
				if (_bool) writeOutput('<tr>');
				if (_bool) writeOutput('<td bgcolor="#footerColor#" class="listItemClass">');
				if (_bool) writeOutput('Expected #ex# verified download sessions out of #k# possible.');
				if (_bool) writeOutput('<br>');
				if (NOT bool) {
					if (_bool) writeOutput(' <b>Analysis:</b> The Download Session has <b>NOT happened yet today</b> and there is a <b>' & DecimalFormat(pAfterThisHour) & '%' & '</b> it may happen sometime today.<br><i>(A darker red color indicates a lower chance of the download event happening sometime today.)</i>');
				} else {
					if (_bool) writeOutput(' <b>Analysis:</b> The Download Session has happened today therefore the system appears to be healthy.');
				}
				if (Len(Trim(skippingDays)) gt 0) {
					skippingDays = Left(skippingDays, Len(skippingDays) - 1);
					writeOutput('<br><b>Missing Downloads Analysis:</b> Downloads have NOT been happening on these days of the week: (#skippingDays#), exclusing those days that are out of range or before the first successful download.  The Missing Downloads Analysis provides a means of determining whether there is a pattern to the instances of failed downloads for any given day of the week.<br>');
				}
				if (_bool) writeOutput('</td>');
				if (_bool) writeOutput('</tr>');
				if (_bool) writeOutput('</table>');
			}
		}

		function _performFtpServerAnalysis(_sys, _const_6_day_symbol, bool) {
			var i = -1;
			var k = -1;
			var _td = -1;
			var _days = -1;
			var _hour = -1;
			var _slotNum = -1;
			var first_id = -1;
			var second_id = -1;
			var _lastDate = -1;
			var _defaultMap = -1;
			var _aDayBucket = -1;
			var displayableDays = -1;
			var _sql_statement_1 = -1;
			var _sql_statement_2 = -1;
			var _sql_statement_3 = -1;
			var _sql_statement_Z = -1;
			var bool_happened_today = -1;
	
			Request.statsQ = QueryNew('id, the_dt', 'integer, date');
			_days = ArrayNew(1);
		
			if (UCASE(_sys) eq UCASE(_const_6_day_symbol)) {
				_sql_statement_1 = "SELECT id, the_dt, log_msg FROM IML_FTP_LOG WHERE (UPPER(log_msg) LIKE UPPER('%attempt to downloaded temp file%')) ORDER BY the_dt";
				_sql_statement_2 = "SELECT id, the_dt, log_msg FROM IML_FTP_LOG WHERE (UPPER(log_msg) LIKE UPPER('%downloaded temp file%')) ORDER BY the_dt";
				_sql_statement_3 = "SELECT id, the_dt, log_msg FROM IML_FTP_LOG WHERE (UPPER(log_msg) LIKE UPPER('%stored ftp data%')) ORDER BY the_dt";
			} else {
				_sql_statement_1 = "SELECT id, the_dt, log_msg FROM TIBCO_FTP_LOG WHERE (log_msg LIKE '%About to fetch (%)%') ORDER BY the_dt";
				_sql_statement_2 = "SELECT id, the_dt, log_msg FROM TIBCO_FTP_LOG WHERE (log_msg LIKE '%Stored Raw Data%') ORDER BY the_dt";
				_sql_statement_3 = "SELECT id, the_dt, log_msg FROM TIBCO_FTP_LOG WHERE (log_msg LIKE '%Stored !%') ORDER BY the_dt";
			}
		
			Request.q1 = Request.primitiveCode.safely_execSQL('QueryLogs1' & Request.excelReader.filterAlphaNumeric(_sys), Request.DSN, _sql_statement_1, CreateTimeSpan(0, 0, 0, 120));
			if (NOT Request.dbError) {
				Request.q2 = Request.primitiveCode.safely_execSQL('QueryLogs2' & Request.excelReader.filterAlphaNumeric(_sys), Request.DSN, _sql_statement_2, CreateTimeSpan(0, 0, 0, 120));
				if (NOT Request.dbError) {
					Request.q3 = Request.primitiveCode.safely_execSQL('QueryLogs3' & Request.excelReader.filterAlphaNumeric(_sys), Request.DSN, _sql_statement_3, CreateTimeSpan(0, 0, 0, 120));
					if (NOT Request.dbError) {
						i = 1;
						first_id = -1;
						second_id = -1;
						do {
							if (Request.q1.recordCount gt i) {
								first_id = Request.q1.id[i];
								second_id = Request.q1.id[i + 1];
			
								_sql_statement_2a = "SELECT id, the_dt, log_msg FROM Request.q2 WHERE (id >= #first_id#) AND (id < #second_id#) ORDER BY the_dt";
								Request.q2a = Request.primitiveCode.safely_execSQL('QueryLogs2a#i#', '', _sql_statement_2a);
								if (NOT Request.dbError) {
									_sql_statement_3a = "SELECT id, the_dt, log_msg FROM Request.q3 WHERE (id >= #first_id#) AND (id < #second_id#) ORDER BY the_dt";
									Request.q3a = Request.primitiveCode.safely_execSQL('QueryLogs3a#i#', '', _sql_statement_3a);
									if (NOT Request.dbError) {
										if ( (IsQuery(Request.q2a)) AND (IsQuery(Request.q3a)) ) {
											if ( (Request.q2a.recordCount gt 0) AND (Request.q3a.recordCount gt 0) ) {
												QueryAddRow(Request.statsQ, 1);
												QuerySetCell(Request.statsQ, 'id', Request.statsQ.recordCount, Request.statsQ.recordCount);
												QuerySetCell(Request.statsQ, 'the_dt', Request.q1.the_dt[i], Request.statsQ.recordCount);
											}
										}
									}
								}
							}
							i = i + 1;
						} while ((i + 1) lt Request.q1.recordCount);
	
						if (Request.statsQ.recordCount gt 0) {
							_lastDate = Now();
							displayableDays = DateDiff('d', Request.statsQ.the_dt[1], _lastDate) + 1;
							if (displayableDays gt 31) {
								displayableDays = 31;
							}
	
							if (bool) writeOutput('IML #_sys# FTP Server :: Displaying ' & displayableDays & ' days of the moving 31 day window.<br>');
							
							_defaultMap = ArrayNew(1);
							for (i = 1; i lte 24; i = i + 1) {
								_defaultMap[i] = -1;
							}
			
							for (i = 1; i lte 31; i = i + 1) {
								_days[i] = _defaultMap;
							}
			
							i = Request.statsQ.recordCount;
							k = 0;
							do {
								_slotNum = DateDiff('d', Request.statsQ.the_dt[i], _lastDate) + 1;
								if (_slotNum gt 31) {
									_slotNum = 31; // limit this to no more than 31 days...
								}
								_hour = Hour(Request.statsQ.the_dt[i]);
								if (_hour eq 0) {
									_hour = 24; // there can be no 0 hour so this must be 12:00 am which is also 00:00 hrs or 24 on our chart...
								}
								try {
									_aDayBucket = _days[_slotNum];
									if (_aDayBucket[_hour] lt 0) {
										_aDayBucket[_hour] = 1;
									} else {
										_aDayBucket[_hour] = _aDayBucket[_hour] + 1;
									}
									_days[_slotNum] = _aDayBucket;
									i = i - 1;
									k = k + 1;
								} catch (Any e) {
									writeOutput(Request.primitiveCode.cf_dump(e, 'e - Programming ERROR - This can never happen unless the silly programmer was asleep when this was written !  Wake up already !!!', false));
									break;
								}
							} while ( (_slotNum lte 31) AND (i gt 0) );
			
							// what time is it now ?
							// has the download happened yet today ?
							bool_happened_today = false;
							_td = CreateODBCDateTime(ParseDateTime(DateFormat(Now(), 'mm/dd/yyyy')));
							_sql_statement_Z = "SELECT id, the_dt FROM Request.statsQ WHERE (the_dt >= #_td#) ORDER BY the_dt"; //  AND (the_dt <= #_td#)
							Request.qZ = Request.primitiveCode.safely_execSQL('QueryLogsZ', '', _sql_statement_Z);
							if (NOT Request.dbError) {
								if (Request.qZ.recordCount gt 0) {
									bool_happened_today = true;
								}
							}
							Request.commonCode.describeStatsArray(Request.statsQ, _lastDate, _days, k, bool_happened_today, displayableDays, bool);
						} else {
							if (bool) writeOutput('<span class="errorStatusClass">Analysis of IML #_sys# FTP Server is NOT possible at this time due to some kind of system failure...</span><br>');
						}
					} else {
						writeOutput('<span class="errorStatusClass">Analysis of IML #_sys# FTP Server is NOT possible at this time due to the following: ' & Request.errorMsg & '</span>');
					}
				} else {
					writeOutput('<span class="errorStatusClass">Analysis of IML #_sys# FTP Server is NOT possible at this time due to the following: ' & Request.errorMsg & '</span>');
				}
			} else {
				writeOutput('<span class="errorStatusClass">Analysis of IML #_sys# FTP Server is NOT possible at this time due to the following: ' & Request.errorMsg & '</span>');
			}
		}

		function performFtpServerAnalysis(_sys, _const_6_day_symbol, bool) {
			var i = -1;
			var k = -1;
			var _td = -1;
			var dt = -1;
			var tbName = '';
			var _days = -1;
			var _hour = -1;
			var _slotNum = -1;
			var _lastDate = -1;
			var _defaultMap = -1;
			var _aDayBucket = -1;
			var displayableDays = -1;
			var _sql_statement_1 = -1;
			var _sql_statement_Z = -1;
			var bool_happened_today = -1;
	
			if (UCASE(_sys) eq UCASE(Request.const_6_day_symbol)) {
				tbName = 'IML_FTP_PROCESS_VALIDATION';
			} else {
				tbName = 'TIBCO_FTP_PROCESS_VALIDATION';
			}
	
			Request.statsQ = QueryNew('id, the_dt', 'integer, date');
			_days = ArrayNew(1);
			Request.thisColor_ftpServerAnalysis = '##c0c0c0';
			// the 31-day reports are being handled very differently now so perform the check differently now...
			_sql_statement_1 = "SELECT id, dt_validated, dt_processed, dt_bytesValidated FROM #tbName# WHERE (dt_validated IS NOT NULL) AND (dt_processed IS NOT NULL) AND (dt_bytesValidated IS NOT NULL) ORDER BY dt_bytesValidated";
			Request.q1 = Request.primitiveCode.safely_execSQL('QueryLogs1_31' & Request.excelReader.filterAlphaNumeric(_sys), Request.DSN, _sql_statement_1);
			if (NOT Request.dbError) {
				if (Request.q1.recordCount gt 0) {
					for (i = 1; i lte Request.q1.recordCount; i = i + 1) {
						dt = Request.q1.dt_validated[i];
						if (DateCompare(Request.q1.dt_processed[i], dt) gt 0) {
							dt = Request.q1.dt_processed[i];
							if (DateCompare(Request.q1.dt_bytesValidated[i], dt) gt 0) {
								dt = Request.q1.dt_bytesValidated[i];
							}
						}
						QueryAddRow(Request.statsQ, 1);
						QuerySetCell(Request.statsQ, 'id', Request.statsQ.recordCount, Request.statsQ.recordCount);
						QuerySetCell(Request.statsQ, 'the_dt', dt, Request.statsQ.recordCount);
					}
					_lastDate = Now();
					displayableDays = DateDiff('d', Request.statsQ.the_dt[1], _lastDate) + 1;
					if (displayableDays gt 31) {
						displayableDays = 31;
					}
	
					if (bool) writeOutput('IML #_sys# FTP Server :: Displaying ' & displayableDays & ' days of the moving 31 day window.<br>');
					
					_defaultMap = ArrayNew(1);
					for (i = 1; i lte 24; i = i + 1) {
						_defaultMap[i] = -1;
					}
	
					for (i = 1; i lte 31; i = i + 1) {
						_days[i] = _defaultMap;
					}
	
					i = Request.statsQ.recordCount;
					k = 0;
					do {
						_slotNum = DateDiff('d', Request.statsQ.the_dt[i], _lastDate) + 1;
						if (_slotNum gt 31) {
							_slotNum = 31; // limit this to no more than 31 days...
						}
						_hour = Hour(Request.statsQ.the_dt[i]);
						if (_hour eq 0) {
							_hour = 24; // there can be no 0 hour so this must be 12:00 am which is also 00:00 hrs or 24 on our chart...
						}
						try {
							_aDayBucket = _days[_slotNum];
							if (_aDayBucket[_hour] lt 0) {
								_aDayBucket[_hour] = 1;
							} else {
								_aDayBucket[_hour] = _aDayBucket[_hour] + 1;
							}
							_days[_slotNum] = _aDayBucket;
							i = i - 1;
							k = k + 1;
						} catch (Any e) {
							writeOutput(Request.primitiveCode.cf_dump(e, 'e - Programming ERROR - This can never happen unless the silly programmer was asleep when this was written !  Wake up already !!!', false));
							break;
						}
					} while ( (_slotNum lte 31) AND (i gt 0) );
	
					// what time is it now ?
					// has the download happened yet today ?
					bool_happened_today = false;
					_td = CreateODBCDateTime(ParseDateTime(DateFormat(Now(), 'mm/dd/yyyy')));
					_sql_statement_Z = "SELECT id, the_dt FROM Request.statsQ WHERE (the_dt >= #_td#) ORDER BY the_dt"; //  AND (the_dt <= #_td#)
					Request.qZ = Request.primitiveCode.safely_execSQL('QueryLogsZ', '', _sql_statement_Z);
					if (NOT Request.dbError) {
						if (Request.qZ.recordCount gt 0) {
							bool_happened_today = true;
						}
					}
					Request.commonCode.describeStatsArray(Request.statsQ, _lastDate, _days, k, bool_happened_today, displayableDays, bool);
				}
			} else {
				writeOutput('<span class="errorStatusClass">Analysis of IML #_sys# FTP Server is NOT possible at this time due to the following: ' & Request.errorMsg & '</span>');
			}
			return;
		}

		function schedulerLogLatestInfoFor(procName) {
			var logContents = '';
			var _details = '';
			var _qq = -1;
			var exec_msg = '';
			var resched_msg = '';
			var const_exec_symbol = 'Executing at ';
			var const_resched_symbol = 'Rescheduling for ';
			
			if (FileExists(Request.schedulerLogPath)) {
				logContents = Request.primitiveCode.safely_cffile(Request.schedulerLogPath);
				_qq = Request.excelReader.str2Query(logContents, Request.Cr, Request.Lf);
				exec_msg = searchInQueryForString(_qq, '[#procName#]', const_exec_symbol, 'data', false);
				resched_msg = searchInQueryForString(_qq, '[#procName#]', const_resched_symbol, 'data', false);
				_details = exec_msg;
				if (Len(_details) gt 0) {
					_details = _details & '<br>';
				}
				_details = _details & resched_msg;
			} else {
				Request.primitiveCode.safely_cfmail(Request.ErrorEmail, Request.const_do_not_reply_symbol, 'Missing the file named "#Request.schedulerLogPath#"', '"#Request.schedulerLogPath#" is missing or cannot be found due to a bad file name.');
			}
			return _details;
		}

		function tibcoFTPDownloader2LatestInfo() {
			var s = '';
			var _msg = '';
			var _qq = -1;
			var qQ = -1;
			var _baseDir = '';
			var _fname = '';
			if (FileExists(Request.tibcoFTPDownloader2ActivityPath)) {
				s = Trim(Request.primitiveCode.safely_cffile(Request.tibcoFTPDownloader2ActivityPath));
				_qq = Request.excelReader.str2Query(s, Request.Cr, Request.Lf);
				_msg = searchInQueryForString(_qq, '&_shortName=', '', 'data', true);
			} else {
			//	Request.primitiveCode.safely_cfmail(Request.ErrorEmail, Request.const_do_not_reply_symbol, 'Missing the file named "#Request.tibcoFTPDownloader2ActivityPath#"', '"#Request.tibcoFTPDownloader2ActivityPath#" is missing or cannot be found due to a bad file name.');
			}
			return _msg;
		}

		function tibcoFTPDownloader2LatestDate() {
			var _msg = '';
			var qQ = -1;
			var _baseDir = '';
			var _fname = '';
			
			if (FileExists(Request.tibcoFTPDownloader2ActivityPath)) {
				_msg = '';
				_baseDir = GetDirectoryFromPath(Request.tibcoFTPDownloader2ActivityPath);
				_fname = GetFileFromPath(Request.tibcoFTPDownloader2ActivityPath);
				qQ = Request.primitiveCode.cf_directory('qCheckFile', _baseDir, _fname);
				if ( (IsDefined("qQ.DATELASTMODIFIED")) AND (Len(Trim(qQ.DATELASTMODIFIED)) gt 0) ) {
					_msg = _msg & ' as of ' & DateFormat(qQ.DATELASTMODIFIED, 'mm/dd/yyyy') & ' ' & TimeFormat(qQ.DATELASTMODIFIED, 'hh:mm tt');
				}
			} else {
			//	Request.primitiveCode.safely_cfmail(Request.ErrorEmail, Request.const_do_not_reply_symbol, 'Missing the file named "#Request.tibcoFTPDownloader2ActivityPath#"', '"#Request.tibcoFTPDownloader2ActivityPath#" is missing or cannot be found due to a bad file name.');
			}
			return _msg;
		}

		function qFileCleanUpQueryInit() {
			Request.qFileCleanUp = QueryNew('id, fName', 'integer, varchar');
		}

		function qFileCleanUpQuery(fName) {
			var _sql_statement_ = "SELECT id, fName FROM Request.qFileCleanUp WHERE (UPPER(fName) = '#UCASE(Trim(fName))#')";
			var _qQ = Request.primitiveCode.safely_execSQL('GetFileCleanUpFile', '', _sql_statement_);
			var _id = -1;
			if ( (IsQuery(_qQ)) AND (_qQ.recordCount gt 0) AND (NOT Request.dbError) ) {
				_id = _qQ.id;
			}
			return _id;
		}

		function qFileCleanUpAppend(fName) {
			var retVal = -1;
			if (NOT IsDefined("Request.qFileCleanUp")) {
				qFileCleanUpQueryInit();
			}
	
			retVal = Request.commonCode.qFileCleanUpQuery(fName);
			if (retVal eq -1) {
				QueryAddRow(Request.qFileCleanUp, 1);
				QuerySetCell(Request.qFileCleanUp, 'id', Request.qFileCleanUp.recordCount, Request.qFileCleanUp.recordCount);
				QuerySetCell(Request.qFileCleanUp, 'fName', fName, Request.qFileCleanUp.recordCount);
			}
		}
	
		function qFileCleanUpProcess() {
			var i = -1;
	
			if ( (IsDefined("Request.qFileCleanUp")) AND (IsQuery(Request.qFileCleanUp)) ) {
				for (i = 1; i lte Request.qFileCleanUp.recordCount; i = i + 1) {
					Request.primitiveCode.safely_cffile(Request.qFileCleanUp.fName[i], 'DELETE');
				}
			}
			
			qFileCleanUpQueryInit();
		}
	
		function tibco_ftp_command_stream_preamble() {
			return 'open ' & Request.ftp_server2 & Chr(13) & 'user' & Chr(13) & Request.ftp_username2 & Chr(13) & Request.ftp_password2 & Chr(13);
		}

		function iml_ftp_command_stream_preamble() {
			return 'open ' & Request.ftp_server & Chr(13) & 'user' & Chr(13) & Request.ftp_username & Chr(13) & Request.ftp_password & Chr(13) & 'cd ' & Request.ftp_folder & Chr(13);
		}

		function defaultBeginDateString() {
			var _dt = CreateDateTime(Year(Now()), Month(Now()), 1, 0, 0, 0);
			return DateFormat(_dt, 'mm/dd/yyyy') & ' ' & TimeFormat(_dt, 'HH:mm:ss');
		}

		function defaultEndDateString() {
			var _dt = CreateDateTime(Year(Now()), Month(Now()), DaysInMonth(Now()), 23, 59, 59);
			return DateFormat(_dt, 'mm/dd/yyyy') & ' ' & TimeFormat(_dt, 'HH:mm:ss');
		}
	
		function stripHTML(s) {
			var _s = REReplace(s, "<[^>]*>", "", "all");
			var _s_ = REReplace(_s, "&[^;]*;", "", "all");
			
			return _s_;
		}

		function QueryObject2DbSchema(repName, q) {
			var i = -1;
			var j = -1;
			var k = -1;
			var kk = -1;
			var varName = '';
			var varVal = '';
			var dType = '';
			var numericIsVarChar = false;
			var allowNulls = '';
			var colsArray = -1;
			var varcharArray = -1;
			var decimalsArray = -1;
			var decimalPrecisionArray = -1;
			var decimalScaleArray = -1;
			var qFields = -1;
			var _qq = -1;
			var sql_statement = '';
			var _sql_statement = '';
			var _sql_statement_ = '';
			var schema_map = QueryNew('colName, dType', 'varchar, varchar');
			var tbName = Request.excelReader.filterAlphaNumeric(repName);
	
			Request.boolArray = -1;
			
			if (IsQuery(q)) {
				QueryAddRow(schema_map, 1);
				colsArray = ListToArray(q.columnList, ',');
				colsArray2 = ArrayNew(1);
				Request.boolArray = ArrayNew(1);
				varcharArray = ArrayNew(1);
				decimalsArray = ArrayNew(1);
				decimalPrecisionArray = ArrayNew(1);
				decimalScaleArray = ArrayNew(1);
				kk = ArrayLen(colsArray);
	//			ArraySet(varcharArray, 1, kk, -1);
				for (j = 1; j lte kk; j = j + 1) {
					Request.boolArray[j] = true; // assume all data is numeric until the test proves otherwise...
					varcharArray[j] = -1;
					decimalsArray[j] = -1;
					decimalPrecisionArray[j] = -1;
					decimalScaleArray[j] = -1;
					for (i = 1; i lte q.recordCount; i = i + 1) {
						varName = 'q.#colsArray[j]#[#i#]';
						try {
							varVal = Evaluate(varName);
						} catch (Any e) {
							varVal = '';
						}
						if (NOT IsNumeric(varVal)) {
							Request.boolArray[j] = false;
							varcharArray[j] = Max(varcharArray[j], Len(varVal));
	//						break;
						} else {
							numericIsVarChar = false;
							decPos = FindNoCase('.', varVal);
	//writeOutput('#colsArray[j]#[#i#] :: varVal = [#varVal#]<br>');
							if (decPos gt 0) {
								if ( (Left(varVal, 1) eq '+') OR (Left(varVal, 1) eq '-') ) {
									numericIsVarChar = true;
								} else {
									decimalsArray[j] = Max(decimalsArray[j], decPos);
									decimalPrecisionArray[j] = Max(decimalPrecisionArray[j], Len(ReplaceNoCase(varVal, '.', '', 'all')));
									decimalScaleArray[j] = Max(decimalScaleArray[j], Len(varVal) - decPos);
								}
							} else if ( (Left(varVal, 1) eq '0') OR (Left(varVal, 1) eq '+') OR (Left(varVal, 1) eq '-') ) {
								numericIsVarChar = true;
							}
							if (numericIsVarChar) {
								Request.boolArray[j] = false;
								varcharArray[j] = Max(varcharArray[j], Len(varVal));
	//							break;
							} else {
								varcharArray[j] = -1;
							}
						}
					}
				}
	
				Request.DbSchema_tableName = 'dm_' & tbName;
				sql_statement = 'CREATE TABLE ' & Request.DbSchema_tableName;
				sql_statement = sql_statement & '(';
				k = ArrayLen(colsArray);
	
				Request.qFields = QueryNew('colName, code', 'varchar, varchar');
				for (j = 1; j lte k; j = j + 1) {
					_sql_statement = '';
					QueryAddRow(Request.qFields, 1);
					dType = 'varchar (#varcharArray[j]#)';
					if (Request.boolArray[j]) {
						if (decimalsArray[j] gt -1) {
							dType = 'decimal (#decimalPrecisionArray[j]#, #decimalScaleArray[j]#)';
						} else {
							dType = 'int';
						}
					}
					allowNulls = '';
					if (LCASE(colsArray[j]) eq LCASE('id')) {
						allowNulls = 'IDENTITY (1, 1) NOT NULL';
	//				} else if ( (LCASE(Request.DbSchema_tableName) eq LCASE(Request.const_dm_SHIPMENTSDETAIL)) AND (LCASE(colsArray[j]) eq LCASE('CUST_PO')) ) {
	//					allowNulls = 'PRIMARY KEY  CLUSTERED';
					}
					_sql_statement = _sql_statement & colsArray[j] & ' ' & dType & ' ' & allowNulls;
					QuerySetCell(Request.qFields, 'colName', LCASE(colsArray[j]), Request.qFields.recordCount);
					QuerySetCell(Request.qFields, 'code', _sql_statement, Request.qFields.recordCount);
				}
	
				_sql_statement_ = "SELECT colName, code FROM Request.qFields WHERE (colName = 'id')";
				_qq = Request.primitiveCode.safely_execSQL('QueryIdCols', '', _sql_statement_);
				if (NOT Request.dbError) {
					sql_statement = sql_statement & _qq.code;
					if (Request.qFields.recordCount gt 1) {
						sql_statement = sql_statement & ',';
					}
				} else {
					writeOutput('_sql_statement_ = [#_sql_statement_#]');
					writeOutput(Request.errorMsg);
					writeOutput('<br>');
				}
	
				_sql_statement = 'ftpID int NOT NULL,';
				sql_statement = sql_statement & _sql_statement;
				
				_sql_statement_ = "SELECT colName, code FROM Request.qFields WHERE (colName <> 'id')";
				_qq = Request.primitiveCode.safely_execSQL('QueryIdCols', '', _sql_statement_);
				if (NOT Request.dbError) {
					for (j = 1; j lte _qq.recordCount; j = j + 1) {
						sql_statement = sql_statement & _qq.code[j];
						if (j lt _qq.recordCount) {
							sql_statement = sql_statement & ',';
						}
					}
				} else {
					writeOutput('_sql_statement_ = [#_sql_statement_#]');
					writeOutput(Request.errorMsg);
					writeOutput('<br>');
				}
				
				sql_statement = sql_statement & ')';
				
	//writeOutput('<table><tr><td>');
	//writeOutput(Request.primitiveCode.cf_dump(Request.boolArray, 'Request.boolArray', true));
	//writeOutput('</td><td>');
	//writeOutput(Request.primitiveCode.cf_dump(colsArray, 'colsArray', true));
	//writeOutput('</td><td>');
	//writeOutput('<small>' & sql_statement & '</small>');
	//writeOutput('</td></tr></table>');
			}
			return sql_statement;
		}

		function BulkInsertQueryObject(tbName, q, recid) {
			var i = -1;
			var j = -1;
			var k = -1;
			var okay_to_handle = false;
			var pkColName = '';
			var pkColVal = '';
			var numErrs = 0;
			var numUpdates = 0;
			var _qq = -1;
			var varName = '';
			var varVal = '';
			var colsArray = -1;
			var sql_statement = '';
	
			colsArray = ListToArray(q.columnList, ',');
			k = ArrayLen(colsArray);
			if (IsQuery(q)) {
	writeOutput('Begin - Bulk Insertion of #q.recordCount# records.<br>');
				for (i = 1; i lte q.recordCount; i = i + 1) {
					sql_statement = 'INSERT INTO ' & tbName;
					sql_statement = sql_statement & '(';
					for (j = 1; j lte k; j = j + 1) {
						if (LCASE(colsArray[j]) neq LCASE('id')) {
							sql_statement = sql_statement & colsArray[j];
							if (j lte k) {
								sql_statement = sql_statement & ',';
							}
						}
					}
					sql_statement = sql_statement & 'ftpID';
					sql_statement = sql_statement & ') ';
					sql_statement = sql_statement & 'VALUES (';
					for (j = 1; j lte k; j = j + 1) {
						if (LCASE(colsArray[j]) neq LCASE('id')) {
							varName = 'q.#colsArray[j]#[#i#]';
							try {
								varVal = Evaluate(varName);
							} catch (Any e) {
								varVal = '';
							}
							if (NOT Request.boolArray[j]) {
								varVal = "'" & varVal & "'";
							}
							sql_statement = sql_statement & varVal;
							if (j lte k) {
								sql_statement = sql_statement & ',';
							}
						}
					}
					sql_statement = sql_statement & recid;
					sql_statement = sql_statement & ')';
					_qq = Request.primitiveCode.safely_execSQL('InsertData#i#', Request.DSN, sql_statement);
					if (Request.dbError) {
						if (Request.primitiveCode._isPKviolation(Request.errorMsg)) {
							// INSERT failed so try an update...
							sql_statement = 'UPDATE ' & tbName;
							sql_statement = sql_statement & ' SET ';
							pkColName = '';
							pkColVal = '';
	//writeOutput('[#i#] :: k = [#k#] ');
							for (j = 1; j lte k; j = j + 1) {
								varName = 'q.#colsArray[j]#[#i#]';
								try {
									varVal = Evaluate(varName);
								} catch (Any e) {
									varVal = '';
								}
								if (NOT Request.boolArray[j]) {
									varVal = "'" & varVal & "'";
								}
	//writeOutput('[#varName#] = [#varVal#]<br>');
	
								okay_to_handle = true;
	//							if (LCASE(tbName) eq LCASE(Request.const_dm_SHIPMENTSDETAIL)) {
	//								if ( (LCASE(colsArray[j]) eq LCASE('CUST_PO')) OR (LCASE(colsArray[j]) eq LCASE('ID')) ) {
	//									okay_to_handle = false;
	//									if (LCASE(colsArray[j]) eq LCASE('CUST_PO')) {
	//										pkColName = colsArray[j];
	//										pkColVal = varVal;
	//									}
	//								}
	//							}
								if (okay_to_handle) {
									sql_statement = sql_statement & colsArray[j] & ' = ' & varVal;
									if (j lt k) {
										sql_statement = sql_statement & ',';
									}
									sql_statement = sql_statement & ' ';
								}
							}
							if (Len(pkColName) gt 0) {
								sql_statement = sql_statement & 'WHERE (' & pkColName & ' = ' & pkColVal & ')';
							}
							_qq = Request.primitiveCode.safely_execSQL('UpdateData#i#', Request.DSN, sql_statement);
							if (Request.dbError) {
								numErrs = numErrs + 1;
								writeOutput('sql_statement[#i#] = [#sql_statement#]');
								writeOutput(Request.errorMsg);
								writeOutput('<br>');
							} else {
								numUpdates = numUpdates + 1;
							}
						} else {
							numErrs = numErrs + 1;
							writeOutput('sql_statement[#i#] = [#sql_statement#]');
							writeOutput(Request.errorMsg);
							writeOutput('<br>');
						}
					} else {
	//writeOutput(Request.primitiveCode.cf_dump(_qq, 'InsertData#i# [#sql_statement#]', false));
	//writeOutput('Sucessfully INSERTed record #i# of #q.recordCount#.<br>');
					}
				}
	writeOutput('End - Bulk Insertion of #(q.recordCount - numUpdates)# records with #numUpdates# updates and #numErrs# errors.<br>');
			}
		}

	</cfscript>
</cfcomponent>
