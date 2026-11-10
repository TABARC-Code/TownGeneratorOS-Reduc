package com.watabou.towngenerator.wards;

import openfl.geom.Point;


import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Architect;

class Market extends Ward {

	override public function createGeometry() {
    var angle:Null<Float> = estimateNearestArteryAngle();
    geometry = Architect.makeMarket(patch.shape, model.culture, angle);
}

private function estimateNearestArteryAngle():Null<Float> {
    if (model == null || model.arteries == null || model.arteries.length == 0) return null;
    var p = patch.shape.centroid;
    var bestD = Math.POSITIVE_INFINITY;
    var bestA:Null<Float> = null;

    for (a in model.arteries) {
        if (a == null || a.length < 2) continue;
        for (i in 0...a.length - 1) {
            var v1 = a[i];
            var v2 = a[i + 1];
            var d = distPointSegment(p, v1, v2);
            if (d < bestD) {
                bestD = d;
                bestA = Math.atan2(v2.y - v1.y, v2.x - v1.x);
            }
        }
    }
    return bestA;
}

private static inline function distPointSegment(p:Point, a:Point, b:Point):Float {
    var abx = b.x - a.x;
    var aby = b.y - a.y;
    var apx = p.x - a.x;
    var apy = p.y - a.y;
    var ab2 = abx * abx + aby * aby;
    if (ab2 <= 1e-9) return Point.distance(p, a);
    var t = (apx * abx + apy * aby) / ab2;
    if (t < 0) t = 0;
    else if (t > 1) t = 1;
    var cx = a.x + abx * t;
    var cy = a.y + aby * t;
    var dx = p.x - cx;
    var dy = p.y - cy;
    return Math.sqrt(dx * dx + dy * dy);
}


	public static function rateLocation( model:Model, patch:Patch ):Float {
		// One market should not touch another
		for (p in model.inner)
			if (Std.is( p.ward, Market ) && p.shape.borders( patch.shape ))
				return Math.POSITIVE_INFINITY;

		// Market shouldn't be much larger than the plaza
		return model.plaza != null ? patch.shape.square / model.plaza.shape.square : patch.shape.distance( model.center );
	}

	override public inline function getLabel() return "Market";
}
