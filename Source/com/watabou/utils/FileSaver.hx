package com.watabou.utils;

#if html5
import js.html.AnchorElement;
import js.html.Blob;
import js.html.URL;
import js.Browser;
#end

class FileSaver {
	public static function saveText( filename:String, text:String ):Void {
		#if html5
		var blob = new Blob([text], {type: "text/plain"});
		var url = URL.createObjectURL( blob );
		var a:AnchorElement = Browser.document.createAnchorElement();
		a.href = url;
		a.download = filename;
		Browser.document.body.appendChild(a);
		a.click();
		Browser.document.body.removeChild(a);
		haxe.Timer.delay(function() URL.revokeObjectURL(url), 1000);
		#else
		trace( "File saving only implemented for HTML5." );
		trace( "Content preview: " + text.substr(0, 80) );
		#end
	}
}
