<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 60)#">

<!--- Note:  This file is no longer being used as it was replaced by the new process... --->

<cfparam name="nocache" type="string" default="">
<cfparam name="filename" type="string" default="">

<cfif 0>
	<cfset filename = "/US112544/-AR--M----TCP A mailbox     10784        0 May 29 01:21 SRP720.PC">
</cfif>

<cfset is_running_detached = (Len(Trim(CGI.HTTP_REFERER)) eq 0)>

<cfif (NOT is_running_detached)>
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
	
	<cfflush>
	
	<body>
</cfif>

<cfoutput>

	<cfscript>
		_qActivity = Request.commonCode.initCachedLog();
	</cfscript>

	<cfset ftpErrMsg = "">
	<cfset ftpErr = "False">
	<cftry>
		<cfftp action="OPEN" server="#Request.ftp_server2#"  username="#Request.ftp_username2#" password="#Request.ftp_password2#" stoponerror="Yes" connection="myFTP">
	
		<cfcatch type="Any">
			<cfset ftpErr = "True">
			<cfsavecontent variable="ftpErrMsg">
				#cfcatch.message#<br>
				#cfcatch.detail#
			</cfsavecontent>
		</cfcatch>
	</cftry>
	
	<cfscript>
		Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action OPEN</b> :: [#ftpErrMsg#]');
	</cfscript>
	
	<cfif (NOT ftpErr)>
		<cfif (cfftp.succeeded)>
			<cfftp action = "LISTDIR" stopOnError = "Yes" name = "ListFiles" directory = "/" connection = "myFTP">
			<cfdump var="#ListFiles#" label="ListFiles">

			<cfif (Len(Trim(filename)) eq 0)>
				<cfscript>
					oFilesListArray = myFTP.listnames();
				 
					Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [oFilesListArray.length = #ArrayLen(oFilesListArray)#]');
				</cfscript>
			<cfelse>
				<cfscript>
					oFilesListArray = ArrayNew(1);
	// /US112544/-AR--M----TCP A mailbox     10784        0 May 29 01:21 SRP720.PC
					original_filename = filename;
					_token_cnt_filename = ListLen(filename, ' ');
					foldername = Request.commonCode._GetToken(filename, 1, '/');
					filesize = Request.commonCode._GetToken(filename, (_token_cnt_filename - 5), ' ');
					filemonth = Request.commonCode._GetToken(filename, (_token_cnt_filename - 3), ' ');
					fileday = Request.commonCode._GetToken(filename, (_token_cnt_filename - 2), ' ');
					fileyear = Year(Now());
					thisMonth = DatePart('m', Now());
					if (FindNoCase(filemonth, MonthAsString(thisMonth)) eq 0) {
						if (thisMonth eq 1) {
							fileyear = DatePart('yyyy', Now()) - 1;
						}
					}
					filedate = filemonth & '-' & fileday;
					filetime = Request.commonCode._GetToken(filename, (_token_cnt_filename - 1), ' ');
					file_timeStamp = CreateDateTime(fileyear, Request.commonCode.monthNameToNum(filemonth), fileday, Request.commonCode._GetToken(filetime, 1, ':'), Request.commonCode._GetToken(filetime, 2, ':'), 0);
					filename = Request.commonCode._GetToken(filename, (_token_cnt_filename - 0), ' ');
					oFilesListArray[1] = filename;          // this matches the documentation from Tibco...
//					oFilesListArray[1] = original_filename; // this failed !
					
					Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [foldername = [#foldername#], filesize = [#filesize#], filedate = [#filedate#], filetime = [#filetime#], file_timeStamp = [#CreateODBCDateTime(file_timeStamp)#], filename = [#filename#]]');
				</cfscript>
			</cfif>
		
			<cftimer label="Tibco FTP Process" type="inline">
				<cfset temp_folder = GetTempDirectory() & 'Tibco_' & Request.commonCode._uniqueTimeBasedUUID('-')>
				<cfdirectory action="CREATE" directory="#temp_folder#">
				<cfscript>
					Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [temp_folder = [#temp_folder#]]');
				</cfscript>
				 <cfloop index="_i" from="1" to="#ArrayLen(oFilesListArray)#">
					<cfset next_file = temp_folder & '\' & filename>
					<cfscript>
						Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [localfile="#next_file#"], remotefile="#oFilesListArray[_i]#"');
					</cfscript>
			
					<cfset ftpErrMsg = "">
					<cfset ftpErr = "False">
					<cftry>
						<cfftp action="GETFILE" stoponerror="No" localfile="#next_file#" remotefile="#oFilesListArray[_i]#" transfermode="AUTO" failifexists="Yes" connection="myFTP">
				
						<cfcatch type="Any">
							<cfset ftpErr = "True">
							<cfsavecontent variable="ftpErrMsg">
								<cfdump var="#cfcatch#" label="cfcatch - cfftp action GETFILE." expand="No">
							</cfsavecontent>
						</cfcatch>
					</cftry>
			
					<cfscript>
						Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action GETFILE</b> :: [#ftpErrMsg#]');
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
					Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>FTP Action CLOSE</b> :: [#ftpErrMsg#]');
				</cfscript>
			
				<cfdirectory action="LIST" directory="#temp_folder#" name="qTibcoFiles">
			
				<cfquery name="qFiles" dbtype="query" debug>
					SELECT * FROM qTibcoFiles
					WHERE (size > 0)
				</cfquery>	
			
				 <cfscript>
				 	if (IsQuery(qTibcoFiles)) {
						Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [Processing #qTibcoFiles.recordCount# Tibco Files.]');
						for (i = 1; i lte qTibcoFiles.recordCount; i = i + 1) {
							fName = qTibcoFiles.directory[i] & '\' & qTibcoFiles.name[i];
							if (FileExists(fName)) {
								bool_is_same_file = false;
								new_ftp_data = Request.primitiveCode.safely_cffile(fName);
				
								_sql_statement = "SELECT id, last_modified_dt, file_length, file_name, file_path, file_url, local_temp_file, raw_data FROM IML_FTP WHERE (last_modified_dt = #CreateODBCDateTime(file_timeStamp)#) AND (file_name = '#qTibcoFiles.name[i]#')";
								q = Request.primitiveCode.safely_execSQL('GetLatestFTPRecord', Request.DSN, _sql_statement);

								bool_is_same_file = true;
								Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [Request.dbError=(#Request.dbError#), q.recordCount=(#q.recordCount#), bool=#( (NOT Request.dbError) AND (q.recordCount eq 0) )#]');
								if ( (NOT Request.dbError) AND (q.recordCount eq 0) ) {
									bool_is_same_file = false;
								}
								
								Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [bool_is_same_file=(#bool_is_same_file#), bool=#(NOT bool_is_same_file)#]');
								if (NOT bool_is_same_file) {
									Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [Saving data for #qTibcoFiles.name[i]# in Db.]');
									_sql_statement = "INSERT INTO IML_FTP (last_modified_dt, file_length, file_name, file_path, file_url, local_temp_file, raw_data) VALUES (#CreateODBCDateTime(file_timeStamp)#,#qTibcoFiles.size[i]#,'#qTibcoFiles.name[i]#','#original_filename#','#Request.const_31_day_symbol#','#fName#','#URLEncodedFormat(Request.commonCode.filterQuotesForSQL(ToString(new_ftp_data)))#')";
									q = Request.primitiveCode.safely_execSQL('SaveFTPdata', Request.DSN, _sql_statement);
			
									if (NOT Request.dbError) {
										Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [Sucessfully saved data for #qTibcoFiles.name[i]# in Db.]');
									} else {
										Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [Did NOT save data for #qTibcoFiles.name[i]# in Db.]');
										Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [#Request.errorMsg#]');
									}
								}
			
								Request.primitiveCode.safely_cffile(fName, "DELETE");
								if (NOT Request.anError) {
									Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) [Deleted Temp File [#fName#]]');
								}
							}
						}
					}
				 </cfscript>
	
				<cfset ftpErrMsg = "">
				<cfset ftpErr = "False">
				<cftry>
					<cfif (DirectoryExists(temp_folder))>
						<cfdirectory action="DELETE" directory="#temp_folder#">
					</cfif>
			
					<cfcatch type="Any">
						<cfset ftpErr = "True">
						<cfsavecontent variable="ftpErrMsg">
							<cfdump var="#cfcatch#" label="cfcatch - action DELETE." expand="No">
						</cfsavecontent>
					</cfcatch>
				</cftry>
		
				<cfscript>
					Request.commonCode.appendFTPLogActivityCache(_qActivity, Now(), '(#CGI.SCRIPT_NAME#) <b>Action DELETE TEMP FILE</b> :: [#ftpErrMsg#]');
					_qActivity = Request.commonCode.dumpCachedLog2DbLog(_qActivity, 'TIBCO_FTP_LOG');
				</cfscript>
			</cftimer>
		<cfelse>
			<!--- Log an error here... someday... --->
		</cfif>
		
		<cfif (NOT is_running_detached)>
			<h4 align="center">
		</cfif>
		Processing Completed !  If no new files were available then none were reported as having been processed - Check back later.
		<cfif (NOT is_running_detached)>
			</h4>
		</cfif>
	</cfif>

</cfoutput>

<cfif (NOT is_running_detached)>
	</body>
	</html>
</cfif>
