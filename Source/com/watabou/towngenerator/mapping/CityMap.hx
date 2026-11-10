package com.watabou.towngenerator.mapping;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Point;
import StringTools;

import com.watabou.geom.Polygon;

import com.watabou.towngenerator.wards.*;
import com.watabou.towngenerator.building.CurtainWall;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Architect;
import com.watabou.utils.NameGenerator;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.GraphicsExtender;
using com.watabou.utils.PointExtender;

class CityMap extends Sprite {

	public static var palette = Palette.DEFAULT;

	private var patches	: Array<PatchView>;
	private var brush	: Brush;
	private var model	: Model;

	public function new( model:Model ) {
		super();
		this.model = model;

		palette = Palette.forCulture(model.culture);
		brush = new Brush( palette );

		var m = model;

		// Main drawn layer (roads + wards + walls)
		var layer = new Shape();
		draw( new OpenFLRenderer( layer.graphics ), m );
		addChild( layer );

		// Hot areas for tooltips
		patches = [];
		for (patch in m.patches) {
			var pv = new PatchView( patch );
			patches.push( pv );
			addChild( pv.hotArea );
		}
	}

	public function getSVG():String {
		var m = model;
		var svg = new SvgRenderer();

		// Compute a tight viewBox around everything we draw.
		var minX = 1e20;
		var minY = 1e20;
		var maxX = -1e20;
		var maxY = -1e20;

		inline function eat( p:Point ) {
			if (p.x < minX) minX = p.x;
			if (p.y < minY) minY = p.y;
			if (p.x > maxX) maxX = p.x;
			if (p.y > maxY) maxY = p.y;
		}

		if (m.border != null) for (v in m.border.shape) eat( v );
		if (m.wall != null) for (v in m.wall.shape) eat( v );
		if (m.waterbody != null) {
			for (p in m.waterbody) for (v in p.shape) eat( v );
		}
		for (p in m.patches) for (v in p.shape) eat( v );
		for (road in m.roads) for (v in road) eat( v );

		if (minX > maxX || minY > maxY) {
			// Fallback, shouldn't happen.
			minX = -m.cityRadius; minY = -m.cityRadius;
			maxX = m.cityRadius;  maxY = m.cityRadius;
		}

		var pad = Brush.THICK_STROKE * 6;
		var x = minX - pad;
		var y = minY - pad;
		var w = (maxX - minX) + pad * 2;
		var h = (maxY - minY) + pad * 2;

		svg.setViewBox( x, y, w, h );
		svg.setBackground( palette.paper, 1.0 );

		draw( svg, m );
		return svg.getOutput();
	}


	public function draw( r:IRenderer, model:Model ):Void {

		var streetScale = 1.0;
		switch (model.culture) {
			case com.watabou.towngenerator.building.Culture.VIKING: streetScale = 1.1;
			case com.watabou.towngenerator.building.Culture.AFRICAN: streetScale = 0.85;
			case com.watabou.towngenerator.building.Culture.TRIBAL: streetScale = 0.65;
			case com.watabou.towngenerator.building.Culture.TENT: streetScale = 0.55;
			default:
		}

		// Water / hydrology
		if (model.waterbody != null && model.waterbody.length > 0) {
			r.beginGroup( "water" );
			for (patch in model.waterbody) {
				r.lineStyle( Brush.NORMAL_STROKE, palette.dark );
				r.beginFill( palette.medium );
				drawPoly( r, patch.shape );
				r.endFill();
			}
			r.endGroup();
		}

// Foreshore / beach band on land patches adjacent to water (visual-only)
		if (model.waterbody != null && model.waterbody.length > 0) {
			r.beginGroup( "foreshore" );
			for (patch in model.patches) {
				if (patch.isWater) continue;
				// Only coastal patches
				var hasWater = false;
				for (n in model.getNeighbours(patch)) if (n.isWater) { hasWater = true; break; }
				if (!hasWater) continue;

				var band = Architect.makeForeshore(patch.shape, Brush.NORMAL_STROKE * 2.0);
				for (b in band) {
					r.lineStyle( Brush.NORMAL_STROKE, palette.dark, 0.6 );
					r.beginFill( palette.paper, 0.35 );
					drawPoly( r, b );
					r.endFill();
				}
			}
			r.endGroup();
		}

		// Roads and crossings are separate layers so a whole road isn't styled as a bridge.
		r.beginGroup("roads");
		for (road in model.arteries) {
			r.lineStyle(Ward.MAIN_STREET * streetScale + Brush.NORMAL_STROKE, palette.medium);
			drawPolyline(r, road);
			r.lineStyle(Ward.MAIN_STREET * streetScale - Brush.NORMAL_STROKE, palette.paper);
			drawPolyline(r, road);
		}
		r.endGroup();

		if (model.bridges != null && model.bridges.length > 0) {
			r.beginGroup("bridges");
			for (bridge in model.bridges) {
				r.lineStyle(Ward.MAIN_STREET * streetScale + Brush.NORMAL_STROKE * 1.2, palette.dark);
				drawPolyline(r, bridge);
				r.lineStyle(Ward.MAIN_STREET * streetScale - Brush.NORMAL_STROKE * 0.4, palette.paper);
				drawPolyline(r, bridge);
			}
			r.endGroup();
		}

		if (model.secondary != null && model.secondary.length > 0) {
			r.beginGroup("secondary-streets");
			r.lineStyle(Ward.REGULAR_STREET * streetScale, palette.paper);
			for (road in model.secondary) drawPolyline(r, road);
			r.endGroup();
		}

		// Piers are on a separate layer for export.
		r.beginGroup("docks");
		for (i in 0...model.patches.length) {
			var patch = model.patches[i];
			if (patch.ward == null || Type.getClass(patch.ward) != Docks) continue;
			var name = patch.districtName == null ? "Docks" : patch.districtName;
			r.beginGroupEx("dock-" + i, 'data-name="' + StringTools.htmlEscape(name, true) + '"');
			for (piece in patch.ward.geometry) {
				r.lineStyle(Brush.NORMAL_STROKE, palette.dark);
				r.beginFill(palette.light);
				drawPoly(r, piece);
				r.endFill();
			}
			r.endGroup();
		}
		r.endGroup();

		r.beginGroup("wards");
		for (i in 0...model.patches.length) {
			var patch = model.patches[i];
			if (patch.ward == null) continue;
			var wardClass = Type.getClass(patch.ward);
			if (wardClass == Water || wardClass == Docks) continue;
			var type = patch.ward.getLabel();
			var name = patch.districtName == null ? type : patch.districtName;
			r.beginGroupEx("ward-" + i, 'data-type="' + StringTools.htmlEscape(type, true) + '" data-name="' + StringTools.htmlEscape(name, true) + '"');

			switch (wardClass) {
				case Castle:
					drawBuilding(r, patch.ward.geometry, palette.light, palette.dark, Brush.NORMAL_STROKE * 2);
				case Cathedral:
					drawBuilding(r, patch.ward.geometry, palette.light, palette.dark, Brush.NORMAL_STROKE);
				case Park:
					for (grove in patch.ward.geometry) {
						r.lineStyle(Brush.NORMAL_STROKE, palette.dark);
						r.beginFill(palette.medium);
						drawPoly(r, grove);
						r.endFill();
					}
				default:
					// Also handles camps, mines, wells, ruins and newer wards.
					if (patch.ward.geometry != null)
						for (building in patch.ward.geometry) {
							r.lineStyle(Brush.NORMAL_STROKE, palette.dark);
							r.beginFill(palette.light);
							drawPoly(r, building);
							r.endFill();
						}
			}
			r.endGroup();
		}
		r.endGroup();

		// Slum alleys / cul-de-sac stubs (visual)
		if (model.slumStubs != null && model.slumStubs.length > 0) {
			r.beginGroup( "alleys" );
			for (a in model.slumStubs) {
				r.lineStyle( Ward.MAIN_STREET * streetScale * 0.35, palette.paper, 1.0 );
				drawPolyline( r, a );
			}
			r.endGroup();
		}

		// Old boundaries are outlines, not active fortifications.
		if (model.oldWall != null && model.oldWall.shape != null && model.oldWall.shape.length > 2) {
			r.beginGroup("old-wall");
			r.lineStyle(Brush.NORMAL_STROKE, palette.dark, 0.45);
			drawPoly(r, model.oldWall.shape);
			r.endGroup();
		}

		// Walls last
		r.beginGroup( "walls" );
		if (model.wall != null)
			drawWall( r, model.wall, false );
		if (model.citadel != null)
			drawWall( r, cast( model.citadel.ward, Castle ).wall, true );
		r.endGroup();
	}

	private function drawWall( r:IRenderer, wall:CurtainWall, large:Bool ):Void {
		r.lineStyle( Brush.THICK_STROKE, palette.dark );
		r.beginFill( palette.paper, 0 );
		drawPoly( r, wall.shape );
		r.endFill();

		for (gate in wall.gates)
			drawGate( r, wall.shape, gate );
		for (t in wall.towers)
			drawTower( r, t, Brush.THICK_STROKE * (large ? 1.5 : 1) );
	}

	private function drawTower( r:IRenderer, p:Point, radius:Float ):Void {
		r.lineStyle( 0, 0, 0 );
		r.beginFill( palette.dark );
		r.drawCircle( p.x, p.y, radius );
		r.endFill();
	}

private function drawGate( r:IRenderer, wall:Polygon, gate:Point ):Void {
	// Gate opening stroke
	r.lineStyle( Brush.THICK_STROKE * 2, palette.dark );
	var dir = wall.next( gate ).subtract( wall.prev( gate ) );
	dir.normalize( Brush.THICK_STROKE * 1.6 );

	var a = gate.subtract( dir );
	var b = gate.add( dir );

	r.moveTo( a.x, a.y );
	r.lineTo( b.x, b.y );

	// Gatehouse: two flanking towers + a small portcullis block.
	// This remains "symbolic" (not structural) but reads as architecture.
	var perp = new Point( -dir.y, dir.x );
	perp.normalize( Brush.THICK_STROKE * 1.2 );

	// Towers
	r.lineStyle( 0, 0, 0 );
	r.beginFill( palette.dark );
	r.drawCircle( a.x, a.y, Brush.THICK_STROKE * 0.65 );
	r.drawCircle( b.x, b.y, Brush.THICK_STROKE * 0.65 );
	r.endFill();

	// Portcullis block (a short rectangle across the opening)
	var p1 = a.add( perp );
	var p2 = b.add( perp );
	var p3 = b.subtract( perp );
	var p4 = a.subtract( perp );

	r.lineStyle( Brush.NORMAL_STROKE, palette.dark );
	r.beginFill( palette.paper );
	r.moveTo( p1.x, p1.y );
	r.lineTo( p2.x, p2.y );
	r.lineTo( p3.x, p3.y );
	r.lineTo( p4.x, p4.y );
	r.lineTo( p1.x, p1.y );
	r.endFill();

	// Reset stroke for subsequent wall segments (caller will set as needed)
}

	private function drawBuilding( r:IRenderer, blocks:Array<Polygon>, fill:Int, line:Int, thickness:Float ):Void {
		if (blocks == null) return;
		for (block in blocks) {
			r.lineStyle( thickness * 2, line );
			r.beginFill( palette.paper, 0 );
			drawPoly( r, block );
			r.endFill();
		}
		for (block in blocks) {
			r.lineStyle( 0, 0, 0 );
			r.beginFill( fill );
			drawPoly( r, block );
			r.endFill();
		}
	}

	private function drawPoly( r:IRenderer, points:Array<Point> ):Void {
		if (points == null || points.length == 0) return;
		r.moveTo( points[0].x, points[0].y );
		for (i in 1...points.length)
			r.lineTo( points[i].x, points[i].y );
		r.lineTo( points[0].x, points[0].y );
	}

	private function drawPolyline( r:IRenderer, points:Array<Point> ):Void {
		if (points == null || points.length == 0) return;
		r.moveTo( points[0].x, points[0].y );
		for (i in 1...points.length)
			r.lineTo( points[i].x, points[i].y );
	}
}