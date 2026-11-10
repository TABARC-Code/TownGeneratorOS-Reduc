package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Architect;
import com.watabou.towngenerator.building.Culture;

class CommonWard extends Ward {

	private var minSq		: Float;
	private var gridChaos	: Float;
	private var sizeChaos	: Float;
	private var emptyProb	: Float;

	public function new( model:Model, patch:Patch, minSq:Float, gridChaos:Float, sizeChaos:Float, emptyProb:Float=0.04 ) {
		super( model, patch );

		this.minSq = minSq;
		this.gridChaos = gridChaos;
		this.sizeChaos = sizeChaos;
		this.emptyProb = emptyProb;
	}

	override public function createGeometry() {
	var block = getCityBlock();

	// Culture presets: swap the default "alleys" building language for something recognisable.
	if (model.culture == Culture.SAXON || model.culture == Culture.VIKING) {
		geometry = Architect.makeLonghouses(block, null, Std.int(10 + Math.sqrt(block.square) / 8));
	} else if (model.culture == Culture.AFRICAN || model.culture == Culture.TRIBAL) {
		geometry = Architect.makeRoundHuts(block, 2 + Std.int(Math.sqrt(block.square) / 60), 6 + Std.int(Math.sqrt(block.square) / 18));
	} else if (model.culture == Culture.TENT) {
		geometry = Architect.makeTents(block, 18 + Std.int(Math.sqrt(block.square) / 6));
	} else {
		geometry = Ward.createAlleys( block, minSq, gridChaos, sizeChaos, emptyProb );
	}

	if (!model.isEnclosed( patch ))
		filterOutskirts();
}
}
