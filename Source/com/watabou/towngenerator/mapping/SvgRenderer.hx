package com.watabou.towngenerator.mapping;

import StringTools;

class SvgRenderer implements IRenderer {
	private var body:StringBuf;
	private var path:StringBuf;
	private var hasPath:Bool = false;
	private var filling:Bool = false;

	private var fillColor:Int = 0;
	private var fillAlpha:Float = 1;
	private var strokeColor:Int = 0;
	private var strokeAlpha:Float = 1;
	private var strokeWidth:Float = 0;

	private var vbSet:Bool = false;
	private var vbX:Float = 0;
	private var vbY:Float = 0;
	private var vbW:Float = 0;
	private var vbH:Float = 0;
	private var bgSet:Bool = false;
	private var bgColor:Int = 0xFFFFFF;
	private var bgAlpha:Float = 1;
	private var groupDepth:Int = 0;

	public function new() {
		body = new StringBuf();
		path = new StringBuf();
	}

	public function setViewBox(x:Float, y:Float, w:Float, h:Float):Void {
		vbSet = true;
		vbX = x; vbY = y; vbW = w; vbH = h;
	}

	public function setBackground(color:Int, alpha:Float = 1.0):Void {
		bgSet = true;
		bgColor = color;
		bgAlpha = alpha;
	}

	public function beginGroup(id:String):Void beginGroupEx(id, "");

	public function beginGroupEx(id:String, attrs:String):Void {
		endFill();
		var suffix = attrs == null || attrs.length == 0 ? "" : " " + attrs;
		body.add('<g id="' + StringTools.htmlEscape(id, true) + '"' + suffix + '>\n');
		groupDepth++;
	}

	public function endGroup():Void {
		endFill();
		if (groupDepth > 0) {
			body.add('</g>\n');
			groupDepth--;
		}
	}

	public function beginFill(color:Int, alpha:Float = 1.0):Void {
		endFill();
		fillColor = color;
		fillAlpha = alpha;
		filling = true;
	}

	public function lineStyle(thickness:Float, color:Int, alpha:Float = 1.0):Void {
		flushPath();
		strokeWidth = thickness;
		strokeColor = color;
		strokeAlpha = alpha;
	}

	public function moveTo(x:Float, y:Float):Void {
		flushPath();
		path.add('M ' + x + ' ' + y + ' ');
		hasPath = true;
	}

	public function lineTo(x:Float, y:Float):Void {
		if (hasPath) path.add('L ' + x + ' ' + y + ' ');
	}

	public function drawCircle(x:Float, y:Float, radius:Float):Void {
		flushPath();
		body.add('<circle cx="' + x + '" cy="' + y + '" r="' + radius + '"');
		body.add(paint());
		body.add(' />\n');
	}

	public function endFill():Void {
		flushPath();
		filling = false;
	}

	private function paint():String {
		var fill = filling ? ' fill="#' + StringTools.hex(fillColor & 0xFFFFFF, 6) + '" fill-opacity="' + fillAlpha + '"' : ' fill="none"';
		var stroke = strokeWidth > 0 ? ' stroke="#' + StringTools.hex(strokeColor & 0xFFFFFF, 6) + '" stroke-width="' + strokeWidth + '" stroke-opacity="' + strokeAlpha + '" stroke-linecap="round" stroke-linejoin="round"' : ' stroke="none"';
		return fill + stroke;
	}

	private function flushPath():Void {
		if (!hasPath) return;
		body.add('<path d="' + path.toString() + (filling ? 'Z' : '') + '"' + paint() + ' />\n');
		path = new StringBuf();
		hasPath = false;
	}

	public function getOutput():String {
		endFill();
		while (groupDepth > 0) endGroup();
		var out = new StringBuf();
		if (vbSet) {
			out.add('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="' + vbW + '" height="' + vbH + '" viewBox="' + vbX + ' ' + vbY + ' ' + vbW + ' ' + vbH + '" preserveAspectRatio="xMidYMid meet">\n');
		} else {
			out.add('<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="100%" height="100%">\n');
		}
		if (bgSet) {
			var bounds = vbSet ? ' x="' + vbX + '" y="' + vbY + '" width="' + vbW + '" height="' + vbH + '"' : ' x="0" y="0" width="100%" height="100%"';
			out.add('<rect' + bounds + ' fill="#' + StringTools.hex(bgColor & 0xFFFFFF, 6) + '" fill-opacity="' + bgAlpha + '" stroke="none" />\n');
		}
		out.add(body.toString());
		out.add('</svg>\n');
		return out.toString();
	}
}
