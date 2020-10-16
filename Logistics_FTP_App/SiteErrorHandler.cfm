<cfsetting enablecfoutputonly="No" showdebugoutput="No">

<cfparam name="_debugMode" type="boolean" default="False">
<cfparam name="bool_isServerLocal" type="boolean" default="False">

<CFINCLUDE TEMPLATE="Header.cfm">

<cfoutput>
		<cfif (IsDefined("error"))>
			<cfif 0>
				<cfdump var="#error#" label="error">
			</cfif>

			<cfset Cr = Chr(13)>
			<cfset html_fmtDateTime = DateFormat(error.dateTime, "full") & "&nbsp;" & TimeFormat(error.dateTime, "long")>
			<cfset txt_fmtDateTime = REReplace(REReplace(html_fmtDateTime, "<[^>]*>", "", "all"), "&[^;]*;", "", "all")>
			<cfset terse_errorContent = "Your Location: #error.remoteAddress##Cr#Your Browser: #error.browser##Cr#Date and Time the Error Occurred: #txt_fmtDateTime##Cr#Page You Came From: #error.HTTPReferer##Cr#Message Content: #error.diagnostics##Cr#">

			<cfsavecontent variable="_errorContent">
				<cfoutput>
					<ul style="font-size: 11px;">
					    <li><b>Your Location:</b> #error.remoteAddress#</li>
					    <li><b>Your Browser:</b> #error.browser#</li>
					    <li><b>Date and Time the Error Occurred:</b> #html_fmtDateTime#</li>
					    <li><b>Page You Came From:</b> #error.HTTPReferer#</li>
					    <li><b>Message Content</b>:
					    <p style="font-size: 11px;">#error.diagnostics#</p></li>
					</ul>
					<cfdump var="#error#" label="error" expand="Yes">
				</cfoutput>
			</cfsavecontent>
		</cfif>

		<cfset Request.isSpecialTemplate = false>

		<cfset verbose_errorContent = "">
		<cfif (IsDefined("error"))>
			<cfset verbose_errorContent = Request.commonCode.explainError(error)>
		</cfif>

		<cfif (IsDefined("error"))>
		    <h2>We're sorry -- An Error Occurred</h2>
		    <p>
		        If you continue to have this problem, please contact <a href="mailto:#error.mailTo#?subject=ColdFusion Error for CMS 1.0&body=#URLEncodedFormat(terse_errorContent)#" target="_blank">#error.mailTo#</a>
		        with the following information:</p>
		    <p>
			#_errorContent#
			<cfif ( (Request.commonCode.isServerLocalHost()) OR (Request.commonCode.isServerredactedDevHost()) ) AND 0>
				#verbose_errorContent#
			</cfif>
			
			<cfset mailError = "False">
			<cfset mailErrorMsg = "">
			<cftry>
				<cfmail to="#error.mailTo#" from="#error.mailTo#" subject="ColdFusion Error for HelpDesk" replyto="#error.mailTo#" type="HTML">
					<CFINCLUDE TEMPLATE="Header.cfm">
					#_errorContent#
					<cfif 0>
						#verbose_errorContent#
					</cfif>
					<CFINCLUDE template="footer.cfm">
				</cfmail>

				<cfcatch type="Any">
					<cfset mailError = "True">
					<cfsavecontent variable="mailErrorMsg">
						<cfdump var="#cfcatch#" label="cfcatch">
					</cfsavecontent>
				</cfcatch>
			</cftry>
			
			<cfif (NOT mailError)>
				<b>An EMail was successfully sent to #error.mailTo# - this problem will be looked at a.s.a.p.</b>
			<cfelse>
				<cfif (Request.commonCode.isServerLocalHost()) OR (Request.commonCode.isServerredactedDevHost())>
					<span class="errorClass"><b>An EMail was NOT successfully sent to #error.mailTo# because this is being run in development. Thx.</b></span>
					#mailErrorMsg#
				<cfelse>
					<span class="errorClass"><b>An EMail was NOT successfully sent to #error.mailTo# PLS do this manually. Thx.</b></span>
				</cfif>
			</cfif>
		</cfif>
	
</cfoutput>

<CFINCLUDE template="footer.cfm">
