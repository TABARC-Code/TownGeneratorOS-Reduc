package com.watabou.towngenerator.building;

import openfl.geom.Point;
import com.watabou.towngenerator.wards.*;

class Economy {
	public static function forOrigin(origin:Origin):EconomyProfile {
		return switch (origin) {
			case Origin.TIMBER_CAMP: new EconomyProfile(0.5, 1, 0.1, 0.1, 0.6, 0.2, 0.1);
			case Origin.FISHING_VILLAGE: new EconomyProfile(0.4, 0.2, 0.1, 1, 0.7, 0.2, 0.2);
			case Origin.MINING_CAMP: new EconomyProfile(0.3, 0.3, 1, 0, 0.7, 0.5, 0.1);
			case Origin.WALLED_WAYSTATION: new EconomyProfile(0.5, 0.3, 0.1, 0.1, 0.8, 0.9, 0.2);
			case Origin.RIVER_PORT: new EconomyProfile(0.6, 0.2, 0.2, 0.8, 1, 0.4, 0.3);
			case Origin.FORTRESS: new EconomyProfile(0.4, 0.2, 0.2, 0.1, 0.3, 1, 0.2);
			case Origin.MONASTERY: new EconomyProfile(0.8, 0.2, 0.1, 0.1, 0.3, 0.3, 1);
			default: new EconomyProfile(0.6, 0.3, 0.2, 0.2, 0.6, 0.4, 0.4);
		};
	}

	public static function hasPreference(wardClass:Class<Ward>):Bool {
		return wardClass == Docks || wardClass == Mine || wardClass == Lumberyard ||
			wardClass == Waystation || wardClass == Market || wardClass == MerchantWard ||
			wardClass == MilitaryWard || wardClass == Cathedral || wardClass == CraftsmenWard;
	}

	public static function score(model:Model, patch:Patch, wardClass:Class<Ward>):Float {
		if (patch.isWater) return Math.POSITIVE_INFINITY;
		var centre = patch.shape.centroid;
		var distance = Point.distance(centre, model.center);
		var water = coastal(model, patch);
		var gate = nearestGate(model, centre);

		if (wardClass == Docks) return water ? distance * 0.3 - model.economy.trade * 25 : Math.POSITIVE_INFINITY;
		if (wardClass == Mine) return -patch.elevation * 40 + distance * 0.08 - model.economy.ore * 25;
		if (wardClass == Lumberyard) return -distance * 0.2 + patch.elevation * 8 - model.economy.timber * 20;
		if (wardClass == Waystation) return gate * 0.4 - model.economy.trade * 15;
		if (wardClass == Market || wardClass == MerchantWard)
			return distance * 0.12 - (water ? model.economy.trade * 20 : 0);
		if (wardClass == MilitaryWard) return gate * 0.22 - model.economy.defence * 18;
		if (wardClass == Cathedral) return distance * 0.15 - model.economy.faith * 20;
		if (wardClass == CraftsmenWard)
			return distance * 0.06 - model.economy.ore * 5 - model.economy.timber * 5;
		return 0;
	}

	public static function finish(model:Model):Void {
		for (patch in model.patches) {
			patch.waterAccess = !patch.isWater && coastal(model, patch);
			patch.roadAccess = !patch.isWater && connectedToRoad(model, patch);
			var label = patch.ward == null ? null : patch.ward.getLabel();
			patch.economicRole = if (patch.isWater) "water" else if (label == null) "undeveloped" else switch (label) {
				case "Docks": model.origin == Origin.FISHING_VILLAGE ? "fishing" : "trade";
				case "Farm": "food";
				case "Mine": "ore";
				case "Lumberyard": "timber";
				case "Market", "Merchant": "trade";
				case "Waystation", "Gate": "transport";
				case "Military", "Castle": "defence";
				case "Cathedral", "Temple": "faith";
				case "Craftsmen": "crafts";
				case "Park", "Well", "Gallows": "civic";
				case "Administration": "administration";
				case "Ruins": "ruins";
				default: "housing";
			};
		}
	}

	private static function coastal(model:Model, patch:Patch):Bool {
		if (patch.isWater) return false;
		for (other in model.getNeighbours(patch)) if (other.isWater) return true;
		return false;
	}

	private static function nearestGate(model:Model, position:Point):Float {
		var best = Math.POSITIVE_INFINITY;
		if (model.gates != null)
			for (gate in model.gates) best = Math.min(best, Point.distance(position, gate));
		return best == Math.POSITIVE_INFINITY ? Point.distance(position, model.center) : best;
	}

	private static function connectedToRoad(model:Model, patch:Patch):Bool {
		for (network in [model.arteries, model.secondary, model.streets, model.roads]) {
			if (network == null) continue;
			for (road in network) {
				if (road == null || road.length == 0) continue;
				if (road.length == 1 && patch.shape.containsPoint(road[0])) return true;
				for (i in 1...road.length)
					if (patch.shape.intersectsSegment(road[i - 1], road[i])) return true;
			}
		}
		return false;
	}
}
