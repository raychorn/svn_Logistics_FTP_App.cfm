<!---
	Template Name:		XMLToStruct.cfm
	Template Type: 		User Defined Function
	Developed By:			Tim Newton, MMCP
	Contact Email:		TNewton@MercuryFusion.com
	Contact Website:	MercuryFusion.com
	Creation Date: 		October 1st, 2001
	Description:			Use this function to add native XML support for ColdFusion 5.
										This function does not recognize XML comments and does not allow
										the use of DTDs or Schemas to validate XML input.  This function
										will take a valid XML string and parse that string into a structure
										of structures, arrays and name/value pairs.  This function will
										either return a structure of the passed XML string or a simple value
										error.
	Change History:		Revised 3/23/2003 to create arrays from duplicate namespaces.
	Attributes:				N/A
	Usage:						
										<cfinclude template="/YourSite/XMLToStruct.cfm">
										<cfhttp url="http://www.YourSite.com/SomeXMLDocument.xml" port="80" method="Get">
										<cfset YourStructure = XMLToStruct(CFHTTP.FileContent)>
										<cfif IsStruct(YourStructure)>
											<!--- Code utilizing your new XML structure --->
										<cfelse>
											<!--- Handle the error --->
										</cfif>
--->

<cfscript>
	function XMLToStruct(Input) {
		
		// If we are dealing with more than the required parameters, this is a recursive call
		if(ArrayLen(Arguments) GT 1) {
			Initialized = Arguments[2];
			ParentStructure = Arguments[3];
			TagRecursiveCount = Arguments[4];
			NodePlateau = Arguments[5];
		}
				
		// Otherwise this is the first execution of this function, create the required variables
		else {
			Initialized = "False";
			ParentStructure = StructNew();
			TagRecursiveCount = 0;
			NodePlateau = 0;
		}
				
		// If this is the first call, remove any spaces, tabs, line feeds or carriage returns between nodes
		if(Not Initialized) {
			Input = REReplace(Input,">([[:space:]]+)<","><","ALL");
		}
				
		// Create a temporary structure to hold node levels
		TempStructure = StructNew();
			
		// Ensure that we have a valid input stream
		if(Len(Trim(Input))) {
				
			// Look for the first starting angle bracket, the start of a node
			StartingBracket = Find("<",Input);
					
			// Ensure that we found a starting angle bracket within the input stream 
			if(StartingBracket NEQ 0) {
					
				// Now look for another starting angle bracket to shrink our search for the ending angle bracket
				NextStartingBracket = Find("<",Input,IncrementValue(StartingBracket));
						
				/* If we found another starting bracket, make our ending bracket searchstring
					 the text between the two starting angle brackets */
				if(NextStartingBracket NEQ 0) {
					EndingBracketSearchString = Left(Input,NextStartingBracket);
				}
						
				// Otherwise make our ending bracket searchstring the remainder of the input stream
				else {
					EndingBracketSearchString = Input;
				}
						
				// Look for the ending angle bracket, the end of our node
				EndingBracket = Find(">",EndingBracketSearchString);
						
				// Ensure that we found an ending angle bracket within the searchstring
				if(EndingBracket NEQ 0) {
						
					// Set a variable to the value of the text between the brackets
					NodeName = ReplaceList(Left(Input,EndingBracket),"<,>","");
						
					// If the first token within the name is a backslash, this must be an end tag
					if(Left(NodeName,1) Is "/") {
						NodeType = "EndTag";
					}
							
					// If the last token within the name is a backslash, this must be an empty tag
					else if(Right(NodeName,1) Is "/") {
						NodeType = "EmptyTag";
					}
							
					// Otherwise proceed as a parent node or value node 
					else {
							
						// Set a variable to the value of the ending tag text
						EndingTag = "</" & ListFirst(NodeName," ") & ">";
							
						// Since this shouldn't be an EMPTY node, only proceed if we can locate an end tag
						if(Find(EndingTag,Input)) {
								
							// If the next tag doesn't immediately follow this one, we must be dealing with a value
							if(NextStartingBracket NEQ IncrementValue(EndingBracket)) {
								NodeType = "ValueTag";
							}
									
							// If this tag is immediately followed by another tag, we must be dealing with a parent node
							else {
								NodeType = "StartTag";
							}
						}	
								
						// Otherwise raise an error
						else {
							ThrowParsingError = "No End Tag Found For: '" & NodeName & "'"; 
						}
					}
				}
							
				// If we didn't find an ending angle bracket, raise an error
				else {
					ThrowParsingError = "No Ending Bracket Found In: #HTMLCodeFormat(EndingBracketSearchString)#";
				}
			}
							
			// If we didn't find a starting angle bracket, raise an error
			else {
				ThrowParsingError = "No Starting Bracket Found In: #HTMLCodeFormat(Input)#";
			}
				
			// If we didn't raise an error searching for a node, continue
			if(Not IsDefined("ThrowParsingError")) {
			  
				// Execute based upon the NodeType we are dealing with
				switch(NodeType) {
						
					// If the node is an end tag, delete it from the input stream and set the appropriate parent structure
					case "EndTag": {

						// Remove this end tag from the input stream
						NewInputStream = RemoveChars(Input,1,EndingBracket);

						// Create a variable to hold the current NodePlateau level
						PreviousPlateau = "Plateau_" & NodePlateau;
						
						// Set the TagRecursiveCount to the value of the current NodePlateau level
						TagRecursiveCount = NodePlateau;
							
						// Set the current NodePlateau level back one to properly end this node
						NodePlateau = DecrementValue(NodePlateau);

						// Create a variable to reference this NodePlateau within the parent structure
						ThisNodePlateau = "Plateau_" & NodePlateau;
						
						// Ensure that this NodePlateau is valid within the parent structure
						if(StructKeyExists(ParentStructure,ThisNodePlateau)) {
						
							// Create a temporary reference to the value structure of this NodePlateau
							TempNodeReference = Duplicate(ParentStructure[ThisNodePlateau]);
							
							// Create a variable to reference every attempt at tag completion
							TagCompletionAttempt = 0;
							
							// Loop through the StructKeyList of this NodePlateau to find the parent node structure
							for(LoopIndex = 1; LoopIndex LTE ListLen(StructKeyList(TempNodeReference)); LoopIndex = IncrementValue(LoopIndex)) {
							
								// Increment the value of TagCompletionAttempt to reference this attempt
								TagCompletionAttempt = IncrementValue(TagCompletionAttempt);
							
								// Create a temporary reference to this key within this NodePlateau
								TheKey = ListGetAt(StructKeyList(TempNodeReference),LoopIndex);
								
								// Determine if the current key is a valid structure, if so then proceed
								if(IsStruct(TempNodeReference[TheKey])) {
								
									// Ensure that we are not dealing with an EMPTY node but that the structure of the node IS empty
									if(ListFirst(TheKey," ") Is Replace(NodeName,"/","","ALL") And StructIsEmpty(TempNodeReference[TheKey])) {

										// Fill this empty key with the value of the previous node plateau
										TempNodeReference[TheKey] = ParentStructure[PreviousPlateau];
									
										// Place the TempNodeReference back into the parent structure for permanence
										ParentStructure[ThisNodePlateau] = TempNodeReference;
									
										// Turn the previous node plateau back into an empty structure
										ParentStructure[PreviousPlateau] = StructNew();
										
										// Reset the value of TagCompletionAttempt to designate successful completion of this tag
										TagCompletionAttempt = 0;
										
										// Make LoopIndex greater than the length of the StructKeyList to kill the loop
										LoopIndex = IncrementValue(ListLen(StructKeyList(TempNodeReference)));
									}
								
									// If there is only an EMPTY node on this plateau or all keys are filled, raise an error
									else if(Not StructIsEmpty(TempNodeReference[TheKey]) And LoopIndex GT ListLen(StructKeyList(TempNodeReference))) {
										ThrowParsingError = "Invalid Node Plateau - All Structure Keys Filled";
									}
								}
								
								// Determine if the current key is a valid array, if so then proceed
								else if(IsArray(TempNodeReference[TheKey])) {

									// Append the value of the previous node plateau to our temporary array
									ArrayAppend(TempNodeReference[TheKey],ParentStructure[PreviousPlateau]);
									
									// Place the TempNodeReference back into the parent structure for permanence
									ParentStructure[ThisNodePlateau] = TempNodeReference;
									
									// Turn the previous node plateau back into an empty structure
									ParentStructure[PreviousPlateau] = StructNew();
									
									// Reset the value of TagCompletionAttempt to designate successful completion of this tag
									TagCompletionAttempt = 0;
										
									// Make LoopIndex greater than the length of the StructKeyList to kill the loop
									LoopIndex = IncrementValue(ListLen(StructKeyList(TempNodeReference)));
								}
								
								// If we have completed looping through this node plateau without successfully completing this tag, raise an error
								else if(TagCompletionAttempt EQ ListLen(StructKeyList(TempNodeReference))) {
									ThrowParsingError = "Invalid Node Plateau - No Structures Available for End Tag";
								}
							}
						}
						
						// If this NodePlateau does not exist within the parent structure, raise an error
						else {
							ThrowParsingError = "Invalid Node Plateau - No Key Exists Within The Parent Structure";
						}
						
						// Set the TagRecursiveCount back to a value prior to this node
						TagRecursiveCount = (TagRecursiveCount - 2);
						
						// Increment the NodePlateau value before continuing
						NodePlateau = IncrementValue(TagRecursiveCount);

						// If we didn't raise an error creating structure keys continue
						if(Not IsDefined("ThrowParsingError")) {
							XMLToStruct(NewInputStream,"True",ParentStructure,TagRecursiveCount,NodePlateau);
						}
						
						// Escape this case if we executed
						break;
					}
							
					// If the node is EMPTY, delete it from the input stream and set the appropriate parent structure
					case "EmptyTag": {

						// Remove the trailing backslash associated with EMPTY nodes
						NodeName = Replace(NodeName,"/","","ALL"); 
					
						// If NodePlateau does not equal zero, we need to update TagRecursiveCount to the NodePlateau value
						if(NodePlateau GT 0) {
							TagRecursiveCount = NodePlateau;
						}
							
						// Otherwise increment TagRecursiveCount and set NodePlateau to its value
						else {
							TagRecursiveCount = IncrementValue(TagRecursiveCount);
							NodePlateau = TagRecursiveCount;
						}
							
						// Create a variable to reference this NodePlateau within the parent structure
						ThisNodePlateau = "Plateau_" & TagRecursiveCount;
							
						// If this NodePlateau already exists within the parent structure, insert this node as a sibling
						if(StructKeyExists(ParentStructure,ThisNodePlateau)) {
							StructInsert(ParentStructure[ThisNodePlateau],NodeName,StructNew());
						}
							
						// Otherwise create the new NodePlateau within the parent structure
						else {
							ParentStructure["Plateau_#TagRecursiveCount#"] = StructNew();
							StructInsert(ParentStructure["Plateau_#TagRecursiveCount#"],NodeName,StructNew());
						}
														
						// Remove this node from the input stream
						NewInputStream = RemoveChars(Input,1,EndingBracket);
								
						// If we didn't raise an error creating structure keys continue
						if(Not IsDefined("ThrowParsingError")) {
							XMLToStruct(NewInputStream,"True",ParentStructure,TagRecursiveCount,NodePlateau);
						}
						
						// Escape this case if we executed
						break;
					}
							
					// If this node contains a value instead of child nodes continue
					case "ValueTag": {

						// Set the value of the node to the text between the tags
						NodeValue = Mid(Input,IncrementValue(EndingBracket),(DecrementValue(NextStartingBracket) - EndingBracket));

						// If NodePlateau does not equal zero, we need to update TagRecursiveCount to the NodePlateau value
						if(NodePlateau GT 0) {
							TagRecursiveCount = NodePlateau;
						}
							
						// Otherwise increment TagRecursiveCount and set NodePlateau to its value
						else {
							TagRecursiveCount = IncrementValue(TagRecursiveCount);
							NodePlateau = TagRecursiveCount;
						}
							
						// Create a variable to reference this NodePlateau within the parent structure
						ThisNodePlateau = "Plateau_" & TagRecursiveCount;

						// If this NodePlateau already exists within the parent structure continue 
						if(StructKeyExists(ParentStructure,ThisNodePlateau)) {
																																						
							// If a node by this name already exists within the parent structure, make this node an array 
							if(StructKeyExists(ParentStructure[ThisNodePlateau],NodeName)) {

								// If this node is already an array, append the NodeValue to it
								if(IsArray(Evaluate("ParentStructure.#ThisNodePlateau#.#NodeName#"))) {
									
									// Create a temporary reference to our parent array
									TempNodeArray = Evaluate("ParentStructure.#ThisNodePlateau#.#NodeName#");
									
									// Append the NodeValue to our TempNodeArray
									ArrayAppend(TempNodeArray,NodeValue);
									
									// Replace our parent array with the value of our TempNodeArray
									"ParentStructure.#ThisNodePlateau#.#NodeName#" = TempNodeArray;
								}
								
								// Otherwise create a new temporary array
								else {
									TempNodeArray = ArrayNew(1);
									
									// Append the present value of the parent array to our temporary array
									ArrayAppend(TempNodeArray,Evaluate("ParentStructure.#ThisNodePlateau#.#NodeName#"));
									
									// Then append the current value to the temporary array
									ArrayAppend(TempNodeArray,NodeValue);

									// Finally, set the parent array to the temporary array for permanence
									"ParentStructure.#ThisNodePlateau#.#NodeName#" = TempNodeArray;
								}
							
							}
							
							// Otherwise insert this node as a sibling
							else {		
								StructInsert(ParentStructure[ThisNodePlateau],NodeName,NodeValue);
							}
						}
							
						// Otherwise create the new NodePlateau within the parent structure
						else {
							ParentStructure[ThisNodePlateau] = StructNew();
							StructInsert(ParentStructure[ThisNodePlateau],NodeName,NodeValue);
						}
														
						// Look for the ending angle bracket of the closing tag
						NextEndingBracket = Find(">",Input,NextStartingBracket);
							
						// If we found an ending angle bracket, strip this tag from the input stream
						if(NextEndingBracket NEQ 0) {
							NewInputStream = RemoveChars(Input,1,NextEndingBracket);
						}
							
						// If we did not find an ending angle tag, raise an error
						else {
							ThrowParsingError = "No End Tag Found For: #HTMLCodeFormat(Mid(EndingBracketSearchString,StartingBracket,EndingBracket))#";
						}
								
						// If we didn't raise an error creating structure keys continue
						if(Not IsDefined("ThrowParsingError")) {
							XMLToStruct(NewInputStream,"True",ParentStructure,TagRecursiveCount,NodePlateau);
						}
						
						// Escape this case if we executed
						break;
					}
							
					// If this node contains child nodes rather than a value continue
					case "StartTag": {

						// Create the appropriate structure key for this node
						TempStructure[NodeName] = StructNew();
							
						/* If NodePlateau is greater than zero set TagRecursiveCount equal to NodePlateau
							 indicating that this node is a sibling */
						if(NodePlateau GT 0) {
							TagRecursiveCount = NodePlateau;
						}
								
						// Otherwise increment TagRecursiveCount for use within the parent structure
						else {
							TagRecursiveCount = IncrementValue(TagRecursiveCount);
						}
							
						// If TagRecursiveCount equals NodePlateau indicating a sibling node continue
						if(TagRecursiveCount EQ NodePlateau) {
								
							// If a node by this name already exists within the parent structure, continue
							if(StructKeyExists(ParentStructure["Plateau_#TagRecursiveCount#"],NodeName)) {
							
								// If the node is not already an array within the parent structure, replace it as such
								if(NOT IsArray(Evaluate("ParentStructure.Plateau_#TagRecursiveCount#.#NodeName#"))) {
									
									// Create a temporary node array
									TempNodeArray = ArrayNew(1);
									
									// Append the present value of the parent plateau array to our temporary array
									ArrayAppend(TempNodeArray,Evaluate("ParentStructure.Plateau_#TagRecursiveCount#.#NodeName#"));
									
									// Finally, set the parent array to the temporary array for permanence
									"ParentStructure.Plateau_#TagRecursiveCount#.#NodeName#" = TempNodeArray;
								}

							}
									
							// Insert this node as a sibling
							else {
								StructInsert(ParentStructure["Plateau_#TagRecursiveCount#"],NodeName,StructNew());
							}
								
							// Reset NodePlateau back to zero to indicate that we need to search for the next plateau
							NodePlateau = 0;
						}
							
						// Otherwise create this NodePlateau within the parent structure
						else {							
							ParentStructure["Plateau_#TagRecursiveCount#"] = TempStructure;
						}
							
						// Remove this node from the input stream
						NewInputStream = RemoveChars(Input,1,EndingBracket);
								
						// If we didn't raise an error creating structure keys continue
						if(Not IsDefined("ThrowParsingError")) {
							XMLToStruct(NewInputStream,"True",ParentStructure,TagRecursiveCount,NodePlateau);
						}
						
						// Escape this case if we executed
						break;
					}
				}
			}
		}
				
		// If we do not have an input stream the first time this function is called, raise an error
		else if(Len(Trim(Input)) And Not Initialized) {
		 	ThrowParsingError = "XMLToStruct Requires A Valid XML Input Stream";
		}
						
		// If we haven't raised an error continue
		if(Not IsDefined("ThrowParsingError")) {
							
			// Pass the structure back to the calling template
			return ParentStructure["Plateau_1"];
		}
		
		// Otherwise if we raised an error while parsing, throw the error
		else {
			
			// Pass the error back to the calling template via the Output parameter
			return "XMLToStruct Parsing Error<br><br>" & ThrowParsingError;
		}
	}
</cfscript>
