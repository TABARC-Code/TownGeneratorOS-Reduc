package com.watabou.towngenerator.mapping;

import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.JointStyle;

class OpenFLRenderer implements IRenderer {
	private var g:Graphics;

	public function new( graphics:Graphics ) {
		this.g = graphics;
	}

	public function beginFill( color:Int, alpha:Float = 1.0 ):Void {
		g.beginFill( color, alpha );
	}

	public function lineStyle( thickness:Float, color:Int, alpha:Float = 1.0 ):Void {
		if (thickness <= 0) {
			g.lineStyle( 0, 0, 0 );
		} else {
			g.lineStyle( thickness, color, alpha, false, null, CapsStyle.ROUND, JointStyle.ROUND );
		}
	}

	public function moveTo( x:Float, y:Float ):Void {
		g.moveTo( x, y );
	}

	public function lineTo( x:Float, y:Float ):Void {
		g.lineTo( x, y );
	}

	public function drawCircle( x:Float, y:Float, radius:Float ):Void {
		g.drawCircle( x, y, radius );
	}

	public function endFill():Void {
		g.endFill();
	}

	// Structure helpers: not applicable for immediate-mode OpenFL drawing.
	public function beginGroup( id:String ):Void {}
	public function beginGroupEx( id:String, attrs:String ):Void {}
	public function endGroup():Void {}

	// Document-level hints: not applicable.
	public function setViewBox( x:Float, y:Float, w:Float, h:Float ):Void {}
	public function setBackground( color:Int, alpha:Float = 1.0 ):Void {}
}
