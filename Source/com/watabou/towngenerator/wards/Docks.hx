package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Architect;

class Docks extends CommonWard {

    public inline function new( model:Model, patch:Patch )
        super( model, patch,
            20 + 20 * Random.float(),
            0.5, 0.5, 0.05 );

    public static function rateLocation( model:Model, patch:Patch ):Float {
        var neighbors = model.getNeighbours(patch);
        var hasWater = false;
        for (n in neighbors)
            if (n.isWater) { hasWater = true; break; }

        if (!hasWater) return Math.POSITIVE_INFINITY;

        // Prefer closer to town centre (ports tend to develop near the core if possible)
        return patch.shape.distance(model.center);
    }

    override public function createGeometry() {
        geometry = Architect.makePiers(patch, model);
    }

    override public inline function getLabel() return "Docks";
}
