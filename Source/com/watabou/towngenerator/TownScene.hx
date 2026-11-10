package com.watabou.towngenerator;

import openfl.display.Sprite;

import com.watabou.coogee.Scene;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.mapping.CityMap;
import com.watabou.towngenerator.io.Exporter;
import com.watabou.towngenerator.ui.CitySizeButton;
import com.watabou.towngenerator.ui.CultureButton;
import com.watabou.towngenerator.ui.Button;
import com.watabou.towngenerator.ui.Tooltip;

import com.watabou.utils.FileSaver;

class TownScene extends Scene {

	private var buttons	: Sprite;
	private var map		: CityMap;

	public function new() {
		super();

		map = new CityMap( Model.instance );
		addChild( map );

		addChild( new Tooltip() );

		buttons = new Sprite();
		addChild( buttons );

		var smallTown = new CitySizeButton( "Small Town", 6, 10 );
		var largeTown = new CitySizeButton( "Large Town", 10, 15 );
		var smallCity = new CitySizeButton( "Small City", 15, 24 );
		var largeCity = new CitySizeButton( "Large City", 24, 40 );

		var styleBtn = new CultureButton();

		var btnExportSVG = new Button( "Export SVG" );
		btnExportSVG.click.add( onExportSVG );

		var btnExportJSON = new Button( "Export JSON" );
		btnExportJSON.click.add( onExportJSON );

		var pos = 0.0;
		for (btn in [smallTown, largeTown, smallCity, largeCity, styleBtn, btnExportSVG, btnExportJSON]) {
			btn.y = pos;
			pos += btn.height + 1;
			buttons.addChild( btn );
		}
	}

	private function onExportSVG( _ ):Void {
		var svgContent = map.getSVG();
		FileSaver.saveText( "city_" + Model.instance.seed + ".svg", svgContent );
	}

	private function onExportJSON( _ ):Void {
		var jsonContent = Exporter.toJSON( Model.instance );
		FileSaver.saveText( "city_" + Model.instance.seed + ".json", jsonContent );
	}

	private var scale(get,set) : Float;
	private inline function get_scale():Float
		return map.scaleX;
	private function set_scale( value:Float ):Float
		return (map.scaleX = map.scaleY = value);

	override public function layout():Void {
		map.x = rWidth / 2;
		map.y = rHeight / 2;

		var radius = Math.max(1, Model.instance.cityRadius);
		var scaleX = rWidth / radius;
		var scaleY = rHeight / radius;
		var scMin = Math.min( scaleX, scaleY );
		var scMax = Math.max( scaleX, scaleY );
		scale = (scMax / scMin > 2 ? scMax / 2 : scMin) * 0.5;

		buttons.x = rWidth - buttons.width - 1;
		buttons.y = 1;
	}
}
