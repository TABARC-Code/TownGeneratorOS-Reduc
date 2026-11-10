package com.watabou.towngenerator;

import com.watabou.utils.Random;

#if html5
import js.Browser;
import js.html.URLSearchParams;
#end

class StateManager {

	private static inline var SIZE = "size";
	private static inline var SEED = "seed";
	private static inline var CULTURE = "culture";
	private static inline var ORIGIN = "origin";

	public static var size	: Int = 15;
	public static var seed	: Int = -1;
	public static var culture	: String = "medieval";
	public static var origin	: String = "town";

	public static function pullParams() {
		#if html5
		var params = new URLSearchParams( Browser.location.search );
		if (params != null) {
			var size1 = Std.parseInt( params.get( SIZE ) );
			if (size1 != null)size = (size1 >= 6 ? (size1 <= 40 ? size1: 40) : 6);

			var seed1 = Std.parseInt( params.get( SEED ) );
			if (seed1 != null) seed = (seed1 > 0 ? seed1 : -1);

			var culture1 = params.get( CULTURE );
			if (culture1 != null && culture1 != "") culture = culture1;

			var origin1 = params.get( ORIGIN );
			if (origin1 != null && origin1 != "") origin = origin1;
		}
		#end
	}

	public static function pushParams() {
		if (seed == -1) {
			Random.reset();
			seed = Random.getSeed();
		}

		#if html5
		var loc = Browser.location;
		var params = new URLSearchParams(loc.search);
		params.set(SIZE, Std.string(size));
		params.set(SEED, Std.string(seed));
		params.set(CULTURE, culture);
		params.set(ORIGIN, origin);
		var url = loc.protocol + "//" + loc.host + loc.pathname + "?" + Std.string(params) + loc.hash;
		Browser.window.history.replaceState({size: size, seed: seed, culture: culture, origin: origin}, getStateName(), url);
		#end
	}

	private static function getStateName():String {
		return if (size >= 6 && size < 10)
			"Small Town"
		else if (size >= 10 && size < 15)
			"Large Town"
		else if (size >= 15 && size <24)
			"Small City"
		else if (size >= 24 && size < 40)
			"Large City"
		else if (size >= 40)
			"Metropolis"
		else
			"Unknown state";
	}
}
