<cfsetting enablecfoutputonly="No" showdebugoutput="No" requesttimeout="120">

<cfscript>
	err_dataResponder = false;
	try {
	   Request.dataResponder = CreateObject("component", "dataResponder");
	} catch(Any e) {
		err_dataResponder = true;
	   writeOutput('<font color="red"><b>dataResponder component has NOT been created.</b></font><br>');
		if (Request.isServerLocal()) {
			writeOutput(Request.primitiveCode.cf_dump(e, 'CreateObject("component", "dataResponder")', false));
		}
	}
</cfscript>

<cfparam name="nocache" type="string" default="">
<cfparam name="recid" type="string" default="-1">
<cfparam name="repName" type="string" default="">
<cfparam name="rec_id" type="string" default="">
<cfparam name="allow_dl" type="boolean" default="False">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Tibco FTP Background Job LaunchPad</title>

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

		.normalClass {
			font-size: 10px;
		}

		.normalBoldClass {
			font-size: 10px;
			font-weight : bold;
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

<cfoutput>
	<cfset bool_usefulData = "False">
	<cfinclude template="cfinclude_processRawData.cfm">
	
	<cfif (bool_usefulData)>
		<cfif (NOT db_err)>
			<cfscript>
				fName = Request.excelReader.filterAlphaNumeric(repName);
				
				writeOutput(Request.primitiveCode.__debugQueryInTable(qFTPTrashData, 'FTP Trash Data (parsed-out of the raw data)', true, ListPrepend(Request.dQ.COLUMNNAMES, 'id', ',')));
			</cfscript>

		<cfelse>
			<BIG><span class="errorStatusClass">ERROR: Cannot Query FTP Reports Trash Data because:</span></BIG><br>
			#Request.db_error#
		</cfif>
	</cfif>
</cfoutput>

</body>
</html>
