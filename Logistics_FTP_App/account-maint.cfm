<cfparam name="nocache" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (Account Maintenance) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
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
		<cfloop index="_i" from="1" to="#ArrayLen(accts_grid.rowstatus.action)#">
			<cfif (LCASE(accts_grid.rowstatus.action[_i]) eq LCASE("I"))>
				<cfquery name="GetAccount" datasource="#Request.DSN#">
					SELECT id FROM XML_Accounts WHERE (account_name = '#accts_grid.account_name[_i]#')
				</cfquery>

				<cfif (IsQuery(GetAccount)) AND (IsDefined("GetAccount.id")) AND (Len(Trim(GetAccount.id)) gt 0)>
					<cfquery name="UpdateAccounts" datasource="#Request.DSN#">
						UPDATE XML_Accounts
						SET account_name = '#accts_grid.account_name[_i]#', 
							account_number = '#accts_grid.account_number[_i]#', 
							iml_account_number = '#accts_grid.iml_account_number[_i]#', 
							account_reason = '#accts_grid.account_reason[_i]#', 
							partner_name = '#accts_grid.partner_name[_i]#', 
							username = '#accts_grid.username[_i]#'
						WHERE (id = #GetAccount.id#)
					</cfquery>
				<cfelse>
					<cfquery name="InsertAccounts" datasource="#Request.DSN#">
						INSERT INTO XML_Accounts
	                    	(account_name, account_number, iml_account_number, account_reason, partner_name, username)
						VALUES ('#accts_grid.account_name[_i]#','#accts_grid.account_number[_i]#','#accts_grid.iml_account_number[_i]#','#accts_grid.account_reason[_i]#','#accts_grid.partner_name[_i]#','#accts_grid.username[_i]#')
					</cfquery>
				</cfif>
			<cfelseif (LCASE(accts_grid.rowstatus.action[_i]) eq LCASE("U"))>
				<cfif (Len(Trim(accts_grid.id[_i])) gt 0)>
					<cfset where_clause = "(id = #accts_grid.id[_i]#)">
				<cfelse>
					<cfset where_clause = "(account_name = '#accts_grid.account_name[_i]#')">
				</cfif>
				<cfquery name="GetAccount" datasource="#Request.DSN#">
					SELECT id FROM XML_Accounts WHERE #where_clause#
				</cfquery>

				<cfif (IsQuery(GetAccount)) AND (IsDefined("GetAccount.id"))>
					<cfquery name="InsertAccounts" datasource="#Request.DSN#">
						UPDATE XML_Accounts
						SET account_name = '#accts_grid.account_name[_i]#', 
							account_number = '#accts_grid.account_number[_i]#', 
							iml_account_number = '#accts_grid.iml_account_number[_i]#', 
							account_reason = '#accts_grid.account_reason[_i]#', 
							partner_name = '#accts_grid.partner_name[_i]#', 
							username = '#accts_grid.username[_i]#'
						WHERE (id = #GetAccount.id#)
					</cfquery>
				</cfif>
			<cfelseif (LCASE(accts_grid.rowstatus.action[_i]) eq LCASE("D"))>
				<cfquery name="GetAccount" datasource="#Request.DSN#">
					SELECT id FROM XML_Accounts WHERE (account_name = '#accts_grid.original.account_name[_i]#')
				</cfquery>

				<cfif (IsQuery(GetAccount)) AND (IsDefined("GetAccount.id"))>
					<cfquery name="DeleteAccount" datasource="#Request.DSN#">
						DELETE FROM XML_Accounts WHERE (id = #GetAccount.id#)
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
	<cfquery name="qGetXMLAccounts" datasource="#Request.DSN#">
		SELECT id, account_name, account_number, iml_account_number, account_reason, partner_name, username
		FROM XML_Accounts
		ORDER BY account_name
	</cfquery>

	<cfcatch type="Database">
		<cfset db_err = "True">
		<cfsavecontent variable="Request.db_error">
			<cfdump var="#cfcatch#" label="qGetXMLAccounts dbError">
		</cfsavecontent>
	</cfcatch>
</cftry>

<cfsavecontent variable="accts_grid_onChange">
//alert(accts_grid.dataProvider[accts_grid.selectedIndex].account_name.length);
	if (accts_grid.dataProvider[accts_grid.selectedIndex].account_name.length < 2) {
		accts_grid.dataProvider[accts_grid.selectedIndex].account_name = 'required field';
	}

	if (accts_grid.dataProvider[accts_grid.selectedIndex].iml_account_number.length < 2) {
		accts_grid.dataProvider[accts_grid.selectedIndex].iml_account_number = 'required field';
	}

	if (accts_grid.dataProvider[accts_grid.selectedIndex].partner_name.length < 2) {
		accts_grid.dataProvider[accts_grid.selectedIndex].partner_name = 'required field';
	}

	if (accts_grid.dataProvider[accts_grid.selectedIndex].username.length < 2) {
		accts_grid.dataProvider[accts_grid.selectedIndex].username = 'required field';
	}

	if (accts_grid.dataProvider[accts_grid.selectedIndex].account_reason.length < 2) {
		accts_grid.dataProvider[accts_grid.selectedIndex].account_reason = 'required field';
	}
</cfsavecontent>

<cfif (NOT db_err)>
	<cfform action="#CGI.SCRIPT_NAME#" method="POST" name="form_accts_grid" format="Flash" skin="haloSilver" enctype="application/x-www-form-urlencoded">
		<cfformgroup  type="accordion" visible="Yes" enabled="Yes">
			<cfformgroup  type="page" label="Data Entry" visible="Yes" enabled="Yes">
				<cfformgroup  type="panel" label="XML Accounts Browser" visible="Yes" enabled="Yes">
					<cfgrid name="accts_grid" query="qGetXMLAccounts" height="350" insert="Yes" delete="Yes" sort="Yes" font="Verdana" fontsize="9" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="EDIT" picturebar="No" insertbutton="[INSERT an Account]" deletebutton="[DELETE an Account]" onchange="#accts_grid_onChange#">
						<cfgridcolumn name="id" header="##" width="40" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="account_name" header="Account Name" width="200" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="account_number" header="Acct No." width="100" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="iml_account_number" header="IML Acct No." width="80" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="partner_name" header="Partner Name" width="100" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="username" header="UserName" width="80" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="No" headeritalic="No">
						<cfset _remaining_width = (900 - (40 + 125 + 80 + 80 + 100 + 80))>
						<cfgridcolumn name="account_reason" header="Reason for Account" width="#_remaining_width#" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="No" headeritalic="No">
					</cfgrid>
					<cfinput type="Hidden" name="nocache" value="#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#">
					<cfinput type="Submit" name="upd_grid_submit_btn" value="[Save Grid to Db]" visible="Yes" enabled="Yes">
				</cfformgroup>
			</cfformgroup>
			<cfformgroup  type="page" label="Online Help" visible="Yes" enabled="Yes">
				<cfformitem  type="html" height="330" width="700" visible="Yes" enabled="Yes">
					Remember the <b>"Account Name"</b> field must be unique.  In case you enter a non-unique item in this field the effect will be a possible loss of data because the record pointed to by the <b>"Account Name"</b> field will be <u>updated</u>&nbsp;<i>rather than</i>&nbsp;<u>inserted</u> as expected.
				</cfformitem>
			</cfformgroup>
		</cfformgroup>
	</cfform>
<cfelse>
	<BIG><span class="errorStatusClass">ERROR: Cannot Query XML Accounts because:</span></BIG><br>
	#Request.db_error#
</cfif>

</cfoutput>

</body>
</html>
