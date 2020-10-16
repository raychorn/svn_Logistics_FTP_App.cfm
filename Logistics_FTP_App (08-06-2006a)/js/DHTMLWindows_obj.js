//DHTML Window script- Copyright Dynamic Drive (http://www.dynamicdrive.com)
//For full source code, documentation, and terms of usage,
//Visit http://www.dynamicdrive.com/dynamicindex9/dhtmlwindow.htm

DHTMLWindowsObj = function(id, imagePath){
	this.id = id;
	this._uuid = uuid();
	this._cframe = 'cframe_' + this._uuid.toString();
	this._maxname = 'maxname_' + this._uuid.toString();
	this._dwindow = 'dwindow_' + this._uuid.toString();
	this._dwindowcontent = 'dwindowcontent_' + this._uuid.toString();
	if (imagePath != null) {
		this._imagePath = imagePath;
	}
};

DHTMLWindowsObj.instances = [];

DHTMLWindowsObj.drag_drop_funcs = [];

DHTMLWindowsObj.drag_drop = function(id, e) {
	var oObj = DHTMLWindowsObj.instances[id];
	if (oObj != null) {
		oObj.drag_drop(e);
	}
};

DHTMLWindowsObj.initializedrag = function(id, e) {
	var oObj = DHTMLWindowsObj.instances[id];
	if (oObj != null) {
		oObj.initializedrag(e);
	}
};

DHTMLWindowsObj.stopdrag = function(id) {
	var oObj = DHTMLWindowsObj.instances[id];
	if (oObj != null) {
		oObj.stopdrag();
	}
};

DHTMLWindowsObj.maximize = function(id) {
	var oObj = DHTMLWindowsObj.instances[id];
//alert('DHTMLWindowsObj.maximize(id = [' + id + '])' + ' oObj = ' + oObj);
	if (oObj != null) {
		oObj.maximize();
	}
};

DHTMLWindowsObj.closeit = function(id) {
	var oObj = DHTMLWindowsObj.instances[id];
//alert('DHTMLWindowsObj.closeit(id = [' + id + '])' + ' oObj = ' + oObj);
	if (oObj != null) {
		oObj.closeit();
	}
};

DHTMLWindowsObj.loadwindow = function(id,url,width,height,leftOffset,topOffset) {
	var oObj = DHTMLWindowsObj.instances[id];
//alert('DHTMLWindowsObj.loadwindow(id = [' + id + '], url = [' + url + '], width = [' + width + '] , height = [' + height + '], leftOffset = [' + leftOffset + '], topOffset = [' + topOffset + '])' + ' oObj = ' + oObj);
	if (oObj != null) {
		oObj.loadwindow(url,width,height,leftOffset,topOffset);
	}
};

DHTMLWindowsObj.getInstance = function(imagePath) {
	// the object.id is the position within the array that holds onto the objects...
	var instance = DHTMLWindowsObj.instances[DHTMLWindowsObj.instances.length];
	if(instance == null) {
		instance = DHTMLWindowsObj.instances[DHTMLWindowsObj.instances.length] = new DHTMLWindowsObj(DHTMLWindowsObj.instances.length, imagePath);
		var f = 'function () { return eval(' + 'DHTMLWindowsObj.drag_drop(' + (DHTMLWindowsObj.instances.length - 1) + ', event)' + '); };';
		DHTMLWindowsObj.drag_drop_funcs[DHTMLWindowsObj.instances.length - 1] = eval(f);
//alert('DHTMLWindowsObj.getInstance(' + imagePath + ')' + ' f = ' + f + ', ' + DHTMLWindowsObj.drag_drop_funcs[DHTMLWindowsObj.instances.length - 1]);
	}
	return instance;
};

DHTMLWindowsObj.removeInstance = function(id) {
	var ret_val = false;
	if ( (id > -1) && (id < DHTMLWindowsObj.instances.length) ) {
		var instance = DHTMLWindowsObj.instances[id];
		if (instance != null) {
			DHTMLWindowsObj.instances[id] = object_destructor(instance);
			ret_val = (DHTMLWindowsObj.instances[id] == null);
		}
	}
	return ret_val;
};

DHTMLWindowsObj.removeInstances = function() {
	var ret_val = true;
	for (var i = 0; i < DHTMLWindowsObj.instances.length; i++) {
		DHTMLWindowsObj.removeInstance(i);
	}
	return ret_val;
};

DHTMLWindowsObj.prototype = {
	id : -1,
	_dragapproved : false,
	_minrestore : 0,
	_initialwidth : -1,
	_initialheight : -1,
	_offsetx : -1,
	_offsety : -1,
	_tempx : -1,
	_tempy : -1,
	_uuid : -1,
	_cframe : 'cframe',
	_maxname : 'maxname',
	_dwindow : 'dwindow',
	_dwindowcontent : 'dwindowcontent',
	_imagePath : 'js/DHTMLWindows-images/',
	ie5 : document.all && document.getElementById,
	ns6 : document.getElementById&&!document.all,
	toString : function() {
		var s_toString = '';
		s_toString += '\n[';
		s_toString += 'id = [' + this.id + ']\n';
		s_toString += '_uuid = [' + this._uuid + ']\n';
		s_toString += '_initialwidth = [' + this._initialwidth + ']\n';
		s_toString += '_initialheight = [' + this._initialheight + ']\n';
		s_toString += '_offsetx = [' + this._offsetx + ']\n';
		s_toString += '_offsety = [' + this._offsety + ']\n';
		s_toString += '_cframe = [' + this._cframe + ']\n';
		s_toString += '_maxname = [' + this._maxname + ']\n';
		s_toString += '_dwindow = [' + this._dwindow + ']\n';
		s_toString += '_dwindowcontent = [' + this._dwindowcontent + ']\n';
		s_toString += '_imagePath = [' + this._imagePath + ']\n';
		s_toString += 'ie5 = [' + this.ie5 + ']\n';
		s_toString += 'ns6 = [' + this.ns6 + ']\n';
		s_toString += ']\n';
		return s_toString;
	},
	asHTML : function() {
		var t = '';

//		t += '<div id="' + this._dwindow + '" style="position:absolute;background-color:#EBEBEB;cursor:hand;left:0px;top:0px;display:none" onMousedown="DHTMLWindowsObj.initializedrag(' + this.id + ', event)" onMouseup="DHTMLWindowsObj.stopdrag(' + this.id + ')" onSelectStart="return false">';
		t += '<div id="' + this._dwindow + '" style="position:absolute;background-color:#EBEBEB;cursor:hand;left:0px;top:0px;display:none">';
		t += '<div align="right" style="background-color:navy"><img src="' + this._imagePath + 'max.gif" id="' + this._maxname + '" onClick="DHTMLWindowsObj.maximize(' + this.id + ')"><img src="' + this._imagePath + 'close.gif" onClick="DHTMLWindowsObj.closeit(' + this.id + ')"></div>';
		t += '<div id="' + this._dwindowcontent + '" style="width:100%; height:100%;">';
		t += '<iframe id="' + this._cframe + '" src="" width="100%" height="100%"></iframe>';
		t += '</div>';
		t += '</div>';
		return (t);
	},
	iecompattest : function() {
		return (!window.opera && document.compatMode && document.compatMode!="BackCompat")? document.documentElement : document.body;
	},
	drag_drop : function(e) {
		var oObj = document.getElementById(this._dwindow);
//alert('drag_drop :: ' + 'oObj = ' + oObj + ', this._dwindow = ' + this._dwindow);
		if (oObj != null) {
			if (this.ie5 && this.dragapproved && event.button==1) {
				oObj.style.left = this._tempx + event.clientX - this._offsetx + "px";
				oObj.style.top = this._tempy + event.clientY - this._offsety + "px";
			}
			else if (this.ns6 && this.dragapproved){
				oObj.style.left = this._tempx + e.clientX - this._offsetx + "px";
				oObj.style.top = this._tempy + e.clientY - this._offsety + "px";
			}
		}
	},
	initializedrag : function(e) {
		this._offsetx = this.ie5 ? event.clientX : e.clientX;
		this._offsety = this.ie5 ? event.clientY : e.clientY;
		var dcObj = document.getElementById(this._dwindowcontent);
		if (dcObj != null) {
			dcObj.style.display = "none"; //extra
		}
		var dObj = document.getElementById(this._dwindow);
		if (dObj != null) {
			this._tempx = parseInt(dObj.style.left);
			this._tempy = parseInt(dObj.style.top);
			
			this._dragapproved = true
//alert('initializedrag :: ' + 'this.id = ' + this.id + ', DHTMLWindowsObj.drag_drop_funcs[' + this.id + '] = ' + DHTMLWindowsObj.drag_drop_funcs[this.id]);
			dObj.onmousemove = null;
			DHTMLWindowsObj.drag_drop_funcs[this.id](e);
		}
	},
	loadwindow : function(url,width,height,leftOffset,topOffset) {
		if (!this.ie5&&!this.ns6)
			window.open(url,"","width=" + width + ",height=" + height + ",scrollbars=1");
		else{
			var dObj = document.getElementById(this._dwindow);
			var cObj = document.getElementById(this._cframe);
			if ( (dObj != null) && (cObj != null) ) {
				leftOffset = ((leftOffset == null) ? 30 : leftOffset);
				topOffset = ((topOffset == null) ? 30 : topOffset);
				dObj.style.display = '';
				dObj.style.width = this._initialwidth = width+"px";
				dObj.style.height = this._initialheight = height+"px";
				dObj.style.left = leftOffset+"px";
				dObj.style.top = this.ns6? window.pageYOffset*1+topOffset+"px" : this.iecompattest().scrollTop*1+topOffset+"px";
				cObj.src = url;
			}
		}
	},
	maximize : function() {
		var mObj = document.getElementById(this._maxname);
		var dObj = document.getElementById(this._dwindow);
		if ( (mObj != null) && (dObj != null) ) {
			if (this._minrestore == 0) {
				this._minrestore = 1 //maximize window
				mObj.setAttribute("src",this._imagePath + "restore.gif");
				dObj.style.width = this.ns6? window.innerWidth-20+"px" : this.iecompattest().clientWidth+"px";
				dObj.style.height = this.ns6? window.innerHeight-20+"px" : this.iecompattest().clientHeight+"px";
			} else {
				this._minrestore = 0 //restore window
				mObj.setAttribute("src",this._imagePath + "max.gif");
				dObj.style.width = this._initialwidth;
				dObj.style.height = this._initialheight;
			}
			dObj.style.left = this.ns6? window.pageXOffset+"px" : this.iecompattest().scrollLeft+"px";
			dObj.style.top = this.ns6? window.pageYOffset+"px" : this.iecompattest().scrollTop+"px";
		}
	},
	closeit : function() {
		var dObj = document.getElementById(this._dwindow);
		if (dObj != null) {
			dObj.style.display="none";
		}
	},
	stopdrag : function() {
		var dObj = document.getElementById(this._dwindow);
		var dcObj = document.getElementById(this._dwindowcontent);
		if ( (dObj != null) && (dcObj != null) ) {
			this._dragapproved = false;
			dObj.onmousemove = null;
			dcObj.style.display = "inline"; //extra
		}
	},
	destructor : function() {
		return (this.id = DHTMLWindowsObj.instances[this.id] = this.id = this._dragapproved = this._minrestore = this._initialwidth = this._initialheight = this._offsetx = this._offsety = this._tempx = this._tempy = this._uuid = this._cframe = this._maxname = this._dwindow = this._dwindowcontent = this._imagePath = this.ie5 = this.ns6 = null);
	},
	dummy : function() {
		return false;
	}
};
