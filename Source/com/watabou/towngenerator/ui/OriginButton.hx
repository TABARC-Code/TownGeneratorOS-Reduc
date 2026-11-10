package com.watabou.towngenerator.ui;

import com.watabou.coogee.Game;
import com.watabou.towngenerator.StateManager;
import com.watabou.towngenerator.TownScene;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Origin;

/**
 * Cycles settlement "origin" presets (why the place exists).
 */
class OriginButton extends Button {

	public function new() {
		super( labelFor(StateManager.origin) );
		click.add( onClick );
	}

	private static function labelFor(o:String):String {
		return "Origin: " + Origin.label( Origin.fromString(o) );
	}

	private function onClick( _ ):Void {
		var cur = Origin.fromString(StateManager.origin);
		var order = Origin.order();
		var idx = order.indexOf(cur);
		if (idx < 0) idx = 0;
		idx = (idx + 1) % order.length;

		StateManager.origin = order[idx];
		StateManager.pushParams();

		new Model( StateManager.size, StateManager.seed );
		Game.switchScene( TownScene );
	}
}
