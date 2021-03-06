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
<title>[<% ident(); %>] 端口转发：端口触发</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->
<style type='text/css'>
#tg-grid .co1 {
	width: 5%;
	text-align: center;
}
#tg-grid .co2 {
	width: 10%;
}
#tg-grid .co3 {
	width: 20%;
}
#tg-grid .co4 {
	width: 20%;
}
#tg-grid .co5 {
	width: 45%;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript'>

//	<% nvram("trigforward"); %>

var tg = new TomatoGrid();

tg.sortCompare = function(a, b) {
	var col = this.sortColumn;
	var da = a.getRowData();
	var db = b.getRowData();
	var r;

	switch (col) {
	case 2:	// t prt
	case 3:	// f prt
		r = cmpInt(da[col], db[col]);
		break;
	default:
		r = cmpText(da[col], db[col]);
		break;
	}

	return this.sortAscending ? r : -r;
}

tg.dataToView = function(data) {
	return [data[0] ? '是' : '', ['TCP', 'UDP', 'TCP / UDP'][data[1] - 1], data[2], data[3], data[4]];
}

tg.fieldValuesToData = function(row) {
	var f = fields.getAll(row);
	return [f[0].checked ? 1 : 0, f[1].value, f[2].value, f[3].value, f[4].value];
}

tg.verifyFields = function(row, quiet) {
	var f = fields.getAll(row);
	ferror.clearAll(f);
	if (!v_portrange(f[2], quiet)) return 0;
	if (!v_portrange(f[3], quiet)) return 0;
	f[4].value = f[4].value.replace(/>/g, '_');
	if (!v_nodelim(f[4], quiet, 'Description')) return 0;
	return 1;
}

tg.resetNewEditor = function() {
	var f = fields.getAll(this.newEditor);
	f[0].checked = 1;
	f[1].selectedIndex = 0;
	f[2].value = '';
	f[3].value = '';
	f[4].value = '';
	ferror.clearAll(f);
}

tg.setup = function() {
	this.init('tg-grid', 'sort', 50, [
		{ type: 'checkbox' },
		{ type: 'select', options: [[1, 'TCP'],[2, 'UDP'],[3,'Both']] },
		{ type: 'text', maxlen: 16 },
		{ type: 'text', maxlen: 16 },
		{ type: 'text', maxlen: 32 }]);
	this.headerSet(['开启', '协议', '触发端口', '转发端口', '描述']);
	var nv = nvram.trigforward.split('>');
	for (var i = 0; i < nv.length; ++i) {
		var r;
		if (r = nv[i].match(/^(\d)<(\d)<(.+?)<(.+?)<(.*)$/)) {
			r[1] *= 1;
			r[2] *= 1;
			r[3] = r[3].replace(/:/g, '-');
			r[4] = r[4].replace(/:/g, '-');
			tg.insertData(-1, r.slice(1, 6));
		}
	}
	tg.sort(4);
	tg.showNewEditor();
}


function save()
{
	if (tg.isEditing()) return;

	var data = tg.getAllData();
	var s = '';
	for (var i = 0; i < data.length; ++i) {
		data[i][2] = data[i][2].replace(/-/g, ':');
		data[i][3] = data[i][3].replace(/-/g, ':');
		s += data[i].join('<') + '>';
	}
	var fom = E('t_fom');
	fom.trigforward.value = s;
	form.submit(fom, 1);
}

function init()
{
	tg.recolor();
	tg.resetNewEditor();
}
</script>
</head>
<body onload='init()'>
<form id='t_fom' method='post' action='tomato.cgi'>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<input type='hidden' name='_nextpage' value='forward.asp'>
<input type='hidden' name='_service' value='firewall-restart'>

<input type='hidden' name='trigforward'>

<div class='section-title'>触发式端口转发</div>
<div class='section'>
	<div class="tomato-grid" id="tg-grid"></div>
	<script type='text/javascript'>tg.setup();</script>
</div>

<div class='section-title'>Notes</div>
<div class='section'>
    <ul>
		<li>使用 "-" 指定端口范围 (200-300).</li>
		<li>触发端口是第一个 LAN 到 WAN 的"触发器".</li>
		<li>被转发的端口是 WAN 到 LAN 的端口，它们是否开启取决于"触发器"的激活状态.</li>
		<li>这些端口将会在停止使用的几分钟后自动关闭.</li>
    </ul>
</div>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='footer-msg'></span>
	<input type='button' value='保存设置' id='save-button' onclick='save()'>
	<input type='button' value='取消设置' id='cancel-button' onclick='reloadPage();'>
</td></tr>
</table>
</form>
</body>
</html>