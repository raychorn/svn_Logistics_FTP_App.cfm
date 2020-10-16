<cfparam name="nocache" type="string" default="">
<cfparam name="pna_method" type="string" default="#Request.const_pna_method_part_nums_symbol#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (PNA Data Entry) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
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

<cfoutput>

<cfscript>
	qSKUGrid = QueryNew('id, sku_code', 'integer, varchar');
</cfscript>

<cfsavecontent variable="_grid_action">
	var t = '';
	var i = -1;
	for (i = 0; i < sku_grid.dataProvider.length; i++) {
		if ((i + 1) <= 30) {
			sku_grid.dataProvider[i].id = i + 1;
		} else {
			sku_grid.dataProvider[i].sku_code = 'Limit is 30 - Sorry !';
		}
	}
</cfsavecontent>

<cfsavecontent variable="_submit_action">
	sku_grid.enabled = false;
	submit_btn.enabled = false;
</cfsavecontent>

<div id="div_sku_form">
	<cfform name="form_sku_grid" action="pna.cfm?nocache=#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#" method="POST" height="350" width="325" format="Flash" skin="haloSilver">
		<cfformgroup  type="accordion" visible="Yes" enabled="Yes">
			<cfformgroup  type="page" label="Data Entry" visible="Yes" enabled="Yes">
				<cfif (LCASE(pna_method) eq LCASE(Request.const_pna_method_skus_symbol))>
					<cfgrid name="sku_grid" query="qSKUGrid" insert="Yes" delete="Yes" sort="Yes" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="EDIT" picturebar="No" insertbutton="[Insert a SKU]" deletebutton="[Delete a SKU]" onchange="#_grid_action#">
						<cfgridcolumn name="id" header="##" width="30" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="Yes" headeritalic="No">
						<cfgridcolumn name="sku_code" header="SKU - (Limit 30)" width="170" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="Yes" headeritalic="No">
					</cfgrid>
					<cfinput type="Submit" name="submit_btn" value="[Submit PNA Request using SKU]" visible="Yes" enabled="Yes" onclick="#_submit_action#">
					<cfinput type="Hidden" name="req_method" value="#Request.symbol_method_pna#">
					<cfinput type="Hidden" name="pna_method" value="#pna_method#">
				<cfelseif (LCASE(pna_method) eq LCASE(Request.const_pna_method_part_nums_symbol))>
					<cfgrid name="sku_grid" query="qSKUGrid" width="275" insert="Yes" delete="Yes" sort="Yes" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderitalic="No" colheaderbold="Yes" selectmode="EDIT" picturebar="No" insertbutton="[Insert a Part ##]" deletebutton="[Delete a Part ##]" onchange="#_grid_action#">
						<cfgridcolumn name="id" header="##" width="30" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="Yes" headeritalic="No">
						<cfgridcolumn name="sku_code" header="Part ## - (Limit 30)" width="170" headeralign="CENTER" dataalign="LEFT" bold="No" italic="No" select="Yes" display="Yes" headerbold="Yes" headeritalic="No">
					</cfgrid>
					<cfinput type="Submit" name="submit_btn" value="[Submit PNA Request using Part ##]" visible="Yes" enabled="Yes" onclick="#_submit_action#">
					<cfinput type="Hidden" name="req_method" value="#Request.symbol_method_pna#">
					<cfinput type="Hidden" name="pna_method" value="#pna_method#">
				</cfif>
			</cfformgroup>
			<cfformgroup  type="page" label="Instructions" visible="Yes" enabled="Yes">
				<cfformitem  type="html" visible="Yes" enabled="Yes">
					Click on the Insert button and then click on a grid row under the SKU column header to edit the grid cell.
				</cfformitem>
			</cfformgroup>
		</cfformgroup>
	</cfform>
</div>

</cfoutput>

</body>
</html>
