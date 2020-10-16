<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (Browse Data) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>

	<script language="JScript.Encode" src="js/loadJSCode_.js"></script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		loadJSCode("js/disable-right-click-script-III_.js");
		loadJSCode("js/MathAndStringExtend_.js");

		function foo(v) {
			alert(v);
		}
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

		.textAreaClass {
			font-size: 10px;
		}

		.boldStatusClass {
			font-size: 10px;
			color: black;
			font-weight: bold;
		}

		.errorStatusClass {
			font-size: 10px;
			color: red;
		}

		.normalStatusClass {
			font-size: 10px;
			color: blue;
		}

		.debugStatusClass {
			font-size: 10px;
			color: green;
		}
</style>
</head>

<body>

<cfquery name="GetXMLRecords" datasource="#Request.DSN#">
	SELECT proc_dt, trans_id, xml_envelope, method_name, raw_xml, parms, run_mode
	FROM IML_XML
	ORDER BY proc_dt
</cfquery>

<cfif 0>
	<cfinclude template="XMLToStruct.cfm">
</cfif>

<cfif (IsQuery(GetXMLRecords)) AND 1>
	<cfscript>
		_raw_xml = GetXMLRecords.raw_xml;

		const_xml_begin_tag = '<?xml ';
		const_xml_end_tag = '?>';

		i = FindNoCase(const_xml_begin_tag, GetXMLRecords.raw_xml);
		if (i gt 0) {
			j = FindNoCase(const_xml_end_tag, GetXMLRecords.raw_xml, i + Len(const_xml_begin_tag));
			if (j gt 0) {
				_raw_xml = Mid(GetXMLRecords.raw_xml, j + Len(const_xml_end_tag), Len(GetXMLRecords.raw_xml) - j);
			}
		}
//		myDoc = XMLParse(GetXMLRecords.raw_xml, false);
	</cfscript>
</cfif>

<cfset grid_width = 915>

<cfsavecontent variable="xmlGrid_onChange">
//	getURL("javascript:foo('{" + xmlGrid.dataProvider[xmlGrid.selectedIndex].trans_id + "}')");
</cfsavecontent>

<cfscript>
	_params = StructNew();
	_params["mask"] = "'mmmm dd of yyyy hh:mm:ss'";
	s_sendData = Request.flashCallCFC('dataResponder.cfc', 'getData', _params, '_root.receiveData', 'trans_id=xmlGrid.dataProvider[xmlGrid.selectedIndex].trans_id');
</cfscript>

<cfsavecontent variable="receiveCall">
	myForm.input_data = 'Accessing Database... PLS Stand-by...';
	myForm.output_data = myForm.input_data;
	
	_root.receiveData = function(obj:Object) {
		//in this case, the cfc returns a variable called time, so we will get it in the parameter (obj) of this callback function    
		//we will simply use it to show it in the input control display     
		myForm.input_data = obj.xml_envelope; // obj.trans_id + '\n' + 
		myForm.output_data = obj.raw_xml;
	}
</cfsavecontent>

<cfsavecontent variable="input_data_btn_action">
//	_global.data = myForm.input_data;
// #input_data_btn_action#
alert('clicked +++ ' + 'i = [' + xmlGrid.selectedIndex + '], ' + xmlGrid.dataProvider[xmlGrid.selectedIndex].trans_id);
</cfsavecontent>

<cfform name="myForm" action="" method="POST" format="Flash" skin="haloBlue">
	<cfformgroup type="ACCORDION" visible="Yes" enabled="Yes" height="520">
		<cfformgroup  type="page" label="Data Browser" visible="Yes" enabled="Yes">
			<cfformgroup  type="vdividedbox" visible="Yes" enabled="Yes">
				<cfformgroup  type="page" visible="Yes" enabled="Yes" tooltip="Click on any row to see the XML Input/Output in the preview panes below.">
					<cfgrid name="xmlGrid" height="145" width="#grid_width#" tooltip="Click on any row to see the XML Input/Output in the preview panes below." query="GetXMLRecords" insert="No" delete="No" sort="Yes" bold="No" italic="No" autowidth="true" appendkey="No" highlighthref="No" enabled="Yes" visible="Yes" griddataalign="LEFT" gridlines="Yes" rowheaders="No" rowheaderalign="LEFT" rowheaderfont="Verdana" rowheaderfontsize="10" rowheaderitalic="No" rowheaderbold="No" colheaders="Yes" colheaderalign="CENTER" colheaderfont="Verdana" colheaderfontsize="10" colheaderitalic="No" colheaderbold="Yes" selectmode="BROWSE" picturebar="No" onchange="#receiveCall##s_sendData#">
						<cfgridcolumn name="run_mode" header="Mode" headeralign="LEFT" dataalign="LEFT" width="40" font="Verdana" fontsize="9" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="proc_dt" header="Date" headeralign="LEFT" dataalign="LEFT" width="140" font="Verdana" fontsize="9" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="trans_id" header="Transaction ID" width="215" font="Verdana" fontsize="9" headeralign="LEFT" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="xml_envelope" header="XML Input" width="#Int(grid_width - (140 + 215 + 40 + 200 + 40)) / 2#" font="Verdana" fontsize="9" headeralign="LEFT" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="method_name" header="Type" width="40" font="Verdana" fontsize="9" headeralign="LEFT" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="raw_xml" header="XML Output" headeralign="LEFT" dataalign="LEFT" width="#Int(grid_width - (140 + 215 + 40 + 200 + 40)) / 2#" font="Verdana" fontsize="9" bold="No" italic="No" display="Yes" headerbold="No" headeritalic="No">
						<cfgridcolumn name="parms" header="Parms" width="200" font="Verdana" fontsize="9" headeralign="LEFT" dataalign="LEFT" bold="No" italic="No" select="No" display="Yes" headerbold="No" headeritalic="No">
					</cfgrid>
				</cfformgroup>
				<cfset panel_width = (grid_width + 25)>
				<cfset panel_height = 255>
				<cfformgroup  type="page" height="#panel_height#" width="#panel_width#" visible="Yes" enabled="Yes">
					<cfformgroup name="data_browser_mode" type="ACCORDION" visible="Yes" enabled="Yes">
						<cfformgroup  type="page" label="XML Data - Click HERE to view the Data Elements that are contained witin the XML." visible="Yes" enabled="Yes">
							<cfformgroup  type="hdividedbox" visible="Yes" enabled="Yes">
								<cfformgroup  type="panel" label="Input Data" height="#(panel_height - 65 - 16)#" width="#Int((panel_width - 32 - 32 - 5) / 2)#" visible="Yes" enabled="Yes">
									<cfinput type="Hidden" name="input_data" value="">
									<cfformitem type="text" tooltip="Input Data - this is the data that is encapsulated within the raw XML..." visible="Yes" enabled="Yes" bind="{myForm.input_data}"></cfformitem>
								</cfformgroup>
								<cfformgroup  type="panel" label="Output Data" height="#(panel_height - 65 - 16)#" width="#Int((panel_width - 32 - 32 - 5) / 2)#" visible="Yes" enabled="Yes">
									<cfinput type="Hidden" name="output_data" value="">
									<cfformitem  type="text" tooltip="XML Output - this is raw XML and is not formatted, however some characters may not appear correclty in this panel..." visible="Yes" enabled="Yes" bind="{myForm.output_data}"></cfformitem>
								</cfformgroup>
							</cfformgroup>
						</cfformgroup>
						<cfformgroup  type="page" label="Raw XML - Click HERE to view the Raw XML." visible="Yes" enabled="Yes">
							<cfformgroup  type="hdividedbox" visible="Yes" enabled="Yes">
								<cfformgroup  type="panel" label="Input XML" height="#(panel_height - 65 - 10)#" width="#Int((panel_width - 32 - 32 - 5) / 2)#" visible="Yes" enabled="Yes">
									<cfformitem  type="text" tooltip="XML Input - this is raw XML and is not formatted..." visible="Yes" enabled="Yes" bind="{xmlGrid.selectedItem.xml_envelope}"></cfformitem>
								</cfformgroup>
								<cfformgroup  type="panel" label="Output XML" height="#(panel_height - 65 - 10)#" width="#Int((panel_width - 32 - 32 - 5) / 2)#" visible="Yes" enabled="Yes">
									<cfformitem  type="text" tooltip="XML Output - this is raw XML and is not formatted, however some characters may not appear correclty in this panel..." visible="Yes" enabled="Yes" bind="{xmlGrid.selectedItem.raw_xml}"></cfformitem>
								</cfformgroup>
							</cfformgroup>
						</cfformgroup>
					</cfformgroup>
				</cfformgroup>
			</cfformgroup>
		</cfformgroup>
		<cfformgroup  type="page" label="Query Form" visible="Yes" enabled="Yes">
			<cfformitem  type="HTML" visible="Yes" enabled="Yes">To be defined...  (A form will go here to allow Queries to be executed...)  In the meantime... Click on the Data Browser TAB to see the data...</cfformitem>
		</cfformgroup>
	</cfformgroup>
</cfform>

</body>
</html>
