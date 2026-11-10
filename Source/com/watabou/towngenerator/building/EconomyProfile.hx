package com.watabou.towngenerator.building;

class EconomyProfile {
	public var food:Float;
	public var timber:Float;
	public var ore:Float;
	public var fishing:Float;
	public var trade:Float;
	public var defence:Float;
	public var faith:Float;

	public function new(food:Float, timber:Float, ore:Float, fishing:Float, trade:Float, defence:Float, faith:Float) {
		this.food = food;
		this.timber = timber;
		this.ore = ore;
		this.fishing = fishing;
		this.trade = trade;
		this.defence = defence;
		this.faith = faith;
	}
}
