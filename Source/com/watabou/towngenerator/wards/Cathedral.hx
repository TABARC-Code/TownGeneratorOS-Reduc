package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Architect;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Patch;
import openfl.geom.Point;

class Cathedral extends Ward {

    override public function createGeometry() {
        var angle:Null<Float> = estimateNearestArteryAngle();
        geometry = Architect.makeCathedral(patch.shape, angle);
    }


/**
 * Estimate orientation based on the nearest artery segment.
 * Falls back to null if no arteries exist.
 */
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
        // High visibility: bias toward plaza adjacency or centrality
        return if (model.plaza != null && patch.shape.borders( model.plaza.shape ))
            -1/patch.shape.square
        else
            patch.shape.distance( model.plaza != null ? model.plaza.shape.center : model.center ) * patch.shape.square;
    }

    override public inline function getLabel() return "Temple";
}
