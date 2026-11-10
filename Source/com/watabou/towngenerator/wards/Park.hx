package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Cutter;
import com.watabou.towngenerator.building.Architect;
import com.watabou.geom.Polygon;
import com.watabou.utils.Random;
import openfl.geom.Point;

class Park extends Ward {

	override public function createGeometry() {
    var block = getCityBlock();
    geometry = block.compactness >= 0.7 ?
        Cutter.radial( block, null, Ward.ALLEY ) :
        Cutter.semiRadial( block, null, Ward.ALLEY );

    // Culture-aware park features
    switch (model.culture) {
        case com.watabou.towngenerator.building.Culture.AFRICAN, com.watabou.towngenerator.building.Culture.TRIBAL:
            // Meeting ring + dense grove
            var ring = Polygon.circle(4 + Random.float() * 2);
            ring.offset(block.centroid);
            geometry.push(ring);
            geometry = geometry.concat(Architect.makeTrees(block, 55 + Random.int(0, 25), 1.2));

        case com.watabou.towngenerator.building.Culture.TENT, com.watabou.towngenerator.building.Culture.NOMAD, com.watabou.towngenerator.building.Culture.FRONTIER:
            // Sparse shade + firepit markers
            geometry = geometry.concat(Architect.makeTrees(block, 12 + Random.int(0, 6), 0.9));
            var pitCount = 3 + Random.int(0, 3);
            for (i in 0...pitCount) {
                var pit = Polygon.circle(0.8 + Random.float() * 0.4);
                var p = new Point(block.centroid.x + (Random.float() - 0.5) * 8, block.centroid.y + (Random.float() - 0.5) * 8);
                pit.offset(p);
                geometry.push(pit);
            }


		case com.watabou.towngenerator.building.Culture.ELVEN_HIGH, com.watabou.towngenerator.building.Culture.ELVEN_WOOD:
			// Sacred grove: very dense trees + clearing
			var clearing = Polygon.circle(3 + Random.float() * 2);
			clearing.offset(block.centroid);
			geometry.push(clearing);
			geometry = geometry.concat(Architect.makeTrees(block, 75 + Random.int(0, 25), 1.1));

		case com.watabou.towngenerator.building.Culture.MARSH:
			// Reeds: many tiny "trees"
			geometry = geometry.concat(Architect.makeTrees(block, 90 + Random.int(0, 30), 0.6));

		case com.watabou.towngenerator.building.Culture.RUINED:
			geometry = geometry.concat(Architect.makeTrees(block, 18 + Random.int(0, 10), 1.0));
			geometry = geometry.concat(Architect.makeRuinsScatter(block, 8));

        default:
            // Medieval/Saxon/Viking: paths + tree scatter
            geometry = geometry.concat(Architect.makeTrees(block, 28 + Random.int(0, 20), 1.0));
    }
}


	override public inline function getLabel() return "Park";
}
