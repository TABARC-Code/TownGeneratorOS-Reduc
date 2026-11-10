import openfl.geom.Point;
import com.watabou.geom.Graph;
import com.watabou.geom.Graph.Node;
import com.watabou.geom.Polygon;
import com.watabou.towngenerator.StateManager;
import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.io.Exporter;
import com.watabou.utils.NameGenerator;
import com.watabou.utils.PerlinNoise;
import com.watabou.towngenerator.mapping.SvgRenderer;

class Regression {
	static function check(ok:Bool, message:String):Void {
		if (!ok) throw message;
	}

	static function geometry():Void {
		var square = Polygon.rect(20, 10);
		check(square.containsPoint(new Point(0, 0)), "inside rectangle");
		check(square.containsPoint(new Point(10, 0)), "on boundary");
		check(!square.containsPoint(new Point(11, 0)), "outside rectangle");
		check(!square.contains(new Point(0, 0)), "new coordinates are not shared vertices");
		check(square.contains(square[0]), "original vertex identity");

		var concave = new Polygon([
			new Point(0, 0), new Point(8, 0), new Point(8, 8),
			new Point(4, 8), new Point(4, 3), new Point(0, 3)
		]);
		check(concave.containsPoint(new Point(6, 6)), "concave interior");
		check(!concave.containsPoint(new Point(2, 6)), "concave notch");
		check(square.intersectsSegment(new Point(-20, 0), new Point(20, 0)), "road crossing without shared vertices");
		check(square.intersectsSegment(new Point(-20, 5), new Point(20, 5)), "road over boundary");
		check(square.intersectsSegment(new Point(-20, -5), new Point(20, -5)), "road on boundary");
		check(!square.intersectsSegment(new Point(20, 20), new Point(30, 30)), "road outside plot");
		check(!square.intersectsSegment(new Point(-20, 10), new Point(20, 10)), "parallel road away from plot");
		check(concave.intersectsSegment(new Point(2, 6), new Point(7, 6)), "road across concave notch");
		var collinear = new Polygon([new Point(0, 0), new Point(5, 0), new Point(10, 0)]);
		check(!Math.isNaN(collinear.centroid.x) && !Math.isNaN(collinear.centroid.y), "collinear centroid");
		check(Math.abs(collinear.centroid.x - 5) < 0.000001, "collinear centroid average");
		var empty = new Polygon();
		check(empty.centroid.x == 0 && empty.centroid.y == 0, "empty centroid");
	}

	static function paths():Void {
		var graph = new Graph();
		var a = graph.add();
		var b = graph.add();
		var c = graph.add();
		a.link(b, 12);
		a.link(c, 2);
		c.link(b, 3);
		var route = graph.aStar(a, b);
		check(route != null && route.length == 3, "weighted route length");
		check(route[0] == a && route[1] == c && route[2] == b, "shortest route direction");
		check(graph.calculatePrice(route) == 5, "weighted route cost");
		var blocked = graph.aStar(a, b, [c]);
		check(blocked != null && blocked.length == 2, "excluded node");
		check(graph.calculatePrice(blocked) == 12, "direct route cost");
		check(graph.aStar(null, b) == null, "missing endpoint");
		check(graph.aStar(a, a, [a]) == null, "excluded endpoint is not traversable");
		var extra = graph.add();
		var extra2 = graph.add();
		extra.link(a, 1);
		extra.link(b, 1);
		extra.link(extra2, 1);
		graph.remove(extra);
		check(!a.links.exists(extra) && !b.links.exists(extra) && !extra2.links.exists(extra), "node removal clears every reverse link");
		var previousOrder = extra.order;
		var replacement = graph.add();
		check(replacement.order > previousOrder, "graph node order is never reused");
		check(graph.add(replacement) == replacement && graph.nodes.length == 5, "duplicate nodes are ignored");
		var inbound = graph.add();
		var sink = graph.add();
		inbound.link(sink, 4, false);
		check(inbound.links.exists(sink), "one-way link set");
		graph.remove(sink);
		check(!inbound.links.exists(sink), "removal clears incoming one-way links");
		check(graph.aStar(inbound, sink) == null, "removed node is not routable");
		var rejected = false;
		try { inbound.link(b, -1); } catch (e:Dynamic) { rejected = true; }
		check(rejected && !inbound.links.exists(b), "negative edge costs rejected");

		var outsider = new Graph();
		var shortcut = outsider.add();
		a.link(b, 10);
		a.link(shortcut, 1);
		shortcut.link(b, 1);
		var contained = graph.aStar(a, b);
		check(contained != null && contained.indexOf(shortcut) == -1, "paths stay inside the graph");
		check(Math.isNaN(graph.calculatePrice([a, shortcut, b])), "foreign nodes have no path cost");

	}

	static function terrain():Void {
		var noise = new PerlinNoise(29);
		for (x in [-100.25, -3.75, -0.01, 0.0, 0.01, 3.75, 100.25])
			for (y in [-100.5, -1.75, 0.0, 1.75]) {
				var value = noise.noise(x, y);
				check(!Math.isNaN(value) && Math.abs(value) < 2, "noise across both axes");
			}
		check(Math.abs(noise.noise(-1.25, 2.75) - noise.noise(254.75, 2.75)) < 0.00001,
			"negative and positive octave wrapping");
	}

	static function svg():Void {
		var renderer = new SvgRenderer();
		renderer.setViewBox(-20, -20, 40, 40);
		renderer.setBackground(0xFFFFFF);
		renderer.beginGroup("roads");
		renderer.lineStyle(2, 0x123456);
		renderer.moveTo(0, 0);
		renderer.lineTo(10, 10);
		renderer.beginFill(0xABCDEF);
		renderer.drawCircle(3, 3, 2);
		renderer.endFill();
		renderer.endGroup();
		var output = renderer.getOutput();
		var parsed = Xml.parse(output);
		check(parsed.firstElement().nodeName == "svg", "SVG root element");
		check(output.indexOf("<circle") >= 0, "SVG circle outside path");
		check(output.indexOf("</g>") >= 0, "SVG group closes");
	}

	static function settlements():Void {
		var cases = [
			{culture:"medieval", origin:"town", size:6, seed:1001},
			{culture:"viking", origin:"fishing_village", size:10, seed:2027},
			{culture:"dwarven_hold", origin:"mining_camp", size:15, seed:1739},
			{culture:"imperial", origin:"walled_waystation", size:24, seed:3113},
			{culture:"marsh", origin:"river_port", size:15, seed:4049},
			{culture:"elven_wood", origin:"monastery", size:10, seed:5813},
			{culture:"frontier", origin:"timber_camp", size:10, seed:7559},
			{culture:"orcinoid", origin:"fortress", size:15, seed:8641}
		];
		for (test in cases) {
			StateManager.size = test.size;
			StateManager.seed = test.seed + 91;
			StateManager.culture = test.culture;
			StateManager.origin = test.origin;
			var first = new Model(test.size, test.seed);
			StateManager.seed = test.seed;
			check(first.patches.length > test.size, "settlement patches");
			check(first.arteries != null && first.gates != null, "transport network");
			for (patch in first.patches) {
				check(patch.shape != null && patch.shape.length >= 3, "patch geometry");
				check(!Math.isNaN(patch.elevation) && Math.abs(patch.elevation) < 2, "elevation");
				check(patch.economicRole != null, "economic role");
				if (patch.isWater) check(patch.waterKind == "sea" || patch.waterKind == "river", "water classification");
				check(!patch.isWater || !patch.withinCity, "dry city core");
				if (patch.ward != null) check(patch.ward.geometry != null, "ward geometry");
			}
			var firstJSON = Exporter.toJSON(first);
			check(first.seed == test.seed && first.size == test.size, "model settings");
			StateManager.seed = 991991;
			StateManager.size = 40;
			StateManager.culture = "imperial";
			StateManager.origin = "fortress";
			check(Exporter.toJSON(first) == firstJSON, "export must use model settings");
			StateManager.seed = test.seed;
			StateManager.size = test.size;
			StateManager.culture = test.culture;
			StateManager.origin = test.origin;
			var second = new Model(test.size, test.seed);
			var secondJSON = Exporter.toJSON(second);
			check(firstJSON == secondJSON, "seed stability: " + test.culture + "/" + test.origin);
			var data:Dynamic = haxe.Json.parse(firstJSON);
			check(data.seed == test.seed && data.size == test.size, "export seed and size");
			check(data.arteries != null && data.streets != null && data.gates != null, "export sections");
			check(data.economy != null && data.bridges != null, "economy and bridges exported");
			for (bridge in first.bridges) {
				check(bridge.length == 2, "crossing length");
				var midpoint = new Point((bridge[0].x + bridge[1].x) / 2,
					(bridge[0].y + bridge[1].y) / 2);
				var wet = false;
				for (water in first.waterbody) if (water.shape.containsPoint(midpoint)) { wet = true; break; }
				check(wet, "crossing through water");
			}
		}
		check(NameGenerator.cityName(42, "viking") == NameGenerator.cityName(42, "viking"), "name stability");
	}

	static function main():Void {
		geometry();
		paths();
		terrain();
		svg();
		settlements();
		trace("Geometry, routes and settlement seeds passed");
	}
}
