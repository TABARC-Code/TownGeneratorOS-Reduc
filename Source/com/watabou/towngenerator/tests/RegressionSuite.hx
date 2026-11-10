package com.watabou.towngenerator.tests;

import com.watabou.towngenerator.StateManager;
import com.watabou.towngenerator.building.Culture;
import com.watabou.towngenerator.building.Origin;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.io.Exporter;
import com.watabou.utils.PerlinNoise;

class RegressionSuite {
	private static function check(ok:Bool, description:String):Void {
		if (!ok) throw description;
	}

	public static function main():Void {
		var cultures:Array<Culture> = [Culture.MEDIEVAL, Culture.VIKING, Culture.TRIBAL, Culture.DWARVEN_HOLD];
		var origins = Origin.order();
		var sizes = [6, 15];
		var args = Sys.args();
		if (args.indexOf("full") >= 0) {
			cultures = [
				Culture.MEDIEVAL, Culture.EUROPEAN_MEDIEVAL, Culture.DARK_AGES,
				Culture.HIGH_MEDIEVAL_CITY, Culture.RENAISSANCE_CITY,
				Culture.SAXON, Culture.VIKING, Culture.IMPERIAL,
				Culture.MERCHANT_REPUBLIC, Culture.INDUSTRIAL, Culture.FRONTIER,
				Culture.RUINED, Culture.AFRICAN, Culture.TRIBAL,
				Culture.BARBARIAN, Culture.NOMAD, Culture.MARSH,
				Culture.TENT, Culture.ELVEN_HIGH, Culture.ELVEN_WOOD,
				Culture.ELVEN_DARK, Culture.DWARVEN_HOLD,
				Culture.ORCINOID, Culture.RELIGIOUS_ENCLAVE
			];
			sizes = [6, 10, 15, 24, 40];
		}

		var noise = new PerlinNoise(1739);
		for (x in [-310.7, -1.25, -0.01, 0.0, 0.75, 219.9])
			for (y in [-130.25, -0.25, 0.0, 24.5]) {
				var n = noise.noiseHigh(x, y, 3);
				check(!Math.isNaN(n) && Math.abs(n) < 2, "Invalid noise at negative coordinates");
			}

		var cases = 0;
		for (culture in cultures)
			for (origin in origins)
				for (size in sizes) {
					StateManager.culture = culture;
					StateManager.origin = origin;
					StateManager.size = size;
					StateManager.seed = 384127;
					var first = new Model(size, StateManager.seed);
					check(first.patches.length > 0, "No patches");
					check(first.cityRadius > 0, "Invalid city radius");
					for (p in first.patches) {
						for (n in first.getNeighbours(p))
							check(first.getNeighbours(n).contains(p), "Asymmetric patch adjacency");
						check(p.shape != null && p.shape.length >= 3, "Broken patch");
						check(!Math.isNaN(p.elevation) && Math.abs(p.elevation) < 2, "Invalid elevation");
						check(!p.isWater || (p.ward != null && p.ward.getLabel() == "Water"), "Water contains a ward");
						check(!p.isWater || !p.withinCity, "Flooded city district");
						check(p.economicRole != null, "Missing economic classification");
						if (p.isWater) check(p.waterKind == "sea" || p.waterKind == "river", "Missing water classification");
					}
					if (first.waterbody.length > 0) {
						var found = [first.waterbody[0]];
						var head = 0;
						while (head < found.length) {
							for (next in first.getNeighbours(found[head++]))
								if (next.isWater && !found.contains(next)) found.push(next);
						}
						check(found.length == first.waterbody.length, "Disconnected water network");
					}
					var json = Exporter.toJSON(first);
					check(first.seed == StateManager.seed && first.size == size, "Model settings changed");
					check(json.length > 50, "Empty JSON");
					var parsed:Dynamic = haxe.Json.parse(json);
					check(parsed != null && parsed.economy != null, "Invalid economic export");
					check(parsed.bridges != null, "Missing bridge export");
					check(first.economy != null, "Missing economic profile");
					for (bridge in first.bridges) {
						check(bridge.length == 2, "Broken crossing");
						var mid = new openfl.geom.Point((bridge[0].x + bridge[1].x) / 2,
							(bridge[0].y + bridge[1].y) / 2);
						var crosses = false;
						for (water in first.waterbody) if (water.shape.containsPoint(mid)) { crosses = true; break; }
						check(crosses, "Crossing misses water");
					}
					new Model(size, StateManager.seed);
					check(json == Exporter.toJSON(Model.instance), "Same seed changed the output");
					cases++;
				}
		trace("Checked " + cases + " settlement combinations");
	}
}
