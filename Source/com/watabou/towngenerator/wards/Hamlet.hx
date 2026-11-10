package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;
import com.watabou.geom.Polygon;
import openfl.geom.Point;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Architect;

class Hamlet extends Ward {

	public function new(model:Model, patch:Patch) {
		super(model, patch);
	}

	override public function createGeometry() {
    var block = patch.shape;

    switch (model.culture) {
        case com.watabou.towngenerator.building.Culture.SAXON, com.watabou.towngenerator.building.Culture.VIKING:
            // Roadside longhouses
            geometry = Architect.makeLonghouses(block, null, 12 + Std.int(Random.float() * 6));

        case com.watabou.towngenerator.building.Culture.AFRICAN, com.watabou.towngenerator.building.Culture.TRIBAL:
            // Small hut compounds
            geometry = Architect.makeRoundHuts(block, 2 + Random.int(0, 2), 8 + Random.int(0, 6));

        case com.watabou.towngenerator.building.Culture.TENT:
            // Nomadic camp
            geometry = Architect.makeTents(block, 28 + Random.int(0, 18));

        default:
            geometry = Architect.makeShantytown(block, 10 + Std.int(Random.float() * 10));
    }

    // Communal marker (well/green)
    var c = block.centroid;
    var marker = Polygon.rect(3, 3);
    marker.offset(c);
    geometry.push(marker);
}


	override public inline function getLabel() return "Hamlet";
}
