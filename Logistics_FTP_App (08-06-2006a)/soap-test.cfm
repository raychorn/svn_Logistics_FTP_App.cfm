<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<cfoutput>
		<title>#Request.title_bar# (SOAP ToolKit Tester) [#Request.system_run_mode#] [#Request.iml_soap_server_url#] [#nocache#]</title>
		#Request.meta_vars#
	</cfoutput>
</head>

<body>

<cfsavecontent variable="_xml">
<binding name="TemperatureBinding" type="tns:TemperaturePortType">
   <soap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
   <operation name="getTemp">
      <soap:operation soapAction=""/>
      <input>
         <soap:body use="encoded" namespace="urn:xmethods-Temperature" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </input>
      <output>
         <soap:body use="encoded" namespace="urn:xmethods-Temperature" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"/>
      </output>
   </operation>
</binding>
</cfsavecontent>

<cfsavecontent variable="_payloadHeader">
POST https://malibu.ingrammicro.com/SOAP HTTP/1.1
Host: malibu.ingrammicro.com
Content-Type: text/xml; charset=utf-8
Content-Length: length
SOAPAction: "https://malibu.ingrammicro.com/SOAP"
</cfsavecontent>

<cfsavecontent variable="_xml2">
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

<cfscript>
	soapclient = CreateObject("COM", "MSSOAP.SoapClient30");
//	soapclient.mssoapinit("http://localhost/redacted/VS_PNA_request.xml"); // , "https://malibu.ingrammicro.com/SOAP", "TestServicePort"
//	soapclient.mssoapinit("localhost/redacted/get-temp.wsdl");
//	soapclient.mssoapinit(_xml);
//	soapclient.mssoapinit(_xml2);
//	soapclient.mssoapinit("http://services.xmethods.net/soap/urn:xmethods-delayed-quotes.wsdl");
//	d = soapclient.getQuote("MSFT");

//	soapclient.mssoapinit("http://www.PerfectXML.net/WebServices/SalesRankNPrice/BookService.asmx?wsdl");

	soapclient.mssoapinit("http://services.xmethods.net/soap/urn:xmethods-delayed-quotes.wsdl");
	dd = soapclient.ClientProperty("ServerHTTPRequest");
	writeOutput('A. ServerHTTPRequest = [#dd#]<br>');
	soapclient.ClientProperty("ServerHTTPRequest", True);
	dd = soapclient.ClientProperty("ServerHTTPRequest");
	writeOutput('B. ServerHTTPRequest = [#dd#]<br>');
	
	d = soapclient.getQuote("MSFT");
</cfscript>

<cfdump var="#soapclient#" label="soapclient">

</body>
</html>
