package com.watabou.towngenerator.mapping;

class Palette {

	public var paper	: Int;
	public var light	: Int;
	public var medium	: Int;
	public var dark		: Int;

	public inline function new( paper, light, medium, dark ) {
		this.paper	= paper;
		this.light	= light;
		this.medium	= medium;
		this.dark	= dark;
	}

	public static var DEFAULT	= new Palette( 0xccc5b8, 0x99948a, 0x67635c, 0x1a1917 );
	public static var BLUEPRINT	= new Palette( 0x455b8d, 0x7383aa, 0xa1abc6, 0xfcfbff );
	public static var BW		= new Palette( 0xffffff, 0xcccccc, 0x888888, 0x000000 );
	public static var INK		= new Palette( 0xcccac2, 0x9a979b, 0x6c6974, 0x130f26 );
	public static var NIGHT		= new Palette( 0x000000, 0x402306, 0x674b14, 0x99913d );
	public static var ANCIENT	= new Palette( 0xccc5a3, 0xa69974, 0x806f4d, 0x342414 );
	public static var COLOUR	= new Palette( 0xfff2c8, 0xd6a36e, 0x869a81, 0x4c5950 );
	public static var ELVEN		= new Palette( 0xf3f7e9, 0xb9d3a6, 0x5a7f62, 0x1f2b24 );
	public static var DWARVEN	= new Palette( 0xe6e2d8, 0xb6ada0, 0x6f6a64, 0x1a1a1a );
	public static var ORC		= new Palette( 0xd8d0b6, 0xa9a07a, 0x5d5a3b, 0x1a1a0f );
	public static var MARSHY	= new Palette( 0xe8efde, 0xa7b39a, 0x5a6b59, 0x1c231d );
	public static var SIMPLE	= new Palette( 0xffffff, 0x000000, 0x000000, 0x000000 );

	public static function forCulture(c:com.watabou.towngenerator.building.Culture):Palette {
		return switch (c) {
			case com.watabou.towngenerator.building.Culture.DARK_AGES: INK;
			case com.watabou.towngenerator.building.Culture.EUROPEAN_MEDIEVAL: DEFAULT;
			case com.watabou.towngenerator.building.Culture.HIGH_MEDIEVAL_CITY: DEFAULT;
			case com.watabou.towngenerator.building.Culture.RENAISSANCE_CITY: COLOUR;

			case com.watabou.towngenerator.building.Culture.SAXON: ANCIENT;
			case com.watabou.towngenerator.building.Culture.VIKING: INK;

			case com.watabou.towngenerator.building.Culture.IMPERIAL: BLUEPRINT;
			case com.watabou.towngenerator.building.Culture.MERCHANT_REPUBLIC: COLOUR;
			case com.watabou.towngenerator.building.Culture.INDUSTRIAL: DWARVEN;
			case com.watabou.towngenerator.building.Culture.FRONTIER: ANCIENT;
			case com.watabou.towngenerator.building.Culture.RUINED: NIGHT;

			case com.watabou.towngenerator.building.Culture.AFRICAN: COLOUR;
			case com.watabou.towngenerator.building.Culture.TRIBAL: NIGHT;
			case com.watabou.towngenerator.building.Culture.BARBARIAN: ANCIENT;
			case com.watabou.towngenerator.building.Culture.NOMAD: BW;
			case com.watabou.towngenerator.building.Culture.MARSH: MARSHY;
			case com.watabou.towngenerator.building.Culture.TENT: BW;

			case com.watabou.towngenerator.building.Culture.ELVEN_HIGH: ELVEN;
			case com.watabou.towngenerator.building.Culture.ELVEN_WOOD: ELVEN;
			case com.watabou.towngenerator.building.Culture.ELVEN_DARK: INK;
			case com.watabou.towngenerator.building.Culture.DWARVEN_HOLD: DWARVEN;
			case com.watabou.towngenerator.building.Culture.ORCINOID: ORC;
			case com.watabou.towngenerator.building.Culture.RELIGIOUS_ENCLAVE: DEFAULT;

			default: DEFAULT;
		}
	}
}
