<cfscript>
	_basePath = Request.commonCode.dotDotPrefixForFileNamed(CGI.CF_TEMPLATE_PATH, 'StyleSheet.css');
</cfscript>

<cfsavecontent variable="Request.html_headerContent">
	<cfoutput>
		<html><head>
		<LINK rel="STYLESHEET" type="text/css" href="#_basePath#StyleSheet.css"> 
				<title>#Request.title_bar# (Version #Request.productVersion#) [#Request.DSN#]</title>
				#Request.meta_vars#
				
				<cfif (IsDefined("Request.js_content"))>
					#Request.js_content#
				</cfif>
		</HEAD>
		<BODY>
		<table width="990px" cellpadding="-1" cellspacing="-1">
			<tr>
				<td>
					<table width="100%" cellpadding="-1" cellspacing="-1">
						<tr>
							<td>
								<img src="#Request.commonCode.fullyQualifiedURLprefix()#images/redacted.gif" alt="" width="120" height="19" border="0">
							</td>
							<td>
								<b>#Request._title_bar# Version #Request.productVersion#</b>
							</td>
							<cfif (IsDefined("Request.isLoggedIn"))>
								<cfif (Request.isLoggedIn)>
									<td>
										#Request._html_logoutForm#
									</td>
								</cfif>
							</cfif>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td>
	</cfoutput>
</cfsavecontent>
