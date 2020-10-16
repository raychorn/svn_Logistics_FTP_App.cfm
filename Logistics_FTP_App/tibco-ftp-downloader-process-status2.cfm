<cfsetting enablecfoutputonly="No" showdebugoutput="No">

<cfoutput>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfset secs_to_wait = 30>

<cfscript>
	_metaTag = '';
	_metaTagInfo = '';
	_repName = '[Processing Done - for now '  & Request.commonCode.tibcoFTPDownloader2LatestDate() & ']<br>(Check again at the next scheduled run-time - see the appropriate status message above.)';
	_msg = Request.commonCode.tibcoFTPDownloader2LatestInfo();
	if ( (ListLen(_msg, '&') gte 1) AND (ListLen(_msg, '=') gt 1) ) {
		_repName_ = Request.commonCode._GetToken(Request.commonCode._GetToken(_msg, 1, '&'), 2, '=');
		if (Len(Trim(_repName_)) gt 0) {
			_repName = _repName_ & Request.commonCode.tibcoFTPDownloader2LatestDate();
			_metaTag = '<meta http-equiv="refresh" content="#secs_to_wait#;URL=#CGI.SCRIPT_NAME#">';
			_metaTagInfo = ' (This status will be updated every #secs_to_wait# secs and will refresh again in <span id="will_refresh_again"></span>.)';
		}
	}
</cfscript>

<html>
<head>
	<title>Tibco FTP Process Status</title>

<cfscript>
	writeOutput(_metaTag);
</cfscript>

	<script language="JScript.Encode" src="js/loadJSCode_.js"></script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		loadJSCode("js/MathAndStringExtend_.js");
	// --> 
	</script>

	<script language="JavaScript1.2" type="text/javascript">
	<!--
		var today = new Date();
		var refresh_begin_time = today.getTime();
		
		function refresh_staus() {
			var aObj = -1;
			var _today = new Date();
			var now_ms = _today.getTime();
			var elap_secs = #secs_to_wait# - ((now_ms - refresh_begin_time) / 1000);
			var aa = elap_secs.toString().split('.');
			elap_secs = aa[0];
			aObj = getGUIObjectInstanceById('will_refresh_again');
			if (aObj != null) {
				aObj.innerHTML = '<b>' + elap_secs + ' sec(s) </b>';
			}
		}

		var timerID = -1;
		
//		alert('getGUIObjectInstanceById = ' + getGUIObjectInstanceById);
		var anObj = getGUIObjectInstanceById('will_refresh_again');
		if (anObj != null) {
			timerID = setInterval("refresh_staus()", 1000);
		}

		var server_timerID = -1;

		var server_today = new Date();
		server_today.setHours(#Hour(Now())#, #Minute(Now())#, #Second(Now())#, 0);
		
		function display_realtime_clock() {
			var aObj = -1;
			var hh = -1;
			var mm = -1;
			var ss = -1;
			var ampm = '';
			var _hh = -1;
			var _mm = -1;
			var _ss = -1;

			aObj = getGUIObjectInstanceById('div_realtime_clock');
			if (aObj != null) {
				_hh = hh = server_today.getHours();
				_mm = mm = server_today.getMinutes();
				_ss = ss = server_today.getSeconds();
				if (ss < 10) {
					ss = '0' + ss.toString();
				}
				if (mm < 10) {
					mm = '0' + mm.toString();
				}
				ampm = 'am';
				if (hh > 11) {
					ampm = 'pm';
					if (hh > 12) {
						hh -= 12;
					}
				}
				if (hh < 10) {
					hh = '0' + hh.toString();
				}
				aObj.innerHTML = 'Time on the Server is <b>' + _hh + ':' + mm + ':' + ss + ' or ' + hh + ':' + mm + ':' + ss + ' ' + ampm + ' </b>';
				server_today.setHours(_hh, _mm, _ss + 1, 0);
			}
		}

		var server_timerID = setInterval("display_realtime_clock()", 1000);
		
		function unLoadThis() {
			if (timerID != -1) {
				clearInterval(timerID);
			}

			if (server_timerID != -1) {
				clearInterval(server_timerID);
			}
//			parent.window.status = 'UnLoading Page...';
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
			font-size: 10px;
		}
	</style>
</head>

<body onunload="unLoadThis()">

<table width="100%" cellpadding="-1" cellspacing="-1">
	<tr>
		<td width="60%" style="font-size: 10px;">
			<cfscript>
				writeOutput('Parsing Report named: "#_repName#"' & _metaTagInfo);
			</cfscript>
		</td>
		<td width="40%" style="font-size: 10px;">
			<div id="div_realtime_clock"></div>
		</td>
	</tr>
</table>

</body>
</html>

</cfoutput>
