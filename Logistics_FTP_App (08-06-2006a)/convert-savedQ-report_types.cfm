<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 5 * 2)#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Convert Saved Query Report Types to Linked Table References</title>

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

<cfscript>
	writeOutput('convert-savedQ-report_types.cfm');

	_sql_statement = "SELECT SavedQueries.id, SavedQueries.reportType, SavedQueryReportType.id AS sqr_id, TibcoReportNameDefs.id AS rep_id, TibcoReportNameDefs.report_name FROM TibcoReportNameDefs INNER JOIN SavedQueryReportType ON TibcoReportNameDefs.id = SavedQueryReportType.rep_id RIGHT OUTER JOIN SavedQueries ON SavedQueryReportType.sqid = SavedQueries.id WHERE (SavedQueryReportType.id IS NULL)";
	q = Request.primitiveCode.safely_execSQL('qGetSavedQueryList', Request.DSN, _sql_statement);

writeOutput(Request.primitiveCode.cf_dump(q, 'q [#_sql_statement#]', false));
	if (NOT Request.dbError) {
writeOutput('q.recordCount = [#q.recordCount#]<br>');
		for (i = 1; i lte q.recordCount; i = i + 1) {
writeOutput('A. i = [#i#]<br>');
			_list_len = ListLen(q.reportType[i], ',');
writeOutput('_list_len = [#_list_len#]<br>');
			for (j = 1; j lte _list_len; j = j + 1) {
writeOutput('j = [#j#]<br>');
				_tok = Trim(ReplaceNoCase(Request.commonCode._GetToken(q.reportType[i], j, ','), '"', '', 'all'));
writeOutput('_tok = [#_tok#]<br>');
				if (Len(_tok) gt 0) {
					_sql_statement2 = "SELECT id, report_prefix, report_name FROM TibcoReportNameDefs WHERE (UPPER(report_name) = '#UCASE(_tok)#')";
					q2 = Request.primitiveCode.safely_execSQL('qRepTypeName#j##i#', Request.DSN, _sql_statement2);
					if (NOT Request.dbError) {
writeOutput(Request.primitiveCode.cf_dump(q2, 'q2 [#_sql_statement2#]', false));
						if ( (Len(q2.id) gt 0) AND (Len(q.id[i]) gt 0) ) {
							_sql_statement3 = "INSERT INTO SavedQueryReportType (rep_id, sqid) VALUES (#q2.id#,#q.id[i]#); SELECT @@IDENTITY AS 'id';";
							q3 = Request.primitiveCode.safely_execSQL('qSaveLinkage#j##i#', Request.DSN, _sql_statement3);
							if (NOT Request.dbError) {
								writeOutput('<span class="normalStatusClass">INFO: Successfully saved the Saved Query --> Report Type Linkage. [(rep_id=#q2.id#, sqid=#q.id[i]#)]</span><br>');
							} else {
								writeOutput('<span class="errorStatusClass">ERROR: B. Cannot save the Saved Query --> Report Type Linkage. [#_sql_statement3#]</span><br>' & Request.errorMsg);
							}
						} else {
							writeOutput('<span class="errorStatusClass">WARNING: C. Missing [q2.id=#q2.id#] or [q.id[i]=#q.id[i]#].</span><br>' & Request.errorMsg);
						}
					}
				}
			}
writeOutput('B. i = [#i#]<br>');
		}
		// sanity check...
		_sql_statement4 = "SELECT SavedQueries.id, SavedQueries.reportType, SavedQueryReportType.id AS sqr_id, TibcoReportNameDefs.id AS rep_id, TibcoReportNameDefs.report_name FROM TibcoReportNameDefs INNER JOIN SavedQueryReportType ON TibcoReportNameDefs.id = SavedQueryReportType.rep_id RIGHT OUTER JOIN SavedQueries ON SavedQueryReportType.sqid = SavedQueries.id WHERE (SavedQueryReportType.id IS NOT NULL)";
		q4 = Request.primitiveCode.safely_execSQL('qLinkedSavedQueryList', Request.DSN, _sql_statement4);

		writeOutput(Request.primitiveCode.cf_dump(q4, 'q4 [#_sql_statement4#]', false));
	} else {
		writeOutput('<span class="errorStatusClass">ERROR: A. Cannot Retrieve the Saved Query List so processing cannot continue.</span><br>' & Request.errorMsg);
	}
</cfscript>

</body>
</html>
