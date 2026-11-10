package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Architect;

class Lumberyard extends Ward {

	public static function rateLocation(model:Model, patch:Patch):Float {
		if (patch.isWater || !patch.withinCity) return 1e30;
		// Prefer near edge (easier hauling), but still inside.
		return patch.shape.distance(model.center) * -1 + patch.shape.square * 0.01;
	}

	override public function createGeometry() {
		geometry = Architect.makeTimberYard(patch.shape);
	}

	override public inline function getLabel() return "Lumberyard";
}
