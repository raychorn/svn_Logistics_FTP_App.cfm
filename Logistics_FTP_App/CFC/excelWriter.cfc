<cfcomponent name="excelWriter" description="Writes Excel CSV files from Query Objects">

	<cffunction name="cf_file_writer" access="public" returntype="any">
		<cfargument name="_action_" type="string" required="yes">
		<cfargument name="_fname_" type="string" required="yes">
		<cfargument name="_output_" type="string" required="yes">
	
		<cfswitch expression="#UCASE(_action_)#">
			<cfcase value="WRITE,APPEND" delimiters=",">
				<cffile action="#_action_#" file="#_fname_#" output="#_output_#" attributes="Normal" addnewline="Yes" fixnewline="No">
			</cfcase>
			
			<cfdefaultcase>
				<cfscript>
					writeOutput('Warning: No valid action defined. (#_action_#)<br>');
				</cfscript>
			</cfdefaultcase>
		</cfswitch>
	
	</cffunction>

	<cfscript>
		function query2ExcelCSV(q) {
			var s = '';
			var i = -1;
			var j = -1;
			var k = -1;
			var val = -1;
			var colsArray = -1;

			if (IsQuery(q)) {
				colsArray = ListToArray(q.columnList, ',');
				k = ArrayLen(colsArray);
				for (i = 1; i lte k; i = i + 1) {
					s = s & '"' & colsArray[i] & '"';
					if (i lt k) {
						s = s & ',';
					}
				}
				s = s & Chr(13) & Chr(10);
				for (j = 1; j lte q.recordCount; j = j + 1) {
					for (i = 1; i lte k; i = i + 1) {
						try {
							val = Evaluate('q.#colsArray[i]#[j]');
						} catch (Any e) {
							val = '';
						}
						s = s & '"' & val & '"';
						if (i lt k) {
							s = s & ',';
						}
					}
					s = s & Chr(13) & Chr(10);
				}
			}
			return s;
		}

		function writeExcelCSVFromQuery(q, fName) {
			var temp_fname = GetTempDirectory() & fName & '_' & createUUID() & '.csv';
			
			cf_file_writer('WRITE', temp_fname, query2ExcelCSV(q));
			return temp_fname;
		}

		function writeExcelCSVFromRawData(rawData, fName) {
			var temp_fname = '';
			var dirName = ListDeleteAt(CGI.CF_TEMPLATE_PATH, ListLen(CGI.CF_TEMPLATE_PATH, '\'), '\') & '\' & Request.const_excel_data_symbol;

			Request.primitiveCode.cf_makeDirectory(dirName);
			temp_fname = dirName & '\' & fName & '_' & CGI.REMOTE_ADDR & '_' & createUUID() & '.csv';
			
			cf_file_writer('WRITE', temp_fname, rawData);
			return temp_fname;
		}
	</cfscript>
</cfcomponent>
