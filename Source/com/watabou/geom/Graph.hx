package com.watabou.geom;

using com.watabou.utils.ArrayExtender;

class Graph {

	public var nodes : Array<Node> = [];
	private var nextOrder:Int = 0;
	private var members:Map<Node, Bool> = new Map();

	public function new() {
	}

	public function add( node:Node=null ):Node {
		if (node == null) {
			node = new Node();
		}
		if (members.exists(node)) return node;
		node.order = nextOrder++;
		nodes.push( node );
		members.set(node, true);
		return node;
	}

	public function remove( node:Node ):Void {
		if (node == null || !members.exists(node)) return;
		for (other in nodes) if (other != node) other.links.remove(node);
		node.links = new Map();
		nodes.remove(node);
		members.remove(node);
	}

	// Dijkstra is sufficient here: all links have non-negative movement costs.
	public function aStar(start:Node, goal:Node, exclude:Array<Node>=null):Array<Node> {
		if (start == null || goal == null || !members.exists(start) || !members.exists(goal)) return null;

		var excluded = new Map<Node, Bool>();
		if (exclude != null)
			for (node in exclude) excluded.set(node, true);
		if (excluded.exists(start) || excluded.exists(goal)) return null;
		if (start == goal) return [start];

		var visited = new Map<Node, Bool>();
		var scores = new Map<Node, Float>();
		var previous = new Map<Node, Node>();
		var pending:Array<Node> = [start];
		scores.set(start, 0);

		while (pending.length > 0) {
			var best = 0;
			for (i in 1...pending.length)
				if (scores.get(pending[i]) < scores.get(pending[best])) best = i;
			var current = pending.splice(best, 1)[0];
			if (current == goal) return buildPath(previous, current);
			if (visited.exists(current)) continue;
			visited.set(current, true);

			var neighbours:Array<Node> = [for (neighbour in current.links.keys()) neighbour];
			neighbours.sort(function(a, b) return a.order - b.order);
			for (neighbour in neighbours) {
				if (!members.exists(neighbour) || visited.exists(neighbour) || excluded.exists(neighbour)) continue;
				var length = current.links.get(neighbour);
				if (Math.isNaN(length) || length < 0 || length == Math.POSITIVE_INFINITY) continue;
				var score = scores.get(current) + length;
				if (!scores.exists(neighbour) || score < scores.get(neighbour)) {
					scores.set(neighbour, score);
					previous.set(neighbour, current);
					if (pending.indexOf(neighbour) == -1) pending.push(neighbour);
				}
			}
		}
		return null;
	}

	private function buildPath(previous:Map<Node, Node>, end:Node):Array<Node> {
		var path = [end];
		while (previous.exists(end)) {
			end = previous.get(end);
			path.unshift(end);
		}
		return path;
	}

	public function calculatePrice(path:Array<Node>):Float {
		if (path == null) return Math.NaN;
		var price = 0.0;
		for (i in 1...path.length) {
			var source = path[i - 1];
			var target = path[i];
			if (source == null || target == null || !members.exists(source) || !members.exists(target) || !source.links.exists(target)) return Math.NaN;
			price += source.links.get(target);
		}
		return price;
	}

}

class Node {
	public var links : Map<Node, Float> = new Map();
	public var order:Int = -1;

	public function new() {}

	public function link( node:Node, price:Float=1, symmetrical:Bool=true ) {
		if (node == null || Math.isNaN(price) || price < 0 || price == Math.POSITIVE_INFINITY)
			throw 'Invalid graph edge';
		links.set( node, price );
		if (symmetrical) {
			node.links.set( this, price );
		}
	}

	public function unlink( node:Node, symmetrical=true ):Void {
		links.remove( node );
		if (symmetrical) {
			node.links.remove( this );
		}
	}

	public function unlinkAll():Void {
		var neighbours = [for (node in links.keys()) node];
		for (node in neighbours) unlink(node);
	}
}
