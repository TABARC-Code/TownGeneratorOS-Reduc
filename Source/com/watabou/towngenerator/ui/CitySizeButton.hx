package com.watabou.towngenerator.ui;

import com.watabou.towngenerator.StateManager;
import com.watabou.towngenerator.TownScene;

import com.watabou.coogee.Game;
import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Model;

class CitySizeButton extends Button {

	private var size : Int;

	public function new( label:String, minSize:Int, maxSize:Int ) {
		super( label );

		size = minSize + Std.int( Math.random() * (maxSize - minSize) );

		click.add( onClick );
	}

	private function onClick( _ ):Void {
		var previousSize = StateManager.size;
		var previousSeed = StateManager.seed;
		StateManager.size = size;
		try {
			var town = new Model(size, -1);
			StateManager.seed = town.seed;
		} catch (e:Dynamic) {
			StateManager.size = previousSize;
			StateManager.seed = previousSeed;
			throw e;
		}
		StateManager.pushParams();
		Game.switchScene( TownScene );
	}
}
