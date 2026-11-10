package com.watabou.towngenerator.building;

import Type;
import openfl.errors.Error;
import openfl.geom.Point;

import com.watabou.geom.GeomUtils;
import com.watabou.geom.Polygon;
import com.watabou.geom.Segment;
import com.watabou.geom.Voronoi;
import com.watabou.utils.MathUtils;
import com.watabou.utils.Random;
import com.watabou.utils.NameGenerator;

import com.watabou.towngenerator.wards.*;
import com.watabou.towngenerator.StateManager;
import com.watabou.towngenerator.building.Culture;

using com.watabou.utils.PointExtender;
using com.watabou.utils.ArrayExtender;

typedef Street = Polygon;

class Model {

	public static var instance	: Model;

	// Small Town	6
	// Large Town	10
	// Small City	15
	// Large City	24
	// Metropolis	40
	private var nPatches	: Int;
	public var size(default, null):Int;
	public var seed(default, null):Int;

	private var plazaNeeded		: Bool;
	private var citadelNeeded	: Bool;
	private var wallsNeeded		: Bool;


	private static var WARDS_MEDIEVAL:Array<Class<Ward>> = [
		Docks,
		Docks,
		CraftsmenWard,
		CraftsmenWard,
		MerchantWard,
		CraftsmenWard,
		CraftsmenWard,
		Cathedral,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		AdministrationWard,
		CraftsmenWard,
		Slum,
		CraftsmenWard,
		Slum,
		PatriciateWard,
		Market,
		Slum,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		Slum,
		CraftsmenWard,
		CraftsmenWard,
		CraftsmenWard,
		MilitaryWard,
		Slum,
		CraftsmenWard,
		Park,
		PatriciateWard,
		Market,
		MerchantWard,
		Well,
		Ruins,
		Gallows
	];
	private static var WARDS_SAXON:Array<Class<Ward>> = [
		Market,
		Docks,
		CraftsmenWard,
		CraftsmenWard,
		MerchantWard,
		CraftsmenWard,
		AdministrationWard,
		PatriciateWard,
		Park,
		Slum,
		Slum,
		MilitaryWard,
		Well,
		Ruins,
		Gallows
	];
	private static var WARDS_VIKING:Array<Class<Ward>> = [
		Docks,
		Docks,
		Docks,
		Market,
		Market,
		CraftsmenWard,
		CraftsmenWard,
		MerchantWard,
		MilitaryWard,
		MilitaryWard,
		CraftsmenWard,
		Slum,
		Slum,
		Park,
		CraftsmenWard,
		Well,
		Ruins,
		Gallows
	];
	private static var WARDS_AFRICAN:Array<Class<Ward>> = [
		Market,
		Market,
		Docks,
		CraftsmenWard,
		CraftsmenWard,
		MerchantWard,
		CraftsmenWard,
		Park,
		Park,
		Slum,
		Cathedral,
		Well,
		Ruins,
		Gallows
	];
	private static var WARDS_TRIBAL:Array<Class<Ward>> = [
		Park,
		Park,
		Market,
		CraftsmenWard,
		CraftsmenWard,
		Slum,
		Slum,
		Well,
		Ruins,
		Gallows
	];
	private static var WARDS_TENT:Array<Class<Ward>> = [
		Market,
		Market,
		CraftsmenWard,
		CraftsmenWard,
		Slum,
		Slum,
		Park,
		Well,
		Ruins
	];

	
	private static var WARDS_IMPERIAL:Array<Class<Ward>> = [
		Market, Market,
		AdministrationWard, AdministrationWard,
		MilitaryWard, MilitaryWard,
		PatriciateWard, PatriciateWard,
		CraftsmenWard, CraftsmenWard,
		Docks,
		Park,
		Well, Ruins
	];

	private static var WARDS_MERCHANT:Array<Class<Ward>> = [
		Docks, Docks, Docks,
		Market, Market, Market,
		MerchantWard, MerchantWard, MerchantWard,
		CraftsmenWard, CraftsmenWard,
		Slum, Slum,
		Park,
		Well, Ruins, Gallows
	];

	private static var WARDS_BARBARIAN:Array<Class<Ward>> = [
		MilitaryWard, MilitaryWard,
		Park, Park,
		Market,
		CraftsmenWard,
		Slum, Slum,
		Well, Ruins, Gallows
	];

	private static var WARDS_NOMAD:Array<Class<Ward>> = [
		Market, Market,
		CraftsmenWard,
		Slum, Slum,
		Park, Park,
		Well, Ruins
	];

	private static var WARDS_RELIGIOUS:Array<Class<Ward>> = [
		Cathedral, Cathedral,
		Market,
		Park, Park,
		AdministrationWard,
		CraftsmenWard,
		PatriciateWard,
		Slum,
		Well, Ruins
	];

	private static var WARDS_INDUSTRIAL:Array<Class<Ward>> = [
		CraftsmenWard, CraftsmenWard, CraftsmenWard, CraftsmenWard,
		Market,
		Docks,
		Slum, Slum, Slum,
		MilitaryWard,
		Park,
		Well, Ruins, Gallows
	];

	private static var WARDS_FRONTIER:Array<Class<Ward>> = [
		Market,
		CraftsmenWard, CraftsmenWard,
		Slum, Slum, Slum,
		MilitaryWard,
		Docks,
		Park,
		Well, Ruins
	];

	private static var WARDS_RUINED:Array<Class<Ward>> = [
		Ruins, Ruins, Ruins,
		Market,
		Slum, Slum,
		CraftsmenWard,
		Park,
		Well,
		Gallows
	];

	private static var WARDS_ELVEN:Array<Class<Ward>> = [
		Park, Park, Park,
		Market, Market,
		CraftsmenWard,
		MerchantWard,
		Cathedral,
		PatriciateWard,
		Well, Ruins
	];

	private static var WARDS_DWARVEN:Array<Class<Ward>> = [
		CraftsmenWard, CraftsmenWard, CraftsmenWard,
		Market,
		MilitaryWard, MilitaryWard,
		PatriciateWard,
		Slum,
		Well, Ruins
	];

	private static var WARDS_ORC:Array<Class<Ward>> = [
		MilitaryWard, MilitaryWard,
		Slum, Slum, Slum,
		Market,
		CraftsmenWard,
		Ruins,
		Gallows
	];

	private static var WARDS_MARSH:Array<Class<Ward>> = [
		Docks, Docks,
		Market,
		CraftsmenWard,
		Slum, Slum,
		Park, Park,
		Well,
		Ruins
	];

public static function wardsForCulture(c:Culture):Array<Class<Ward>> {
		return switch (c) {
			case Culture.SAXON: WARDS_SAXON;
			case Culture.VIKING: WARDS_VIKING;
			case Culture.AFRICAN: WARDS_AFRICAN;
			case Culture.TRIBAL: WARDS_TRIBAL;
			case Culture.TENT: WARDS_TENT;

			case Culture.EUROPEAN_MEDIEVAL: WARDS_MEDIEVAL;
			case Culture.DARK_AGES: WARDS_SAXON;
			case Culture.HIGH_MEDIEVAL_CITY: WARDS_MEDIEVAL;
			case Culture.RENAISSANCE_CITY: WARDS_IMPERIAL;

			case Culture.IMPERIAL: WARDS_IMPERIAL;
			case Culture.MERCHANT_REPUBLIC: WARDS_MERCHANT;
			case Culture.BARBARIAN: WARDS_BARBARIAN;
			case Culture.NOMAD: WARDS_NOMAD;
			case Culture.RELIGIOUS_ENCLAVE: WARDS_RELIGIOUS;
			case Culture.INDUSTRIAL: WARDS_INDUSTRIAL;
			case Culture.FRONTIER: WARDS_FRONTIER;
			case Culture.RUINED: WARDS_RUINED;

			case Culture.ELVEN_HIGH, Culture.ELVEN_WOOD, Culture.ELVEN_DARK: WARDS_ELVEN;
			case Culture.DWARVEN_HOLD: WARDS_DWARVEN;
			case Culture.ORCINOID: WARDS_ORC;
			case Culture.MARSH: WARDS_MARSH;

			default: WARDS_MEDIEVAL;
		}
	}

	
	private static function wardsForOrigin(o:Origin, base:Array<Class<Ward>>):Array<Class<Ward>> {
		var wards = base.copy();
		var priority:Array<Class<Ward>> = [];
		switch (o) {
			case Origin.TIMBER_CAMP:
				priority = [Lumberyard, Lumberyard, CraftsmenWard, Park];
				// de-emphasise civic grandeur
				wards.remove(Cathedral);
			case Origin.FISHING_VILLAGE, Origin.RIVER_PORT:
				priority = [Docks, Docks, Market, Market];
			case Origin.MINING_CAMP:
				priority = [Mine, Mine, CraftsmenWard, MilitaryWard, Slum];
			case Origin.WALLED_WAYSTATION:
				priority = [Waystation, Waystation, GateWard, MilitaryWard];
				// keep it utilitarian
				wards.remove(PatriciateWard);
			case Origin.FORTRESS:
				priority = [MilitaryWard, MilitaryWard, Waystation];
			case Origin.MONASTERY:
				priority = [Cathedral, Park, Well];
			default:
		}
		return priority.concat(wards);
	}

	private var neighbourCache:Map<Patch, Array<Patch>>;

	public var topology	: Topology;
	public var culture	: Culture;
	public var origin	: Origin;

	public var patches	: Array<Patch>;
	public var waterbody: Array<Patch>;
	public var bridges: Array<Street>;
	public var economy: EconomyProfile;
	// For a walled city it's a list of patches within the walls,
	// for a city without walls it's just a list of all city wards
	public var inner	: Array<Patch>;
	public var citadel	: Patch;
	public var plaza	: Patch;
	public var center	: Point;

	public var border	: CurtainWall;
	public var wall		: CurtainWall;
	public var oldWall	: CurtainWall;

	public var cityRadius	: Float;

	// List of all entrances of a city including castle gates
	public var gates	: Array<Point>;

	// Joined list of streets (inside walls) and roads (outside walls)
	// without diplicating segments
	public var arteries	: Array<Street>;
	public var streets	: Array<Street>;
	public var roads	: Array<Street>;
	public var hamlets	: Array<Patch>;
	public var secondary	: Array<Street>;
	public var slumStubs	: Array<Street>;

	public function new( nPatches=-1, seed=-1 ) {

		Random.reset(seed > 0 ? seed : -1);
		this.seed = Random.getSeed();
		this.nPatches = nPatches != -1 ? nPatches : 15;
		if (this.nPatches < 6) this.nPatches = 6;
		if (this.nPatches > 40) this.nPatches = 40;
		this.size = this.nPatches;

		culture = Culture.fromString( StateManager.culture );
		origin = Origin.fromString( StateManager.origin );
		economy = Economy.forOrigin(origin);

		plazaNeeded		= Random.bool();
		// Culture presets may disable certain medieval-specific structures
		if (culture == Culture.TRIBAL || culture == Culture.TENT) plazaNeeded = false;
		citadelNeeded	= Random.bool();
		if (culture == Culture.TRIBAL || culture == Culture.TENT) citadelNeeded = false;
		wallsNeeded		= Random.bool();
		if (culture == Culture.TRIBAL || culture == Culture.TENT) wallsNeeded = false;

		// Origin overrides (why this settlement exists)
		switch (origin) {
			case Origin.TIMBER_CAMP, Origin.FISHING_VILLAGE, Origin.MINING_CAMP:
				wallsNeeded = false;
				citadelNeeded = false;
				// camps rarely have plazas
				plazaNeeded = Random.bool(0.2);
			case Origin.WALLED_WAYSTATION:
				wallsNeeded = true;
				citadelNeeded = false;
				plazaNeeded = false;
			case Origin.FORTRESS:
				wallsNeeded = true;
				citadelNeeded = true;
				plazaNeeded = false;
			case Origin.MONASTERY:
				wallsNeeded = Random.bool(0.3);
				citadelNeeded = false;
				plazaNeeded = false;
			case Origin.RIVER_PORT:
				wallsNeeded = Random.bool(0.4);
				citadelNeeded = Random.bool(0.3);
				plazaNeeded = Random.bool(0.6);
			default:
		}

		// Keep the previous map available if generation fails.
		var lastError:Dynamic = null;
		for (attempt in 0...12) {
			try {
				build();
				instance = this;
				return;
			} catch (e:Dynamic) {
				lastError = e;
			}
		}
		throw new Error("Town generation failed after 12 attempts: " + (lastError == null ? "unknown error" : Std.string(lastError)));
	}

	private function build():Void {
		#if debug
		function callValidate(stage:String) validate(stage);
		#end
		// A failed layout must not leave parts of the previous attempt behind.
		plaza = null;
		citadel = null;
		center = null;
		border = null;
		wall = null;
		oldWall = null;
		gates = [];
		topology = null;
		arteries = [];
		hamlets = [];
		streets = [];
		roads = [];
		secondary = [];
		slumStubs = [];
		waterbody = [];
		bridges = [];
		neighbourCache = null;

		buildPatches();
		#if debug
		callValidate("buildPatches");
		#end
		optimizeJunctions();
		#if debug
		callValidate("optimizeJunctions");
		#end
		buildWalls();
		#if debug
		callValidate("buildWalls");
		#end
		buildWater();
		#if debug
		callValidate("buildWater");
		#end
		buildStreets();
		#if debug
		callValidate("buildStreets");
		#end
		buildSecondaryRoads();
		buildHamlets();
		createWards();
		connectWorkingWards();
		#if debug
		callValidate("createWards");
		#end
		#if debug
		callValidate("buildHamlets");
		#end
		computeGradients();
		#if debug
		callValidate("computeGradients");
		#end
		buildGeometry();
		#if debug
		callValidate("buildGeometry");
		#end
		buildSlumStubs();
		Economy.finish(this);
		#if debug
		callValidate("buildSlumStubs");
		#end
		buildOldCityLayer();
		#if debug
		callValidate("buildOldCityLayer");
		#end
	}

	private function buildWater():Void {
		cacheNeighbours();
		Hydrology.apply(this, seed);
	}


	private function buildPatches():Void {
		var sa = Random.float() * 2 * Math.PI;
		var points = [for (i in 0...nPatches * 8) {
			var a = sa + Math.sqrt( i ) * 5;
			var r = (i == 0 ? 0 : 10 + i * (2 + Random.float()));
			new Point( Math.cos( a ) * r, Math.sin( a ) * r );
		}];
		var voronoi = Voronoi.build( points );

		// Relaxing central wards
		for (i in 0...3) {
			var toRelax = [for (j in 0...3) voronoi.points[j]];
			toRelax.push( voronoi.points[nPatches] );
			voronoi = Voronoi.relax( voronoi, toRelax );
		}

		voronoi.points.sort( function( p1:Point, p2:Point )
			return MathUtils.sign( p1.length - p2.length ) );
		var regions = voronoi.partioning();

		patches = [];
		inner = [];

		var count = 0;
		for (r in regions) {
			var patch = Patch.fromRegion( r );
			patches.push( patch );

			if (count == 0) {
				center = patch.shape.min( function( p:Point ) return p.length );
				if (plazaNeeded)
					plaza = patch;
			} else if (count == nPatches && citadelNeeded) {
				citadel = patch;
				citadel.withinCity = true;
			}

			if (count < nPatches) {
				patch.withinCity = true;
				patch.withinWalls = wallsNeeded;
				inner.push( patch );
			}

			count++;
		}
	}

	private function buildWalls():Void {
		var reserved = citadel != null ? citadel.shape.copy() : [];

		border = new CurtainWall( wallsNeeded, this, inner, reserved );
		if (wallsNeeded) {
			wall = border;
			wall.buildTowers();
		}

		var radius = border.getRadius();
		patches = patches.filter( function( p:Patch ) return p.shape.distance( center ) < radius * 3 );

		gates = border.gates;

		if (citadel != null) {
			var castle = new Castle( this, citadel );
			castle.wall.buildTowers();
			citadel.ward = castle;

			if (citadel.shape.compactness < 0.75)
				throw new Error( "Bad citadel shape!" );

			gates = gates.concat( castle.wall.gates );
		}
	}

	public static function findCircumference( wards:Array<Patch> ):Polygon {
		if (wards.length == 0)
			return new Polygon()
		else if (wards.length == 1)
			return new Polygon( wards[0].shape );

		var A:Array<Point> = [];
		var B:Array<Point> = [];

		for (w1 in wards)
			w1.shape.forEdge( function(a, b ) {
				var outerEdge = true;
				for (w2 in wards)
					if (w2.shape.findEdge( b, a ) != -1) {
						outerEdge = false;
						break;
					}
				if (outerEdge) {
					A.push( a );
					B.push( b );
				}
			} );

		if (A.length < 3) throw new Error("No valid boundary for selected wards");
		var result = new Polygon();
		var index = 0;
		var steps = 0;
		do {
			if (index < 0 || index >= A.length || steps++ >= A.length)
				throw new Error("Disconnected or invalid ward boundary");
			result.push(A[index]);
			index = A.indexOf(B[index]);
		} while (index != 0);
		if (steps != A.length) throw new Error("Ward boundary contains disconnected edges");
		return result;
	}

	public function patchByVertex( v:Point ):Array<Patch> {
		// patchByVertex is used to discover which patches share an exact vertex reference.
		// Using polygon "contains" is incorrect here (point-in-polygon test).
		return patches.filter( function( patch:Patch ) return patch.shape.indexOf( v ) != -1 );
	}

	private function buildStreets():Void {

		function smoothStreet( street:Street ):Void {
			var smoothed = street.smoothVertexEq( 3 );
			for (i in 1...street.length-1)
				street[i].set( smoothed[i] );
		}

		topology = new Topology( this );

		for (gate in gates) {
			// Each gate is connected to the nearest corner of the plaza or to the central junction
			var end:Point = plaza != null ?
				plaza.shape.min( function( v ) return Point.distance( v, gate ) ) :
				center;

			var street = topology.buildPath( gate, end, topology.outer );
			if (street != null) {
				streets.push( street );

				if (border.gates.contains( gate )) {
					var dir = gate.norm( 1000 );
					var start = null;
					var dist = Math.POSITIVE_INFINITY;
					for (node in topology.outer) {
						var p = topology.node2pt.get(node);
						if (p == null) continue;
						var d = Point.distance(p, dir);
						if (d < dist) {
							dist = d;
							start = p;
						}
					}

					var road = topology.buildPath(start, gate, topology.inner);
					if (road != null)
						roads.push( road );
				}
			} else
				throw new Error( "Unable to build a street!" );
		}

		tidyUpRoads();

		for (a in arteries)
			smoothStreet( a );
	}

	private function tidyUpRoads() {
		var segments = new Array<Segment>();
		function cut2segments( street:Street ) {
			var v0:Point = null;
			var v1:Point = street[0];
			for (i in 1...street.length) {
				v0 = v1;
				v1 = street[i];

				// Removing segments which go along the plaza
				if (plaza != null && plaza.shape.contains( v0 ) && plaza.shape.contains( v1 ))
					continue;

				var exists = false;
				for (seg in segments)
					if ((seg.start == v0 && seg.end == v1) || (seg.start == v1 && seg.end == v0)) {
						exists = true;
						break;
					}

				if (!exists)
					segments.push( new Segment( v0, v1 ) );
			}
		}

		for (street in streets)
			cut2segments( street );
		for (road in roads)
			cut2segments( road );

		arteries = [];
		while (segments.length > 0) {
			var seg = segments.pop();

			var attached = false;
			for (a in arteries)
				if (a[0] == seg.end) {
					a.unshift( seg.start );
					attached = true;
					break;
				} else if (a.last() == seg.start) {
					a.push( seg.end );
					attached = true;
					break;
				}

			if (!attached)
				arteries.push( [seg.start, seg.end] );
		}
	}


	private function buildSecondaryRoads():Void {
		secondary = [];

		// Secondary roads: a single internal spine for oversized patches.
		// Built BEFORE wards assignment; purely geometric.
		var threshold = 1200.0;
		for (p in inner) {
			if (p == null || p.isWater) continue;
			if (p.shape == null || p.shape.square < threshold) continue;

			var c = p.shape.centroid;
			var dir = center.subtract(c);
			// Culture-specific street topology hints.
			if (culture == Culture.TRIBAL || culture == Culture.AFRICAN) {
				// Ring-ish: prefer tangential paths around the centre.
				dir = new Point(-(c.y - center.y), (c.x - center.x));
			} else if (culture == Culture.TENT) {
				// Camp-like: prefer orthogonal lanes.
				dir = Math.abs(c.x) > Math.abs(c.y) ? new Point(0, 1) : new Point(1, 0);
			}
			if (dir.length < 1) continue;
			dir.normalize(1);

			// Find intersections of the infinite line through c with the polygon edges.
			var hits:Array<{t:Float, pt:Point}> = [];
			for (i in 0...p.shape.length) {
				var a = p.shape[i];
				var b = p.shape[(i + 1) % p.shape.length];
				var ed = b.subtract(a);
				var t = GeomUtils.intersectLines(c.x, c.y, dir.x, dir.y, a.x, a.y, ed.x, ed.y);
				if (t == null) continue;
				var tLine = t.x;
				var tSeg = t.y;
				if (tSeg >= 0 && tSeg <= 1) {
					hits.push({t:tLine, pt:new Point(c.x + dir.x * tLine, c.y + dir.y * tLine)});
				}
			}
			if (hits.length < 2) continue;

			// Extremes along the line
			hits.sort(function(h1, h2) return h1.t < h2.t ? -1 : 1);
			var a = hits[0].pt;
			var b = hits[hits.length - 1].pt;

			// Pull endpoints inward slightly so the line doesn't hug the border.
			var inset = 6.0;
			var v = b.subtract(a);
			if (v.length > inset * 2) {
				v.normalize(inset);
				a = a.add(v);
				b = b.subtract(v);
			}

			secondary.push([a, b]);
		}
	}

	private function buildSlumStubs():Void {
		slumStubs = [];
		for (p in patches) {
			if (p == null || p.ward == null) continue;
			if (Type.getClass(p.ward) != Slum) continue;

			var c = p.shape.centroid;
			// Deterministic pseudo-random from centroid
			var seed = Std.int((c.x * 31) + (c.y * 17));
			var n = 2 + (seed & 1); // 2-3 stubs
			if (culture == Culture.TENT) n = 1;
			if (culture == Culture.TRIBAL) n = 0;
			for (i in 0...n) {
				var a = (seed * 1103515245 + i * 12345) & 0x7fffffff;
				var ang = (a % 6283) / 1000.0; // 0..~6.283
				var len = 10 + (a % 8);
				if (culture == Culture.TENT) len = 6 + (a % 6);
				var end = new Point(c.x + Math.cos(ang) * len, c.y + Math.sin(ang) * len);
				// Keep inside patch
				if (p.shape.containsPoint(end)) slumStubs.push([c, end]);
			}
		}
	}
	private function optimizeJunctions():Void {

		var patchesToOptimize:Array<Patch> =
			citadel == null ? inner : inner.concat( [citadel] );

		var wards2clean:Array<Patch> = [];
		for (w in patchesToOptimize) {
			var index = 0;
			while (index < w.shape.length) {

				var v0:Point = w.shape[index];
				var v1:Point = w.shape[(index + 1) % w.shape.length];

				if (v0 != v1 && Point.distance( v0, v1 ) < 8) {
					for (w1 in patchByVertex( v1 )) if (w1 != w) {
						w1.shape[w1.shape.indexOf( v1 )] = v0;
						wards2clean.push( w1 );
					}

					v0.addEq( v1 );
					v0.scaleEq( 0.5 );

					w.shape.remove( v1 );
				}
				index++;
			}
		}

		// Removing duplicate vertices
		for (w in wards2clean)
			for (i in 0...w.shape.length) {
				var v = w.shape[i];
				var dupIdx;
				while ((dupIdx = w.shape.indexOf( v, i + 1 )) != -1)
					w.shape.splice( dupIdx, 1 );
			}
	}

	private function createWards():Void {
		// Water patches are not buildable.
		for (p in waterbody)
			p.ward = new Water(this, p);

		var unassigned = inner.copy();
		if (plaza != null) {
			plaza.ward = new Market( this, plaza );
			unassigned.remove( plaza );
		}

		// Assigning inner city gate wards
		for (gate in border.gates)
			for (patch in patchByVertex( gate ))
				if (patch.withinCity && patch.ward == null && Random.bool( wall == null ? 0.2 : 0.5 )) {
					patch.ward = new GateWard( this, patch );
					unassigned.remove( patch );
				}

		var baseWards = wardsForCulture(culture).copy();
		for (i in 0...Std.int(baseWards.length / 10)) {
			var index = Random.int(0, baseWards.length - 1);
			var tmp = baseWards[index];
			baseWards[index] = baseWards[index + 1];
			baseWards[index + 1] = tmp;
		}
		var wards = wardsForOrigin(origin, baseWards);

		// Assigning inner city wards
		while (unassigned.length > 0) {
			var bestPatch:Patch = null;

			var wardClass = wards.length > 0 ? wards.shift() : Slum;
			var rateFunc = Reflect.field( wardClass, "rateLocation" );

			if (rateFunc == null && !Economy.hasPreference(wardClass)) {
				bestPatch = unassigned.random();
			} else {
				var bestScore = Math.POSITIVE_INFINITY;
				for (patch in unassigned) {
					var score:Float = rateFunc == null ? 0 : Reflect.callMethod(wardClass, rateFunc, [this, patch]);
					score += Economy.score(this, patch, wardClass);
					if (score < bestScore) {
						bestScore = score;
						bestPatch = patch;
					}
				}
				// A dock without water isn't a dock. Use ordinary housing instead.
				if (bestPatch == null || bestScore == Math.POSITIVE_INFINITY || bestScore >= 1e20) {
					wardClass = CraftsmenWard;
					bestPatch = unassigned.random();
				}
			}

			bestPatch.ward = Type.createInstance(wardClass, [this, bestPatch]);

			unassigned.remove( bestPatch );
		}

		// Outskirts
		if (wall != null)
			for (gate in wall.gates) if (!Random.bool( 1 / (nPatches - 5) )) {
				for (patch in patchByVertex( gate ))
					if (patch.ward == null) {
						patch.withinCity = true;
						patch.ward = new GateWard( this, patch );
					}
			}

		// Calculating radius and processing countryside
		cityRadius = 0;
		for (patch in patches)
			if (patch.withinCity)
				// Radius of the city is the farthest point of all wards from the center
				for (v in patch.shape)
					cityRadius = Math.max( cityRadius, v.length );
			else if (patch.ward == null && !patch.isWater)
				patch.ward = Random.bool( 0.2 ) && patch.shape.compactness >= 0.7 ?
					new Farm( this, patch ) :
					new Ward( this, patch );

		// Deterministic district naming (one-time assignment, shared by UI and exports)
		for (p in patches) {
			var type = (p.ward != null) ? p.ward.getLabel() : (p.isWater ? "Water" : null);
			p.districtName = (type != null) ? NameGenerator.districtName(type, p.shape.centroid) : null;
		}
	}

	private function connectWorkingWards():Void {
		if (arteries == null || arteries.length == 0 || topology == null) return;
		var added = false;
		for (patch in inner) {
			if (patch.ward == null || patch.isWater) continue;
			var label = patch.ward.getLabel();
			if (label != "Docks" && label != "Mine" && label != "Lumberyard" && label != "Waystation") continue;

			var from:Point = null;
			var to:Point = null;
			var best = Math.POSITIVE_INFINITY;
			for (candidate in patch.shape)
				for (road in arteries)
					for (target in road) {
						var d = Point.distance(candidate, target);
						if (d < best) {
							best = d;
							from = candidate;
							to = target;
						}
					}
			if (from == null || to == null || from == to) continue;
			var access = topology.buildPath(from, to, topology.outer);
			if (access == null) access = topology.buildPath(from, to);
			if (access != null && access.length > 1) {
				streets.push(access);
				added = true;
			}
		}
		if (added) tidyUpRoads();
	}

	private function buildGeometry():Void {
		for (patch in patches) {
			if (patch.ward != null) patch.ward.createGeometry();
		}
	}


	public function getNeighbour( patch:Patch, v:Point ):Patch {
		var next = patch.shape.next( v );
		for (p in patches)
			if (p.shape.findEdge( next, v ) != -1)
				return p;
		return null;
	}

	private function cacheNeighbours():Void {
		neighbourCache = new Map();
		for (p in patches) neighbourCache.set(p, []);
		for (i in 0...patches.length)
			for (j in (i + 1)...patches.length)
				if (patches[i].shape.borders(patches[j].shape)) {
					neighbourCache.get(patches[i]).push(patches[j]);
					neighbourCache.get(patches[j]).push(patches[i]);
				}
	}

	public function getNeighbours(patch:Patch):Array<Patch> {
		if (neighbourCache != null) {
			var neighbours = neighbourCache.get(patch);
			return neighbours == null ? [] : neighbours;
		}
		return patches.filter(function(p:Patch) return p != patch && p.shape.borders(patch.shape));
	}

	// A ward is "enclosed" if it belongs to the city and
	// it's surrounded by city wards and water
	public function isEnclosed( patch:Patch ):Bool {
		return patch.withinCity && (patch.withinWalls || getNeighbours( patch ).every( function( p:Patch ) return p.withinCity || p.isWater ));
	}

	private function buildOldCityLayer():Void {
		oldWall = null;
		if (inner == null || inner.length < 8) return;
		var r = border != null ? border.getRadius() : 0;
		if (r <= 0) return;

		var candidates = inner.filter(function(p:Patch) return !p.isWater && p.shape.distance(center) < r * 0.65);
		if (candidates.length < 4 || candidates.length == inner.length) return;
		var core = candidates[0];
		var connected:Array<Patch> = [core];
		var index = 0;
		while (index < connected.length) {
			for (next in getNeighbours(connected[index]))
				if (candidates.indexOf(next) != -1 && connected.indexOf(next) == -1)
					connected.push(next);
			index++;
		}
		if (connected.length < 4) return;
		try {
			oldWall = new CurtainWall(false, this, connected, []);
		} catch (e:Error) {
			// Some inner rings have holes. Leave those unmarked.
			oldWall = null;
		}
	}

	private function buildHamlets():Void {
		hamlets = [];
		if (border == null || gates == null) return;

		for (gate in border.gates) {
			// Find a nearby non-city patch outside the walls for a roadside hamlet.
			var candidates = patchByVertex(gate).filter(function(p:Patch)
				return !p.withinCity && !p.isWater && p.ward == null);
			if (candidates.length == 0) continue;
			var pick = candidates.min(function(p:Patch) return p.shape.distance(center));
			pick.ward = new com.watabou.towngenerator.wards.Hamlet(this, pick);
			hamlets.push(pick);
		}
	}

	private function computeGradients():Void {
		// Social gradients: wealth + decay. Lightweight and stable.
		var r = border != null ? border.getRadius() : 0;
		if (r <= 0) r = 200;

		for (p in patches) {
			var nd = Math.min(1.0, p.shape.distance(center) / (r * 1.2));
			var elev = p.elevation;
			// Wealth: centrality + elevation, but water is poor (and wet).
			p.wealth = p.isWater ? 0.0 : Math.max(0.0, Math.min(1.0, (1 - nd) * 0.75 + elev * 0.25));
			// Decay: inverse wealth, slums rot faster.
			p.decay = 1.0 - p.wealth;
			if (p.ward != null) {
				var t = p.ward.getLabel();
				switch (t) {
					case "Slum": p.decay = Math.min(1.0, p.decay + 0.35);
					case "Docks": p.decay = Math.min(1.0, p.decay + 0.15);
					case "Patriciate": p.decay = Math.max(0.0, p.decay - 0.25);
					case "Temple": p.decay = Math.max(0.0, p.decay - 0.15);
					default:
				}
			}
			// Deterministic district naming stored on patch.
			if (p.ward != null && p.districtName == null) {
				p.districtName = com.watabou.utils.NameGenerator.districtName(p.ward.getLabel(), p.shape.centroid);
			}
		}
	}

	#if debug
	private function validate(stage:String):Void {
		// Minimal invariants: catch NaNs, degenerate polygons, and reserved patches becoming water.
		if (plaza != null && plaza.isWater) throw new Error("Validation failed (" + stage + "): plaza became water");
		if (citadel != null && citadel.isWater) throw new Error("Validation failed (" + stage + "): citadel became water");
		for (bridge in bridges) if (bridge == null || bridge.length != 2 || Point.distance(bridge[0], bridge[1]) < 0.001)
			throw new Error("Validation failed (" + stage + "): invalid bridge");

		for (p in patches) {
			if (p.shape == null || p.shape.length < 3 || Math.isNaN(p.shape.square) || Math.abs(p.shape.square) < 0.000001)
				throw new Error("Validation failed (" + stage + "): degenerate patch shape");
			for (v in p.shape) {
				if (Math.isNaN(v.x) || Math.isNaN(v.y) || Math.abs(v.x) == Math.POSITIVE_INFINITY || Math.abs(v.y) == Math.POSITIVE_INFINITY) throw new Error("Validation failed (" + stage + "): NaN vertex");
			}
			if (p.ward != null && p.ward.geometry != null) {
				for (poly in p.ward.geometry) {
					if (poly == null || poly.length < 3 || Math.isNaN(poly.square) || Math.abs(poly.square) < 0.000001)
						throw new Error("Validation failed (" + stage + "): degenerate ward poly");
					for (vv in poly) if (Math.isNaN(vv.x) || Math.isNaN(vv.y) || Math.abs(vv.x) == Math.POSITIVE_INFINITY || Math.abs(vv.y) == Math.POSITIVE_INFINITY) throw new Error("Validation failed (" + stage + "): NaN ward vertex");
				}
			}
		}
	}
	#end
}
