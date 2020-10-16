<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>redacted SOAP Tests (test1.cfm)</title>
</head>

<body>

<cfsavecontent variable="_xml">
<?xml version = "1.0" encoding = "UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
  <SOAP-ENV:Header>
    <ns:PartyInfo xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns0="http://www.tibco.com/namespaces/bc/2002/04/partyinfo.xsd" xmlns:ns="http://www.tibco.com/namespaces/bc/2002/04/partyinfo.xsd">
      <from>
        <name>redacted</name>
      </from>
      <to>
        <name>Ingram Micro</name>
      </to>
      <operationID>Price And Availability/3.0/Price And Availability Query</operationID>
      <operationType>sync</operationType>
      <transactionID>20050616000001</transactionID>
    </ns:PartyInfo>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body>
    <ns0:OperationRequest xmlns:ns0="http://pnarequest.org/body">
      <ns0:OpHeader>
        <ns0:userID>visuser1</ns0:userID>
        <ns0:userPassword>VisIM52705</ns0:userPassword>
      </ns0:OpHeader>
      <ns0:PNARequest>
        <ns0:ProductLineItem>
          <ns0:SKU>F91380</ns0:SKU>
        </ns0:ProductLineItem>
        <ns0:priceAndAvailabilityOption>Pricing and Availability</ns0:priceAndAvailabilityOption>
      </ns0:PNARequest>
    </ns0:OperationRequest>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
</cfsavecontent>

<cfset _url = "https://malibu.ingrammicro.com/SOAP">

<!--- 
POST https://malibu.ingrammicro.com/SOAP HTTP/1.1
Host: malibu.ingrammicro.com
Content-Type: text/xml; charset=utf-8
Content-Length: #Len(_xml)#
SOAPAction: "https://malibu.ingrammicro.com/SOAP"
 --->

<cfhttp url="#_url#" method="GET" resolveurl="No" throwOnError="Yes">
	<cfhttpparam type="HEADER" name="Content-Type" value="text/xml; charset=utf-8">
	<cfhttpparam type="HEADER" name="Content-Length" value="#Len(_xml)#">
	<cfhttpparam type="HEADER" name="SOAPAction" value='"https://malibu.ingrammicro.com/SOAP"'>
	<cfhttpparam type="XML" name="xml" value="#_xml#">
</cfhttp>

<cfdump var="#cfhttp#">


</body>
</html>
