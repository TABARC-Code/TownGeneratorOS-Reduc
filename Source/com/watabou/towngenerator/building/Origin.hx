package com.watabou.towngenerator.building;

/**
 * Locational / functional origin of a settlement.
 * Orthogonal to Culture: "culture" controls architectural grammar,
 * "origin" controls why the settlement exists and what it prioritises.
 */
enum abstract Origin(String) from String to String {
	public var TOWN = "town";
	public var TIMBER_CAMP = "timber_camp";
	public var FISHING_VILLAGE = "fishing_village";
	public var MINING_CAMP = "mining_camp";
	public var WALLED_WAYSTATION = "walled_waystation";
	public var RIVER_PORT = "river_port";
	public var FORTRESS = "fortress";
	public var MONASTERY = "monastery";

	public static function fromString(s:String):Origin {
		if (s == null) return TOWN;
		var v = s.toLowerCase();
		return switch (v) {
			case "town", "default": TOWN;
			case "timber", "logging", "timber_camp", "logging_camp": TIMBER_CAMP;
			case "fishing", "fish", "fishing_village": FISHING_VILLAGE;
			case "mining", "mine", "mining_camp": MINING_CAMP;
			case "waystation", "walled", "walled_waystation", "road_fort": WALLED_WAYSTATION;
			case "river_port", "port", "river": RIVER_PORT;
			case "fortress", "fort": FORTRESS;
			case "monastery", "abbey": MONASTERY;
			default: TOWN;
		}
	}

	public static function label(o:Origin):String {
		return switch (o) {
			case TOWN: "Town";
			case TIMBER_CAMP: "Timber Camp";
			case FISHING_VILLAGE: "Fishing Village";
			case MINING_CAMP: "Mining Camp";
			case WALLED_WAYSTATION: "Walled Waystation";
			case RIVER_PORT: "River Port";
			case FORTRESS: "Fortress";
			case MONASTERY: "Monastery";
			default: "Town";
		}
	}

	public static function order():Array<Origin> {
		return [TOWN, TIMBER_CAMP, FISHING_VILLAGE, MINING_CAMP, WALLED_WAYSTATION, RIVER_PORT, FORTRESS, MONASTERY];
	}
}
