/*
 popup_window_obj.js -- PopUpWindowObj
 
	WARNING:	This object contains or holds onto references to functions that are contained within the body of
				other functions which might result in accidental closures that need to be freed or a memory leak
				may result.  Make sure you are using the destructor method to properly release all objects being
				referenced by every instance of this object in order to avoid any possible memory leak problems.
*/

PopUpWindowObj = function(id, windowProperties){
	this.id = id;				// the id is the position within the global ButtonBarObj.instances array
	if (windowProperties) {
		this.windowProperties = windowProperties;
	}
};

PopUpWindowObj.instances = [];

PopUpWindowObj.getInstance = function(windowProperties) {
	// the object.id is the position within the array that holds onto the objects...
	var instance = PopUpWindowObj.instances[PopUpWindowObj.instances.length];
	if(instance == null) {
		instance = PopUpWindowObj.instances[PopUpWindowObj.instances.length] = new PopUpWindowObj(PopUpWindowObj.instances.length, windowProperties);
	}
	return instance;
};

PopUpWindowObj.removeInstance = function(id) {
	var ret_val = false;
	if ( (id > -1) && (id < PopUpWindowObj.instances.length) ) {
		var instance = PopUpWindowObj.instances[id];
		if (instance != null) {
			PopUpWindowObj.instances[id] = object_destructor(instance);
			ret_val = (PopUpWindowObj.instances[id] == null);
		}
	}
	return ret_val;
};

PopUpWindowObj.removeInstances = function() {
	var ret_val = true;
	for (var i = 0; i < PopUpWindowObj.instances.length; i++) {
		PopUpWindowObj.removeInstance(i);
	}
	return ret_val;
};

PopUpWindowObj.prototype = {
	id : -1,
	handle : -1,
	name : -1,
	_width : 800,
	_height : 600,
	_screenX : 0,
	_left : 0,
	_screenY : 0,
	_top : 0,
	_clientX : 0,
	_clientY : 0,
	_url : '',
	windowProperties : 'toolbar=no,location=no,status=no,menubar=no,scrollbars=yes,resizable,alwaysRaised,dependent,titlebar=no',
	avoidAboutBlank : window.opera || ( document.layers && !navigator.mimeTypes['*'] ) || navigator.vendor == 'KDE' || ( document.childNodes && !document.all && !navigator.taintEnabled ),
	toString : function() {
		var s_toString = '';
		s_toString += 'id = [' + this.id + ']\n';
		s_toString += ', handle = [' + this.handle + ']\n';
		s_toString += ', name = [' + this.name + ']\n';
		s_toString += ', width = [' + this._width + ']\n';
		s_toString += ', height = [' + this._height + ']\n';
		s_toString += ', screenX = [' + this._screenX + ']\n';
		s_toString += ', screenY = [' + this._screenY + ']\n';
		s_toString += ', top = [' + this._top + ']\n';
		s_toString += ', left = [' + this._left + ']\n';
		s_toString += ', _clientX = [' + this._clientX + ']\n';
		s_toString += ', _clientY = [' + this._clientY + ']\n';
		s_toString += ', clientWidth = [' + this.clientWidth() + ']\n';
		s_toString += ', clientHeight = [' + this.clientHeight() + ']\n';
		s_toString += ', windowProperties = [' + this.windowProperties + ']\n';
		s_toString += ', avoidAboutBlank = [' + this.avoidAboutBlank + ']\n';
		s_toString += ', _url = [' + this._url + ']\n';
		return s_toString;
	},
	clientWidth : function() {
		return clientWidth();
	},
	clientHeight : function() {
		return clientHeight();
	},
	width : function(w) {
		this._width = w;
		return w;
	},
	height : function(h) {
		this._height = h;
		return h;
	},
	screenX : function(x) {
		this._screenX = x;
		return x;
	},
	screenY : function(y) {
		this._screenY = y;
		return y;
	},
	left : function(l) {
		this._left = l;
		return l;
	},
	top : function(t) {
		this._top = t;
		return t;
	},
	openWindow : function(name, url) {
		if (this._left == 'NaN') {
			this._left = (this.clientWidth() / 2) - (this._width / 2);
		}
		if (this._top == 'NaN') {
			this._top = (this.clientHeight() / 2) - (this._height / 2);
		}
		if (name != null) {
			this.name = name;
		}
		if (url != null) {
			this._url = url;
		}
		this.windowProperties += ',width=' + this._width + ',height=' + this._height + ',screenX=' + this._screenX + ',left=' + this._left + ',screenY=' + this._screenY + ',top=' + this._top + '';
		this.handle = window.open( ((this._url.length > 0) ? this._url : ((this.avoidAboutBlank) ? '' : 'about:blank')), this.name, this.windowProperties);
		return false;
	},
	openModalWindow : function(name, url, parmsArray) {
		var s = '';
		if (name != null) {
			this.name = name;
		}
		if (url != null) {
			this._url = url;
		}
		var _clientHeight_ = this.clientHeight();
		var _clientWidth_ = this.clientWidth();
		if (typeof parmsArray == const_object_symbol) {
			for (var i = 0; i < parmsArray.length; i++) {
				s = parmsArray[i].toString();
				var a = s.split('=');
				if (typeof a == const_object_symbol) {
					if (a.length > 1) {
						if (a[0].toLowerCase() == 'clientHeight'.toLowerCase()) {
							_clientHeight_ = parseInt(a[1]);
						} else if (a[0].toLowerCase() == 'clientWidth'.toLowerCase()) {
							_clientWidth_ = parseInt(a[1]);
						}
					}
				}
			}
		}
		if ( (navigator.userAgent.indexOf('Opera') != -1) || (navigator.userAgent.indexOf('Gecko') != -1) || (navigator.userAgent.indexOf('Firefox') != -1) || (navigator.userAgent.indexOf('Netscape') != -1) || (navigator.userAgent.indexOf('MSIE 6') == -1) ) {
			this.windowProperties += ',width=' + _clientWidth_ + ',height=' + _clientHeight_ + ',screenX=' + this._screenX + ',left=' + this._left + ',screenY=' + this._screenY + ',top=' + this._top + '';
			this.handle = window.open( ((url.length > 0) ? url : ((this.avoidAboutBlank) ? '' : 'about:blank')), name, this.windowProperties);
		} else {
			this.handle = window.showModalDialog( ((this._url.length > 0) ? this._url : ((this.avoidAboutBlank) ? '' : 'about:blank')),parmsArray,"dialogWidth: " + _clientWidth_ + "px; dialogHeight: " + _clientHeight_ + "px;" + "center: yes; resizable: no; help: no; status: no; scroll: yes;") 
		}
	},
	beginHTML : function(sTitle) {
		var s = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">';
		s += '<html><head><title>' + sTitle + '</title></head>';
		s += '<scr' + 'ipt language="JavaScript1.2" type="text/javascript">';
		s += 'function cleanUp() {';
		s += 'opener.PopUpWindowObj.removeInstance(' + this.id + ');';
		s += '}';
		s += '</scr' + 'ipt>';
		s += '<body onUnload="cleanUp()">';
		return s;
	},
	endHTML : function(sTitle) {
		var s = '</body></html>';
		return s;
	},
	openWindow_writeln : function(name, s) {
		this.openWindow(name);
		this.open();
		this.writeln(s);
		this.close();
		this.focus();
		return true;
	},
	open : function() {
		this.handle.document.open();
		return false;
	},
	close : function() {
		this.handle.document.close();
		return false;
	},
	writeln : function(s) {
		this.handle.document.writeln(s);
		return false;
	},
	focus : function() {
		if (this.handle) {
			this.handle.focus();
		}
		return false;
	},
	repositionWithinClientWindow : function() {
		var x = 0;
		var y = 0;
		if (document.getElementById) {
			if (isNaN(window.screenX)) {
				x = document.body.scrollLeft + window.screenLeft;
				y = document.body.scrollTop + window.screenTop;
			} else {
				x = window.screenX+(window.outerWidth - window.innerWidth) - window.pageXOffset;
				y = window.screenY+(window.outerHeight - 24 - window.innerHeight) - window.pageYOffset;
			}
		} else if (document.all) {
			x = document.body.scrollLeft + window.screenLeft;
			y = document.body.scrollTop + window.screenTop;
		} else if (document.layers) {
			x = window.screenX + (window.outerWidth - window.innerWidth) - window.pageXOffset;
			y = window.screenY + (window.outerHeight - 24 - window.innerHeight) - window.pageYOffset;
		}
		if (this.handle) {
			this.handle.resizeTo(this.clientWidth(), this.clientHeight());
		}
		this._clientX = x;
		this._clientY = y;
		if (this.handle) {
			this.handle.moveTo( this._clientX, this._clientY);
		}
	},
	destructor : function() {
		return (this.id = PopUpWindowObj.instances[this.id] = this.handle = this.name = this._width = this._height = this._screenX = this._left = this._screenY = this._top = this.windowProperties = this.avoidAboutBlank = null);
	},
	dummy : function() {
		return false;
	}
};
