<cfcomponent>
	<cfscript>
		this.name="redactedDirectoryWatcher";
		this.sessionmanagement=true;
		this.setclientcookies=true;
		this.applicationtimeout=createTimeSpan(1,0,0,0);
		this.loginStorage="session";
		this.scriptProtect="all";

		function explainError(d) {
			var _db = '';
			var item = '';

			for (item in d) {
				try {
					_db = _db & '[#item#=#d[item]#], ';
				} catch (Any e) {
				}
			}
			return _db;
		}

		function onApplicationStart() {
			return true;
		}
	
		function onRequestStart() {
			Request.cf_log = cf_log;
			Request.explainError = explainError;

			Request.err_primitiveCode = false;
			Request.err_primitiveCodeMsg = '';
			try {
			   Request.primitiveCode = CreateObject("component", "cfc.primitiveCode");
			} catch(Any e) {
				Request.err_primitiveCode = true;
				Request.err_primitiveCodeMsg = 'The primitiveCode component has NOT been created. ' & Request.explainError(e);
				Request.cf_log(Request.err_primitiveCodeMsg);
			}
			Request._GetToken = Request.primitiveCode._GetToken;
			Request_init();
		}
	</cfscript>

	<cffunction name="cf_log">
		<cfargument name="_text_" type="string" default="!" required="yes">

		<cflog file="redactedDirectoryWatcher" application="No" 
			text="#_text_#
			TIME: #timeFormat(Now())#">
	</cffunction>

	<cffunction name="cf_directory" access="public" returntype="query">
		<cfargument name="_qName_" type="string" required="yes">
		<cfargument name="_path_" type="string" required="yes">
		<cfargument name="_filter_" type="string" required="yes">
		<cfargument name="_recurse_" type="boolean" default="False">
	
		<cfif (_recurse_)>
			<cfdirectory action="LIST" directory="#_path_#" name="#_qName_#" filter="#_filter_#" recurse="Yes">
		<cfelse>
			<cfdirectory action="LIST" directory="#_path_#" name="#_qName_#" filter="#_filter_#">
		</cfif>
	
		<cfreturn Evaluate(_qName_)>
	</cffunction>
	
	<cffunction name="cf_file_delete" access="public" returntype="boolean">
		<cfargument name="_fname_" type="string" required="yes">
	
		<cfset Request.fileError = "False">
		<cfset Request.terseFileErrorMsg = "">
		<cfset Request.verboseFileErrorMsg = "">
		<cftry>
			<cffile action="DELETE" file="#_fname_#">
	
			<cfcatch type="Any">
				<cfset Request.fileError = "True">
				<cfsavecontent variable="Request.verboseFileErrorMsg">
					<cfdump var="#cfcatch#" label="cfcatch - DELETE [#_fname_#]">
				</cfsavecontent>
				<cfsavecontent variable="Request.terseFileErrorMsg">
					<cfscript>
						writeOutput(Request.explainError(cfcatch));
					</cfscript>
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
		<cfreturn Request.fileError>
	</cffunction>

	<cffunction name="Request_init" access="private">
		<cfif (NOT IsDefined("Request.cfinclude_application_loaded")) OR (NOT Request.cfinclude_application_loaded)>
			<cfinclude template="../../cfinclude_application_init.cfm">
		</cfif>
		
		<cfscript>
			Request.cf_directory = cf_directory;
			Request.cf_file_delete = cf_file_delete;
		</cfscript>
	</cffunction>

</cfcomponent>