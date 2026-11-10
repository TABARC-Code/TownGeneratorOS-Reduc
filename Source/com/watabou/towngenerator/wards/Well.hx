package com.watabou.towngenerator.wards;

import com.watabou.geom.Polygon;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class Well extends Ward {

    public static function rateLocation(model:Model, patch:Patch):Float {
        if (patch.isWater || !patch.withinCity) return 1e30;
        var tgt = model.plaza != null ? model.plaza.shape.centroid : model.center;
        return patch.shape.distance(tgt) * 0.5 + patch.shape.square * 0.02;
    }

    override public function createGeometry() {
        var c = patch.shape.centroid;
        var ring = Polygon.rect(3.0, 3.0);
        ring.offset(c);
        geometry = [ring];
    }

    override public inline function getLabel() return "Well";
}
