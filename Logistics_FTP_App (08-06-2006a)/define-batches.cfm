<cfparam name="nocache" type="string" default="">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (Define Batches) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
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
	</style>

</head>

<body>

<cfif (IsDefined("form.upd_grid_submit_btn"))>
	<cfoutput>
		<!--- 
			batches_grid.original.BatchName
			batches_grid.batch_type
			batches_grid.batch_parms
			batches_grid.rowstatus.action (I, U)
		 --->
		<cfset db_err = "False">
		<cfset db_err_content = "">
		<cfset db_NativeErrorCode = -1>
		<cftry>
			<cfif (IsDefined("batches_grid"))>
				<cfgridupdate grid = "batches_grid" dataSource = "#Request.DSN#" Keyonly="Yes" tableName = "WorkBatches">
			<cfelse>
			</cfif>
	
			<cfcatch type="Database">
				<cfset db_err = "True">
				<cfset db_NativeErrorCode = cfcatch.NativeErrorCode>
				<cfsavecontent variable="db_err_content">
					<cfdump var="#cfcatch#" label="cfcatch">
				</cfsavecontent>
			</cfcatch>
		</cftry>
	
		<cfif (NOT IsDefined("batches_grid")) OR ( (db_err) AND (db_NativeErrorCode eq 2627) )>
			<cfloop index="_index" from="1" to="#ArrayLen( batches_grid.BatchName)#">
				<cfif (Len(Trim(batches_grid.BatchName[_index])) gt 0) AND (LCASE(batches_grid.BatchName[_index]) neq LCASE('undefined'))>
					<cfset db_err = "False">
					<cfset db_err_content = "">
					<cfset db_NativeErrorCode = -1>
					<cftry>
						<cfquery name="qGetBatchId" datasource="#Request.DSN#">
							SELECT id FROM WorkBatches WHERE (BatchName = '#Request.commonCode.filterQuotesForSQL(batches_grid.BatchName[_index])#')
						</cfquery>

						<cfif (IsDefined("qGetBatchId.id"))>
							<cfif (Len(Trim(qGetBatchId.id)) eq 0)>
								<cfsavecontent variable="_SQL_statement">
									<cfoutput>
										INSERT INTO WorkBatches
												(BatchName, batch_type, batch_parms)
										VALUES ('#Request.commonCode.filterQuotesForSQL(batches_grid.BatchName[_index])#', '#batches_grid.batch_type[_index]#', '#Request.commonCode.filterQuotesForSQL(batches_grid.batch_parms[_index])#')
									</cfoutput>
								</cfsavecontent>
							<cfelse>
								<cfsavecontent variable="_SQL_statement">
									<cfoutput>
										UPDATE WorkBatches
										SET BatchName = '#Request.commonCode.filterQuotesForSQL(batches_grid.BatchName[_index])#', batch_type = '#batches_grid.batch_type[_index]#', batch_parms = '#Request.commonCode.filterQuotesForSQL(batches_grid.batch_parms[_index])#'
										WHERE (id = #qGetBatchId.id#)
									</cfoutput>
								</cfsavecontent>
							</cfif>
	
							<cfquery name="qUpdBatchesGrid" datasource="#Request.DSN#">
								#PreserveSingleQuotes(_SQL_statement)#
							</cfquery>
						</cfif>
				
						<cfcatch type="Database">
							<cfset db_err = "True">
							<cfset db_NativeErrorCode = cfcatch.NativeErrorCode>
							<cfsavecontent variable="db_err_content">
								<cfdump var="#cfcatch#" label="cfcatch">
							</cfsavecontent>
						</cfcatch>
					</cftry>

					<cfif Len(Trim(db_err_content)) gt 0>
						_SQL_statement = [#_SQL_statement#], db_err = [#db_err#],<br>db_NativeErrorCode = [#db_NativeErrorCode#]<br><br>
						#db_err_content#
					</cfif>
				</cfif>
			</cfloop>
			
			<cfif 0>
				<cfdump var="#form#" label="batches_grid">
			</cfif>
		<cfelseif (db_err) AND (db_NativeErrorCode neq -1)>
			#db_err_content#
		</cfif>
	</cfoutput>
</cfif>

<cfquery name="qBatchesGrid" datasource="#Request.DSN#">
	SELECT id, BatchName, batch_type, batch_parms, trans_id
	FROM WorkBatches
	ORDER BY BatchName
</cfquery>

<cfscript>
	qBatchType = QueryNew('batch_type', 'varchar');
	QueryAddRow(qBatchType, 1);
	QuerySetCell(qBatchType, 'batch_type', '?', qBatchType.recordCount);
	QueryAddRow(qBatchType, 1);
	QuerySetCell(qBatchType, 'batch_type', UCASE(Request.symbol_method_pna), qBatchType.recordCount);
	QueryAddRow(qBatchType, 1);
	QuerySetCell(qBatchType, 'batch_type', UCASE(Request.symbol_method_os), qBatchType.recordCount);
</cfscript>

<cfscript>
	qSKUGrid = QueryNew('id, sku_code', 'integer, varchar');
	QueryAddRow(qSKUGrid, 1);
	QuerySetCell(qSKUGrid, 'sku_code', 'place-holder', qSKUGrid.recordCount);
</cfscript>

<cfsavecontent variable="sku_grid_action">
	var t = '';
	var i = -1;
	var p = '';
	for (i = 0; i < sku_grid.dataProvider.length; i++) {
		if ((i + 1) <= 30) {
			sku_grid.dataProvider[i].id = i + 1;
			p = p + sku_grid.dataProvider[i].sku_code;
			if ((i + 1) <= (sku_grid.dataProvider.length - 1)) {
				p = p + ',';
			}
		} else {
			sku_grid.dataProvider[i].sku_code = 'Limit is 30 - Sorry !';
		}
	}

	if (batches_grid.dataProvider[batches_grid.selectedIndex].batch_type == 'OS') {
		// do nothing for OS type here...
	} else if (batches_grid.dataProvider[batches_grid.selectedIndex].batch_type == 'PNA') {
		batches_grid.editField(batches_grid.selectedIndex, 'batch_parms', p); 
	}
</cfsavecontent>

<cfsavecontent variable="cfselect_batch_type_onChange">
	if ( (batches_grid.dataProvider[batches_grid.selectedIndex].BatchName.length > 0) && (batch_type.selectedItem.data != '?') ) { 
		batches_grid.editField(batches_grid.selectedIndex, 'batch_type', batch_type.selectedItem.data); 

		if (batches_grid.dataProvider[batches_grid.selectedIndex].batch_type == 'OS') {
			batches_grid.editField(batches_grid.selectedIndex, 'batch_parms', batch_parms_os.htmlText); 
		} else if (batches_grid.dataProvider[batches_grid.selectedIndex].batch_type == 'PNA') {
		}
	}
</cfsavecontent>

<cfsavecontent variable="batches_grid_onChange">
	if (batches_grid.dataProvider[batches_grid.selectedIndex].batch_type == 'OS') {
		batch_type.selectedIndex = 2;
	} else if (batches_grid.dataProvider[batches_grid.selectedIndex].batch_type == 'PNA') {
		batch_type.selectedIndex = 1;
		var a = batches_grid.dataProvider[batches_grid.selectedIndex].batch_parms.split(',');

		var dp:Array = [];

		var i = -1;
		for (i = 0; i < a.length; i++) {
			var oo:Object = {id:(i + 1), sku_code:a[i]};
			dp.push(oo);
		}

		sku_grid.dataProvider = dp;
		batch_parms_os.htmlText = '';
	} else {
		batch_type.selectedIndex = 0;
	}
</cfsavecontent>

<cfsavecontent variable="cfinput_batch_parms_os_onChange">
	if (batches_grid.selectedIndex.toString().length > 0) {
		if (batches_grid.dataProvider[batches_grid.selectedIndex].batch_type == 'OS') {
			batches_grid.editField(batches_grid.selectedIndex, 'batch_parms', batch_parms_os.htmlText); 
		}
	}
//	alert(batches_grid.selectedIndex.toString());
</cfsavecontent>

<cfoutput>

<cfset form_width = (30 + 170 + 50 + 215 + 250 + 40)>
<div style="padding-left: 15px;">
	<cfform name="form_batches_grid" action="define-batches.cfm?nocache=#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#" method="POST" height="550" width="#form_width#" format="Flash" skin="haloSilver">
		<cfgrid name="batches_grid" query="qBatchesGrid" insert="Yes" delete="Yes" sort="Yes" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="EDIT" picturebar="No" insertbutton="[Insert a Batch]" deletebutton="[Delete a Batch]" onchange="#batches_grid_onChange#">
			<cfgridcolumn name="BatchName" header="Batch Name" width="170" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="Yes" headeritalic="No">
			<cfgridcolumn name="batch_type" header="Type" width="50" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="Yes" headeritalic="No">
			<cfgridcolumn name="batch_parms" header="Parms" width="250" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="Yes" headeritalic="No">
			<cfgridcolumn name="trans_id" header="Trans Id (Filled in by system)" width="215" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="Yes" headeritalic="No">
		</cfgrid>
		<cfinput type="Submit" name="upd_grid_submit_btn" value="[Save Batches to Db]" visible="Yes" enabled="Yes">
	
		<cfformgroup  type="horizontal" width="#(form_width - 16)#" visible="Yes" enabled="Yes">
			<cfformgroup  type="panel" label="Editing Batch Name" width="190" height="70" visible="Yes" enabled="Yes">
				<cfformitem  type="html" visible="Yes" enabled="Yes" bind="{batches_grid.dataProvider[batches_grid.selectedIndex].BatchName}"></cfformitem>
			</cfformgroup>
			<cfformgroup  type="panel" label="Batch Type" width="100" height="70" visible="Yes" enabled="Yes">
				<cfselect name="batch_type" width="50" query="qBatchType" value="batch_type" visible="Yes" enabled="Yes" onchange="#cfselect_batch_type_onChange##sku_grid_action#"></cfselect> 
			</cfformgroup>
			<cfformgroup  type="panel" label="Batch Parms - OS" width="215" height="70" visible="Yes" enabled="Yes">
				<cfinput type="Text" name="batch_parms_os" bind="{batches_grid.dataProvider[batches_grid.selectedIndex].batch_parms}" required="No" visible="Yes" enabled="Yes" size="18" maxlength="50" onchange="#cfinput_batch_parms_os_onChange#">
			</cfformgroup>
	
			<cfformgroup  type="panel" label="Batch Parms - PNA" width="195" height="235" visible="Yes" enabled="Yes">
				<cfgrid name="sku_grid" query="qSKUGrid" insert="Yes" delete="Yes" sort="Yes" bold="No" italic="No" width="175" height="125" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="EDIT" picturebar="No" insertbutton="[+ SKU]" deletebutton="[- SKU]" onchange="#sku_grid_action#">
					<cfgridcolumn name="id" header="##" width="30" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="Yes" headeritalic="No">
					<cfgridcolumn name="sku_code" header="SKU - (Limit 30)" width="170" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="Yes" headeritalic="No">
				</cfgrid>
				<cfinput type="Button" name="upd_batches_grid_btn" value="[Update Selected Batch]" visible="Yes" enabled="Yes" onclick="#sku_grid_action#">
			</cfformgroup>
		</cfformgroup>
	</cfform>
</div>

<!--- 
	alert(batch_type.selectedIndex.toString() + ', ' + batch_type.dataProvider.length.toString() + ', ' + batch_type.selectedItem.data); 
	batches_grid.dataProvider[batches_grid.selectedIndex].batch_type = batch_type.selectedItem.data; 
	<cfgridcolumn name="id" header="##" width="30" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="Yes" headeritalic="No">

	if (batch_type.selectedItem.data == 'OS') {
		batch_parms_os.enabled = true;
	} else if (batch_type.selectedItem.data == 'PNA') {
		batch_parms_os.enabled = false;
	}

	alert(batch_parms_os.htmlText);

//	batch_type.editField(batch_type.selectedIndex, 'batch_type', batches_grid.dataProvider[batches_grid.selectedIndex].batch_type); 
//	batch_type.selectedItem.data = batches_grid.dataProvider[batches_grid.selectedIndex].batch_type;
//	alert(batches_grid.dataProvider[batches_grid.selectedIndex].batch_type);
--->

</cfoutput>

</body>
</html>
