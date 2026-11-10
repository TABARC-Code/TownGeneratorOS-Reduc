package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Patch;

/**
 * A non-buildable patch representing sea/lake/river surface.
 * Geometry is intentionally empty; rendering uses the patch boundary.
 */
class Water extends Ward {

	public function new(model:Model, patch:Patch) {
		super(model, patch);
	}

	override public function createGeometry() {
		// No buildings/plots.
		geometry = [];
	}

	override public function getLabel():String return "Water";
}
