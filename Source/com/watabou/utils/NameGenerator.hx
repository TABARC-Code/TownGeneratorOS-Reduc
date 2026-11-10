package com.watabou.utils;

import openfl.geom.Point;

/**
 * Deterministic name generator.
 *
 * Important: this avoids touching the global Random seed, so names remain stable
 * across hover order, export, and reruns of rendering.
 */
class NameGenerator {

	static var ADJECTIVES = ["Old", "New", "High", "Low", "Great", "Little", "Black", "White", "Red", "Green", "Silver", "Golden", "Broken", "Lost", "King's", "Beggar's", "Merchant's", "Saint's", "Hollow", "Crooked", "Iron", "Ashen"];
	static var NOUNS = ["Market", "Gate", "Bridge", "Tower", "Hill", "Field", "Garden", "Yard", "Square", "Way", "Lane", "Walk", "End", "Rise", "Drop", "Keep", "Hold", "Sanctuary", "Quay", "Wharf", "Steps", "Row", "Cut", "Reach"];

	static var DOCKS = ["Quay", "Wharf", "Harbour", "Slip", "Moor", "Dock"];
	static var SLUM = ["Hollow", "Steps", "End", "Cut", "Sprawl"];
	static var POSH = ["Heights", "Crescent", "Close", "Gardens", "Terrace"];
	static var MIL = ["Barracks", "Yard", "Drill", "Armoury", "Wall"];
	static var FARM = ["Field", "Furlong", "Meadow", "Ridge", "Strip"];

	static inline function mix32(x:Int):Int {
		// Cheap 32-bit avalanche hash.
		var y = x;
		y ^= (y >>> 16);
		y *= 0x7feb352d;
		y ^= (y >>> 15);
		y *= 0x846ca68b;
		y ^= (y >>> 16);
		return y;
	}

	static inline function pick(arr:Array<String>, seed:Int, salt:Int):String {
		var h = mix32(seed ^ salt) & 0x7fffffff;
		return arr[h % arr.length];
	}

	static inline function seedFromPoint(p:Point):Int {
		// Stable even with floats: quantise to 1/10th unit
		var x = Std.int(p.x * 10);
		var y = Std.int(p.y * 10);
		return mix32(x * 73856093 ^ y * 19349663);
	}

	public static function districtName(type:String, centroid:Point):String {
		var seed = seedFromPoint(centroid);

		var nounPool = NOUNS;
		switch (type) {
			case "Docks": nounPool = DOCKS;
			case "Slum": nounPool = SLUM;
			case "Patriciate": nounPool = POSH;
			case "Military": nounPool = MIL;
			case "Farm": nounPool = FARM;
			default:
		}

		var a = pick(ADJECTIVES, seed, 11);
		var n = pick(nounPool, seed, 29);

		// 50% "functional", 50% "place"
		if (((seed >>> 3) & 1) == 0) {
			return a + " " + type;
		} else {
			return a + " " + n;
		}
	}

	public static function streetName(index:Int, seed:Int):String {
		var a = pick(ADJECTIVES, seed, 101 + index * 3);
		var n = pick(["Way", "Road", "Lane", "Street", "Walk", "Row", "Causeway"], seed, 203 + index * 7);
		return a + " " + n;
	}

	public static function cityName(seed:Int, ?culture:String):String {
		var c = culture != null ? culture.toLowerCase() : "medieval";

		var prefix = ["East", "West", "North", "South", "Port", "Fort", "Dun", "High", "Low", "Winter", "Summer"];
		var suffix = ["watch", "guard", "landing", "ford", "bridge", "mouth", "hold", "fast", "grad", "bury", "ton"];

		// Culture flavour without real-world ethnonym stereotypes. Keep it subtle.
		switch (c) {
			case "imperial", "renaissance_city":
				prefix = ["Nova", "Civita", "Aurea", "Val", "Castel", "Porta", "San"];
				suffix = ["ium", "polis", "gate", "mar", "terra", "ford", "haven"];
			case "merchant_republic":
				prefix = ["Port", "Free", "Harbour", "Salt", "Coin", "Ledger", "St"];
				suffix = ["haven", "quay", "port", "market", "dock", "bridge", "mouth"];
			case "elven_high", "elven_wood":
				prefix = ["Ael", "Leth", "Eryn", "Sil", "Calen", "El", "Ith"];
				suffix = ["lith", "wyn", "dell", "glade", "thalas", "mere", "anor"];
			case "elven_dark":
				prefix = ["Ner", "Dra", "Vel", "Umbra", "Noct", "Sable"];
				suffix = ["hollow", "spire", "deep", "shade", "crypt", "gloom"];
			case "dwarven_hold":
				prefix = ["Kar", "Dur", "Stone", "Iron", "Deep", "Forge", "Anvil"];
				suffix = ["hold", "delve", "gate", "hall", "deep", "forge", "root"];
			case "orcinoid":
				prefix = ["Skull", "Ash", "Blood", "Grim", "Rot", "Bone", "Brak"];
				suffix = ["pit", "mire", "crag", "scar", "fang", "den", "camp"];
			case "marsh":
				prefix = ["Fen", "Reed", "Moss", "Bog", "Willow", "Wet", "Silt"];
				suffix = ["mere", "mire", "reach", "marsh", "pool", "stead", "mouth"];
			case "frontier":
				prefix = ["New", "Prospect", "Dust", "Timber", "Red", "Broken"];
				suffix = ["camp", "post", "cross", "ridge", "ford", "gulch"];
			default:
		}

		var p = pick(prefix, seed, 401);
		var s = pick(suffix, seed, 503);
		return p + s;
	}
}
