var isFocus = false;
var isBlur = false;
var isSiteLaunched = false;
var tid_site_launched = -1;
var winObj = PopUpWindowObj.getInstance();

function openChromeless(_name, _url) {
	if (winObj != null) {
		if (_name == null) {
			_name = 'my_window';
		}
		if (_url == null) {
			_url = 'content.html';
		}
		winObj.openWindow(_name, _url);
		winObj.repositionWithinClientWindow();
	}
}

function openModalChromeless(_name, _url, _parmsArray) {
	var parmsArray = (_parmsArray == null) ? [] : _parmsArray;
	if (winObj != null) {
		if (_name == null) {
			_name = 'my_window';
		}
		if (_url == null) {
			_url = 'content.html';
		}
		if (parmsArray.length == 0) {
			parmsArray.push(clientWidth());
			parmsArray.push(clientHeight());
			parmsArray.push(confirmSiteLaunched);
		}
		winObj.openModalWindow(_name, _url, parmsArray);
	}
}

function _adjustBlur() {
	if ( (isFocus) && (isBlur) ) {
		winObj.repositionWithinClientWindow();
		winObj.focus();
		isFocus = false;
		isBlur = false;
	}
}

function adjustBlur() {
	isBlur = true;
	_adjustBlur();
}

function adjustFocus() {
	isFocus = true;
	_adjustBlur();
}

function confirmSiteLaunched() {
	isSiteLaunched = true;
}

function window_onUnload() {
	clearInterval(tid_site_launched);
}

function goodByeBrowser() {
	window.opener=top;
	window.close();
}

function waitForSiteLaunched() {
	if (isSiteLaunched == true) {
		clearInterval(tid_site_launched);
		
		var btnObj = getGUIObjectInstanceById('btn_openChromeless');
		if (btnObj != null) {
			btnObj.disabled = false;
		}
	}
}

function window_onLoad() {
	var tid_site_launched = setInterval("waitForSiteLaunched()", 250);
}

window.onfocus = adjustFocus;
window.onblur = adjustFocus;
window.onresize = adjustFocus;
window.onunload = window_onUnload;
window.onload = window_onLoad;
