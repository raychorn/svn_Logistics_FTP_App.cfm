<cfinclude template="cfinclude_application_init.cfm">

<cfset Request._title_bar = "IML/FTP/XML Interface">
<cfset Request.title_bar = "redacted #Request._title_bar#">

<cfset Request.productVersion = "1.0.8">

<cfinclude template="cfinclude_application_const.cfm">

<CFSET Request.ErrorEmail = "raychorn@hotmail.com">
<CFSET Request.EmailFrom  = Request.const_do_not_reply_symbol>

<cfinclude template="cfinclude_primitiveCode.cfm">

<cfinclude template="cfinclude_commonCode.cfm">

<cfscript>
	Request.ftpDownloader_last_touched_dt = CreateDateTime(2005, 10, 6, 16, 30, 0);

	Request.tbName = '';
	Request._lid = -1;
	Request._fid = -1;

	Request.bool_inhibit_database_cache = true;
	Request.bool_inhibit_use_of_step3 = true;
	Request.bool_use_SQL_Server_Query_Aggregator = false;
	Request.bool_inhibit_writeOutput_during_process_new = true;
	Request.bool_inhibit_logfile_cache_during_process_new = true;
	Request.bool_inhibit_cfdump_during_process_new = true;

	Request.bool_show_verbose_SQL_errors = false;

	Request.const_redacted_dev_symbol = 'redacted.dev';
	Request.const_myVisionDev_symbol = 'mvdev1';
	Request.const_myVisionDev2_symbol = 'redacted.dev';
	Request.const_myVisionDev2_ip_symbol = '192.168.100.54';

	Request.const_delay_cmd_exec_exe_symbol = '30';
	Request.const_begin_dir_cmd_exec_exe_symbol = 'c:\Program Files\';
	Request.const_cmd_exec_exe_symbol = 'cmd-exec.exe';
	Request.const_actual_path_cmd_exec_exe_symbol = Request.const_begin_dir_cmd_exec_exe_symbol & 'ftpUtils\' & Request.const_cmd_exec_exe_symbol;
	Request.actual_path_cmd_exec_exe_symbol = Request.const_actual_path_cmd_exec_exe_symbol;
	
	Request.const_cfprobe_symbol = 'cfprobe___'; // ignore scheduled tasks with this name...

	Request.const_excel_data_symbol = 'excel-data';
	
	Request.const_where_clause_token = '%where_clause%';
	Request.const_begin_date_symbol = '%begin_date_symbol%';
	Request.const_end_date_symbol = '%end_date_symbol%';
	Request.const_report_type_symbol = '%report_type_symbol%';
	
	Request.const_end_date_time_alpha_symbol = '00:00:00.0';
	Request.const_end_date_time_omega_symbol = '23:59:59.9';
	
	Request.const_opt_101_symbol = '101';

	Request.const_forgot_password_symbol = 'forgot_password';
	Request.const_new_user_account_symbol = 'new_user_account';
	Request.const_chg_user_account_password_symbol = 'chg_user_password';
</cfscript>

<cfscript>
	err_excelReader = false;
	err_excelReaderMsg = '';
	try {
	   Request.excelReader = CreateObject("component", "cfc.excelReader");
	} catch(Any e) {
		err_excelReader = true;
		err_excelReaderMsg = 'The excelReader component has NOT been created.';
		writeOutput('<font color="red"><b>#err_excelReaderMsg#</b></font><br>');
		if (Request.commonCode.isServerLocal()) {
			writeOutput(Request.primitiveCode.cf_dump(e, 'CreateObject("component", "cfc.excelReader")', false));
		}
	}
</cfscript>

<cfif (NOT IsObject(Request.excelReader))>
	<cfabort showerror="ERROR: #err_excelReaderMsg#">
</cfif>

<cfif (NOT IsObject(Request.commonCode))>
	<cfabort showerror="ERROR: #err_commonCodeMsg#">
</cfif>

<cfscript>
	if (0) {
		if (UCASE(CGI.SERVER_NAME) eq UCASE(Request.const_myVisionDev_symbol)) {
			Request.schedulerLogPath = 'C:\CFusionMX7\logs\scheduler.log';
			Request.tibcoFTPDownloader2ActivityPath = 'C:\@temp\tibco-ftp_1.html';
		} else {
			Request.schedulerLogPath = '\\#Request.const_myVisionDev_symbol#\CFusionMX7\logs\scheduler.log';
			Request.tibcoFTPDownloader2ActivityPath = '\\#Request.const_myVisionDev_symbol#\@temp\tibco-ftp_1.html';
		}
	} else {
		try {
			Request.schedulerLogPath = 'C:\CFusionMX7\logs\scheduler.log';
			if (NOT FileExists(Request.schedulerLogPath)) {
				_fname = Request.commonCode._GetToken(Request.schedulerLogPath, ListLen(Request.schedulerLogPath, '\'), '\');
				tpath = GetTempDirectory();
				n = ListLen(tpath, '\');
				_baseDir = tpath;
				for (i = n; i gte 1; i = i - 1) {
					_baseDir = ListDeleteAt(_baseDir, i, '\');
					if (Len(Trim(_baseDir)) gt 0) {
						qQ = Request.primitiveCode.cf_directory('qSearchForFile', _baseDir, _fname, true);
						if (qQ.recordCount gt 0) {
							Request.schedulerLogPath = qQ.DIRECTORY & '\' & _fname;
							break;
						}
					}
				}
			}
			Request.tibcoFTPDownloader2ActivityPath = 'C:\@temp\tibco-ftp_1.html';
		} catch (Any e) {
		}
	}
</cfscript>

<cfif (NOT IsObject(Request.primitiveCode))>
	<cfabort showerror="ERROR: #err_primitiveCodeMsg#">
</cfif>

<cfscript>
	Randomize(Right('#GetTickCount()#', 9), 'SHA1PRNG');
</cfscript>

<cfset Request.symbol_method_pna = "pna">
<cfset Request.symbol_method_os = "os">

<cfset Request.ftp_server = "ftpsecure.ingrammicro.com">
<cfset Request.ftp_username = "333719">
<cfset Request.ftp_password = "675VSN23">
<cfset Request.ftp_folder = "/FUSION/US/V3719">

<cfset Request.ftp_server2 = "ediftp.ingrammicro.com">
<cfset Request.ftp_username2 = "US112544">
<cfset Request.ftp_password2 = "vision">
<cfset Request.ftp_folder2 = "/" & Request.ftp_username2>

<cfset Request.system_run_mode_test = "Test">
<cfset Request.iml_test_soap_server_url = "https://malibu.ingrammicro.com/SOAP">

<cfset Request.system_run_mode_prod = "Prod">
<cfset Request.iml_prod_soap_server_url = "https://newport.ingrammicro.com/SOAP">

<cfset Request.system_run_mode = Request.system_run_mode_prod>
<cfset Request.iml_soap_server_url = Request.iml_prod_soap_server_url>

<cfparam name="run_mode" type="string" default="">
<cfparam name="nocache" type="string" default="">

<cfif (Len(Trim(run_mode)) gt 0)>
	<cfset Client.run_mode = run_mode>
</cfif>

<cfif (IsDefined("Client.run_mode"))>
	<cfif (LCASE(Client.run_mode) eq LCASE(Request.system_run_mode_test))>
		<cfset Request.system_run_mode = Request.system_run_mode_test>
		<cfset Request.iml_soap_server_url = Request.iml_test_soap_server_url>
	<cfelseif (LCASE(Client.run_mode) eq LCASE(Request.system_run_mode_prod))>
		<cfset Request.system_run_mode = Request.system_run_mode_prod>
		<cfset Request.iml_soap_server_url = Request.iml_prod_soap_server_url>
	</cfif>
</cfif>

<cfscript>
	Request.const_dm_SHIPMENTSDETAIL = 'dm_SHIPMENTSDETAIL';
</cfscript>

<!--- +++ --->
<cfif (NOT IsDefined("flashCallCFC"))>
</cfif>
<cffunction name="flashCallCFC" access="public" returntype="string">
	<cfargument name="component" required="yes">
	<cfargument name="method" required="yes">
	<cfargument name="params" type="struct" default="#StructNew()#" required="yes">
	<cfargument name="callBack" type="string" default="" required="yes">
	<cfargument name="CFCparmsFromFlash" type="string" default="" required="yes">

	<!---
		Name:			flashCallCFC.cfm
		Author:			Nahuel Foronda & Laura Arguello
		Created:		March 31, 2005
		Last Updated:	March 31, 2005
		
		Attributes:
			component: The path and name of the component to call (including .cfc). It must be accessible from the root. No mappings allowed. Ex: /com/mycomponent.cfc
			method: The method to call
			params: A structure containing all the parameters to send to the component. Keys in the structure should match arguments expected by CFC (declared or undeclared arguments)
			callBack: the function to call back when result form CFC is loaded. This function will receive an object containing any variables that the response from the CFC returned
			varName: Name of the variable to be set on calling template
		
		Usage:
			This custom tag should be called before making a cfform="flash". It will set a variable in the caller template with the name given
			by attribute "varName" or "callCFC" by default. This variable should be put in an OnClick/Onchange attribute of a button or other control. 
			<cf_flashCallCFC component="myCFC.cfc" method="myMethod" callBack="_root.myFunction" params="#myParamsStructure#" varName="callMyCFC">
		
			For this to work, component should output (not return) any variable in the loadvars compatible format, and string should be ended by "&loaded=true". It should also have 
			access="remote"
			An example of a component function with the correct output:
		
			<cffunction name="myMethod" output="true" access="remote" returntype="void">
				<!--- your method may not need a parameter. If you do need it, you should add regular cfargument attributes such as type, required, etc --->
				<cfargument name="oneParameter" />
				<!--- do something with the parameter sent, output result --->
				<cfoutput>&myresult=hi Flash!&loaded=true</cfoutput>
				<!--- loaded variable is required to indicate that the result has loaded --->
			</cffunction>
			In this case, callBack function will receive an object with two variables: myresult and loaded.
	--->

	<cfif NOT len(component) OR NOT len(method)>
		<cfthrow type="MissingAttributes" detail="Component and method attributes are required">
	</cfif>
	
	<cfset method_signature = "#method#_#ReplaceNoCase(component, '.', '_', 'all')#">
	<cfsavecontent variable="callingFunction">
		<cfoutput>
			// empty movie clip to store the data that will be sent
			// the level number can be any high number. Because it will always be the same, it will overwrite the previous movieclip, saving memory usage
			var #method_signature#_dataholder  = this.createEmptyMovieClip('dataholder',4587);
			#method_signature#_dataholder.method = "#method#";
			<cfloop collection="#params#" item="param">
				#method_signature#_dataholder.#param# = #params[param]#;
			</cfloop>
			<cfloop index="_pair" list="#CFCparmsFromFlash#" delimiters=",">
				<cfset varName = Request.commonCode._GetToken(_pair, 1, "=")>
				<cfset varVal = Request.commonCode._GetToken(_pair, 2, "=")>
				#method_signature#_dataholder.#varName# = #varVal#;
			</cfloop>
			#method_signature#_dataholder.loadVariables ('#component#', 'POST');	
			var #method_signature#_obj = {};
			var #method_signature#_result = {};
			var #method_signature#_timeout_ticks = (60000 / 250);

			var #method_signature#_checkData = function(obj) {
				obj._cnt++;
				if ( (obj._cnt > #method_signature#_timeout_ticks) || (#method_signature#_dataholder.loaded != undefined) ) {
					clearInterval(obj.id);
					if (obj._cnt < #method_signature#_timeout_ticks) {
						var i;
						for (i in #method_signature#_dataholder) {
							#method_signature#_result[i] = #method_signature#_dataholder[i];
						}
						#method_signature#_dataholder.loaded = undefined;
						#callBack#(#method_signature#_result);
					} else {
						alert('Server timed-out - unable to retrieve data (#method_signature#).  PLS contact the organization that produced this system and report this error.');
					}
				}
			}

			#method_signature#_obj._cnt = 0;
			#method_signature#_obj.id = setInterval(#method_signature#_checkData, 250, #method_signature#_obj);
		</cfoutput>
	</cfsavecontent>
	
	<cfreturn callingFunction>

</cffunction>

<cfscript>
	Request.flashCallCFC = flashCallCFC;
</cfscript>

<cfinclude template="cfinclude_meta_vars.cfm">

<cfset Request.const_pna_method_part_nums_symbol = "part_nums">
<cfset Request.const_pna_method_skus_symbol = "skus">

<cfsavecontent variable="Request.AS_stripTickMarks">
	function stripTickMarks(s) {
		var i = -1;
		var t = '';
		var _ch = '';

		if (s != null) {
			for (i = 0; i < s.length; i++) {
				_ch = s.substring(i, i + 1);
				if (_ch != "'") {
					t = t + _ch; // removes the tick mark because either AS complains or JS complains.
				}
			}
		}
		return t;
	}

</cfsavecontent>

<cfif 0>
	<!--- BEGIN: This block of code MUST reside at the end of this file to allow errors generated within this file to be seen as errors by the developer... --->
	<cfset _mailto = Request.ErrorEmail>
	<CFERROR TYPE="Exception" template="SiteErrorHandler.cfm" mailto="#_mailto#">
	<CFERROR TYPE="Request" template="SiteErrorHandler.cfm" mailto="#_mailto#">
	<CFERROR TYPE="Validation" template="SiteErrorHandler.cfm" mailto="#_mailto#">
	<!--- END! This block of code MUST reside at the end of this file to allow errors generated within this file to be seen as errors by the developer... --->
</cfif>

<cfif 0>
	<cftry>
		<CFLOCK SCOPE="SESSION" TIMEOUT="300" TYPE="EXCLUSIVE">
			<cfscript>
				if ( (NOT IsDefined("Session.userParms")) OR (NOT IsQuery(Session.userParms)) ) {
					Session.userParms = QueryNew('id, username, password, dt', 'integer, varchar, varchar, date');
				}
			</cfscript>
		</CFLOCK>
	
		<cfcatch type="Any">
		</cfcatch>
	</cftry>
</cfif>

<cfset Request.cfinclude_application_loaded = "True">
