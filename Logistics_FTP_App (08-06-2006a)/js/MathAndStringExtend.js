/** BEGIN: Globals ************************************************************************/
const_block_style = 'block';
const_inline_style = 'inline';
const_none_style = 'none';

//_global_menu_mode = true; // true for the new menu, false for the original menu...
_global_menu_mode = false; // true for the new menu, false for the original menu...

_cache_gui_objects = [];

_cache_onload_functions = [];

_cache_tooltips = [];
_stack_tooltips_obj = [];
_cache_tooltips_timerId = [];
_cache_tooltips_functions = [];

const_text_symbol = 'text';
const_hidden_symbol = 'hidden';
const_textarea_symbol = 'textarea';
const_password_symbol = 'password';

const_function_symbol = 'function';
const_blank_symbol = '_blank';
const_slash_slash_symbol = '//';
const_slash_symbol = '/';
const_indexcfm_symbol = 'index.cfm';

const_http_symbol = 'http://';
const_https_symbol = 'https://';
const_mailto_symbol = 'mailto:';
const_ftp_symbol = 'ftp://';
const_other_symbol = '(other)';

const_cursor_hand = 'hand';
const_cursor_default = 'default';

const_object_symbol = 'object';
const_number_symbol = 'number';

const_radio_symbol = 'radio';
const_checkbox_symbol = 'checkbox';
const_button_symbol = 'button';

const_submit_symbol = 'submit';
const_cancel_symbol = 'cancel';

const_backgroundColor_symbol = 'backgroundColor';

const_no_response_symbol = 'No';

const_true_value_symbol = 'True';

const_gif_filetype_symbol = '.gif';
const_jpg_filetype_symbol = '.jpg';
const_jpeg_filetype_symbol = '.jpeg';

const_images_symbol = '/images/';             		// used by _autoCorrectLinksAndImages()
const_components_symbol = '/components/';     		// used by _autoCorrectLinksAndImages()
const_images_prime_symbol = 'images/';        		// used by _autoCorrectLinksAndImages()
const_images_uploaded_symbol = '/uploaded-images/'; // used by _autoCorrectLinksAndImages()

const_panagons_link_symbol = 'http://panagons';

const_anchor_menu_anchorStyles = 'text-decoration: none; font-weight: bold; color: white; padding: 2px;';

/** END! Globals ************************************************************************/

function uuid() {
	var uuid = (new Date().getTime() + "" + Math.floor(1000 * Math.random()));
	return uuid;
}

function _setup_tooltip_handlers(_id_, _parked_id_) {
	_html = '';
	
	_html += 'id="' + _id_ + '"';
	js_id = '\'' + _id_ + '\'';

	if (_parked_id_ == null) {
		_parked_id_ = '';
	}
	js_pid = '\'' + _parked_id_ + '\'';

	_html += ' onmouseover="handle_ToolTip_MouseOver(event, ' + js_id + ', ' + js_pid + '); return false;" onmouseout="handle_ToolTip_MouseOut(event, ' + js_id + '); return false;"';
	
	return _html;
}

function html_tooltips(s) {
	var _html = '';
	
	if ( (s != null) && (s.trim().length > 0) ) {
		_html += '<div id="div_html_tooltips">';
		_html += '<p align="justify" style="font-size: 9px;"><b>' + s + '</b></p>';
		_html += '<a name="_table_html_tooltips_anchor"></a>';
		_html += '</div>';
	}
	
	return _html;
}

function clientHeight() {
	var _clientHeight = -1;
	var ta = typeof window.innerHeight;
	if (ta.trim().toUpperCase() == const_number_symbol.trim().toUpperCase()) {
		_clientHeight = window.innerHeight;
	} else {
		if (document.documentElement && document.documentElement.clientHeight) {
			_clientHeight = document.documentElement.clientHeight;
		} else {
			if (document.body && document.body.clientHeight) {
				_clientHeight = document.body.clientHeight;
			}
		}
	}
	return _clientHeight;
}

function clientWidth() {
	var _clientWidth = -1;
	var ta = typeof window.innerWidth;
	if (ta.trim().toUpperCase() == const_number_symbol.trim().toUpperCase()) {
		_clientWidth = window.innerWidth;
	} else {
		if (document.documentElement && document.documentElement.clientWidth) {
			_clientWidth = document.documentElement.clientWidth;
		} else {
			if (document.body && document.body.clientWidth) {
				_clientWidth = document.body.clientWidth;
			}
		}
	}
	return _clientWidth;
}

function toolTipWatcherProcess() {
	// this process exists in case the widget which had been enabled at the time the sticky tooltip was made visible then became disabled and the tooltip remained visible because a disabled widget doesn't get events...
	// the better way to do this might have been to handle events higher up in the DOM chain however this method took less development time, at the time it was conceived...
	var _obj = -1;
	for (var i = 0; i < _stack_tooltips_obj.length; i++) {
		_obj = _stack_tooltips_obj[i];
		try {
			if (_obj != null) {
				if ( (_obj.disabled == true) || (_obj.style.display == const_none_style) ) {
					handle_ToolTip_MouseOut(null, _obj.id);
				}
			}
		} catch(e) {
		} finally {
		}
	}
}

function terminateToolTipWatcherProcess() {
	var tid = -1;
	for (; _cache_tooltips_timerId.length > 0; ) {
		tid = _cache_tooltips_timerId.pop();
		clearInterval(tid);
	}
}

function startToolTipWatcherProcess() {
	// Make sure the clock is stopped
	terminateToolTipWatcherProcess();
	var tid = setInterval("toolTipWatcherProcess()", 333)
	_cache_tooltips_timerId.push(tid);
}

function handle_ToolTip_MouseOver(ev, id, parked_id) {
	var adjustedX = false;
	var adjustedY = false;
	var obj = getGUIObjectInstanceById(id);
	if (obj != null) {
		var xPos_m = -1;
		var yPos_m = -1; // master x,y position for the tooltips if the anchor is defined...
		if ( (parked_id != null) && (parked_id.trim().length > 0) ) {
			var _tt_obj = getGUIObjectInstanceById(parked_id);
			if (_tt_obj != null) {
				var m_coord = getAnchorPosition(parked_id);
				xPos_m = m_coord.x;
				yPos_m = m_coord.y; // master x,y position for the tooltips if the anchor is defined...
			}
		}
		var tt_obj = getGUIObjectInstanceById('_delayed_tooltips');
		if (tt_obj != null) {
			var _clientHeight = clientHeight();
			var _clientWidth = clientWidth();
			if ( (obj.title) && (obj.title.trim().length > 0) ) {
				_cache_tooltips[id] = obj.title;
				obj.title = '';
			}
			_stack_tooltips_obj.push(obj);
			var xPos = (ev.clientX + document.body.scrollLeft);
			if ((xPos + 400) >= _clientWidth) {
				adjustedX = true;
				xPos = _clientWidth - 400;
			}
			if (xPos_m != -1) {
				xPos = xPos_m;
			}
			tt_obj.style.left = xPos.toString() + 'px';
			var yPos = (ev.clientY + document.body.scrollTop);
//			var s = 'ev.clientY = ' + ev.clientY + ', ev.screenY = ' + ev.screenY + ', document.body.scrollLeft = ' + document.body.scrollLeft + ', document.body.scrollTop = ' + document.body.scrollTop + ', tt_obj.style.left = ' + tt_obj.style.left + ', tt_obj.style.top = ' + tt_obj.style.top + ', screen.height = ' + screen.height + ', screen.width = ' + screen.width + ', _clientHeight = ' + _clientHeight + ', _clientWidth = ' + _clientWidth + '<br>';
			var ns = _cache_tooltips[id];
			if (ns == null) {
				ns = '';
			}
			ns = ns.stripHTML();
			var ni = (((ns.length * 10) / (400 - 50)) + 2) * 10;
			if ((yPos + ni) >= _clientHeight) {
				adjustedY = true;
				yPos = _clientHeight - ni;
			} else if (adjustedX) {
				yPos += 20;
			}
			if (yPos_m != -1) {
				yPos = yPos_m;
			}
			tt_obj.style.top = yPos.toString() + 'px';
			tt_obj.innerHTML = html_tooltips(_cache_tooltips[id]);
			tt_obj.style.display = const_inline_style;

			if (obj.disabled == false) {
				startToolTipWatcherProcess();
			}
			handle_tooltips_functions(true);
		}
	}
}

function handle_ToolTip_MouseOut(ev, id) {
	var obj = getGUIObjectInstanceById(id);
	if ( (obj != null) && (_cache_tooltips[id] != null) ) {
		var tt_obj = getGUIObjectInstanceById('_delayed_tooltips');
		if (tt_obj != null) {
			// obj.title = _cache_tooltips[id];
			_stack_tooltips_obj.pop(); // flush the stack - also need to kill the background process at this point...
			terminateToolTipWatcherProcess();
			// _cache_tooltips[id] = null;
			tt_obj.style.display = const_none_style;
			handle_tooltips_functions(false);
		}
	}
}

function attachToolTipEvents(el) {
	if (el.attachEvent) { // IE
		el.attachEvent("onMouseOver", handle_ToolTip_MouseOver);
		el.attachEvent("onMouseOut", handle_ToolTip_MouseOut);
	} else if (document.addEventListener) { // Gecko / W3C
		el.addEventListener("onMouseOver", handle_ToolTip_MouseOver, true);
		el.addEventListener("onMouseOut", handle_ToolTip_MouseOut, true);
	} else {
		el["onMouseOver"] = handle_ToolTip_MouseOver;
		el["onMouseOut"] = handle_ToolTip_MouseOut;
	}
}

function attachToolTipEventsTo(a) {
	var s = '';
	if (a != null) {
		var ta = typeof a;
		if (ta.trim().toUpperCase() == const_object_symbol.trim().toUpperCase()) {
			for (var i = 0; i < a.length; i++) {
				if ( (a[i].title) && (a[i].id) && (a[i].id.trim().length > 0) && (a[i].title.trim().length > 40) ) {
					s += 'a[i].id = ' + a[i].id + ' (' + a[i].title.trim().length + ')\n';
					attachToolTipEvents(a[i]);
				}
			}
		}
	}
}

function handleScroll(ev) {
	window.status = 'handleScroll() :: document.body.scrollLeft = ' + document.body.scrollLeft + ', document.body.scrollTop = ' + document.body.scrollTop;
}

function register_tooltips_function(f) {
	_cache_tooltips_functions.push(f);
}

function handle_tooltips_functions(bool) {
	for (var i = 0; i < _cache_tooltips_functions.length; i++) {
		var f = _cache_tooltips_functions[i];
		f(bool);
	}
}

function handle_onload_functions() {
	for (var i = 1; _cache_onload_functions.length > 0; i++) {
		var f = _cache_onload_functions.pop();
		if (f != null) {
			eval(f);
		}
	}
}

function register_onload_function(f) {
	_cache_onload_functions.push(f);
}

function initGUIObjectCache() {
	_cache_gui_objects = [];
}

function flushGUIObjectChildrenForObj(obj) {
	if (obj != null) {
		var sfEls = obj.getElementsByTagName("*");
		for (var i = 0; i < sfEls.length; i++) {
			if (sfEls[i].id) {
				_cache_gui_objects[sfEls[i].id] = null;
			}
		}
	}
}

function _getGUIObjectInstanceById(id) {
	var obj = -1;
	obj = ((document.getElementById) ? document.getElementById(id) : ((document.all) ? document.all[id] : ((document.layers) ? document.layers[id] : null)));
	return obj;
}

function getGUIObjectInstanceById(id) {
	var obj = -1;
	if (_cache_gui_objects[id] == null) {
		obj = _getGUIObjectInstanceById(id);
		_cache_gui_objects[id] = obj;
	} else {
		obj = _cache_gui_objects[id];
	}
	return obj;
}

function setFocusSafely(pObj) {
	if (pObj != null) {
		if (pObj.focus) {
			if ( (pObj.disabled == null) || (pObj.disabled == false) ) {
				pObj.focus();
			}
		}
	}
}

function setFocusSafelyById(id) {
	var pObj = getGUIObjectInstanceById(id);
	return setFocusSafely(pObj);
}

function isTextarea(obj) {
	if (obj != null) {
		return (obj.tagName.toLowerCase() == const_textarea_symbol.toLowerCase());
	}
	return false;
}

function _disable_button(btnObj) {
	if (btnObj != null) {
		btnObj.disabled = true;
	}
}

function debugProbe(arrayOfVarNames) {
	var _db = '';
	var varName = '';
	var varValue = '';

	for (var i = 0; i < arrayOfVarNames.length; i++) {
		varName = arrayOfVarNames[i].trim();
		try {
			varValue = eval(varName);
		} catch(e) {
			// jsErrorExplainer(e, 'debugProbe(' + arrayOfVarNames + ')');
		} finally {
		}
		_db += varName + ' = (' + varValue + ')';
		if (i < (arrayOfVarNames.length - 1)) {
			_db += ', ';
		}
	}
	alert('debugProbe(' + arrayOfVarNames + ')\n' + _db);
}

function makeArrayFromThese(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) {
	var a = [];
	
	if (arg1 != null) {
		a.push(arg1);
	}

	if (arg2 != null) {
		a.push(arg2);
	}

	if (arg3 != null) {
		a.push(arg3);
	}

	if (arg4 != null) {
		a.push(arg4);
	}

	if (arg5 != null) {
		a.push(arg5);
	}

	if (arg6 != null) {
		a.push(arg6);
	}

	if (arg7 != null) {
		a.push(arg7);
	}

	if (arg8 != null) {
		a.push(arg8);
	}

	if (arg9 != null) {
		a.push(arg9);
	}

	return a;
}

cache_flash_button_timers = [];

function unflash_button(btnObj) {
	// btnObj must have an id to be handled by this function...
	if (btnObj != null) {
		if (btnObj.id.trim().length > 0) {
			if (cache_flash_button_timers[btnObj.id] != null) {
				var a = cache_flash_button_timers[btnObj.id];
				if (typeof a == const_object_symbol) {
					for (; a.length > 0; ) {
						clearTimeout(a.pop());
					}
				}
				cache_flash_button_timers[btnObj.id] = null;
			}
		}
	}
}

function _flash_button(btnObj, color1, color2) {
	// btnObj must have an id to be handled by this function...
	if (btnObj != null) {
		if (btnObj.id.trim().length > 0) {
			if (cache_flash_button_timers[btnObj.id] != null) {
				var a = cache_flash_button_timers[btnObj.id];
				if (typeof a == const_object_symbol) {
					// make color change here...
					btnObj.style.color = color1;
					if (a.length == 1) {
						a.push(setInterval(_flash_button, 50, btnObj, color1, color2));
						cache_flash_button_timers[btnObj.id] = a;
					} else {
						btnObj.style.color = color2;
					}
				}
			}
		}
	}
}

function flash_button(btnObj, color1, color2) {
	// btnObj must have an id to be handled by this function...
	if (btnObj != null) {
		if (btnObj.id.trim().length > 0) {
			if (cache_flash_button_timers[btnObj.id] == null) {
				var a = [];
				a.push(setInterval(_flash_button, 50, btnObj, color1, color2));
				cache_flash_button_timers[btnObj.id] = a;
			}
		}
	}
}

//*** BEGIN: Form double-click suppressor ***********************************************************************/

_cache_disableButtons_functions = [];

function register_disableButtons_function(f) {
	_cache_disableButtons_functions.push(f);
}

function handle_disableButtons_functions(bool) {
	for (var i = 0; i < _cache_disableButtons_functions.length; i++) {
		var f = _cache_disableButtons_functions[i];
		f(bool);
	}
}

function jsErrorExplainer(e, funcName) {
	var _db = ''; 
	_db += "e.number is: " + (e.number & 0xFFFF) + '\n'; 
	_db += "e.description is: " + e.description + '\n'; 
	_db += "e.name is: " + e.name + '\n'; 
	_db += "e.message is: " + e.message + '\n';
	alert(funcName + '\n' + e.toString() + '\n' + _db);
}

function jsErrorExplainer(e, funcName) {
	var _db = ''; 
	_db += "e.number is: " + (e.number & 0xFFFF) + '\n'; 
	_db += "e.description is: " + e.description + '\n'; 
	_db += "e.name is: " + e.name + '\n'; 
	_db += "e.message is: " + e.message + '\n';
	alert(funcName + '\n' + e.toString() + '\n' + _db);
}

function jsEventExplainer(e, newLine) {
	var _db = ''; 

	try {
		if (e.data) _db += "e.data is: " + e.data + newLine; 
	} catch(e) {
		_db += 'e.data is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.height) _db += "e.height is: " + e.height + newLine; 
	} catch(e) {
		_db += 'e.height is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.layerX) _db += "e.layerX is: " + e.layerX + newLine; 
	} catch(e) {
		_db += 'e.layerX is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.layerY) _db += "e.layerY is: " + e.layerY + newLine; 
	} catch(e) {
		_db += 'e.layerY is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.modifiers) _db += "e.modifiers is: " + e.modifiers + newLine; 
	} catch(e) {
		_db += 'e.modifiers is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.pageX) _db += "e.pageX is: " + e.pageX + newLine; 
	} catch(e) {
		_db += 'e.pageX is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.pageY) _db += "e.pageY is: " + e.pageY + newLine; 
	} catch(e) {
		_db += 'e.pageY is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.screenX) _db += "e.screenX is: " + e.screenX + newLine; 
	} catch(e) {
		_db += 'e.screenX is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.screenY) _db += "e.screenY is: " + e.screenY + newLine; 
	} catch(e) {
		_db += 'e.screenY is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.target) _db += "e.target is: " + e.target + newLine; 
	} catch(e) {
		_db += 'e.target is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.type) _db += "e.type is: " + e.type + newLine; 
	} catch(e) {
		_db += 'e.type is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.which) _db += "e.which is: " + e.which + newLine; 
	} catch(e) {
		_db += 'e.which is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.width) _db += "e.width is: " + e.width + newLine; 
	} catch(e) {
		_db += 'e.width is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.x) _db += "e.x is: " + e.x + newLine; 
	} catch(e) {
		_db += 'e.x is: -- UNKNOWN --' + newLine; 
	} finally {
	}

	try {
		if (e.y) _db += "e.y is: " + e.y + newLine; 
	} catch(e) {
		_db += 'e.y is: -- UNKNOWN --' + newLine; 
	} finally {
	}
	return _db;
}

var theForm;
var _cache_theForm_timerId = [];
var _cache_requestSubmitted = [];

function getStandardFormIdFor(form) {
	var _id = "null";
	if (form != null) {
		_id = form.id;
		if (_id == null) {
			_id = form.name;
		}
	}
	return _id;
}

function disableButton(btn,btn2,form,buttonType) {
	var _id = getStandardFormIdFor(form);
	if (_cache_requestSubmitted[_id] == null){
		if (buttonType != null) {
			var buttonName = buttonType;
			btn.src = buttonName.src; // image swap happens here
		} else {
			var submitMessage = "  Please Wait...  ";
			btn.value = submitMessage;
		}
		theForm = form;
		if (btn != null) {
			btn.disabled = true;
		}
		if (btn2 != null) {
			btn2.disabled = true;
		}
		handle_disableButtons_functions(true);
		_cache_requestSubmitted[_id] = true;
		if (form == null) {
			return false;
		} else {
			var buts = theForm.getElementsByTagName("INPUT");
			var _db = '';
			for (var i = 0; i < buts.length; i++) {
				if (buts[i].type.trim().toUpperCase() == const_button_symbol.trim().toUpperCase()) {
					if (buts[i].disabled == false) {	
						buts[i].disabled = true;
					}
				}
			}

			_cache_theForm_timerId[_id] = setTimeout("submitIt()", 250);
		}
	} else {
		return false;
	}
}
function submitIt() {
	if (theForm != null) {
		theForm.submit();
	}
	var _id = getStandardFormIdFor(theForm);
	if (_cache_theForm_timerId[_id] != null) {
		clearTimeout(_cache_theForm_timerId[_id]);
		_cache_theForm_timerId[_id] = null;
	}
	return false;
}
function checkandsubmit(submitForm) {
	var _id = getStandardFormIdFor(submitForm);
	if(_cache_requestSubmitted[_id] == true) {
		return false;
	} else {
		_cache_requestSubmitted[_id] = true;
		if (submitForm != null) {
			submitForm.submit();
		}
		return false;
	}
}

//*** END! Form double-click suppressor ***********************************************************************/

//*** BEGIN: cross-browser getSelection() ***********************************************************************/

function _getSelection() {
	var txt = '';
	if (window.getSelection) {
		txt = window.getSelection();
	}
	else if (document.getSelection)	{
		txt = document.getSelection();
	}
	else if (document.selection) {
		var r = document.selection.createRange();
		txt = r.text;
	}
	else return;
}

//*** END! cross-browser getSelection() ***********************************************************************/

//*** BEGIN: URLEncode() ***********************************************************************/

function URLEncode(plaintext) {
	// The Javascript escape and unescape functions do not correspond
	// with what browsers actually do...
	var SAFECHARS = "0123456789" +					// Numeric
					"ABCDEFGHIJKLMNOPQRSTUVWXYZ" +	// Alphabetic
					"abcdefghijklmnopqrstuvwxyz" +
					"-_.!~*'()";					// RFC2396 Mark characters
	var HEX = "0123456789ABCDEF";

	var encoded = "";
	if (plaintext != null) {
		for (var i = 0; i < plaintext.length; i++ ) {
			var ch = plaintext.charAt(i);
		    if (ch == " ") {
			    encoded += "+";				// x-www-urlencoded, rather than %20
			} else if (SAFECHARS.indexOf(ch) != -1) {
			    encoded += ch;
			} else {
			    var charCode = ch.charCodeAt(0);
				if (charCode > 255) {
				    alert( "Unicode Character '" 
	                        + ch 
	                        + "' cannot be encoded using standard URL encoding.\n" +
					          "(URL encoding only supports 8-bit characters.)\n" +
							  "A space (+) will be substituted." );
					encoded += "+";
				} else {
					encoded += "%";
					encoded += HEX.charAt((charCode >> 4) & 0xF);
					encoded += HEX.charAt(charCode & 0xF);
				}
			}
		}
	}

	return encoded;
}

//*** END! URLEncode() ***********************************************************************/


//*** BEGIN: URLDecode() ***********************************************************************/

function URLDecode(encoded) {
   // Replace + with ' '
   // Replace %xx with equivalent character
   // Put [ERROR] in output if %xx is invalid.
   var HEXCHARS = "0123456789ABCDEFabcdef"; 
   var plaintext = "";
   var i = 0;
   while (i < encoded.length) {
       var ch = encoded.charAt(i);
	   if (ch == "+") {
	       plaintext += " ";
		   i++;
	   } else if (ch == "%") {
			if (i < (encoded.length-2) 
					&& HEXCHARS.indexOf(encoded.charAt(i+1)) != -1 
					&& HEXCHARS.indexOf(encoded.charAt(i+2)) != -1 ) {
				plaintext += unescape( encoded.substr(i,3) );
				i += 3;
			} else {
				alert( 'Bad escape combination near ...' + encoded.substr(i) );
				plaintext += "%[ERROR]";
				i++;
			}
		} else {
		   plaintext += ch;
		   i++;
		}
	} // while
   return plaintext;
}

//*** END! URLDecode() ***********************************************************************/


//**************************************************************************/

/** MathAndStringExtend.js
 *  JavaScript to extend String class
 *  - added trim methods 
 *    - uses regular expressions and pattern matching. 
 * *  eg. *    var s1 = new String("   abc   "); 
 *    var trimmedS1 = s1.trim(); 
 * *  similary for String.triml() and String.trimr(). 
 *
 //**************************************************************************/
 
function _int(i){
	var _s = i.toString().split(".");
	return eval(_s[0]);
};

// Relaxed the requirement than "SBC" MSIE Browsers be used - now any MSIE browser that's not a disallowed type such as Opera or Netscape or Mozilla will be allowed without warning.
browser_is_opera = (/opera/i.test(navigator.userAgent));
browser_is_ie = ( ( (/msie/i.test(navigator.userAgent)) || (/Gecko/i.test(navigator.userAgent)) || (/Firefox/i.test(navigator.userAgent)) || (/Netscape/i.test(navigator.userAgent)) || (browser_is_opera) ) );

if (browser_is_ie == false) {
	alert('Unsupported Browser has been detected !  Some site functionality may not be available.  This site supports the SBC Standard Microsoft IE Browser. Your browser appears to be (' + navigator.userAgent + ').');
}

/**************************************************************************/

function caselessIndexOfAll(s) {
	var _f = 0;
	var _fr = 0;
	var a = [];
	var sl = s.trim().length;
	var st = this.trim().length;
	while ((_f = this.trim().toUpperCase().indexOf(s.trim().toUpperCase(), _fr)) != -1) {
		a.push(_f);
		_fr += _f + sl;
		if (_fr >= st) {
			break;
		}
	}
	return a;
}

String.prototype.caselessIndexOfAll = caselessIndexOfAll;

/**************************************************************************/

function keywordSearchCaseless(kw) {
	var const_begin_tag_symbol = '<';
	var const_end_tag_symbol = '>';
	var const_begin_literal_symbol = '&';
	var const_end_literal_symbol = ';';

	var _debug_output = '';

	function gobbleUpCharsUntil(e_ch, _s) {
		var _ch = '';
		for (; i < _s.length; i++) {
			_ch = _s.substr(i, 1); // charAt(i);
			if (_ch == e_ch) {
				i++;
				_ch = _s.substr(i, 1); // charAt(i);
				break;
			}
		}
		return _ch;
	}

	var _s = this.trim().stripHTML().trim();
	var _hasHTMLtags = this.trim().length != _s.length;
	var _kw = kw.trim().stripHTML().trim().toUpperCase();
	var _f = _s.toUpperCase().indexOf(_kw);
	if ( (_f != -1) && (_hasHTMLtags) ) {
		// found something - try to map it back into the HTML...
		// (1). scan thru this breaking apart words based on where the words fall relative to HTML tags.
		var _ch = '';
		var _word = '';
		var _words_array = [];
		_ch = this.substr(i, 1); // charAt(i);
		for (var i = 0; i < this.length; i++) {
			if (_ch == const_begin_tag_symbol) {
				// gobble-up chars until we reach the end tag symbol
				_ch = gobbleUpCharsUntil(const_end_tag_symbol, this);
			}
			if (_ch == const_begin_literal_symbol) {
				// gobble-up chars until we reach the end literal symbol
				_ch = gobbleUpCharsUntil(const_end_literal_symbol, this);
			}
			// now _ch should be at a char not within an HTML'ish tag or literal...
			// now collect chars until we encounter another HTML'ish symbol be it tag or literal...
			if ( (_ch != const_begin_tag_symbol) && (_ch != const_begin_literal_symbol) ) {
				_word = '';
				for (; i < this.length; i++) {
					_ch = this.substr(i, 1); // charAt(i);
					if ( (_ch == const_begin_tag_symbol) || (_ch == const_begin_literal_symbol) ) {
						break;
					}
					_word += _ch;
				}
				if (_word.trim().length > 0) {
					// store the word in the array along with the index for the word...
					a = [];
					a.push(_word);
					a.push(i - _word.length);
					_words_array.push(a);
				}
			}
			_ch = this.substr(i, 1); // charAt(i);
		}
		if (_words_array.length > 0) {
			// we found some words so now we search the _words_array for the keyword...
			var a = [];
			for (i = 0; i < _words_array.length; i++) {
				a = _words_array[i];
				_s = a[0];
				var _ff = _s.toUpperCase().indexOf(_kw);
				if (_ff != -1) {
					// found the keyword...
					var o_f = _f;
					_f = a[1] + _ff;
					break;
				}
			}
		}
	} else if (_hasHTMLtags == false) {
		// there are no HTML tags to account for so just do the silly search...
		var _f = this.toUpperCase().indexOf(kw.toUpperCase());
	}
	return _f;
}

String.prototype.keywordSearchCaseless = keywordSearchCaseless;

/**************************************************************************/

function countCrs() {
	var cnt = 0;
	for (var i = 0; i < this.length; i++) {
		_ch = this.substr(i, 1); // charAt(i);
		if (_ch == '\n') {
			cnt++;
		}
	}
	return cnt;
}

String.prototype.countCrs = countCrs;

/**************************************************************************/

function countCrLfs() {
	var cnt = 0;
	for (var i = 0; i < this.length; i++) {
		_ch = this.substr(i, 1); // charAt(i);
		if ( (_ch == '\n') || (_ch == '\r') ) {
			cnt++;
		}
	}
	return cnt;
}

String.prototype.countCrLfs = countCrLfs;

/**************************************************************************/

function stripHTML() {
	var s = null;
	s = this.replace(/(<([^>]+)>)/ig,""); // trim everything that's between < and >
	s = s.replace(/(&([^;]+);)/ig,""); // trim everything that's between & and ;
	return s;
}

String.prototype.stripHTML = stripHTML;

/**************************************************************************/

function stripTickMarks() {
	return this.replace(/\'/ig, "");
}

String.prototype.stripTickMarks = stripTickMarks;

/**************************************************************************/

function stripQuoteMarks() {
	return this.replace(/\"/ig, "");
}

String.prototype.stripQuoteMarks = stripQuoteMarks;

/**************************************************************************/

function replaceTickMarksWith(ch) {
	return this.replace(/\'/ig, ch);
}

String.prototype.replaceTickMarksWith = replaceTickMarksWith;

/**************************************************************************/

function stripIllegalChars() {
	return this.URLEncode(); // .replace(/,/ig, "").replace(/\|/ig, "");
}

String.prototype.stripIllegalChars = stripIllegalChars;

/**************************************************************************/

function _URLEncode() {
	return URLEncode(this);
}

String.prototype.URLEncode = _URLEncode;

/**************************************************************************/

function _URLDecode() {
	return URLDecode(this);
}

String.prototype.URLDecode = _URLDecode;

/**************************************************************************/

function stripCrLfs() {
	return this.replace(/\n/ig, "").replace(/\r/ig, "");
}

String.prototype.stripCrLfs = stripCrLfs;

/**************************************************************************/

function replaceSubString(i, j, s) {
	var s = this.substring(0, i) + s + this.substring(j, this.length);
	return s;
}

String.prototype.replaceSubString = replaceSubString;

/**************************************************************************/

function clipCaselessReplace(keyword, sText) {
	var _ff = this.toUpperCase().indexOf(keyword.toUpperCase());
	if (_ff != -1) {
		return this.replaceSubString(_ff, _ff + keyword.length, sText);
	}

	return this;
}

String.prototype.clipCaselessReplace = clipCaselessReplace;

/**************************************************************************/

function trim() {  
 	var s = null;
	// trim white space from the left  
	s = this.replace(/^[\s]+/,"");  
	// trim white space from the right  
	s = s.replace(/[\s]+$/,"");  
	return s;
}

function triml() {  
	// trim white space from the left   
	return this.replace(/^[\s]+/,"");
}

function trimr() {  
	// trim white space from the right  
	return this.replace(/[\s]+$/,"");
}

String.prototype.trim = trim;
String.prototype.triml = triml;
String.prototype.trimr = trimr;

/**************************************************************************/

function mungeIntoSymbol() {
	var _symbol = "";

	for (i = 0; i < this.length; i++) {
		ch = this.substring(i, i + 1);
		if ( (ch >= "0") && (ch <= "z") ) {
			_symbol += ch;
		} else {
			_symbol += "_";
		}
	}

	return _symbol;
}

String.prototype.mungeIntoSymbol = mungeIntoSymbol;
 
/**************************************************************************/

function sum() {
	var _sum = 0;

	for (i = 0; i < this.length; i++) {
		_sum += this[i];
	}

	return _sum;
}

Array.prototype.sum = sum;

/**************************************************************************/

function avg() {
	return (this.sum()/this.length);
}

Array.prototype.avg = avg;

/**************************************************************************/

function max() {
	var m = -1;
	if (typeof this[0] == const_number_symbol) {
		m = this[0];
	}
	for (var i = this.length; i > 0; i--) {
		if (typeof this[i] == const_number_symbol) {
			m = Math.max(m, this[i]);
		}
	}
	return m;
}

Array.prototype.max = max;

/**************************************************************************/

function min() {
	var m = -1;
	if (typeof this[0] == const_number_symbol) {
		m = this[0];
	}
	for (var i = this.length; i > 0; i--) {
		if (typeof this[i] == const_number_symbol) {
			m = Math.min(m, this[i]);
		}
	}
	return m;
}

Array.prototype.min = min;

/**************************************************************************/

function iMax() {
	var m = this.max();

	for (var i = 0; i < this.length; i++) {
		if (this[i] == m) {
			return i;
		}
	}
	return -1;
}

Array.prototype.iMax = iMax;

/**************************************************************************/

function iMin() {
	var m = this.min();

	for (var i = 0; i < this.length; i++) {
		if (this[i] == m) {
			return i;
		}
	}
	return -1;
}

Array.prototype.iMin = iMin;

/**************************************************************************/

function cfString() {
	var s = '';
	var b = true;

	for (var i = 0; i < this.length; i++) {
		if (b) {
			s += "'" + this[i] + "'";
			b = false;
		} else {
			s += ', ' + "'" + this[i] + "'";
		}
	}
	return s;
}

Array.prototype.cfString = cfString;

/**************************************************************************/

function keyValFromKey(keyName) {
	var val = -1;
	var aa = [];

	keyName = keyName.trim().toUpperCase();
	for (var i = 0; i < this.length; i++) {
		aa = this[i].toString().split(',');
		if (aa.length == 2) {
			if (aa[0].trim().toUpperCase() == keyName) {
				val = aa[1];
				break;
			}
		}
	}
	return val;
}

Array.prototype.keyValFromKey = keyValFromKey;

/**************************************************************************/


