package com.watabou.towngenerator.building;

/**
 * Culture preset that influences ward geometry, ward pools, palettes and (optionally)
 * generation rules.
 *
 * String-backed abstract so it round-trips cleanly via URL params/JSON.
 */
enum abstract Culture(String) from String to String {
	public var EUROPEAN_MEDIEVAL = "european_medieval";
	public var DARK_AGES = "dark_ages";
	public var HIGH_MEDIEVAL_CITY = "high_medieval_city";
	public var RENAISSANCE_CITY = "renaissance_city";

	public var MEDIEVAL = "medieval";
	public var SAXON = "saxon";
	public var VIKING = "viking";
	public var AFRICAN = "african";
	public var TRIBAL = "tribal";
	public var TENT = "tent";

	public var IMPERIAL = "imperial";
	public var MERCHANT_REPUBLIC = "merchant_republic";
	public var BARBARIAN = "barbarian";
	public var NOMAD = "nomad";
	public var RELIGIOUS_ENCLAVE = "religious_enclave";
	public var INDUSTRIAL = "industrial";
	public var FRONTIER = "frontier";
	public var RUINED = "ruined";

	public var ELVEN_HIGH = "elven_high";
	public var ELVEN_WOOD = "elven_wood";
	public var ELVEN_DARK = "elven_dark";
	public var DWARVEN_HOLD = "dwarven_hold";
	public var ORCINOID = "orcinoid";
	public var MARSH = "marsh";

	public static function fromString(s:String):Culture {
		if (s == null) return MEDIEVAL;
		var v = s.toLowerCase();

		return switch (v) {
			// Europe flavours
			case "european", "european_medieval", "euro_medieval": EUROPEAN_MEDIEVAL;
			case "darkages", "dark_ages", "early_medieval": DARK_AGES;
			case "high_medieval", "high_medieval_city", "medieval_city", "late_medieval_city": HIGH_MEDIEVAL_CITY;
			case "renaissance", "renaissance_city", "early_modern": RENAISSANCE_CITY;

			// Existing
			case "saxon": SAXON;
			case "viking": VIKING;
			case "african": AFRICAN;
			case "tribal": TRIBAL;
			case "tent", "tentcity", "tent_city": TENT;

			// Systemic cultures
			case "imperial", "roman", "planned": IMPERIAL;
			case "merchant", "merchant_republic", "trade": MERCHANT_REPUBLIC;
			case "barbarian", "hill", "warband": BARBARIAN;
			case "nomad", "nomadic", "pastoral": NOMAD;
			case "religious", "religious_enclave", "theocracy", "holy": RELIGIOUS_ENCLAVE;
			case "industrial", "proto_industrial", "mine": INDUSTRIAL;
			case "frontier", "boomtown", "new": FRONTIER;
			case "ruined", "ruins", "decayed": RUINED;

			// Fantasy (generic, non-real-world)
			case "elf", "elven", "high_elf", "elven_high": ELVEN_HIGH;
			case "wood_elf", "elven_wood", "sylvan": ELVEN_WOOD;
			case "dark_elf", "elven_dark", "underdeep": ELVEN_DARK;
			case "dwarf", "dwarven", "dwarven_hold": DWARVEN_HOLD;
			case "orc", "orcinoid", "ork", "orkinoid": ORCINOID;
			case "marsh", "swamp", "fen": MARSH;

			// Back-compat default
			case "medieval": MEDIEVAL;
			default: MEDIEVAL;
		}
	}

	public static function label(c:Culture):String {
		return switch (c) {
			case EUROPEAN_MEDIEVAL: "European Medieval";
			case DARK_AGES: "Dark Ages";
			case HIGH_MEDIEVAL_CITY: "Medieval City";
			case RENAISSANCE_CITY: "Renaissance City";

			case SAXON: "Saxon";
			case VIKING: "Viking";
			case AFRICAN: "African";
			case TRIBAL: "Tribal";
			case TENT: "Tent City";
			case IMPERIAL: "Imperial";
			case MERCHANT_REPUBLIC: "Merchant Republic";
			case BARBARIAN: "Barbarian";
			case NOMAD: "Nomad";
			case RELIGIOUS_ENCLAVE: "Religious Enclave";
			case INDUSTRIAL: "Industrial";
			case FRONTIER: "Frontier";
			case RUINED: "Ruined";

			case ELVEN_HIGH: "Elven High";
			case ELVEN_WOOD: "Elven Wood";
			case ELVEN_DARK: "Elven Dark";
			case DWARVEN_HOLD: "Dwarven Hold";
			case ORCINOID: "Orcinoid";
			case MARSH: "Marsh Settlement";

			default: "Medieval";
		}
	}
}
