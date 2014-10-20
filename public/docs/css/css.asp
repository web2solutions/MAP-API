<style type="text/css">
<!--
@charset "UTF-8";

.divShow { display:block; }
.divHidden { display:none; }

* {
	font-family: tahoma;
	font-size: 11px;
	color: #000000;
}
body {
	background-color: #E8E7E3;
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
}
.verdeon {
	color: #006633;
	font: bold 12px Arial, Helvetica, sans-serif;
}
-->


/* SpryMenuBarHorizontal.css - Revision: Spry Preview Release 1.4 */

/* Copyright (c) 2006. Adobe Systems Incorporated. All rights reserved. */

/*******************************************************************************

 LAYOUT INFORMATION: describes box model, positioning, z-order

 *******************************************************************************/

/* The outermost container of the Menu Bar, an auto width box with no margin or padding */
ul.MenuBarHorizontal
{
	margin: 0;
	padding: 0;
	list-style-type: none;
	font-size: 10px;
	cursor: default;
	width: auto;
}
/* Set the active Menu Bar with this class, currently setting z-index to accomodate IE rendering bug: http://therealcrisp.xs4all.nl/meuk/IE-zindexbug.html */
ul.MenuBarActive
{
	z-index: 1000;
}
/* Menu item containers, position children relative to this container and are a fixed width */
ul.MenuBarHorizontal li
{
	margin: 0;
	padding: 0;
	list-style-type: none;
	font-size: 10px;
	position: relative;
	text-align: left;
	cursor: pointer;
	width: auto;
	float: left;
}
/* Submenus should appear below their parent (top: 0) with a higher z-index, but they are initially off the left side of the screen (-1000em) */
ul.MenuBarHorizontal ul
{
	margin: 0;
	padding: 0;
	list-style-type: none;
	font-size: 10px;
	z-index: 1020;
	cursor: default;
	width: 200px;
	position: absolute;
	left: -1000em;
}
/* Submenu that is showing with class designation MenuBarSubmenuVisible, we set left to auto so it comes onto the screen below its parent menu item */
ul.MenuBarHorizontal ul.MenuBarSubmenuVisible
{
	left: auto;
}
/* Menu item containers are same fixed width as parent */
ul.MenuBarHorizontal ul li
{
	width: 100%;
}
/* Submenus should appear slightly overlapping to the right (95%) and up (-5%) */
ul.MenuBarHorizontal ul ul
{
	position: absolute;
	margin: -5% 0 0 95%;
}
/* Submenu that is showing with class designation MenuBarSubmenuVisible, we set left to 0 so it comes onto the screen */
ul.MenuBarHorizontal ul.MenuBarSubmenuVisible ul.MenuBarSubmenuVisible
{
	left: auto;
	top: 0;
}

/*******************************************************************************

 DESIGN INFORMATION: describes color scheme, borders, fonts

 *******************************************************************************/

/* Submenu containers have borders on all sides */
ul.MenuBarHorizontal ul
{
	border-right: 1px solid #333333;
	border-bottom: 1px solid #333333;
	border-left: 1px solid #FFFFFF;
	border-top: 1px solid #FFFFFF;
}
/* Menu items are a light gray block with padding and no text decoration */
ul.MenuBarHorizontal a
{
	display: block;
	cursor: pointer;
	background-color: #D4D0C8;
	padding: 0.5em 0.75em;
	color: #333;
	text-decoration: none;
	border: 1px solid #D4D0C8;
}
/* Menu items that have mouse over or focus have a blue background and white text */
ul.MenuBarHorizontal a:hover, ul.MenuBarHorizontal a:focus
{
	background-color: #D4D0C8;
	color: #333;
	border-right: 1px solid #333333;
	border-bottom: 1px solid #333333;
	border-left: 1px solid #FFFFFF;
	border-top: 1px solid #FFFFFF;
}
/* Menu items that are open with submenus are set to MenuBarItemHover with a blue background and white text */
ul.MenuBarHorizontal a.MenuBarItemHover, ul.MenuBarHorizontal a.MenuBarItemSubmenuHover, ul.MenuBarHorizontal a.MenuBarSubmenuVisible
{
	background-color: #D4D0C8;
	color: #333;
	border-right: 1px solid #333333;
	border-bottom: 1px solid #333333;
	border-left: 1px solid #FFFFFF;
	border-top: 1px solid #FFFFFF;
}

/*******************************************************************************

 SUBMENU INDICATION: styles if there is a submenu under a given menu item

 *******************************************************************************/

/* Menu items that have a submenu have the class designation MenuBarItemSubmenu and are set to use a background image positioned on the far left (95%) and centered vertically (50%) */
ul.MenuBarHorizontal a.MenuBarItemSubmenu
{
	background-image: url(SpryMenuBarDown.gif);
	background-repeat: no-repeat;
	background-position: 95% 50%;
}
/* Menu items that have a submenu have the class designation MenuBarItemSubmenu and are set to use a background image positioned on the far left (95%) and centered vertically (50%) */
ul.MenuBarHorizontal ul a.MenuBarItemSubmenu
{
	background-image: url(SpryMenuBarRight.gif);
	background-repeat: no-repeat;
	background-position: 95% 50%;
}
/* Menu items that are open with submenus have the class designation MenuBarItemSubmenuHover and are set to use a "hover" background image positioned on the far left (95%) and centered vertically (50%) */
ul.MenuBarHorizontal a.MenuBarItemSubmenuHover
{
	background-image: url(SpryMenuBarDownHover.gif);
	background-repeat: no-repeat;
	background-position: 95% 50%;
}
/* Menu items that are open with submenus have the class designation MenuBarItemSubmenuHover and are set to use a "hover" background image positioned on the far left (95%) and centered vertically (50%) */
ul.MenuBarHorizontal ul a.MenuBarItemSubmenuHover
{
	background-image: url(SpryMenuBarRightHover.gif);
	background-repeat: no-repeat;
	background-position: 95% 50%;
}

/*******************************************************************************

 BROWSER HACKS: the hacks below should not be changed unless you are an expert

 *******************************************************************************/

/* HACK FOR IE: to make sure the sub menus show above form controls, we underlay each submenu with an iframe */
ul.MenuBarHorizontal iframe
{
	position: absolute;
	z-index: 1010;
}
/* HACK FOR IE: to stabilize appearance of menu items; the slash in float is to keep IE 5.0 from parsing */
@media screen, projection
{
	ul.MenuBarHorizontal li.MenuBarItemIE
	{
		display: inline;
		float: left;
		background: #FFF;
	}
}
-->
select {
	height: 20px;
	font-size: 12px;
	color: #4B6B89;
	border: 1px solid #cccccc;
	background-color: #F5F5F5;
}
		
optgroup {
	background-color: #EDF5FF;
	color: #000;
}
label {
	font-size: 12px;
	color: #333333;
	text-align: left;
	margin-left: 3px;
	}
input {
	height: 18px;
	font-size: 12px;
	color: #4B6B89;
	border: 1px solid #cccccc;
	background-color: #F5F5F5;
	}
textarea {
	border: 1px solid #7F9DB9;
	margin-bottom: 3px;
	padding: 3px;
	background-color: #F5F5F5;
	font-size: 12px;
	width: 320px;
	color: #4B6B89;
	margin-left: 5px;
	}
	
	
	
	.highslide-html {
    background-color: white;
}
.highslide-html-blur {
}
.highslide-html-content {
	position: absolute;
    display: none;
}
.highslide-loading {
    display: block;
	color: black;
	font-size: 8pt;
	font-family: sans-serif;
	font-weight: bold;
    text-decoration: none;
	padding: 2px;
	border: 1px solid black;
    background-color: white;
    
    padding-left: 22px;
    background-image: url(highslide/graphics/loader.white.gif);
    background-repeat: no-repeat;
    background-position: 3px 1px;
}
a.highslide-credits,
a.highslide-credits i {
    padding: 2px;
    color: silver;
    text-decoration: none;
	font-size: 10px;
}
a.highslide-credits:hover,
a.highslide-credits:hover i {
    color: white;
    background-color: gray;
}


/* Styles for the popup */
.highslide-wrapper {
	background-color: white;
}
.highslide-wrapper .highslide-html-content {
    width: 400px;
    padding: 5px;
}
.highslide-wrapper .highslide-header div {
}
.highslide-wrapper .highslide-header ul {
	margin: 0;
	padding: 0;
	text-align: right;
}
.highslide-wrapper .highslide-header ul li {
	display: inline;
	padding-left: 1em;
}
.highslide-wrapper .highslide-header ul li.highslide-previous, .highslide-wrapper .highslide-header ul li.highslide-next {
	display: none;
}
.highslide-wrapper .highslide-header a {
	font-weight: bold;
	color: gray;
	text-transform: uppercase;
	text-decoration: none;
}
.highslide-wrapper .highslide-header a:hover {
	color: black;
}
.highslide-wrapper .highslide-header .highslide-move a {
	cursor: move;
}
.highslide-wrapper .highslide-footer {
	height: 11px;
}
.highslide-wrapper .highslide-footer .highslide-resize {
	float: right;
	height: 11px;
	width: 11px;
	background: url(highslide/graphics/resize.gif);
}
.highslide-wrapper .highslide-body {
}
.highslide-move {
    cursor: move;
}
.highslide-resize {
    cursor: nw-resize;
}

/* These must be the last of the Highslide rules */
.highslide-display-block {
    display: block;
}
.highslide-display-none {
    display: none;
}
/*======= Inicio SWFUpload =======*/
.progressWrapper {
	width: 357px;
	overflow: hidden;
}
.progressContainer {
	margin: 5px;
	padding: 4px;
	
	border: solid 1px #E8E8E8;
	background-color: #F7F7F7;
	
	overflow: hidden;
}
.red /* Error */
{
	border: solid 1px #B50000;
	background-color: #FFEBEB;
}
.green /* Current */ 
{
	border: solid 1px #DDF0DD;
	background-color: #EBFFEB;
}
.blue /* Complete */
{
	border: solid 1px #CEE2F2;
	background-color: #F0F5FF;
}

.progressName {
	font-size: 8pt;
	font-weight: bold;
	color: #555555;
	
	width: 323px;
	height: 14px;
	text-align: left;
	white-space: nowrap;
	overflow: hidden;
}
.progressBarInProgress,
.progressBarComplete,
.progressBarError {
	font-size: 0px;
	width: 0%;
	height: 2px;
	background-color: blue;
	margin-top: 2px;
}
.progressBarComplete {
	width: 100%;
	background-color: green;
	visibility: hidden;
}
.progressBarError {
	width: 100%;
	background-color: red;
	visibility: hidden;
}
.progressBarStatus {
	margin-top: 2px;
	width: 337px;
	font-size: 7pt;
	font-family: Verdana;
	text-align: left;
	white-space: nowrap;
}
a.progressCancel {
	font-size: 0;
	display: block;
	height: 14px;
	width: 14px;
	background-image: url(Scripts/swfupload/cancelbutton.gif);
	background-repeat: no-repeat;
	background-position: -14px 0px;
	float: right;
}

a.progressCancel:hover {
	background-position: 0px 0px;
}


#thumbnails {
	margin-bottom: 15px;
	padding:5px;
}

#thumbnails img {
	margin: 5px;
}

button {
	height: 19px;
	font-size: 0.7em;
	color: #4B6B89;
	margin-bottom: 3px;
	margin-top: 5px;
	border: 1px solid #cccccc;
	background-color: #EAEAEA;
	width: 185px;
	margin-left: 5px;
}
/*======= Fim SWFUpload =======*/
</style>