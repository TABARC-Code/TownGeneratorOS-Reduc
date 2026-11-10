package com.watabou.towngenerator.io;

import openfl.geom.Point;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.building.Patch;
import com.watabou.utils.NameGenerator;

class Exporter {
	public static function toJSON( model:Model ):String {
		// Index patches for adjacency lists
		var indexOf = new Map<Patch, Int>();
		for (i in 0...model.patches.length) indexOf.set(model.patches[i], i);

		var data:Dynamic = {
			seed: model.seed,
			size: model.size,
			cityName: NameGenerator.cityName(model.seed, model.culture),
			culture: model.culture,
			origin: model.origin,
			radius: model.cityRadius,
			economy: {
				food: model.economy.food, timber: model.economy.timber,
				ore: model.economy.ore, fishing: model.economy.fishing,
				trade: model.economy.trade, defence: model.economy.defence,
				faith: model.economy.faith
			},
			districts: [],
			roads: [],
			bridges: [],
			streets: [],
			arteries: [],
			secondary: [],
			alleys: [],
			gates: [],
			walls: null,
			oldWall: null,
			citadelWall: null,
			hamlets: []
		};

		for (patch in model.patches) {
			var verts = [];
			for (p in patch.shape) verts.push({x: p.x, y: p.y});

			var isWater:Bool = patch.isWater;
			var elev:Float = patch.elevation;

			var neigh = [];
			for (n in model.getNeighbours(patch)) {
				if (indexOf.exists(n)) neigh.push(indexOf.get(n));
			}

			var type = patch.ward != null ? patch.ward.getLabel() : (isWater ? "Water" : null);
			var name = (type != null) ? ((patch.districtName != null) ? patch.districtName : NameGenerator.districtName(type, patch.shape.centroid)) : null;

			var features = [];
			if (patch.ward != null && patch.ward.geometry != null) {
				for (j in 0...patch.ward.geometry.length) {
					var points = [];
					for (v in patch.ward.geometry[j]) points.push({x: v.x, y: v.y});
					features.push({id: "p" + indexOf.get(patch) + "-f" + j, vertices: points});
				}
			}

			data.districts.push({
				index: indexOf.get(patch),
				type: type,
				name: name,
				vertices: verts,
				centroid: {x: patch.shape.centroid.x, y: patch.shape.centroid.y},
				elevation: elev,
				wealth: patch.wealth,
				decay: patch.decay,
				isWater: isWater,
				waterKind: patch.waterKind,
				economicRole: patch.economicRole,
				waterAccess: patch.waterAccess,
				roadAccess: patch.roadAccess,
				withinCity: patch.withinCity,
				withinWalls: patch.withinWalls,
				neighbours: neigh,
				features: features
			});
		}

		if (model.bridges != null)
			for (i in 0...model.bridges.length)
				data.bridges.push({index: i, points: [for (v in model.bridges[i]) {x:v.x, y:v.y}]});

		// Outer roads, city streets and their joined street network.
		if (model.roads != null) {
			for (i in 0...model.roads.length) {
				var road = model.roads[i];
				var pts = [];
				for (p in road) pts.push({x:p.x, y:p.y});
				data.roads.push({
					name: NameGenerator.streetName(i, model.seed),
					points: pts
				});
			}
		}

		if (model.streets != null)
			for (i in 0...model.streets.length)
				data.streets.push({name: NameGenerator.streetName(200 + i, model.seed), points: [for (p in model.streets[i]) {x:p.x, y:p.y}]});
		if (model.arteries != null)
			for (i in 0...model.arteries.length)
				data.arteries.push({index: i, points: [for (p in model.arteries[i]) {x:p.x, y:p.y}]});
		if (model.slumStubs != null)
			for (i in 0...model.slumStubs.length)
				data.alleys.push({index: i, points: [for (p in model.slumStubs[i]) {x:p.x, y:p.y}]});

		// Secondary streets (if present)
		if (model.secondary != null) {
			for (i in 0...model.secondary.length) {
				var s = model.secondary[i];
				var pts = [];
				for (p in s) pts.push({x:p.x, y:p.y});
				data.secondary.push({
					name: NameGenerator.streetName(100 + i, model.seed),
					points: pts
				});
			}
		}

		if (model.gates != null)
			for (g in model.gates) data.gates.push({x: g.x, y: g.y});
		if (model.wall != null)
			data.walls = [for (v in model.wall.shape) {x: v.x, y: v.y}];
		if (model.oldWall != null)
			data.oldWall = [for (v in model.oldWall.shape) {x: v.x, y: v.y}];
		if (model.citadel != null && model.citadel.ward != null) {
			var castle:com.watabou.towngenerator.wards.Castle = cast model.citadel.ward;
			data.citadelWall = [for (v in castle.wall.shape) {x: v.x, y: v.y}];
		}
		if (model.hamlets != null)
			for (p in model.hamlets) data.hamlets.push(indexOf.get(p));

		return haxe.Json.stringify(data);
	}
}
