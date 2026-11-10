package com.watabou.towngenerator.wards;

import openfl.geom.Point;
import com.watabou.geom.Polygon;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class Gallows extends Ward {

    public static function rateLocation(model:Model, patch:Patch):Float {
        if (patch.isWater) return 1e30;
        var dGate = 1e30;
        for (g in model.gates) {
            var d = Point.distance(g, patch.shape.centroid);
            if (d < dGate) dGate = d;
        }
        var bonus = patch.withinWalls ? 10.0 : 0.0;
        return dGate + bonus;
    }

    override public function createGeometry() {
        var c = patch.shape.centroid;
        var frame = Polygon.rect(2.5, 4.0);
        frame.offset(c);
        geometry = [frame];
    }

    override public inline function getLabel() return "Gallows";
}
