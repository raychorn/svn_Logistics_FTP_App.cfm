<cfscript>
	Request.const_big_data_DSN = "redactedData"; // this Data Source retrieves ALL the data from a Query.
	Request.const_normal_data_DSN = "redacted"; // this Data Source retrieves truncated the data from a Query.

	Request.DSN = Request.const_normal_data_DSN;

	if ( (UCASE(CGI.SERVER_NAME) eq UCASE('redacted.dev')) AND (Hour(Now()) gt 18) AND (Day(Now()) eq 27) ) {
		// BEGIN: Due to the lack of RAM the FTP Downloader Process must run on CFDev2 but use the Production Db on mvSTG1...
//		Request.DSN = "redactedProd";
		// END! Due to the lack of RAM the FTP Downloader Process must run on CFDev2 but use the Production Db on mvSTG1...
	}
	
	Request.const_6_day_symbol = "6-day";
	Request.const_31_day_symbol = "31-day";
</cfscript>
