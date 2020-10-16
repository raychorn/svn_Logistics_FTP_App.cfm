<cfsetting enablecfoutputonly="yes">
<cfif ThisTag.ExecutionMode IS "start">

	<cfsilent>
	
	<!--- 
	
		CF_EasyXML.CFM Version 1.0: 
			a) Generate XML output given CFML structure
			b) Generate CFML structure given XML input

		Author: Ariel Jakobovits <arieljake@yahoo.com>
		
		CF_EasyXML is free software; you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation; either version 2 of the License, or
		(at your option) any later version.
		
		CF_EasyXML is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.
		
		You should have received a copy of the GNU General Public License
		along with CF_EasyXML; if not, write to the Free Software
		Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
		
		Contributions: 
			Ariel Jakobovits <arieljake@yahoo.com>:
				Original concept in early 2004.  Attempting to use the built-in XML functionality of Cold Fusion,
				with XMLAttribute and XMLChild drove me nuts. "This is better."

	--->
	
	<!--- NEW LINE --->
	<cfif UCase(Server.OS.Name) eq UCase("Unix")>
		<cfset ThisTag.newline = Chr(10)>
	<cfelse>
		<cfset ThisTag.newline = Chr(13) & Chr(10)>
	</cfif>

	<!--- Mode 1: XML input to CFML Structure --->
	<cfif StructKeyExists(Attributes,"xml")>
		
		<cfparam name="Attributes.saveas">

		<!--- Function Call and Value Return --->
		<cfset xml_struct = ParseXML(Attributes.xml)>
		<cfset Caller[Attributes.saveas] = xml_struct>

	<!--- Mode 2: CFML Structure to XML output --->
	<cfelseif StructKeyExists(Attributes,"struct")>
		
		<cfparam name="Attributes.saveas">
		<cfparam name="Attributes.root_node" default="">
		<cfparam name="Attributes.make_readable" default="1">
		<cfparam name="Attributes.attribute_list" default="@ll">
		<cfparam name="Attributes.preserve_empties" default="l">
		
		<!--- Attribute Processing --->
		<cfif IsNumeric(Attributes.make_readable)>
			<cfif NOT Attributes.make_readable>	
				<cfset ThisTag.newline = "">
			</cfif>
		<cfelse>
			<cfset ThisTag.newline = Attributes.make_readable>
		</cfif>
		
		<cfset ThisTag.attribute_list = Attributes.attribute_list>
		<cfset ThisTag.preserve_empties = IIF(IsBoolean(Attributes.preserve_empties),"Attributes.preserve_empties","Attributes.preserve_empties GT 0")>
		
		<cfset ThisTag.element_orders = ArrayNew(1)>
		<cfloop from="1" to="#ListLen(StructKeyList(Attributes))#" index="i">
			<cfif StructKeyExists(Attributes,"element_order_#i#")>
				<cfset ArrayAppend(ThisTag.element_orders,Attributes["element_order_#i#"])>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<!--- Function Call and Value Return --->
		<cfset xml_output = Struct2XML(Attributes.struct,Attributes.root_node,"")>
		<cfset Caller[Attributes.saveas] = xml_output>
		
	</cfif>
	
	
	
	<!--- UTILITY FUNCTIONS --->
	<cffunction name="Struct2XML" returntype="string">
		<cfargument name="xml_struct" type="struct" required="yes">
		<cfargument name="cur_node" type="string" required="yes">
		<cfargument name="tabstring" type="string" default="">
	
		<cfset var output = "">
		<cfset var debug_output = "">

		<cfset var keyarray = "">
		<cfset var tabstr = Arguments.tabstring>
		
		<cfset var key = "">
		<cfset var i = "">
		<cfset var j = "">
		<cfset var attribute_count = 0>
	
		<cfset keyarray = ListToArray(StructKeyList(xml_struct))>
		<cfset keyarray = QuickSort(keyarray,ArrayLen(keyarray))>
		
		<cfsavecontent variable="debug_output">
	
		<cfscript>
			// begin START TAG
			if (cur_node neq "") {

				output = output & tabstr & "<#cur_node#";
			
				// add text attributes
				for (i=1; i LTE ArrayLen(keyarray); i = i+1) {
					key = keyarray[i];
					
					if (IsSimpleValue(xml_struct[key]) AND IsAttribute(key)) { 
						output = output & " #key# = ""#xml_struct[key]#""";
						attribute_count = attribute_count + 1;
					}
				}
				
				// end START TAG
				if (ArrayLen(keyarray) eq attribute_count) {
					// end START TAG with no need for END TAG
					output = output & "/>" & ThisTag.newline;
				}
				else {
					// end START TAG with need for END TAG
					output = output & ">" & ThisTag.newline;
				}
			
				tabstr = tabstr & "  ";
			}
			
			try {
	
				// add rest of elements
				for (i=1; i LTE ArrayLen(keyarray); i = i+1) {
					key = keyarray[i];
		
					// struct element
					if (IsStruct(xml_struct[key])) {
						output = output & Struct2XML(xml_struct[key],key,"#tabstr#");
					}
					
					// array element
					else if (IsArray(xml_struct[key])) {
						if (ArrayLen(xml_struct[key]) eq 0) {
							if (ThisTag.preserve_empties) {
								output = output & tabstr & "<#key# />" & ThisTag.newline;
							}
						}
						else {
							for (j=1; j LTE ArrayLen(xml_struct[key]); j = j + 1) {
								if (IsStruct(xml_struct[key][j])) {
									if (NOT StructIsEmpty(xml_struct[key][j]) OR ThisTag.preserve_empties) {
										output = output & Struct2XML(xml_struct[key][j],key,"#tabstr#");
									}
								}
								else if (IsSimpleValue(xml_struct[key][j])) {
									if (xml_struct[key][j] neq "" OR ThisTag.preserve_empties) {
										output = output & "#tabstr#  " & "<#key#>#xml_struct[key][j]#</#key#>" & ThisTag.newline;
									}
								}
							}
						}
					}
					
					// simple value (only get here if root node not specified
					else if (IsSimpleValue(xml_struct[key]) AND NOT IsAttribute(key)) {
						if (xml_struct[key] neq "" OR ThisTag.preserve_empties) {
							output = output & tabstr & "<#key#>#xml_struct[key]#</#key#>" & ThisTag.newline;
						}
					}
				}
			
			} catch (any error) {
				writeOutput("Error: #error.Message# <br> #error.Detail#<br>");
				writeOutput("Current Node: #cur_node#<br>");
				writeOutput("Current Attribute: #key#<br>");
				writeOutput("Output So Far: #output#<br>");
			}
		
			// END TAG if needed
			if (cur_node neq "" AND ArrayLen(keyarray) gt attribute_count) {
				tabstr = Arguments.tabstring;
		
				output = output & tabstr & "</#cur_node#>" & ThisTag.newline;
			}
		</cfscript>
	
		</cfsavecontent>
		
		<cfif debug_output neq "">
			<cfdump var="#debug_output#">
			<cfabort>
		</cfif>
	
		<cfreturn output>
	</cffunction>
	
	<cffunction name="IsAttribute" returntype="boolean">
		<cfargument name="key" type="string">
		
		<cfif ThisTag.attribute_list eq "@ll" OR ListFindNoCase(ThisTag.attribute_list,key)>
			<cfreturn TRUE>
		</cfif>
		
		<cfreturn FALSE>
	</cffunction>
	
	<cffunction name="QuickSort">
		<cfargument name="values" type="array" required="yes">
		<cfargument name="array_size" type="numeric" required="yes">
	 
	 	<cfif ArrayLen(values) gt 0>
	 		<cfset values = Q_Sort(values, 1, array_size)>
		</cfif>
		
		<cfreturn values>
	</cffunction>
	
	
	<cffunction name="Q_Sort">
		<cfargument name="values" type="array" required="yes">
		<cfargument name="lefty" type="numeric" required="yes">
		<cfargument name="righty" type="numeric" required="yes">

	  	<cfset var pivot = "">
		<cfset var l_hold = "">
		<cfset var r_hold = "">

		<cfscript>
		l_hold = lefty;
		r_hold = righty;

		pivot = values[lefty];
		  
		while (lefty LT righty) {
			while ((EasyCompare(values[righty],pivot) GTE 0) AND (lefty LT righty)) {
				righty = righty - 1;
			}
				
			if (lefty NEQ righty)
			{
				values[lefty] = values[righty];
				lefty = lefty + 1;
			}
		
			while ((EasyCompare(values[lefty],pivot) LTE 0) AND (lefty LT righty)) {
				lefty = lefty + 1;
			}
			
			if (lefty NEQ righty)
			{
				values[righty] = values[lefty];
				righty = righty - 1;
			}
		}
		  
		values[lefty] = pivot;
		pivot = lefty;
		lefty = l_hold;
		righty = r_hold;
		
		if (lefty LT pivot) {
			values = Q_Sort(values, lefty, pivot-1);
		}
		
		if (righty GT pivot) {
			values = Q_Sort(values, pivot+1, righty);
		}
		
		return values;
		</cfscript>
	</cffunction>
	
	<cffunction name="EasyCompare" returntype="numeric">
		<cfargument name="val1" type="string">
		<cfargument name="val2" type="string">
		
		<cfset var i = "">
		
		<cfloop from="1" to="#ArrayLen(ThisTag.element_orders)#" index="i">
			<cfset index1 = ListFindNoCase(ThisTag.element_orders[i],val1)>
			<cfset index2 = ListFindNoCase(ThisTag.element_orders[i],val2)>

			<cfif index1 gt 0 AND index2 gt 0>
				<cfreturn Compare(index1,index2)>
			</cfif>
		</cfloop>
		
		<cfreturn CompareNoCase(val1,val2)>
	</cffunction>
	
	<cffunction name="ParseXml" returntype="struct" output="true">
		<cfargument name="xmlinput" type="string">
		
		<cfset var debug_output = "">
		
		<cfsavecontent variable="debug_output">

		<cftry>
		
			<cfscript>
				This.xmlstruct = StructNew();
				
				cur_node = "This.xmlstruct";
				cur_tag = "";
				cur_tagindex = "";
				cur_attributes = "";
				
				hasendtag = 0;
				tag_status = "";
				
				error = "";
	
				xmlinput = ListToArray(xmlinput,ThisTag.newline);
			
				while (ArrayLen(xmlinput) gt 0) {
				
					// grab and remove the next input line
					line = Trim(xmlinput[1]);
					ArrayDeleteAt(xmlinput,1);
		
					// replace multiple spaces with just one
					line = REReplace(line,"\s{2,}"," ","All"); 
			
					if (line neq "") {
					
						/* **********
						   ENDING TAG
						   **********
						*/
						if (Left(line,2) eq "</") {
						
							// debugging output
							writeOutput("<H3 style=""text-decoration:underline; "">END TAG encountered: #HTMLEditFormat(line)#</H3>");
							writeOutput("<ol>");
							writeOutput("<H4><li>Current node is ""#cur_node#"" and Current tag is ""#cur_tag#"".</li></H4>");
						
							// End tag must be complete on one line EX: "</body>"
							if (NOT Find(">",line)) {
								error = "No end bracket for END TAG starting with #HTMLEditFormat(line)#";
								break;
							}
						
							// CHECK for additional stuff going on after ending tag, put back at top of input queue
							if (Find(">",line) lt Len(line)) {
								extra = Mid(line,Find(">",line)+1,Len(line));
								ArrayPrepend(xmlinput,extra);
								line = Left(line,Find(">",line));
							}
						
							// remove starting "</"
							line = Replace(line,"</","","one");
	
							// set "cur_tag" to the tag name, ended by a space, ">", or "/>"
							end_tag = Mid(line,1,REFind("[\s\>\/]{1}",line)-1);
							
							// check that end tag encountered matches matches current tag
							if (LCase(end_tag) neq LCase(cur_tag)) {
								error = "End tag ""#end_tag#"" does not match last start tag encountered: #cur_tag#.";
								break;
							}
							
							// Back up one in hierarchy of xml structure
							cur_node = ListDeleteAt(cur_node,ListLen(cur_node,"."),".");
							
							if (ListLen(cur_node,".") gt 1) {
								cur_tag = ListLast(cur_node,".");
								
								// isolate tag name from array index if appropriate
								if (Right(cur_tag,1) eq "]") {
									cur_tag = ListGetAt(cur_tag,1,"[");
								}
							}
							else {
								cur_tag = "";
							}
							
							writeOutput("<H4><li>Current node is now ""#cur_node#"" and Current Tag is not ""#cur_tag#"".</li></H4>");
							writeOutput("</ol>");
	
						}
						/* **********************
						   END OF END TAG PROCESS
						   **********************
						*/
						
						else if (Left(line,2) eq "<?") {
							// do nothing for xml declaration
						}
						
						/* *********
						   START TAG
						   *********
						*/
						else if (Left(line,1) eq "<") {
							
							// debugging output
							writeOutput("<H3><u>START TAG encountered:</u> ""#HTMLEditFormat(line)#""></H3>");
							writeOutput("<ol>");
							writeOutput("<li>Current node is ""#cur_node#"".</li>");
							
							// Check for additional info on line with start tag (including possibility of end tag)
							// EX: <xmltag>text-data-inside-tag</xmltag>
							// If there is data on the same line, put the "text-data-inside-tag</xmltag>" atop the input queue
							if (Find(">",line) AND Find(">",line) lt Len(line)) {
								extra = Mid(line,Find(">",line)+1,Len(line));
								ArrayPrepend(xmlinput,extra);
								line = Left(line,Find(">",line));
								
								writeOutput("<li>Additional data found with start tag: <strong>#extra#</strong></li>");
							}
							
							// remove starting "<"
							line = Replace(line,"<","","one");
			
							// set "cur_tag" to the tag name, ended by a space, ">", or "/>"
							cur_tag = Mid(line,1,REFind("[\s\>\/]{1}",line)-1);
								
							// remove tag name from line
							line = RemoveChars(line,1,Len(cur_tag));
							
							// if there are attributes for this START TAG add them atop the input queue for later
							if (Len(line) gt 0) {
								ArrayPrepend(xmlinput,line);
								
								writeOutput("<li>Attributes found with start tag: <strong>#line#</strong></li>");
							}
							
							// indicate that we are currently IN a START TAG
							tag_status = "starting";
							
							writeOutput("<li>Current tag is now ""#cur_tag#""</li>");
							writeOutput("</ol>");
						}
						/* ************************
						   END OF START TAG PROCESS
						   ************************
						*/
						
						/* *****************************************
						   TEXT DATA OPTION 1: 
						   A START TAG was opened AND closed and we are IN the tag, 
						   so we are looking at text data between START and END tags
						   *****************************************
						*/
						else if (tag_status eq "started") {
								
							writeOutput("<H3 style=""text-decoration:underline; "">TEXT DATA encountered</H3>");
							writeOutput("#line#");
							writeOutput("<ol>");
								
							// Check for a START or END tag on the line to reinsert into the input queue
							temp = Find("<",line);
							if (temp gt 0 AND temp lt Len(line)) {
								extra = Mid(line,temp,Len(line));
								ArrayPrepend(xmlinput,extra);
								line = Left(line,temp-1);
							}
							
							grabvariable = Evaluate("#cur_node#");
							
							// if the current node is a simple value
							// i.e. a tag with no attributes and no inner tags
							// then append the text data to the string
							if (IsSimpleValue(grabvariable)) {
								if (Right(cur_node,1) eq "]") {  
					
									// xml_struct.node1.node2[2] --> 2]
									cur_tagindex = ListLast(cur_node,"[");
									// 2] --> 2
									cur_tagindex = ListFirst(cur_tagindex,"]");
									
									// xml_struct.node1.node2[2] --> xml_struct.node1.node2
									// NOTE: + 2 for the "[" and the "]"
									temp = Left(cur_node,Len(cur_node) - ( Len(cur_tagindex) + 2 ) );
									
									// set the element to the tag content
									ArraySet(Evaluate("#temp#"),cur_tagindex,cur_tagindex,line);
								}
								else {
									// get pointer to parent node
									temp = ListDeleteAt(cur_node,ListLen(cur_node,"."),".");
									
									// insert tag content
									StructInsert(Evaluate("#temp#"),cur_tag,line,"yes");
								}
							}
							
							// if the current node is a structure 
							// then add the text data under the "tagcontent" heading
							else if (IsStruct(grabvariable)) {
							
								if (StructIsEmpty(grabvariable)) {
									temp = ListDeleteAt(cur_node,ListLen(cur_node,"."),".");
									StructInsert(Evaluate("#temp#"),cur_tag,line,"yes");
								}
								else {
									if (NOT StructKeyExists(grabvariable,"tagcontent")) {
										StructInsert(grabvariable,"tagcontent","");
									}
		
									grabvariable.tagcontent = ListAppend(grabvariable.tagcontent,line,ThisTag.newline);
								}
							}
							
							// this should not happen - cur_node should not point to an array, only to an element of an array
							else if (IsArray(grabvariable)) {
								error = "Unexpected pointer to array encountered.";
								break;	
							}
							
							writeOutput("<H4><li>Text data appended to ""#cur_node#""</li></H4>");
							writeOutput("<H4><li>Current node is now ""#cur_node#""</li></H4>");
							writeOutput("</ol>");
						}
						/* ************************
						   END OF TEXT DATA OPTION 1 PROCESS
						   ************************
						*/
						
						/* *****************************************
						   TEXT DATA OPTION 2: 
						   A START TAG was opened but NOT closed and we are IN THE START TAG, 
						   so we are looking at attributes of the START TAG
						   *****************************************
						*/
						else if (tag_status eq "starting") {
						
							writeOutput("<H3><u>START TAG ATTRIBUTES encountered:</u> #line#</H3>");
							writeOutput("<ol>");
							writeOutput("<li>Current node is ""#cur_node#"" and Current tag is ""#cur_tag#""</li>");
							
							if (hasendtag lt 0) {
								use_same_struct = 1;
							} else {
								use_same_struct = 0;
							}
							
							// Check for the end of the START TAG and add the rest to the input queue
							temp = Find(">",line);
							if (temp gt 0) {
								tag_status = "started";
								
								// Prepend additional data beyond close of START TAG to input queue
								if (temp lt Len(line)) {
									extra = Mid(line,temp+1,Len(line));
									ArrayPrepend(xmlinput,extra);
									line = Left(line,temp);
								}

								if (Right(line,2) eq "/>") {
									hasendtag = 0;
								
									// remove ending "/>"
									if (Len(line) gt 2) {
										line = Left(line,Len(line)-2);
									} else {
										line = "";
									}
								}
								else {
									hasendtag = 1;
									
									// remove ending ">"
									if (Len(line) gt 1) {
										line = Left(line,Len(line)-1);
									} else {
										line = "";
									}
								}
							}
							else {
								hasendtag = -1;
							}
							
							// Parse tag attributes
							// EX: <xml-tag attr1="" attr2="" ...
							cur_attributes = ParseAttributes(line);
								
							writeOutput("<li>""#cur_tag#"" tag attributes parsed: #line#.</li>");
	
							// Before we add the current tag to the XMLSTRUCT,
							// We must check that the parent node to the current node is not a simple value
							// since the default behavior for a node with no attributes is to save the node
							// as a simple value. Now that we know there are inner tags, we must convert this
							// parent node to a structure.
							if (IsSimpleValue(Evaluate("#cur_node#"))) {
					
								// if the parent node is an element in an array
								// EX: xml_struct.node1.node2[2]
								if (Right(cur_node,1) eq "]") {  
					
									// xml_struct.node1.node2[2] --> 2]
									cur_tagindex = ListLast(cur_node,"[");
									// 2] --> 2
									cur_tagindex = ListFirst(cur_tagindex,"]");
									
									// xml_struct.node1.node2[2] --> xml_struct.node1.node2
									// NOTE: + 2 for the "[" and the "]"
									temp = Left(cur_node,Len(cur_node) - ( Len(cur_tagindex) + 2 ) );
									
									// set the element to a Struct
									ArraySet(Evaluate("#temp#"),cur_tagindex,cur_tagindex,StructNew());
								}
								else {
									// "#cur_node#" = StructNew();
									parent = ListLast(cur_node,".");
									root = ListDeleteAt(cur_node,ListLen(cur_node,"."),".");
									StructInsert(Evaluate("#root#"),parent,StructNew(),"yes");
								}
							}
	
							// NOTE: Now we know that the parent node ("#node#") is a structure
							
							// if the "#cur_tag#" is NOT an element in the parent node already
							// then we just add it
							if (NOT StructKeyExists(Evaluate("#cur_node#"),cur_tag)) {
								// add the node
								StructInsert(Evaluate("#cur_node#"),cur_tag,cur_attributes);
								
								writeOutput("<li>Put ""#cur_tag#"" into ""#cur_node#"" as structure.</li>");
							}
							
							// there already is an element "#cur_tag#" in the parent node structure...
							else {
	
								// if the cur_node.cur_tag is not an array, then we must make it one because there
								// are multiple elements named "#cur_tag#" belonging to the parent node "#cur_node#"
								if (NOT IsArray(Evaluate("#cur_node#.#cur_tag#")) ) {
									
									writeOutput("<H4><li>""#cur_tag#"" exists in ""#cur_node#"" but not as an array.</li></H4>");
									
									// grab the current non-array value of "#cur_node#.#cur_tag#"
									temp = Evaluate("#cur_node#.#cur_tag#");
									
									// Evaluate "#cur_node#" into a variable for manipulation
									grabstruct = Evaluate("#cur_node#");
									
									// Make #cur_tag# in #cur_node# an array
									grabstruct[cur_tag] = ArrayNew(1);
									
									// Add the initial value of #cur_node#.#cur_tag# as the first element of the new array
									ArrayAppend(grabstruct[cur_tag],temp); // OLD: ArrayAppend(Evaluate("#cur_node#.#cur_tag#"),temp);
									
									writeOutput("<li>Converted #cur_node#.#cur_tag# to array and added first element.</li>");
								}
					
								writeOutput("<H4><li>""#cur_tag#"" exists in ""#cur_node#"" as an array.</li></H4>");
	
								if (use_same_struct AND IsStruct(cur_attributes)) {
									grabstruct = Evaluate("#cur_node#.#cur_tag#");
									
									if (IsArray(grabstruct)) {
										grabindex = ArrayLen(grabstruct);
										grabstruct = Evaluate("#cur_node#.#cur_tag#[#grabindex#]");
									}
									
									key_list = StructKeyList(cur_attributes);
									for (i=1; i LTE ListLen(key_list); i = i + 1) {
										key = ListGetAt(key_list,i);
										StructInsert(grabstruct,key,cur_attributes[key],"yes");
									}
								}
								else {
									// Append the value of nodestruct, whether it is a structure or a blank string to the "#cur_tag#" array
									ArrayAppend(Evaluate("#cur_node#.#cur_tag#"),cur_attributes);
								}
								
								writeOutput("<li>Appended new element to array #cur_node#.#cur_tag#.</li>");
							}
							
							// 3 Options when we get here:
							//   1) we encountered ">" for the tag, i.e. there IS an end tag ahead - 
							//   	change the current node to include the current tag (simple)
							//   2) we encountered "/>" for the tag, i.e. there is NO end tag - 
							//   	change the current node to include the current tag AND
							//      prepend a non-existent END TAG to make use of the END TAG functionality above so we back up immediately
							//   3) we have yet to encounter a ">" OR a "/>" - 
							//   	don't change anything
							if (hasendtag gte 0) {
	
								if (IsArray(Evaluate("#cur_node#.#cur_tag#"))) {
									writeOutput("<li>""#cur_tag#"" expects end tag. Changing Current Node from ""#cur_node#"" to ""#cur_node#.#cur_tag#[#cur_tagindex#]""</li>");
									
									cur_tagindex = ArrayLen(Evaluate("#cur_node#.#cur_tag#"));
									cur_node = "#cur_node#.#cur_tag#[#cur_tagindex#]";
								}
								else {
									writeOutput("<li>""#cur_tag#"" expects end tag. Changing Current Node from ""#cur_node#"" to ""#cur_node#.#cur_tag#""</li>");
	
									cur_node = "#cur_node#.#cur_tag#";
								}
								
								if (hasendtag eq 0) {
									ArrayPrepend(xmlinput,"</#cur_tag#>");
								}
							}
							
							writeOutput("</ol>");
						}
						/* *********************************
						   END OF TEXT DATA OPTION 2 PROCESS
						   *********************************
						*/
					}
						
				}					
			</cfscript>
			
			<cfcatch type="any">
				<cfset error = CFCATCH.message & "<BR>" & CFCATCH.Detail>
			</cfcatch>
		
		</cftry>
			
		</cfsavecontent>
		
		<cfif error neq "">
			<cfoutput>
			<br>
			<strong>EasyXML Error: </strong>#error#<br>
			<strong>Current Line:</strong><cfdump var="#line#"><br>
			<strong>Current Node Name:</strong>#cur_node#<br>
			<strong>Current Tag:</strong>#cur_tag#<br>
			<strong>Current Array Index:</strong>#cur_tagindex#<br>
			<strong>Current Node:</strong><cfdump var="#cur_attributes#"><br>
			<strong>XML Structure:</strong><cfdump var="#This.xmlstruct#" label="xmlstruct">
			#debug_output#
			</cfoutput>
			<cfabort>
		</cfif>

		<cfreturn This.xmlstruct>	
	</cffunction>
	
	<!--- Takes a line of an XML file and parses the attributes contained in the tag --->
	<!--- NOTE: the tag name itself has been removed as well as the ending > or />. --->
	<cffunction name="ParseAttributes" returntype="any">
		<cfargument name="xmlline" type="string">
		
		<cfset var params = StructNew()>
		<cfset var param = "">
		<cfset var value = "">
		<cfset var equal_sign = "">
		
		<cfset xmlline = Trim(xmlline)>

		<cfloop condition="Len(xmlline) gt 0">
			<cfset xmlline = Trim(xmlline)>

			<cfif Left(line,1) eq "\" OR Left(line,1) eq ">">
				<cfbreak>
				
			<cfelseif param eq "">
				<cfset equal_sign = Find("=",xmlline)>
				<cfset param = Trim(Left(xmlline,equal_sign-1))>

				<cfif REFindNoCase("[^\w\-\:]",param)>
					<cfthrow message="Bad Attribute name #param# encountered.">
				</cfif>

				<cfset xmlline = Trim(RemoveChars(xmlline,1,equal_sign))>

			<cfelse>

				<cfif Left(xmlline,2) eq """""">
					<!--- empty string --->
					<cfset value = "">
					<cfset xmlline = Trim(RemoveChars(xmlline,1,2))>
				<cfelseif Left(xmlline,1) eq """">
					<!--- this removes quotes around value --->
					<cfset value = Mid(xmlline,2,Find("""",xmlline,2)-2)> 
					<cfset xmlline = Trim(RemoveChars(xmlline,1,Find("""",xmlline,2)))>
				<cfelse>
					<cfset value = Left(xmlline,REFind("[\s\>\/]{1}",xmlline))>
					<cfset xmlline = Trim(RemoveChars(xmlline,1,Len(value)))>
				</cfif>

				<cfset StructInsert(params,param,value,"yes")>

				<cfset param = "">
			</cfif>
		</cfloop>
	
		<cfif StructIsEmpty(params)>
			<cfset params = "">
		</cfif>
	
		<cfreturn params>
	</cffunction>

	</cfsilent>

</cfif>
<cfsetting enablecfoutputonly="no">