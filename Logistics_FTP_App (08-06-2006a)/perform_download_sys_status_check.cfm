<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="#(60 * 5 * 2)#">

<cfparam name="sys" type="string" default="#Request.const_6_day_symbol#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Perform Download System Status Check</title>

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

		.listItemClass {
			font-size: 10px;
		}

		.listItemBorderedClass {
			font-size: 10px;
			border-left : thin solid Black;
			border-right : thin solid Black;
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

<cfflush>

<cfscript>
	Request.commonCode.performFtpServerAnalysis(sys, Request.const_6_day_symbol, true);
</cfscript>

</body>
</html>
