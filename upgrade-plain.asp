<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>Firmware Upgrade</title>
<style type="text/css">
body {
    background:rgb(0,0,0) url(tomatousb_bg.png);
    font:14px Tahoma,Arial,sans-serif;
    color:rgb(255,255,255);
}
input {
    width:80px;
    height:24px;
}
.div {
    width:800px;
    height:240px;
    background-color:rgb(47,61,64);
    position:absolute;
    top:0;
    bottom:0;
    left:0;
    right:0;
    text-align:center;
    margin:auto;
    padding:10px 10px;
    border-radius:5px;
}
</style>
</head>
<body>
    <div class="div">
		<h1>固件升级</h1>
		<b>警告:</b>
		<ul>
			<li>当您按下升级按纽后，本页面并不显示更新进度，在更新固件完成后才会显示新的页面.
			<li>固件升级完成大约需要3分钟. 在这期间请不要断开路由器或者浏览页面.
		</ul>
		<br />
		<form name="firmware_upgrade" method="post" action="upgrade.cgi?<% nv(http_id) %>" encType="multipart/form-data">
			<div>
				<input type="hidden" name="submit_button" value="升级">
				固件: <input type="file" name="file"> <input type="submit" value="升级">
			</div>
		</form>
	</div>
</body>
</html>