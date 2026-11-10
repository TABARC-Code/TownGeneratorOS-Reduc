package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;
import com.watabou.geom.Polygon;
import openfl.geom.Point;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class Ruins extends Ward {

    public static function rateLocation(model:Model, patch:Patch):Float {
        if (patch.isWater) return 1e30;
        return patch.shape.distance(model.center) - patch.elevation * 50;
    }

    override public function createGeometry() {
        var out:Array<Polygon> = [];
        var b = patch.shape.getBounds();
        for (i in 0...6) {
            var w = 2 + Random.float()*5;
            var h = 2 + Random.float()*5;
            var r = Polygon.rect(w,h);
            r.rotate(Random.float()*Math.PI);
            r.offset(new Point(b.left + Random.float()*b.width, b.top + Random.float()*b.height));
            if (patch.shape.containsPoint(r.center)) out.push(r);
        }
        geometry = out;
    }

    override public inline function getLabel() return "Ruins";
}
