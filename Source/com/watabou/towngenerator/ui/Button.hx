package com.watabou.towngenerator.ui;

import com.watabou.towngenerator.Main;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;

import msignal.Signal.Signal1;

import com.watabou.coogee.BitmapText;

import com.watabou.towngenerator.mapping.CityMap;

class Button extends Sprite {

	private static inline var WIDTH		= 45;
	private static inline var HEIGHT	= 13;

	public var click	: Signal1<MouseEvent> = new Signal1<MouseEvent>();

	public function new( label:String ) {
		super();

		var txtBmp = new BitmapText( Main.uiFont, label ).bitmapData;
		var bmp = new BitmapData(Std.int(Math.max(WIDTH, txtBmp.width + 10)), HEIGHT, false, CityMap.palette.dark);
		bmp.copyPixels( txtBmp, txtBmp.rect, new Point( 5, (HEIGHT - Main.uiFont.baseLine) >> 1 ), null, null, true );
		addChild( new Bitmap( bmp ) );

		buttonMode = true;
		addEventListener( MouseEvent.CLICK, onClickHandler );
	}

	private function onClickHandler( e:MouseEvent ) click.dispatch( e );
}
