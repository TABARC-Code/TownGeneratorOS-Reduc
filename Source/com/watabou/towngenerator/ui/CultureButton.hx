package com.watabou.towngenerator.ui;

import com.watabou.coogee.Game;
import com.watabou.towngenerator.StateManager;
import com.watabou.towngenerator.TownScene;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Culture;
import com.watabou.towngenerator.building.Origin;
import openfl.events.MouseEvent;

/** Click for culture, Shift-click for settlement origin. */
class CultureButton extends Button {

	private var order:Array<Culture> = [
		Culture.MEDIEVAL,
		Culture.EUROPEAN_MEDIEVAL,
		Culture.DARK_AGES,
		Culture.HIGH_MEDIEVAL_CITY,
		Culture.RENAISSANCE_CITY,

		Culture.SAXON,
		Culture.VIKING,

		Culture.IMPERIAL,
		Culture.MERCHANT_REPUBLIC,
		Culture.INDUSTRIAL,
		Culture.FRONTIER,
		Culture.RUINED,

		Culture.AFRICAN,
		Culture.TRIBAL,
		Culture.BARBARIAN,
		Culture.NOMAD,
		Culture.MARSH,
		Culture.TENT,

		Culture.ELVEN_HIGH,
		Culture.ELVEN_WOOD,
		Culture.ELVEN_DARK,
		Culture.DWARVEN_HOLD,
		Culture.ORCINOID,
		Culture.RELIGIOUS_ENCLAVE
	];

	public function new() {
		super( labelFor(StateManager.culture, StateManager.origin) );
		click.add( onClick );
	}

	private static function labelFor(c:String, o:String):String {
		return "Style: " + Culture.label( Culture.fromString(c) ) + " / " + Origin.label( Origin.fromString(o) );
	}

	private function onClick( e:MouseEvent ):Void {
		var previousCulture = StateManager.culture;
		var previousOrigin = StateManager.origin;
		// Shift-click cycles Origin; normal click cycles Culture.
		if (e != null && e.shiftKey) {
			var curO = Origin.fromString(StateManager.origin);
			var oOrder = Origin.order();
			var oIdx = oOrder.indexOf(curO);
			if (oIdx < 0) oIdx = 0;
			oIdx = (oIdx + 1) % oOrder.length;
			StateManager.origin = oOrder[oIdx];
		} else {
			var cur = Culture.fromString(StateManager.culture);
			var idx = order.indexOf(cur);
			if (idx < 0) idx = 0;
			idx = (idx + 1) % order.length;
			StateManager.culture = order[idx];
		}

		// Only store the new style once it has produced a settlement.
		try {
			new Model(StateManager.size, StateManager.seed);
		} catch (e:Dynamic) {
			StateManager.culture = previousCulture;
			StateManager.origin = previousOrigin;
			throw e;
		}
		StateManager.pushParams();
		Game.switchScene( TownScene );
	}
}
