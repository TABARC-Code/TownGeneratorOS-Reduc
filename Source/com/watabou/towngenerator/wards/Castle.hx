package com.watabou.towngenerator.wards;

import openfl.geom.Point;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.CurtainWall;
import com.watabou.towngenerator.building.Architect;

using com.watabou.utils.ArrayExtender;

class Castle extends Ward {

	public var wall	: CurtainWall;

	public function new( model:Model, patch:Patch ) {
		super( model, patch );

		wall = new CurtainWall( true, model, [patch], patch.shape.filter(
			function( v:Point ) return model.patchByVertex( v ).some(
				function( p:Patch ) return !p.withinCity
			)
		) );
	}

	override public function createGeometry() {
		geometry = Architect.makeStarFort(patch.shape);
	}

	override public inline function getLabel() return "Castle";
}
