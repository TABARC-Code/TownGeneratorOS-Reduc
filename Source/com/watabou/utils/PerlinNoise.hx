package com.watabou.utils;

class PerlinNoise {
	private static var permutation = [
		151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
		190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,
		20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,
		230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,216,80,73,209,76,132,187,208,89,18,
		169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,64,52,217,226,250,124,123,5,202,38,
		147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,
		2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,98,108,110,79,113,224,232,178,185,
		112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241,81,51,145,235,249,14,239,107,
		49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,127,4,150,254,138,236,205,93,222,114,
		67,29,24,72,243,141,128,195,78,66,215,61,156,180
	];

	private var p:Array<Int>;

	public function new(seed:Int) {
		var offset = wrap(seed);
		p = [for (i in 0...256) permutation[(i + offset) % 256]];
	}

	private static inline function wrap(n:Int):Int {
		return (n % 256 + 256) % 256;
	}

	private static inline function fade(t:Float):Float {
		return t * t * t * (t * (t * 6 - 15) + 10);
	}

	private static inline function dot(hash:Int, x:Float, y:Float):Float {
		return switch (hash & 3) {
			case 0: x + y;
			case 1: x - y;
			case 2: -x + y;
			case 3: -x - y;
			default: 0;
		};
	}

	private static inline function mix(a:Float, b:Float, t:Float):Float {
		return a + (b - a) * t;
	}

	public function noise(x:Float, y:Float, gridSize:Float=1):Float {
		x *= gridSize;
		y *= gridSize;
		var x0 = Math.floor(x);
		var y0 = Math.floor(y);
		var fx = x - x0;
		var fy = y - y0;
		var ix = wrap(Std.int(x0));
		var iy = wrap(Std.int(y0));
		var ix1 = wrap(ix + 1);
		var iy1 = wrap(iy + 1);

		var aa = p[wrap(p[ix] + iy)];
		var ab = p[wrap(p[ix1] + iy)];
		var ba = p[wrap(p[ix] + iy1)];
		var bb = p[wrap(p[ix1] + iy1)];

		var sx = fade(fx);
		var sy = fade(fy);
		var lower = mix(dot(aa, fx, fy), dot(ab, fx - 1, fy), sx);
		var upper = mix(dot(ba, fx, fy - 1), dot(bb, fx - 1, fy - 1), sx);
		return mix(lower, upper, sy);
	}

	public function noiseMap(width:Int, height:Int, gridSize:Float=1):Array<Array<Float>> {
		return [for (y in 0...height) [for (x in 0...width)
			noise(x * gridSize / width, y * gridSize / height)]];
	}

	public function noiseHigh(x:Float, y:Float, octaves:Int, gridSize:Float=1, persistence:Float=0.5):Float {
		var total = 0.0;
		var amplitude = 1.0;
		var frequency = gridSize;
		var normaliser = 0.0;
		for (i in 0...octaves) {
			total += noise(x, y, frequency) * amplitude;
			normaliser += amplitude;
			amplitude *= persistence;
			frequency *= 2;
		}
		return normaliser == 0 ? 0 : total / normaliser;
	}

	public function noiseMapHigh(width:Int, height:Int, octaves:Int, gridSize:Float=1, persistence:Float=0.5):Array<Array<Float>> {
		return [for (y in 0...height) [for (x in 0...width)
			noiseHigh(x / width, y / height, octaves, gridSize, persistence)]];
	}
}
