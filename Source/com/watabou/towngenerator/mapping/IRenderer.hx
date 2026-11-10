package com.watabou.towngenerator.mapping;

interface IRenderer {
	public function beginFill( color:Int, alpha:Float = 1.0 ):Void;
	public function lineStyle( thickness:Float, color:Int, alpha:Float = 1.0 ):Void;
	public function moveTo( x:Float, y:Float ):Void;
	public function lineTo( x:Float, y:Float ):Void;
	public function drawCircle( x:Float, y:Float, radius:Float ):Void;
	public function endFill():Void;

	// Optional structure helpers. Renderers that don't support these can no-op.
	public function beginGroup( id:String ):Void;
	public function beginGroupEx( id:String, attrs:String ):Void;
	public function endGroup():Void;

	// Document-level hints. Renderers that don't support these can no-op.
	public function setViewBox( x:Float, y:Float, w:Float, h:Float ):Void;
	public function setBackground( color:Int, alpha:Float = 1.0 ):Void;
}
