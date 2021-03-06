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
<title>[<% ident(); %>] 带宽监控：最近24小时</title>
<link rel='stylesheet' type='text/css' href='tomato.css'>
<% css(); %>
<script type='text/javascript' src='tomato.js'></script>

<!-- / / / -->

<style type='text/css'>
#txt {
	width: 550px;
	white-space: nowrap;
}
#bwm-controls {
	text-align: right;
	margin-right: 5px;
	margin-top: 5px;
	float: right;
	visibility: hidden;
}
</style>

<script type='text/javascript' src='debug.js'></script>

<script type='text/javascript' src='wireless.jsx?_http_id=<% nv(http_id); %>'></script>
<script type='text/javascript' src='bwm-hist.js'></script>
<script type='text/javascript' src='bwm-common.js'></script>
<script type='text/javascript' src='interfaces.js'></script>

<script type='text/javascript'>

//	<% nvram("wan_ifname,wan_iface,wan2_ifname,wan2_iface,wan3_ifname,wan3_iface,wan4_ifname,wan4_iface,lan_ifname,wl_ifname,wan_proto,wan2_proto,wan3_proto,wan4_proto,web_svg,rstats_enable,rstats_colors"); %>

var cprefix = 'bw_24';
var updateInt = 120;
var updateDiv = updateInt;
var updateMaxL = 720;
var updateReTotal = 1;
var hours = 24;
var lastHours = 0;
var debugTime = 0;
var rstats_busy = 0;

function showHours()
{
	if (hours == lastHours) return;
	showSelectedOption('hr', lastHours, hours);
	lastHours = hours;
}

function switchHours(h)
{
	if ((!svgReady) || (updating)) return;

	hours = h;
	updateMaxL = (720 / 24) * hours;
	showHours();
	loadData();
	cookie.set(cprefix + 'hrs', hours);
}

var ref = new TomatoRefresh('update.cgi', 'exec=bandwidth&arg0=speed');

ref.refresh = function(text)
{
	++updating;
	try {
		this.refreshTime = 1500;
		speed_history = {};
		try {
			eval(text);
			if (rstats_busy) {
				E('rbusy').style.display = 'none';
				rstats_busy = 0;
			}
			this.refreshTime = (fixInt(speed_history._next, 1, 120, 60) + 2) * 1000;
		}
		catch (ex) {
			speed_history = {};
		}
		if (debugTime) E('dtime').innerHTML = (new Date()) + ' ' + (this.refreshTime / 1000);
		loadData();
	}
	catch (ex) {
//		alert('ex=' + ex);
	}
	--updating;
}

ref.showState = function()
{
	E('refresh-button').value = this.running ? '停止' : '开始';
}

ref.toggleX = function()
{
	this.toggle();
	this.showState();
	cookie.set(cprefix + 'refresh', this.running ? 1 : 0);
}

ref.initX = function()
{
	var a;

	a = fixInt(cookie.get(cprefix + 'refresh'), 0, 1, 1);
	if (a) {
		ref.refreshTime = 100;
		ref.toggleX();
	}
}

function init()
{
	if (nvram.rstats_enable != '1') {
		E('refresh-button').setAttribute("disabled", "disabled");
		return;
	}

	try {
	//	<% bandwidth("speed"); %>
	}
	catch (ex) {
		speed_history = {};
	}
	rstats_busy = 0;
	if (typeof(speed_history) == 'undefined') {
		speed_history = {};
		rstats_busy = 1;
		E('rbusy').style.display = '';
	}

	hours = fixInt(cookie.get(cprefix + 'hrs'), 1, 24, 24);
	updateMaxL = (720 / 24) * hours;
	showHours();

	initCommon(1, 0, 0, 1);
	ref.initX();
}
</script>

</head>
<body onload='init()'>
<form action=''>
<table id='container' cellspacing=0>
<tr><td colspan=2 id='header'>
	<div class='title'>Tomato</div>
	<div class='version'>Version <% version(); %></div>
</td></tr>
<tr id='body'><td id='navi'><script type='text/javascript'>navi()</script></td>
<td id='content'>
<div id='ident'><% ident(); %></div>

<!-- / / / -->

<div class='section-title'>WAN Bandwidth - Last 24 Hours</div>
<div id='rstats'>
	<div id='tab-area'></div>

	<script type='text/javascript'>
	if ((nvram.web_svg != '0') && (nvram.rstats_enable == '1')) {
		W('<div style="border-top:1px solid #f0f0f0;border-bottom:1px solid #f0f0f0;visibility:hidden;padding:0;margin:0" id="graph"><embed src="bwm-graph.svg?<% version(); %>" style="width:760px;height:300px;margin:0;padding:0" type="image/svg+xml" pluginspage="http://www.adobe.com/svg/viewer/install/"><\/embed><\/div>\n');
	}
	</script>

	<div id='bwm-controls'>
		<small>(2 分钟间隔)</small>
		<br />
		<br />
		单位(小时):&nbsp;
			<a href='javascript:switchHours(1);' id='hr1'>1</a>,
			<a href='javascript:switchHours(2);' id='hr2'>2</a>,
			<a href='javascript:switchHours(4);' id='hr4'>4</a>,
			<a href='javascript:switchHours(6);' id='hr6'>6</a>,
			<a href='javascript:switchHours(12);' id='hr12'>12</a>,
			<a href='javascript:switchHours(18);' id='hr18'>18</a>,
			<a href='javascript:switchHours(24);' id='hr24'>24</a><br />
		平均:&nbsp;
			<a href='javascript:switchAvg(1)' id='avg1'>关闭</a>,
			<a href='javascript:switchAvg(2)' id='avg2'>2x</a>,
			<a href='javascript:switchAvg(4)' id='avg4'>4x</a>,
			<a href='javascript:switchAvg(6)' id='avg6'>6x</a>,
			<a href='javascript:switchAvg(8)' id='avg8'>8x</a><br />
		最大:&nbsp;
			<a href='javascript:switchScale(0)' id='scale0'>一致</a>,
			<a href='javascript:switchScale(1)' id='scale1'>每个 IF</a><br />
		单位:&nbsp;
			<a href='javascript:switchUnit(0)' id='unit0'>kbit/KB</a>,
			<a href='javascript:switchUnit(1)' id='unit1'>Mbit/MB</a><br />
		显示:&nbsp;
			<a href='javascript:switchDraw(0)' id='draw0'>填充</a>,
			<a href='javascript:switchDraw(1)' id='draw1'>实线</a><br />
		颜色:&nbsp; <a href='javascript:switchColor()' id='drawcolor'>-</a><br />
		<small><a href='javascript:switchColor(1)' id='drawrev'>[颜色反转]</a></small><br />
		<br /><br />
		&nbsp; &raquo; <a href="admin-bwm.asp">设置</a>
	</div>

	<br /><br />
	<table border=0 cellspacing=2 id='txt'>
		<tr>
			<td style='width:8%' align='right' valign='top'><b style='border-bottom:blue 1px solid' id='rx-name'>接收</b></td>
			<td style='width:15%' align='right' valign='top'><span id='rx-current'></span></td>
			<td style='width:8%' align='right' valign='top'><b>平均</b></td>
			<td style='width:15%' align='right' valign='top' id='rx-avg'></td>
			<td style='width:8%' align='right' valign='top'><b>最大</b></td>
			<td style='width:15%' align='right' valign='top' id='rx-max'></td>
			<td style='width:8%' align='right' valign='top'><b>合计</b></td>
			<td style='width:14%' align='right' valign='top' id='rx-total'></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td style='width:8%' align='right' valign='top'><b style='border-bottom:blue 1px solid' id='tx-name'>传送</b></td>
			<td style='width:15%' align='right' valign='top'><span id='tx-current'></span></td>
			<td style='width:8%' align='right' valign='top'><b>平均</b></td>
			<td style='width:15%' align='right' valign='top' id='tx-avg'></td>
			<td style='width:8%' align='right' valign='top'><b>最大</b></td>
			<td style='width:15%' align='right' valign='top' id='tx-max'></td>
			<td style='width:8%' align='right' valign='top'><b>合计</b></td>
			<td style='width:14%' align='right' valign='top' id='tx-total'></td>
			<td>&nbsp;</td>
		</tr>
	</table>

	<br />

</div>

<!-- / / / -->

<script type='text/javascript'>checkRstats();</script>

<!-- / / / -->

</td></tr>
<tr><td id='footer' colspan=2>
	<span id='dtime'></span>
	<img src='spin.gif' id='refresh-spinner' alt='' onclick='debugTime=1'>
	<input type='button' value='刷新' id='refresh-button' onclick='ref.toggleX()'>
</td></tr>
</table>
</form>
</body>
</html>
