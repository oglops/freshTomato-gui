<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<!--
	Tomato GUI
	Copyright (C) 2006-2010 Jonathan Zarate
	http://www.polarcloud.com/tomato/

	For use with Tomato Firmware only.
	No part of this file may be used without permission.
-->
<html>
<head>
<meta http-equiv='content-type' content='text/html;charset=utf-8'>
<meta name='robots' content='noindex,nofollow'>
<title>[<% ident(); %>] 实用工具: 无线勘测</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
#survey-grid .brate {
	color: blue;
}
#survey-grid .grate {
	color: green;
}
#survey-grid .co4 {
	text-align: right;
}
#survey-grid .co5,
#survey-grid .co6,
#survey-grid .co7 {
	text-align: center;
}
#survey-msg {
	border: 1px dashed #f0f0f0;
	background: #fefefe;
	padding: 5px;
	width: 300px;
	position: absolute;
}
#survey-controls {
	text-align: right;
}
#expire-time {
	width: 120px;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>
//	<% nvram(''); %>	// http_id

var wlscandata = [];
var entries = [];
var dayOfWeek = ['日','一','二','三','四','五','六'];

Date.prototype.toWHMS = function() {
	return dayOfWeek[this.getDay()] + ' ' + this.getHours() + ':' + this.getMinutes().pad(2)+ ':' + this.getSeconds().pad(2);
}

var sg = new TomatoGrid();

sg.sortCompare = function(a, b) {
	var col = this.sortColumn;
	var da = a.getRowData();
	var db = b.getRowData();
	var r;

	switch (col) {
	case 0:
		r = -cmpDate(da.lastSeen, db.lastSeen);
		break;
	case 3:
		r = cmpInt(da.rssi, db.rssi);
		break;
	case 4:
		r = cmpInt(da.qual, db.qual);
		break;
	case 5:
		r = cmpInt(da.channel, db.channel);
		break;
	default:
		r = cmpText(a.cells[col].innerHTML, b.cells[col].innerHTML);
	}
	if (r == 0) r = cmpText(da.bssid, db.bssid);

	return this.sortAscending ? r : -r;
}

sg.rateSorter = function(a, b)
{
	if (a < b) return -1;
	if (a > b) return 1;
	return 0;
}

sg.populate = function()
{
	var added = 0;
	var removed = 0;
	var i, j, k, t, e, s;

	if ((wlscandata.length == 1) && (!wlscandata[0][0])) {
		setMsg("error: " + wlscandata[0][1]);
		return;
	}

	for (i = 0; i < wlscandata.length; ++i) {
		s = wlscandata[i];
		e = null;

		for (j = 0; j < entries.length; ++j) {
			if (entries[j].bssid == s[0]) {
				e = entries[j];
				break;
			}
		}
		if (!e) {
			++added;
			e = {};
			e.firstSeen = new Date();
			entries.push(e);
		}
		e.lastSeen = new Date();
		e.bssid = s[0];
		e.ssid = s[1];
		e.channel = s[3];
		e.channel = e.channel + '<br /><small>' + s[9] + ' GHz<\/small>'+ '<br /><small>' + s[4] + ' MHz<\/small>';
		e.rssi = s[2];
		e.cap = s[7]+ '<br />' +s[8];
		e.rates = s[6];
		e.qual = Math.round(s[5]);
	}

	t = E('expire-time').value;
	if (t > 0) {
		var cut = (new Date()).getTime() - (t * 1000);
		for (i = 0; i < entries.length; ) {
			if (entries[i].lastSeen.getTime() < cut) {
				entries.splice(i, 1);
				++removed;
			}
			else ++i;
		}
	}

	for (i = 0; i < entries.length; ++i) {
		var seen, m, mac;

		e = entries[i];

		seen = e.lastSeen.toWHMS();
		if (useAjax()) {
			m = Math.floor(((new Date()).getTime() - e.firstSeen.getTime()) / 60000);
			if (m <= 10) seen += '<br /> <b><small>NEW (' + -m + 'm)<\/small><\/b>';
		}

		mac = e.bssid;
		if (mac.match(/^(..):(..):(..)/))
			mac = '<a href="http://api.macvendors.com/' + RegExp.$1 + '-' + RegExp.$2 + '-' + RegExp.$3 + '" class="new_window" title="OUI search">' + mac + '<\/a>';

		sg.insert(-1, e, [
			'<small>' + seen + '<\/small>',
			'' + e.ssid,
			mac,
			(e.rssi == -999) ? '' : (e.rssi + ' <small>dBm<\/small>'),
			'<small>' + e.qual + '<\/small> <img src="bar' + MIN(MAX(Math.floor(e.qual / 10), 1), 6) + '.gif">',
			'' + e.channel,
			'' + e.cap,
			'' + e.rates], false);
	}

	s = '';
	if (useAjax()) s = added + ' 个新增, ' + removed + ' 个移除, ';
	s += entries.length + ' 个AP可用.';

	s += '<br /><br /><small>更新于: 星期: ' + (new Date()).toWHMS() + '<\/small>';
	setMsg(s);

	wlscandata = [];
}

sg.setup = function() {
	this.init('survey-grid', 'sort');
	this.headerSet(['最近可见', 'SSID', 'BSSID', 'RSSI &nbsp; &nbsp; ', '信号质量', '所选信道', '加密方式', '传输速率']);
	this.populate();
	this.sort(0);
}


function setMsg(msg)
{
	E('survey-msg').innerHTML = msg;
}


var ref = new TomatoRefresh('update.cgi', 'exec=wlscan', 0, 'tools_survey_refresh');

ref.refresh = function(text)
{
	try {
		eval(text);
	}
	catch (ex) {
		return;
	}
	sg.removeAllData();
	sg.populate();
	sg.resort();
}

function earlyInit()
{
	if (!useAjax()) E('expire-time').style.visibility = 'hidden';
	sg.setup();
}

function init()
{
	new observer(InNewWindow).observe(E("survey-grid"), { childList: true, subtree: true });
	sg.recolor();
	ref.initPage();
}

var observer = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;

function InNewWindow () {
	var elements = document.getElementsByClassName("new_window");
	for (var i = 0; i < elements.length; i++) if (elements[i].nodeName.toLowerCase()==="a")
		addEvent(elements[i], "click", function(e) { cancelDefaultAction(e); window.open(this,"_blank"); } );
}
</script>
</head>
<body onload='init()'>
<form action='javascript:{}'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<div class='section-title'>无线网络勘测</div>
<div class='section'>
	<div id="survey-grid" class="tomato-grid"></div>
	<div id='survey-msg'></div>
	<br /><br /><br /><br />
	<script type='text/javascript'>
	if ('<% wlclient(); %>' == '0') {
		document.write('<small>注意：使用此工具可能会导致无线客户端和此路由器的连接中断.<\/small>');
	}
	</script>
</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan='2'>
	<div id='survey-controls'>
		<img src="spin.gif" alt="" id="refresh-spinner">
		<script type='text/javascript'>
		genStdTimeList('expire-time', 'Auto Expire', 0);
		genStdTimeList('refresh-time', 'Auto Refresh', 0);
		</script>
		<input type="button" value="Refresh" onclick="ref.toggle()" id="refresh-button">
	</div>
</td></tr>
</table>
</form>
<script type='text/javascript'>earlyInit();</script>
</body>
</html>