<cfparam name="nocache" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (Tibco Reports Maintenance) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>

	<script language="JavaScript1.2" type="text/javascript" src="js/disable-right-click-script-III.js"></script>
	<script language="JavaScript1.2" type="text/javascript" src="js/MathAndStringExtend.js"></script>

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

<body>

<cfoutput>

<cfif 0>
	<cfdump var="#form#" label="form scope" expand="No">
</cfif>

<cfif (IsDefined("form.upd_grid_submit_btn"))>
	<cfset db_err = "False">
	<cfset db_err_content = "">
	<cfset db_NativeErrorCode = -1>
	<cftry>
		<cfloop index="_i" from="1" to="#ArrayLen(reportdefs_grid.rowstatus.action)#">
			<cfif (LCASE(reportdefs_grid.rowstatus.action[_i]) eq LCASE("I"))>
				<cfquery name="GetReportDef" datasource="#Request.DSN#">
					SELECT id FROM TibcoReportNameDefs WHERE (report_prefix = '#reportdefs_grid.report_prefix[_i]#')
				</cfquery>

				<cfif (IsQuery(GetReportDef)) AND (IsDefined("GetReportDef.id")) AND (Len(Trim(GetReportDef.id)) gt 0)>
					<cfquery name="UpdateAccounts" datasource="#Request.DSN#">
						UPDATE TibcoReportNameDefs
						SET report_prefix = '#reportdefs_grid.report_prefix[_i]#', 
							report_name = '#reportdefs_grid.report_name[_i]#'
						WHERE (id = #GetReportDef.id#)
					</cfquery>
				<cfelse>
					<cfquery name="InsertReportsDef" datasource="#Request.DSN#">
						INSERT INTO TibcoReportNameDefs
	                    	(report_prefix, report_name)
						VALUES ('#reportdefs_grid.report_prefix[_i]#','#reportdefs_grid.report_name[_i]#')
					</cfquery>
				</cfif>
			<cfelseif (LCASE(reportdefs_grid.rowstatus.action[_i]) eq LCASE("U"))>
				<cfif (Len(Trim(reportdefs_grid.id[_i])) gt 0)>
					<cfset where_clause = "(id = #reportdefs_grid.id[_i]#)">
				<cfelse>
					<cfset where_clause = "(report_prefix = '#reportdefs_grid.report_prefix[_i]#')">
				</cfif>
				<cfquery name="GetReportDef" datasource="#Request.DSN#">
					SELECT id FROM TibcoReportNameDefs WHERE #where_clause#
				</cfquery>

				<cfif (IsQuery(GetReportDef)) AND (IsDefined("GetReportDef.id"))>
					<cfquery name="InsertReportsDef" datasource="#Request.DSN#">
						UPDATE TibcoReportNameDefs
						SET report_prefix = '#reportdefs_grid.report_prefix[_i]#', 
							report_name = '#reportdefs_grid.report_name[_i]#'
						WHERE (id = #GetReportDef.id#)
					</cfquery>
				</cfif>
			<cfelseif (LCASE(reportdefs_grid.rowstatus.action[_i]) eq LCASE("D"))>
				<cfquery name="TibcoReportNameDefs" datasource="#Request.DSN#">
					SELECT id FROM TibcoReportNameDefs WHERE (report_prefix = '#reportdefs_grid.original.report_prefix[_i]#')
				</cfquery>

				<cfif (IsQuery(GetReportDef)) AND (IsDefined("GetReportDef.id"))>
					<cfquery name="DeleteReportsDef" datasource="#Request.DSN#">
						DELETE FROM TibcoReportNameDefs WHERE (id = #GetReportDef.id#)
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>

		<cfcatch type="Database">
			<cfset db_err = "True">
			<cfset db_NativeErrorCode = cfcatch.NativeErrorCode>
			<cfsavecontent variable="db_err_content">
				<cfdump var="#cfcatch#" label="cfcatch" expand="No">
			</cfsavecontent>
		</cfcatch>
	</cftry>

	<cfif (db_err) OR ( (db_err) AND (db_NativeErrorCode eq 2627) )>
		#db_err_content#
	</cfif>
</cfif>

<cfset db_err = "False">
<cftry>
	<cfquery name="qGetTibcoReportDefs" datasource="#Request.DSN#">
		SELECT id, report_prefix, report_name
		FROM TibcoReportNameDefs
		ORDER BY report_name
	</cfquery>

	<cfcatch type="Database">
		<cfset db_err = "True">
		<cfsavecontent variable="Request.db_error">
			<cfdump var="#cfcatch#" label="qGetTibcoReportDefs dbError">
		</cfsavecontent>
	</cfcatch>
</cftry>

<cfsavecontent variable="reportdefs_grid_onChange">
	if (reportdefs_grid.dataProvider[reportdefs_grid.selectedIndex].report_prefix.length < 2) {
		reportdefs_grid.dataProvider[reportdefs_grid.selectedIndex].report_prefix = 'required field';
	}

	if (reportdefs_grid.dataProvider[reportdefs_grid.selectedIndex].report_name.length < 2) {
		reportdefs_grid.dataProvider[reportdefs_grid.selectedIndex].report_name = 'required field';
	}
</cfsavecontent>

<cfif (NOT db_err)>
	<cfform action="#CGI.SCRIPT_NAME#" method="POST" name="form_tibco_grid" format="Flash" skin="haloSilver" enctype="application/x-www-form-urlencoded">
		<cfformgroup  type="accordion" visible="Yes" enabled="Yes">
			<cfformgroup  type="page" label="Data Entry" visible="Yes" enabled="Yes">
				<cfformgroup  type="panel" label="Tibco Report Definitions Browser" visible="Yes" enabled="Yes">
					<cfset _canDelete = "No">
					<cfif (Request.commonCode.isServerLocal())>
						<cfset _canDelete = "Yes">
					</cfif>
					<cfgrid name="reportdefs_grid" query="qGetTibcoReportDefs" height="350" insert="Yes" delete="#_canDelete#" sort="Yes" font="Verdana" fontsize="9" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="EDIT" picturebar="No" insertbutton="[INSERT an Definition]" deletebutton="[DELETE an Definition]" onchange="#reportdefs_grid_onChange#">
						<cfgridcolumn name="id" header="##" width="40" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="report_prefix" header="Report Prefix" width="200" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="#Request.commonCode.isServerLocal()#" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="report_name" header="Report Name" width="100" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="#Request.commonCode.isServerLocal()#" display="Yes" headerbold="No" headeritalic="No">
					</cfgrid>
					<cfinput type="Hidden" name="nocache" value="#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#">
					<cfinput type="Submit" name="upd_grid_submit_btn" value="[Save Grid to Db]" visible="Yes" enabled="Yes">
				</cfformgroup>
			</cfformgroup>
			<cfformgroup  type="page" label="Online Help" visible="Yes" enabled="Yes">
				<cfformitem  type="html" height="330" width="700" visible="Yes" enabled="Yes">
					Remember the <b>"Report Prefix"</b> and <b>"Report Name"</b> field must be unique.  In case you enter a non-unique item in this field the effect will be a possible loss of data because the record pointed to by the <b>"Report Prefix"</b> and <b>"Report Name"</b> field will be <u>updated</u>&nbsp;<i>rather than</i>&nbsp;<u>inserted</u> as expected.
				</cfformitem>
			</cfformgroup>
		</cfformgroup>
	</cfform>
<cfelse>
	<BIG><span class="errorStatusClass">ERROR: Cannot Query Tibco Report Definitions because:</span></BIG><br>
	#Request.db_error#
</cfif>

</cfoutput>

</body>
</html>
