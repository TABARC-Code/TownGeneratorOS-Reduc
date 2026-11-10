package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Architect;
import com.watabou.towngenerator.building.Culture;

class Waystation extends Ward {

	public static function rateLocation(model:Model, patch:Patch):Float {
		if (patch.isWater || !patch.withinCity) return 1e30;
		// Prefer near gates / border so it's a real stop.
		var dGate = 1e30;
		for (g in model.gates) dGate = Math.min(dGate, patch.shape.distance(g));
		return dGate + patch.shape.square * 0.01;
	}

	override public function createGeometry() {
		geometry = Architect.makeWaystation(patch.shape, model.culture);
	}

	override public inline function getLabel() return "Waystation";
}
