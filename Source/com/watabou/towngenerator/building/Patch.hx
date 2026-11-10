package com.watabou.towngenerator.building;

import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Voronoi.Region;

import com.watabou.towngenerator.wards.Ward;

class Patch {

	public var shape	: Polygon;
	public var ward 	: Ward;

	public var withinWalls	: Bool;
	public var withinCity	: Bool;
	public var isWater		: Bool;
	public var waterKind	: String;
	public var economicRole	: String;
	public var roadAccess	: Bool;
	public var waterAccess	: Bool;
	public var elevation	: Float;

	public var wealth		: Float;
	public var decay		: Float;
	public var districtName	: String;

	public inline function new( vertices:Array<Point> ) {
		this.shape = new Polygon( vertices );

		withinCity	= false;
		withinWalls	= false;
		isWater		= false;
		waterKind	= null;
		economicRole	= null;
		roadAccess	= false;
		waterAccess	= false;
		elevation	= 0.0;
		wealth		= 0.0;
		decay		= 0.0;
		districtName	= null;
	}

	public static function fromRegion( r:Region ):Patch
		return new Patch( [for (tr in r.vertices) tr.c] );
}

