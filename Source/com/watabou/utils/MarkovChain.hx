package com.watabou.utils;

using com.watabou.utils.ArrayExtender;

class MarkovChain<T> {

	private var table	: Map<T, FollowUp<T>>;

	public function new() {
		table = new Map();
	}

	public function addSample( sample:Array<T> ) {
		var prev:T = null;
		for (i in 0...sample.length) {
			var cur = sample[i];
			addCase( prev, cur );
			prev = cur;
		}
		addCase( prev, null );
	}

	private function addCase( a:T, b:T ) {
		var followUp = table[a];
		if (followUp == null)
			followUp = table[a] = new FollowUp<T>();

		followUp.observe( b );
	}

	public function generate():Array<T> {
		var result:Array<T> = [];

		var state:T = null;
		var remaining = 1000;
		while (remaining-- > 0) {
			var next = getNext(state);
			if (next == null || isTerminal(next)) break;
			result.push(next);
			state = next;
		}

		return result;
	}

	public function getNext(a:T):T {
		var followUp = table.get(a);
		return followUp == null ? null : followUp.get();
	}

	public var isTerminal = function(state:T) { return state == null; };
}

private class FollowUp<T> {
	public var states	: Array<T> = [];
	public var weights	: Array<Float> = [];

	public function new() {};

	public function observe( state:T ) {
		var index = states.indexOf( state );
		if (index == -1) {
			states.push( state );
			weights.push( 1 );
		} else
			weights[index]++;
	}

	public function get():T return states.weighted( weights );
}

