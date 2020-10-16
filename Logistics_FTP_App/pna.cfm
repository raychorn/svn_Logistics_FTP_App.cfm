<cfsetting requesttimeout="3600">

<cfparam name="input_sku" type="string" default="">
<cfparam name="cust_po" type="string" default="">
<cfparam name="req_method" type="string" default="#Request.symbol_method_pna#">
<cfparam name="nocache" type="string" default="">
<cfparam name="pna_method" type="string" default="#Request.const_pna_method_part_nums_symbol#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (PNA Processor) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>
	
	<script language="JScript.Encode" src="js/loadJSCode_.js"></script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		loadJSCode("js/disable-right-click-script-III_.js");
		loadJSCode("js/MathAndStringExtend_.js");
		loadJSCode("js/popup_window_obj_.js");
		loadJSCode("js/chromeless_windows_.js");

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
	</style>
</head>

<body onunload="window_onunload()">

<cfif (IsDefined("Form")) AND 0>
	<cfdump var="#Form#" label="Form Scope">
</cfif>

<cfif (IsDefined("form.sku_grid.id")) AND 0>
	<cfdump var="#form.sku_grid.id#" label="form.sku_grid.id">
</cfif>

<cfif (IsDefined("form.sku_grid.rowstatus.action")) AND 0>
	<cfdump var="#form.sku_grid.rowstatus.action#" label="form.sku_grid.rowstatus.action">
</cfif>

<cfif (IsDefined("form.sku_grid.sku_code")) AND 0>
	<cfdump var="#form.sku_grid.sku_code#" label="form.sku_grid.sku_code">
</cfif>

<cfscript>
	function processSKUlist(code_array, action_array) {
		var i = -1;
		var s_skus = '';
		for (i = 1; i lte ArrayLen( action_array); i = i + 1) {
			if (UCASE(action_array[i]) eq UCASE('I')) {
				s_skus = ListAppend(s_skus, code_array[i], ',');
			}
		}
		return s_skus;
	}

	input_sku = '';
	if ( (IsDefined("form.sku_grid.sku_code")) AND (IsDefined("form.sku_grid.rowstatus.action")) ) {
		input_sku = processSKUlist(form.sku_grid.sku_code, form.sku_grid.rowstatus.action);
	}

	if ( (Len(Trim(cust_po)) eq 0) AND (Len(Trim(input_sku)) eq 0) ) {
		writeOutput('<font color="red"><BIG><b>ERROR: Missing SKU List - PLS define a SKU list and try again. <a href="pna-data-entry.cfm?nocache=#Abs(RandRange(111111111, 999999999, 'SHA1PRNG'))#">Click HERE to continue...</a></b></BIG></font>');
	} else if ( (Len(Trim(cust_po)) gt 0) OR (Len(Trim(input_sku)) gt 0) ) {
		writeOutput('<input type="hidden" id="browser_buffer" value="">');
	
		_input = '';
	
		_output = '';
		sql_output = _output;
	}
</cfscript>

<cfscript>
	_server = CGI.SERVER_NAME;
	if (LCASE(_server) eq LCASE('coldfusion.servehttp.com')) {
//		_server = _server & ':8085';
	}
	_url = 'http://' & _server & '/' & Request.commonCode._GetToken(CGI.SCRIPT_NAME, 1, '/') & '/sendXMLmessage.cfm?nocache=#URLEncodedFormat(Abs(RandRange(111111111, 999999999, 'SHA1PRNG')))#';
	if (Len(Trim(input_sku)) gt 0) {
		_url = _url & '&input_sku=#URLEncodedFormat(input_sku)#&pna_method=#URLEncodedFormat(pna_method)#';
	} else if (Len(Trim(cust_po)) gt 0) {
		_url = _url & '&cust_po=#URLEncodedFormat(cust_po)#';
	}
	_url = _url & '&req_method=#URLEncodedFormat(req_method)#';
	writeOutput('<small>_url = [#_url#]</small><br>');
	writeOutput('<br><BIG><B>In case this operation produces an error it is likely the XML will be saved to the database - simply dismiss this window and browse the data in the database to confirm.</B></BIG>');
</cfscript>

<cfflush>

<cfoutput>
<script language="JavaScript1.2" type="text/javascript">
<!--
	window.location.href = '#_url#';
// --> 
</script>
</cfoutput>

</body>
</html>
