package com.watabou.towngenerator.building;

import openfl.geom.Point;
import com.watabou.utils.PerlinNoise;
import com.watabou.utils.Random;

using com.watabou.utils.ArrayExtender;

class Hydrology {
	// Work on existing outer patches. Nothing is deleted from the street topology.
	public static function apply(model:Model, seed:Int):Void {
		model.waterbody = [];
		var noise = new PerlinNoise(seed);
		for (p in model.patches) {
			p.isWater = false;
			p.waterKind = null;
			var c = p.shape.centroid;
			p.elevation = noise.noiseHigh(c.x / 320, c.y / 320, 3);
		}

		var isPort = model.origin == Origin.FISHING_VILLAGE || model.origin == Origin.RIVER_PORT;
		if (model.patches.length < 12 && !isPort) return;

		var outer = model.patches.filter(function(p:Patch) return !p.withinCity);
		if (outer.length == 0) return;

		var angle = Random.float() * Math.PI * 2;
		var direction = new Point(Math.cos(angle), Math.sin(angle));
		var coastMin = model.border.getRadius() * 1.6;
		var selected:Array<Patch> = [];
		for (p in outer) {
			var c = p.shape.centroid;
			if (c.length > coastMin && c.x * direction.x + c.y * direction.y > 0)
				selected.push(p);
		}
		if (selected.length == 0 && isPort)
			selected.push(outer.max(function(p:Patch)
				return p.shape.centroid.x * direction.x + p.shape.centroid.y * direction.y));
		if (selected.length == 0) return;

		// Keep one connected sea rather than sprinkling unrelated water patches.
		var coastStart = selected.max(function(p:Patch)
			return p.shape.centroid.x * direction.x + p.shape.centroid.y * direction.y);
		var visited:Array<Patch> = [coastStart];
		var head = 0;
		while (head < visited.length) {
			var p = visited[head++];
			markWater(model, p, "sea");
			for (next in model.getNeighbours(p))
				if (selected.contains(next) && !visited.contains(next)) visited.push(next);
		}

		if (isPort) {
			var landings = outer.filter(function(p:Patch) {
				if (p.isWater) return false;
				for (n in model.getNeighbours(p))
					if (n.withinCity && n != model.plaza && n != model.citadel) return true;
				return false;
			});
			if (landings.length > 0) {
				var landing = landings.max(function(p:Patch)
					return p.shape.centroid.x * direction.x + p.shape.centroid.y * direction.y);
				var course = channel(model, landing, function(p:Patch) return p.isWater);
				if (course.length > 0)
					for (p in course) if (!p.isWater) markWater(model, p, "river");
			}
		}

		// A tributary has to meet existing water, or it isn't drawn at all.
		if (model.patches.length >= 30 && (model.origin == Origin.RIVER_PORT || Random.bool(0.55))) {
			var candidates = outer.filter(function(p:Patch) return !p.isWater);
			if (candidates.length > 0) {
				var source = candidates.max(function(p:Patch) return p.elevation);
				var course = channel(model, source, function(p:Patch) return p.isWater);
				if (course.length > 2)
					for (p in course) if (!p.isWater) markWater(model, p, "river");
			}
		}
	}

	private static function markWater(model:Model, p:Patch, kind:String):Void {
		if (p == null || p.withinCity || p == model.plaza || p == model.citadel || p.isWater) return;
		p.isWater = true;
		p.waterKind = kind;
		model.waterbody.push(p);
	}

	// Shortest navigable course over the patch graph, with uphill travel penalised.
	private static function channel(model:Model, start:Patch, reaches:Patch->Bool):Array<Patch> {
		if (start == null) return [];
		var distances = new Map<Patch, Float>();
		var previous = new Map<Patch, Patch>();
		var pending:Array<Patch> = [start];
		var settled = new Map<Patch, Bool>();
		distances.set(start, 0);
		var end:Patch = null;

		while (pending.length > 0) {
			var index = 0;
			for (i in 1...pending.length)
				if (distances.get(pending[i]) < distances.get(pending[index])) index = i;
			var current = pending.splice(index, 1)[0];
			if (settled.exists(current)) continue;
			settled.set(current, true);
			if (reaches(current)) { end = current; break; }

			for (next in model.getNeighbours(current)) {
				if (next.withinCity || settled.exists(next) || next == model.plaza || next == model.citadel) continue;
				var climb = Math.max(0, next.elevation - current.elevation);
				var step = 1 + climb * 12;
				var distance = distances.get(current) + step;
				if (!distances.exists(next) || distance < distances.get(next)) {
					distances.set(next, distance);
					previous.set(next, current);
					if (!pending.contains(next)) pending.push(next);
				}
			}
		}
		if (end == null) return [];
		var course:Array<Patch> = [end];
		while (previous.exists(end)) {
			end = previous.get(end);
			course.unshift(end);
		}
		return course;
	}
}
