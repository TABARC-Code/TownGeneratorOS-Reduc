package com.watabou.towngenerator.wards;

import com.watabou.geom.Polygon;
import openfl.geom.Point;
import com.watabou.towngenerator.building.Architect;
import com.watabou.towngenerator.building.Patch;

class Farm extends Ward {

    override public function createGeometry() {
        // Authentic strip fields.
// If this farm borders water, orient strips parallel to the shoreline.
        var coastAngle:Null<Float> = null;
        var waterNeighbours = model.getNeighbours(patch).filter(function(p) return p.isWater);
        if (waterNeighbours.length > 0) {
            coastAngle = estimateShorelineAngle(waterNeighbours);
        }
        geometry = Architect.makeStripFields(patch.shape, coastAngle);

        // Farmhouse + a couple of small sheds near the centroid
        var c = patch.shape.centroid;

        var house = Polygon.rect(4.5, 4.0);
        house.offset(c);
        geometry.push(house);

        var shed1 = Polygon.rect(2.5, 2.0);
        shed1.offset(c.add(new Point(5, -4)));
        geometry.push(shed1);

        var shed2 = Polygon.rect(2.2, 1.8);
        shed2.offset(c.add(new Point(-5, -3)));
        geometry.push(shed2);
    }


/**
 * Estimate shoreline direction by averaging angles of edges shared with adjacent water patches.
 * Returns an angle in radians (direction along the shore).
 */
private function estimateShorelineAngle(waterNeighbours:Array<Patch>):Null<Float> {
    var angles:Array<Float> = [];
    var shape = patch.shape;
    for (i in 0...shape.length) {
        var v1 = shape[i];
        var v2 = shape[(i + 1) % shape.length];

        // Shared edge if both vertices appear in a neighbour polygon
        var shared = false;
        for (wn in waterNeighbours) {
            if (wn.shape.indexOf(v1) != -1 && wn.shape.indexOf(v2) != -1) {
                shared = true;
                break;
            }
        }
        if (shared) {
            angles.push(Math.atan2(v2.y - v1.y, v2.x - v1.x));
        }
    }

    if (angles.length == 0) return null;

    // Circular mean
    var sx = 0.0;
    var sy = 0.0;
    for (a in angles) {
        sx += Math.cos(a);
        sy += Math.sin(a);
    }
    return Math.atan2(sy, sx);
}

    override public inline function getLabel() return "Farm";
}
