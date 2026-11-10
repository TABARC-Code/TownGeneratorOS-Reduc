package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Architect;

class Mine extends Ward {

	public static function rateLocation(model:Model, patch:Patch):Float {
		if (patch.isWater || !patch.withinCity) return 1e30;
		// Prefer higher elevation (hills) if available.
		return -(patch.elevation * 50) + patch.shape.square * 0.02;
	}

	override public function createGeometry() {
		geometry = Architect.makeMine(patch.shape);
	}

	override public inline function getLabel() return "Mine";
}
