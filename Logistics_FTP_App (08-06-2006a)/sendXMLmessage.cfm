<cfsetting showdebugoutput="Yes" requesttimeout="9999">

<cfparam name="input_sku" type="string" default="">
<cfparam name="req_method" type="string" default="#Request.symbol_method_pna#">
<cfparam name="cust_po" type="string" default="">
<cfparam name="pna_method" type="string" default="#Request.const_pna_method_part_nums_symbol#">

<!--- 
	XML Limits per IML :: 
							ProductLineItem limited to max of 30 per XML envelope.
							customerPO limited to max of 1 per XML envelope.
 --->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (PNA Processor -> XML) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>
	
	<script language="JavaScript1.2" type="text/javascript" src="js/disable-right-click-script-III.js"></script>
	<script language="JavaScript1.2" type="text/javascript" src="js/MathAndStringExtend.js"></script>
	<script language="JavaScript1.2" type="text/javascript" src="js/popup_window_obj.js"></script>
	<script language="JavaScript1.2" type="text/javascript" src="js/chromeless_windows.js"></script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		function hideShowObject(id, bool) {
			var dlObj = getGUIObjectInstanceById(id);
			if (dlObj != null) {
				dlObj.style.display = ((bool == true) ? const_inline_style : const_none_style);
			}
		}

		function updateValueOfObject(id, val) {
			var oObj = getGUIObjectInstanceById(id);
			if (oObj != null) {
				oObj.value = val;
			}
		}

		function getValueOfObject(id) {
			var oObj = getGUIObjectInstanceById(id);
			if (oObj != null) {
				return oObj.value;
			}
			return '';
		}

		var tid_timeout = -1;
		var i_timeout_cnt = 0;
		var i_timeout_period = 250;
		var i_timeout_mins = 5;
		var i_timeout_secs = (60 * i_timeout_mins);
		var i_timeout_periods = ((i_timeout_secs * 1000) / i_timeout_period);
		var i_timeout_period_n = parseInt((1000 / i_timeout_period).toString());
		var i_timeout_cnt_n = 0;

		function enableDisableObj(bool, id) {
			var oObj = getGUIObjectInstanceById(id);
			if (oObj != null) {
				oObj.disabled = (((bool == null) || (bool == false)) ? false : true);
			}
		}

		function _processingTimeOut() {
			if (tid_timeout > -1) {
				clearInterval(tid_timeout);
			}
		}

		function processingTimeOut() {
			hideShowObject('div_processing_begin', false)
			hideShowObject('div_processing_end', true)
			hideShowObject('div_processing_abort', false)

			_processingTimeOut();
		}

		function _processingTimedOut() {
			hideShowObject('div_processing_begin', false)
			hideShowObject('div_processing_end', false)
			hideShowObject('div_processing_abort', true)

			_processingTimeOut();
		}

		function initSanityChecker() {
			var oObj = getGUIObjectInstanceById('ta_output');
			if (oObj != null) {
				oObj.value = '';
			}
		}

		function processingSanityChecker() {
			var oObj = getGUIObjectInstanceById('ta_output');
			if (oObj != null) {
				if (oObj.value.length > 0) {
					processingTimeOut();
				}
				i_timeout_cnt++;
				if (i_timeout_cnt > i_timeout_periods) {
					_processingTimedOut();
				}
				if ((i_timeout_cnt % i_timeout_period_n) == 0) {
					i_timeout_cnt_n++;
					var spObj = getGUIObjectInstanceById('span_processing_timer');
					if (spObj != null) {
						spObj.innerHTML = i_timeout_cnt_n + ' of ' + parseInt((i_timeout_periods / i_timeout_period_n).toString());
					}
				}
			}
		}
		
		function window_onunload() {
//			_processingTimedOut();
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

		.normalTextClass {
			font-size: 9px;
		}

		.buttonClass {
			font-size: 10px;
		}

		.normalStatusClass {
			font-size: 12px;
			color: blue;
		}

		.errorStatusClass {
			font-size: 12px;
			color: red;
		}
	</style>
</head>

<body>

<cfscript>
	function xmlEnvelope(_method, _transactionID, _ProductLineItems) {
		var i = -1;
		var list_len = -1;
		var anItem = '';
		var _xml = '';
		
		if (LCase(req_method) eq LCase(Request.symbol_method_pna)) {
			_xml = _xml & '<?xml version = "1.0" encoding = "UTF-8"?>';
			_xml = _xml & '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">';
			_xml = _xml & '<SOAP-ENV:Header>';
			_xml = _xml & '<ns:PartyInfo xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="http://www.tibco.com/namespaces/bc/2002/04/partyinfo.xsd" xmlns:ns="http://www.tibco.com/namespaces/bc/2002/04/partyinfo.xsd">';
			_xml = _xml & '<from>';
			_xml = _xml & '<name>redacted</name>';
			_xml = _xml & '</from>';
			_xml = _xml & '<to>';
			_xml = _xml & '<name>Ingram Micro</name>';
			_xml = _xml & '</to>';
			_xml = _xml & '<operationID>Price And Availability/3.0/Price And Availability Query</operationID>';
			_xml = _xml & '<operationType>sync</operationType>';
			_xml = _xml & '<transactionID>#_transactionID#</transactionID>';
			_xml = _xml & '</ns:PartyInfo>';
			_xml = _xml & '</SOAP-ENV:Header>';
			_xml = _xml & '<SOAP-ENV:Body>';
			_xml = _xml & '<ns0:OperationRequest xmlns:ns0="http://pnarequest.org/body">';
			_xml = _xml & '<ns0:OpHeader>';
			_xml = _xml & '<ns0:userID>visuser1</ns0:userID>';
			_xml = _xml & '<ns0:userPassword>VisIM52705</ns0:userPassword>';
			_xml = _xml & '</ns0:OpHeader>';
			_xml = _xml & '<ns0:PNARequest>';
			list_len = ListLen(_ProductLineItems, ',');
			if (list_len gt 1) {
				for (i = 1; i lte Min(30, list_len); i = i + 1) {
					anItem = Trim(Request.commonCode._GetToken(_ProductLineItems, i, ','));
					_xml = _xml & '<ns0:ProductLineItem>';
					if (LCASE(pna_method) eq LCASE(Request.const_pna_method_skus_symbol)) {
						_xml = _xml & '<ns0:SKU>#anItem#</ns0:SKU>';
					} else if (LCASE(pna_method) eq LCASE(Request.const_pna_method_part_nums_symbol)) {
						_xml = _xml & '<ns0:manufacturerPartNumber>#anItem#</ns0:manufacturerPartNumber>';
					}
					_xml = _xml & '</ns0:ProductLineItem>';
				}
			} else {
				_xml = _xml & '<ns0:ProductLineItem>';
				_xml = _xml & '<ns0:SKU>#_ProductLineItems#</ns0:SKU>';
				_xml = _xml & '</ns0:ProductLineItem>';
			}
			_xml = _xml & '<ns0:priceAndAvailabilityOption>Pricing and Availability</ns0:priceAndAvailabilityOption>';
			_xml = _xml & '</ns0:PNARequest>';
			_xml = _xml & '</ns0:OperationRequest>';
			_xml = _xml & '</SOAP-ENV:Body>';
			_xml = _xml & '</SOAP-ENV:Envelope>';
		} else if (LCase(req_method) eq LCase(Request.symbol_method_os)) {
			_xml = _xml & '<?xml version = "1.0" encoding = "UTF-8"?>';
			_xml = _xml & '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">';
			_xml = _xml & '<SOAP-ENV:Header>';
			_xml = _xml & '<ns:PartyInfo xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="http://www.tibco.com/namespaces/bc/2002/04/partyinfo.xsd" xmlns:ns="http://www.tibco.com/namespaces/bc/2002/04/partyinfo.xsd">';
			_xml = _xml & '<from>';
			_xml = _xml & '<name>redacted</name>';
			_xml = _xml & '</from>';
			_xml = _xml & '<to>';
			_xml = _xml & '<name>Ingram Micro</name>';
			_xml = _xml & '</to>';
			_xml = _xml & '<operationID>OrderStatus/3.0/SyncOrderStatusRequest</operationID>';
			_xml = _xml & '<operationType>sync</operationType>';
			_xml = _xml & '<transactionID>#_transactionID#</transactionID>';
			_xml = _xml & '</ns:PartyInfo>';
			_xml = _xml & '</SOAP-ENV:Header>';
			_xml = _xml & '<SOAP-ENV:Body>';
			_xml = _xml & '<ns0:OperationRequest xmlns:ns0="http://ordestatusrequest.org/body">';
			_xml = _xml & '<ns0:OpHeader>';
			_xml = _xml & '<ns0:userID>visuser1</ns0:userID>';
			_xml = _xml & '<ns0:userPassword>VisIM52705</ns0:userPassword>';
			_xml = _xml & '</ns0:OpHeader>';
			list_len = ListLen(_ProductLineItems, ',');
			if (list_len gt 1) {
				for (i = 1; i lte Min(1, list_len); i = i + 1) {
					anItem = Trim(Request.commonCode._GetToken(_ProductLineItems, i, ','));
					_xml = _xml & '<ns0:OrderInformation>';
					_xml = _xml & '<ns0:customerPO>#anItem#</ns0:customerPO>';
					_xml = _xml & '</ns0:OrderInformation>';
				}
			} else {
				_xml = _xml & '<ns0:OrderInformation>';
				_xml = _xml & '<ns0:customerPO>#_ProductLineItems#</ns0:customerPO>';
				_xml = _xml & '</ns0:OrderInformation>';
			}
			_xml = _xml & '</ns0:OperationRequest>';
			_xml = _xml & '</SOAP-ENV:Body>';
			_xml = _xml & '</SOAP-ENV:Envelope>';
		}
		
		return _xml;
	}

	_trans_id = Request.commonCode.uniqueTimeBasedUUID();
	_parms = '';
	if (LCase(req_method) eq LCase(Request.symbol_method_pna)) {
		_parms = input_sku;
	} else if (LCase(req_method) eq LCase(Request.symbol_method_os)) {
		_parms = cust_po;
	}
	_input = xmlEnvelope(req_method, _trans_id, _parms);

	try {
		if (Len(Trim(_input)) gt 0) {
			xmlHTTP = CreateObject("COM", "MSXML2.XMLHTTP");
			XMLHTTP.Open("POST", Request.iml_soap_server_url, False);
			XMLHTTP.setRequestHeader("SOAPAction", Request.iml_soap_server_url);
			XMLHTTP.setRequestHeader("Content-Type", "text/xml");
			XMLHTTP.send(_input);
	
			if (IsDefined("XMLHTTP.responseText")) {
				_output = XMLHTTP.responseText;
			}
		} else {
			_output = 'ERROR: No data to retrieve due to a system error.';
		}
	} catch (Any e) {
		writeOutput('<font color="red"><b>ERROR: See Error detail below:</b></font>');
		writeOutput(Request.primitiveCode.cf_dump(e, 'cfcatch error detail', true));
	}

	if (NOT IsDefined("_output")) {
		_output = '--- MISSING DATA ---';
	}

	_output = Replace(_output, Chr(13), "", 'all');
	_output = Replace(_output, Chr(10), "", 'all');
	_output = Replace(_output, "&##10;", "", 'all');
	sql_output = Replace(_output, "'", "''", 'all');
</cfscript>

<cfif 0>
	<cfoutput>
		<script language="JavaScript1.2" type="text/javascript">
		<!--
			parent.enableDisableObj(false, 'btn_browse_data');
			parent.enableDisableObj(false, 'btn_continue');
			parent.updateValueOfObject('ta_input', '#_input#');
			parent.updateValueOfObject('ta_output', '#_output#');
	//		alert(101);
			parent.enableDisableObj(false, 'btn_inspect_input');
			parent.enableDisableObj(false, 'btn_inspect_output');
		// --> 
		</script>
	</cfoutput>
<cfelse>
	<cfif 0>
		<cfsavecontent variable="_input_xml_dump">
			<cfset myDoc = XMLParse(_input, false)>
			<cfdump var="#myDoc#" label="Input XML">
		</cfsavecontent>
	
		<cfsavecontent variable="_output_xml_dump">
			<cfset myDoc = XMLParse(_output, false)>
			<cfdump var="#myDoc#" label="Output XML">
		</cfsavecontent>
	</cfif>

	<cfscript>
		myDoc = XMLParse(_input, false);
		s_output_input = Request.commonCode.xmlNodeWalker(myDoc.xmlRoot.xmlNodes, 1, false);
		s_output_input = ReplaceNoCase(s_output_input, '<br>', Chr(13), 'all');

		writeOutput('<table width="100%" cellpadding="-1" cellspacing="-1">');
		writeOutput('<input type="hidden" id="browser_buffer" value="">');

		writeOutput('<tr>');
		writeOutput('<td>');
		writeOutput('<b>INPUT:</b>');
		writeOutput('<br>');
		writeOutput('<button id="btn_inspect_input" class="buttonClass" onclick="var val = getValueOfObject(' & "'ta_input'" & '); updateValueOfObject(' & "'browser_buffer'" & ', val); openChromeless(' & "'win_inspect_input'" & ', ' & "'data_inspector.html'" & '); return false;">[Inspect Raw XML]</button>');
		writeOutput('<br>');
		writeOutput('<br>');
		writeOutput('<button id="btn_inspect_input2" class="buttonClass" onclick="var val = getValueOfObject(' & "'ta_input2'" & '); updateValueOfObject(' & "'browser_buffer'" & ', val); openChromeless(' & "'win_inspect_input2'" & ', ' & "'data_inspector.html'" & '); return false;">[Inspect XML Data]</button>');
		writeOutput('</td>');
		writeOutput('<td>');
		writeOutput('<div id="div_raw_xml_input_browser" style="display: inline;"><textarea id="ta_input" readonly cols="120" rows="15" class="textAreaClass">#_input#</textarea></div>');
		writeOutput('<div style="display: none;"><textarea id="ta_input2" readonly cols="120" rows="15" class="textAreaClass">#s_output_input#</textarea></div>');
		writeOutput('</td>');
		writeOutput('</tr>');

		myDoc = XMLParse(_output, false);
		s_output_output = xmlNodeWalker(myDoc.xmlRoot.xmlNodes, 1, false);
		s_output_output = ReplaceNoCase(s_output_output, '<br>', Chr(13), 'all');

		writeOutput('<tr>');
		writeOutput('<td>');
		writeOutput('<b>OUTPUT:</b>');
		writeOutput('<br>');
		writeOutput('<br>');
		writeOutput('<button id="btn_inspect_output" class="buttonClass" onclick="var val = getValueOfObject(' & "'ta_output'" & '); updateValueOfObject(' & "'browser_buffer'" & ', val); openChromeless(' & "'win_inspect_output'" & ', ' & "'data_inspector.html'" & '); return false;">[Inspect Raw XML]</button>');
		writeOutput('<br>');
		writeOutput('<br>');
		writeOutput('<button id="btn_inspect_output2" class="buttonClass" onclick="var val = getValueOfObject(' & "'ta_output2'" & '); updateValueOfObject(' & "'browser_buffer'" & ', val); openChromeless(' & "'win_inspect_output2'" & ', ' & "'data_inspector.html'" & '); return false;">[Inspect XML Data]</button>');
		writeOutput('</td>');
		writeOutput('<td>');
		writeOutput('<div id="div_raw_xml_output_browser" style="display: inline;"><textarea id="ta_output" readonly cols="120" rows="15" class="textAreaClass">#_output#</textarea></div>');
		writeOutput('<div style="display: none;"><textarea id="ta_output2" readonly cols="120" rows="15" class="textAreaClass">#s_output_output#</textarea></div>');
		writeOutput('</td>');
		writeOutput('</tr>');

		writeOutput('<tr>');
		writeOutput('<td colspan="2">');
		writeOutput('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button id="btn_browse_data" class="buttonClass" onclick="parent.DHTMLWindowsObj.closeit(0); parent.DHTMLWindowsObj.closeit(1); parent.clickBrowseBtn(); return false;">[Browse Data]</button>');
		writeOutput('</td>');
		writeOutput('</tr>');

		writeOutput('</table>');
	</cfscript>
</cfif>

<cfset db_err = "False">
<cftry>
	<cfquery name="SaveXML" datasource="#Request.DSN#">
		INSERT INTO IML_XML
		       (proc_dt, trans_id, xml_envelope, method_name, raw_xml, parms, run_mode)
		VALUES (#CreateODBCDateTime(Now())#,'#_trans_id#','#_input#','#UCASE(req_method)#','#sql_output#','#_parms#', '#Request.system_run_mode#')
	</cfquery>

	<cfcatch type="Database">
		<cfset db_err = "True">
	</cfcatch>
</cftry>

<cfif (IsDefined("SaveXML")) AND 0>
	<cfdump var="#SaveXML#" label="SaveXML">
</cfif>

<cfscript>
	if (db_err) {
		writeOutput('<br><span class="errorStatusClass">XML was NOT saved to the database due to an error.</span><br>');
	} else {
		writeOutput('<br><span class="normalStatusClass">XML was saved to the database without error(s).</span><br>');
	}
</cfscript>

</body>
