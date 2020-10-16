<cfcomponent name="excelReader" description="Reads Excel CSV files into Query Objects">
	<cfscript>
		function trimRightMostUnderBars(t) {
			if (Right(t, 1) eq '_') {
				return trimRightMostUnderBars(Left(t, Len(t) - 1));
			}
			return t;
		}

		function trimLeftMostUnderBars(t) {
			if (Left(t, 1) eq '_') {
				return trimLeftMostUnderBars(Right(t, Len(t) - 1));
			}
			return t;
		}

		function spaces2UnderBar(s) {
			var t = '';
			t = ReplaceNoCase(Trim(URLDecode(Trim(s))), ' ', '_', 'all');
			if (Right(t, 1) eq '_') {
				t = trimRightMostUnderBars(t);
			}
			if (Left(t, 1) eq '_') {
				t = trimLeftMostUnderBars(t);
			}
			return t;
		}

		function filterAlphaNumeric(s) {
			var i = -1;
			var t = '';
			var ch = '';
			
			s = URLDecode(Trim(s));
			for (i = 1; i lte Len(s); i = i + 1) {
				ch = Asc(LCASE(Mid(s, i, 1)));
				if ( ( (ch gte Asc(LCASE('A'))) AND (ch lte Asc(LCASE('Z'))) ) OR ( (ch gte Asc('0')) AND (ch lte Asc('9')) ) OR (ch eq Asc('_')) ) {
					t = t & Chr(ch);
				}
			}
			return UCASE(t);
		}

		function filterAlphaNumericSpaces2UnderBar(s) {
			return trimRightMostUnderBars(spaces2UnderBar(filterAlphaNumeric(s)));
		}

		function stateFulParser(str, delim, quotes) {
			// Purpose: This function parses the string "str" using the delimiters "delim" between fields surrounded by "quotes" and returns an Array object...
			var i = -1;
			var _ch = '';
			var aField = '';
			var aRecord = -1;
			var bool_insideQuotes = false;
			var bool_betweenQuotes = false;
			var n = -1;
			var delim_hits = -1;
			var delim_max = -1;
			var _sum = -1;
			var l_str = '';
			var r_str = '';
			var _v = '';
			
			str = Trim(str);
			n = Len(str);
			aRecord = ArrayNew(1);

			delim_hits = Request.commonCode.countCharsFromSet(str, quotes);
			delim_max = ArrayLen(delim_hits);
			_sum = ArraySum(delim_hits) + delim_max;

			if ((delim_max MOD 2) neq 0) {
				if ((_sum - 2) gt 0) {
					l_str = Left(str, _sum - 2);
					r_str = Right(str, (Len(str) - (_sum - 2)) - 1);
					str = l_str & r_str;
				}
			}
	
			for (i = 1; i lte n; i = i + 1) {
				_ch = Mid(str, i, 1);

				if (_ch eq quotes) {
					if (bool_insideQuotes) {
						aField = aField & _ch;
						bool_insideQuotes = false;
					} else {
						bool_insideQuotes = true;
					}
					if (NOT bool_insideQuotes) {
						_v = Trim(ReplaceNoCase(aField, '"', '', 'all'));
						if (Len(_v) eq 0) {
							_v = ' ';
						}
						aRecord[ArrayLen(aRecord) + 1] = URLEncodedFormat(_v);
						aField = '';

						if (bool_betweenQuotes) {
							bool_betweenQuotes = false;
						} else {
							bool_betweenQuotes = true;
						}
					}
				}

				if (bool_insideQuotes) {
					aField = aField & _ch;
				} else {
					if (_ch eq delim) {
						if (Len(aField) gt 0) {
							_v = Trim(ReplaceNoCase(aField, '"', '', 'all'));
							if (Len(_v) eq 0) {
								_v = ' ';
							}
							aRecord[ArrayLen(aRecord) + 1] = URLEncodedFormat(_v);
							aField = '';
						}
					} else if (_ch neq quotes) {
						aField = aField & _ch;
					}
				}
			}
			if (Len(Trim(aField)) gt 0) {
				_v = Trim(ReplaceNoCase(aField, '"', '', 'all'));
				if (Len(_v) eq 0) {
					_v = ' ';
				}
				aRecord[ArrayLen(aRecord) + 1] = URLEncodedFormat(_v);
			}
			return aRecord;
		}
	
		function copyArrayItems(a, func) {
			var i = -1;
			var _item = -1;
			var newArray = ArrayNew(1);
			
			for (i = 1; i lte ArrayLen(a); i = i + 1) {
				_item = a[i];
				if (IsCustomFunction(func)) {
					_item = Trim(func(_item));
				}
				newArray[i] = _item;
			}
			return newArray;
		}

		function str2Query(str, Cr, Lf) {
			var i = -1;
			var _ch = -1;
			var _qq = -1;
			var _row_data = '';
			
			_qq = QueryNew('data', 'varchar');
			QueryAddRow(_qq, 1);

			str = Trim(str);
			for (i = 1; i lte Len(str); i = i + 1) {
				_ch = Mid(str, i, 1);
				if (_ch eq Cr) {
					QuerySetCell(_qq, 'data', _row_data, _qq.recordCount);
					QueryAddRow(_qq, 1);
					i = i + 1;
	
					_ch = Mid(str, i, 1);
					if (_ch eq Lf) {
						i = i + 1;
						_ch = Mid(str, i, 1);
					}
	
					_row_data = '';
				}
				_row_data = _row_data & _ch;
			}
			QuerySetCell(_qq, 'data', _row_data, _qq.recordCount);
			return _qq;
		}
		
		function query2FlashDataStream(_qq, delim, quotes) {
			var j = -1;
			var k = -1;
			var _item = -1;
			var _rec = -1;
			var a_data_row = -1;
			var data_rows = '';
			
			if (IsQuery(_qq)) {
				if ( (NOT IsDefined("Request._ftp_schema")) OR (NOT IsArray(Request._ftp_schema)) ) {
					Request._ftp_schema = ArrayNew(1);
				}
				if ( (NOT IsDefined("Request._ftp_schema_map")) OR (NOT IsArray(Request._ftp_schema_map)) ) {
					Request._ftp_schema_map = ArrayNew(1);
				}
				// BEGIN: Locate the row of column headers.. this row does not always appear in the same place...
				for (j = 1; j lte _qq.recordCount; j = j + 1) {
					_item = _qq.data[j];
					_rec = stateFulParser(_item, delim, quotes);
					if (ArrayLen(_rec) gt 2) {
						Request._ftp_schema = copyArrayItems(_rec, -1);
						Request._ftp_schema_map = copyArrayItems(_rec, filterAlphaNumericSpaces2UnderBar);
						break;
					}
				}
				// END! Locate the row of column headers.. this row does not always appear in the same place...
				for (k = 0; j lte _qq.recordCount; j = j + 1) {
					k = k + 1; // preincrement to avoid problems that result from wrong row counts...
					_item = _qq.data[j];
					_rec = stateFulParser(_item, delim, quotes);

					a_data_row = ArrayToList(_rec, ',');
					data_rows = data_rows & '&row#k#=';
					data_rows = data_rows & '#URLEncodedFormat(a_data_row)#';
				}
				data_rows = data_rows & '&rowCount=#k#';
			}
			return data_rows;
		}

		function DataStreamToQueryObject(dS) {
			var q = QueryNew('');
			var i = -1;
			var _pair = '';
			var _varName = '';
			var _varVal = '';
			
			for (i = 1; i lte ListLen(dS, '&'); i = i + 1) {
				_pair = Request.commonCode._GetToken(dS, i, '&');
				if (ListLen(_pair, '=') eq 2) {
					_varName = Request.commonCode._GetToken(_pair, 1, '=');
					_varVal = URLDecode(Request.commonCode._GetToken(_pair, 2, '='));
					QueryAddColumn(q, _varName, 'varchar', ArrayNew(1));
					if (q.recordCount eq 0) {
						QueryAddRow(q, 1);
					}
					QuerySetCell(q, _varName, _varVal, q.recordCount);
				}
			}
			return q;
		}

	</cfscript>
</cfcomponent>
