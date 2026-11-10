package com.watabou.towngenerator.building;

import openfl.geom.Point;

import com.watabou.geom.GeomUtils;
import com.watabou.geom.Polygon;
import com.watabou.utils.Random;
import com.watabou.towngenerator.wards.Ward;
import com.watabou.towngenerator.building.Culture;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

/**
 * Extra shape generators for wards.
 *
 * This project intentionally avoids heavy polygon boolean/clipping libs, so
 * complex shapes are typically represented as multi-polygons.
 */
class Architect {

    public static function makeCourtyardBuilding(poly:Polygon, wallThickness:Float):Array<Polygon> {
        var holePoly = poly.shrinkEq(wallThickness);
        if (holePoly != null && holePoly.square > 10) return Cutter.ring(poly, wallThickness);
        return [poly];
    }

    public static function makeGrid(poly:Polygon, step:Float):Array<Polygon> {
        var bounds = poly.getBounds();
        var buildings:Array<Polygon> = [];

        var x = bounds.left;
        while (x < bounds.right) {
            var y = bounds.top;
            while (y < bounds.bottom) {
                var rect = Polygon.rect(step * 0.8, step * 0.8);
                rect.offset(new Point(x + step / 2, y + step / 2));
                if (poly.containsPoint(rect.center)) buildings.push(rect);
                y += step;
            }
            x += step;
        }
        return buildings;
    }

    public static function makeShantytown(poly:Polygon, density:Int):Array<Polygon> {
        var buildings:Array<Polygon> = [];
        var bounds = poly.getBounds();

        for (i in 0...density) {
            var attempt = 0;
            while (attempt < 10) {
                var px = bounds.left + Random.float() * bounds.width;
                var py = bounds.top + Random.float() * bounds.height;
                var p = new Point(px, py);
                if (poly.containsPoint(p)) {
                    var w = 2 + Random.float() * 3;
                    var h = 2 + Random.float() * 3;
                    var shanty = Polygon.rect(w, h);
                    shanty.rotate(Random.float() * Math.PI);
                    shanty.offset(p);
                    buildings.push(shanty);
                    break;
                }
                attempt++;
            }
        }
        return buildings;
    }

    /**
     * Converts a citadel blob into a star fort + keep.
     */
    public static function makeStarFort(poly:Polygon):Array<Polygon> {
        var c = poly.centroid;

        var points = Random.int(5, 8);
        var radius = Math.sqrt(poly.square / Math.PI) * 0.8;
        var innerRadius = radius * 0.5;

        var starVerts = new Array<Point>();
        var angleStep = (Math.PI * 2) / points;

        for (i in 0...points) {
            var a = i * angleStep;
            starVerts.push(new Point(c.x + Math.cos(a) * radius, c.y + Math.sin(a) * radius));

            var a2 = a + angleStep / 2;
            starVerts.push(new Point(c.x + Math.cos(a2) * innerRadius, c.y + Math.sin(a2) * innerRadius));
        }

        // Central keep: regular polygon approximates a circle.
        var keep = Polygon.regular(8, innerRadius * 0.5);
        keep.offset(c);

        return [new Polygon(starVerts), keep];
    }

    /**
     * Foreshore / beach band along a water edge.
     * This is purely visual: a thin ring that the renderer can draw lighter than land.
     */
    public static function makeForeshore(poly:Polygon, thickness:Float):Array<Polygon> {
        if (thickness <= 0) return [];
        // Cutter.ring returns a set of polygons representing the band.
        return Cutter.ring(poly, thickness);
    }

    /**
     * Generates a quay + piers for docks.
     *
     * Output:
     * - Quay rectangles along coastline edges (slightly inland)
     * - Piers orthogonal to the coastline
     * - Small warehouses at the base
     */
    public static function makePiers(landPatch:com.watabou.towngenerator.building.Patch, model:com.watabou.towngenerator.building.Model):Array<Polygon> {
        var out:Array<Polygon> = [];

        var waterNeighbors = model.getNeighbours(landPatch).filter(function(p) return p.isWater);
        if (waterNeighbors.length == 0) return makeShantytown(landPatch.shape, 5);

        var shape = landPatch.shape;

        // Gather coastline edges
        var coastEdges = new Array<{a:Point, b:Point, normal:Point, mid:Point}>();

        for (i in 0...shape.length) {
            var a = shape[i];
            var b = shape[(i + 1) % shape.length];
            var mid = new Point((a.x + b.x) / 2, (a.y + b.y) / 2);

            var touchesWater = false;
            for (wn in waterNeighbors) {
                if (wn.shape.findEdge(b, a) != -1 || wn.shape.findEdge(a, b) != -1) {
                    touchesWater = true;
                    break;
                }
            }
            if (!touchesWater) continue;

            // Edge outward normal
            var dx = b.x - a.x;
            var dy = b.y - a.y;
            var normal = new Point(-dy, dx);
            normal.normalize(1);

            // Point it away from land centroid
            var toCenter = landPatch.shape.centroid.subtract(mid);
            if (toCenter.dot(normal) > 0) {
                normal.x = -normal.x;
                normal.y = -normal.y;
            }

            coastEdges.push({a:a, b:b, normal:normal, mid:mid});
        }

        if (coastEdges.length == 0) return makeShantytown(landPatch.shape, 5);

        // Quay: draw a short rectangle along each coastline edge (slightly inland)
        for (e in coastEdges) {
            var edgeLen = Point.distance(e.a, e.b);
            if (edgeLen < 4) continue;
            var quayDepth = 2.0 + Random.float() * 1.0;
            var quayLen = edgeLen * 0.85;

            var quay = Polygon.rect(quayDepth, quayLen);
            // Rotate to edge direction
            var ang = Math.atan2(e.b.y - e.a.y, e.b.x - e.a.x);
            quay.rotate(ang + Math.PI / 2); // rect is (w,h) with h "up" by default in this lib
            // Push slightly inland (opposite of outward normal)
            var inset = e.normal.clone();
            inset.x = -inset.x; inset.y = -inset.y;
            inset.normalize(quayDepth * 0.6);
            quay.offset(e.mid.add(inset));
            out.push(quay);

            // Piers off the quay
            if (Random.bool(0.6)) {
                var len = 10 + Random.float() * 10;
                var width = 2 + Random.float();

                var pier = Polygon.rect(width, len);
                pier.rotate(Math.atan2(e.normal.y, e.normal.x) - Math.PI / 2);
                pier.offset(e.mid.add(e.normal.scale(len / 2)));
                out.push(pier);

                var warehouse = Polygon.rect(width * 2, width * 2);
                warehouse.rotate(Math.atan2(e.normal.y, e.normal.x) - Math.PI / 2);
                // Warehouse slightly inland at the base of the pier
                var inland = e.normal.clone(); inland.x = -inland.x; inland.y = -inland.y;
                inland.normalize(width * 1.5);
                warehouse.offset(e.mid.add(inland));
                out.push(warehouse);
            }
        }

        return out;
    }

    /**
     * Medieval strip fields (long thin ribbons).
     *
     * - preferredAngle: if provided, strips are aligned to it (used for coastal alignment).
     * - otherwise we fall back to the longest boundary edge.
     *
     * This returns true strips by repeatedly cutting the polygon with parallel lines.
     */
    public static function makeStripFields(poly:Polygon, ?preferredAngle:Null<Float>):Array<Polygon> {
        var angle = preferredAngle;

        if (angle == null) {
            var maxLen = 0.0;
            var best = 0.0;
            poly.forEdge(function(p1:Point, p2:Point) {
                var d = Point.distance(p1, p2);
                if (d > maxLen) {
                    maxLen = d;
                    best = Math.atan2(p2.y - p1.y, p2.x - p1.x);
                }
            });
            angle = best;
        }

        // We will cut with lines orthogonal to the strip direction.
        var cutAngle = angle + Math.PI / 2;

        // Work on a copy.
        var remaining:Polygon = poly.copy();
        var fields:Array<Polygon> = [];

        // Determine width based on area: larger farms get wider strips.
        var stripWidth = 3.0 + Random.float() * 2.0;

        // Project all points onto the cut normal to know range.
        var nx = Math.cos(cutAngle);
        var ny = Math.sin(cutAngle);
        var minP = 1e20;
        var maxP = -1e20;
        for (p in poly) {
            var proj = p.x * nx + p.y * ny;
            if (proj < minP) minP = proj;
            if (proj > maxP) maxP = proj;
        }

        // Sweep across the polygon
        var p = minP + stripWidth;
        var safety = 0;
        while (p < maxP && safety < 200) {
            safety++;

            // Build a long cutting line (as two far points)
            var cx = nx * p;
            var cy = ny * p;

            // Direction along the cut line
            var dx = -ny;
            var dy = nx;

            var a = new Point(cx - dx * 5000, cy - dy * 5000);
            var b = new Point(cx + dx * 5000, cy + dy * 5000);

            var pieces = remaining.cut(a, b);
            if (pieces == null || pieces.length < 2) {
                p += stripWidth;
                continue;
            }

            // Pick the "near" piece (lower projection) as a field, keep the "far" piece to continue slicing.
            // This is deterministic enough for visual output.
            pieces.sort(function(p1:Polygon, p2:Polygon) {
                return (p1.center.x * nx + p1.center.y * ny) < (p2.center.x * nx + p2.center.y * ny) ? -1 : 1;
            });

            var field = pieces.shift();
            remaining = pieces.pop();

            // Add a small gap between strips
            var shrunk = field.shrinkEq(0.4);
            fields.push(shrunk != null ? shrunk : field);

            p += stripWidth;
        }

        // Final remaining piece as last field
        if (remaining != null && remaining.square > 1) {
            var shr = remaining.shrinkEq(0.4);
            fields.push(shr != null ? shr : remaining);
        }

        // Filter tiny scraps
        return fields.filter(function(f) return f != null && f.square > 5);
    }

    /**
     * Cruciform cathedral: nave + transept + apse (multi-polygons).
     *
     * preferredAngle: if provided, aligns the nave axis to it (used for artery alignment).
     */
    public static function makeCathedral(poly:Polygon, ?preferredAngle:Null<Float>):Array<Polygon> {
        var c = poly.centroid;
        var w = Math.sqrt(poly.square) * 0.6;

        var naveW = w * 0.35;
        var naveL = w * 1.2;
        var nave = Polygon.rect(naveW, naveL);

        var tranW = w * 0.8;
        var tranL = w * 0.32;
        var tran = Polygon.rect(tranW, tranL);
        tran.offset(new Point(0, -naveL * 0.18));

        // Apse at the end
        var apse = Polygon.regular(8, naveW * 0.55);
        apse.offset(new Point(0, naveL * 0.45));

        // Orientation
        var angle = preferredAngle;
        if (angle == null) {
            // Align to longest edge
            var maxLen = 0.0;
            var best = 0.0;
            poly.forEdge(function(p1:Point, p2:Point) {
                var d = Point.distance(p1, p2);
                if (d > maxLen) {
                    maxLen = d;
                    best = Math.atan2(p2.y - p1.y, p2.x - p1.x);
                }
            });
            angle = best;
        }

        nave.rotate(angle);
        tran.rotate(angle);
        apse.rotate(angle);

        nave.offset(c);
        tran.offset(c);
        apse.offset(c);

        // Optional twin towers if the lot is large enough
        var out = [nave, tran, apse];
        if (poly.square > 1200) {
            var tw = naveW * 0.55;
            var th = naveW * 0.55;
            var t1 = Polygon.rect(tw, th);
            var t2 = Polygon.rect(tw, th);

            // Place at the entrance side
            var forward = new Point(Math.cos(angle), Math.sin(angle));
            var right = new Point(-forward.y, forward.x);

            var entrance = c.subtract(forward.scale(naveL * 0.48));
            t1.rotate(angle);
            t2.rotate(angle);

            t1.offset(entrance.add(right.scale(naveW * 0.65)));
            t2.offset(entrance.subtract(right.scale(naveW * 0.65)));

            out.push(t1);
            out.push(t2);
        }

        return out;
    }
/**
 * Saxon/Viking-style longhouses: long thin rectangles aligned to an axis.
 * Returns multiple building polygons.
 */
public static function makeLonghouses(poly:Polygon, ?preferredAngle:Null<Float>, density:Int=18):Array<Polygon> {
    var out:Array<Polygon> = [];
    var angle = preferredAngle;

    if (angle == null) {
        var maxLen = 0.0;
        var best = 0.0;
        poly.forEdge(function(p1:Point, p2:Point) {
            var d = Point.distance(p1, p2);
            if (d > maxLen) { maxLen = d; best = Math.atan2(p2.y - p1.y, p2.x - p1.x); }
        });
        angle = best;
    }

    var bounds = poly.getBounds();
    var tries = density * 8;

    while (tries-- > 0 && out.length < density) {
        var px = bounds.left + Random.float() * bounds.width;
        var py = bounds.top + Random.float() * bounds.height;
        var c = new Point(px, py);
        if (!poly.containsPoint(c)) continue;

        var len = 8 + Random.float() * 14;
        var wid = 2.4 + Random.float() * 2.2;

        // Slightly rounded ends are too expensive; keep rects but vary length/width
        var house = Polygon.rect(wid, len);
        house.rotate(angle + (Random.float() - 0.5) * 0.2);
        house.offset(c);

        // Avoid extreme overlap by simple center-distance test
        var ok = true;
        for (b in out) if (Point.distance(b.center, house.center) < wid * 1.2) { ok = false; break; }

        if (ok) out.push(house);
    }

    return out.length > 0 ? out : Ward.createAlleys(poly, 35, 0.4, 0.6, 0.08);
}

/**
 * African/tribal compounds: circular/round huts clustered in a few family compounds.
 * Huts are approximated with regular polygons.
 */
public static function makeRoundHuts(poly:Polygon, compounds:Int=3, hutsPer:Int=10):Array<Polygon> {
    var out:Array<Polygon> = [];
    var bounds = poly.getBounds();

    for (cidx in 0...compounds) {
        var attempt = 0;
        var center:Point = null;
        while (attempt++ < 30) {
            var p = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
            if (poly.containsPoint(p)) { center = p; break; }
        }
        if (center == null) continue;

        // Compound ring / yard marker (optional, low alpha in render if desired)
        var yardR = 10 + Random.float() * 10;
        var yard = Polygon.regular(16, yardR);
        yard.offset(center);
        out.push(yard);

        for (i in 0...hutsPer) {
            var a = Random.float() * Math.PI * 2;
            var r = (yardR * 0.35) + Random.float() * (yardR * 0.55);
            var hp = center.add(new Point(Math.cos(a) * r, Math.sin(a) * r));
            if (!poly.containsPoint(hp)) continue;

            var hutR = 1.8 + Random.float() * 2.4;
            var sides = 8 + Random.int(0, 4);
            var hut = Polygon.regular(sides, hutR);
            hut.rotate(Random.float() * Math.PI);
            hut.offset(hp);
            out.push(hut);
        }
    }

    return out.length > 0 ? out : Ward.createAlleys(poly, 35, 0.6, 0.7, 0.1);
}

/**
 * Tent city: small triangles/diamonds in clusters. No permanence, higher randomness.
 */
public static function makeTents(poly:Polygon, tents:Int=40):Array<Polygon> {
    var out:Array<Polygon> = [];
    var bounds = poly.getBounds();
    var tries = tents * 10;

    while (tries-- > 0 && out.length < tents) {
        var c = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
        if (!poly.containsPoint(c)) continue;

        var w = 2.0 + Random.float() * 2.5;
        var h = 2.0 + Random.float() * 3.0;

        // Diamond tent (two triangles would be nicer, but one polygon is cheaper)
        var tent = new Polygon([
            new Point(0, -h * 0.6),
            new Point(w * 0.6, 0),
            new Point(0, h * 0.6),
            new Point(-w * 0.6, 0)
        ]);
        tent.rotate(Random.float() * Math.PI);
        tent.offset(c);

        // Keep some spacing
        var ok = true;
        for (b in out) if (Point.distance(b.center, tent.center) < 1.6) { ok = false; break; }
        if (ok) out.push(tent);
    }

    return out.length > 0 ? out : makeShantytown(poly, 25);
}


/**
 * Elven homes: light geometry, angled hexes and slender halls.
 * Kept cheap: a mix of small regular polygons and thin rectangles.
 */
public static function makeElvenHomes(poly:Polygon, homes:Int=22):Array<Polygon> {
    var out:Array<Polygon> = [];
    var bounds = poly.getBounds();
    var tries = homes * 10;

    while (tries-- > 0 && out.length < homes) {
        var c = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
        if (!poly.containsPoint(c)) continue;

        var r = 1.6 + Random.float() * 2.6;
        var sides = 6 + Random.int(0, 2);
        var hut = Polygon.regular(sides, r);
        hut.rotate(Random.float() * Math.PI);
        hut.offset(c);

        // spacing
        var ok = true;
        for (b in out) if (Point.distance(b.center, hut.center) < 2.2) { ok = false; break; }
        if (ok) out.push(hut);

        // occasional slender hall
        if (ok && Random.float() < 0.25) {
            var hall = Polygon.rect(1.6 + Random.float() * 1.2, 6 + Random.float() * 8);
            hall.rotate(Random.float() * Math.PI);
            hall.offset(c.add(new Point(Random.float()*2-1, Random.float()*2-1)));
            out.push(hall);
        }
    }

    return out.length > 0 ? out : makeLonghouses(poly, null, Std.int(homes * 0.6));
}

/**
 * Stone blocks: dwarven/undercity logic. Chunky rectangles with tight packing.
 */
public static function makeStoneBlocks(poly:Polygon, blocks:Int=18):Array<Polygon> {
    var out:Array<Polygon> = [];
    var bounds = poly.getBounds();
    var tries = blocks * 12;

    while (tries-- > 0 && out.length < blocks) {
        var c = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
        if (!poly.containsPoint(c)) continue;

        var w = 3.5 + Random.float() * 4.5;
        var h = 3.5 + Random.float() * 4.5;
        if (Random.float() < 0.35) h *= 1.8;

        var b = Polygon.rect(w, h);
        b.rotate((Random.int(0, 3) * Math.PI) / 2); // orthogonal feel
        b.offset(c);

        var ok = true;
        for (o in out) if (Point.distance(o.center, b.center) < 3.0) { ok = false; break; }
        if (ok) out.push(b);
    }

    return out.length > 0 ? out : makeGrid(poly, 7);
}

/**
 * Marsh stilt huts: small raised huts + simple "walkway" planks.
 */
public static function makeStiltHuts(poly:Polygon, huts:Int=22):Array<Polygon> {
    var out:Array<Polygon> = [];
    var bounds = poly.getBounds();
    var tries = huts * 12;

    while (tries-- > 0 && out.length < huts) {
        var c = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
        if (!poly.containsPoint(c)) continue;

        var w = 2.6 + Random.float() * 2.2;
        var h = 2.6 + Random.float() * 2.2;

        var hut = Polygon.rect(w, h);
        hut.rotate(Random.float() * Math.PI);
        hut.offset(c);
        out.push(hut);

        // walkway plank
        if (Random.float() < 0.30) {
            var plank = Polygon.rect(1.0, 6.0 + Random.float() * 8.0);
            plank.rotate(Random.float() * Math.PI);
            plank.offset(c.add(new Point(Random.float()*3-1.5, Random.float()*3-1.5)));
            out.push(plank);
        }
    }

    return out.length > 0 ? out : makeShantytown(poly, 18);
}

/**
 * Ruins scatter: broken rectangles and collapsed footprints.
 */
public static function makeRuinsScatter(poly:Polygon, count:Int=12):Array<Polygon> {
    var out:Array<Polygon> = [];
    var bounds = poly.getBounds();
    var tries = count * 14;

    while (tries-- > 0 && out.length < count) {
        var c = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
        if (!poly.containsPoint(c)) continue;

        var w = 3 + Random.float() * 8;
        var h = 3 + Random.float() * 8;
        var r = Polygon.rect(w, h);
        r.rotate(Random.float() * Math.PI);
        r.offset(c);

        // "collapsed" by cutting a corner with a short segment (cheap)
        if (r.length >= 4 && Random.float() < 0.6) r.splice(1, 1);

        out.push(r);
    }

    return out.length > 0 ? out : makeShantytown(poly, 8);
}


/**
 * Culture-aware market layout.
 * Returns multi-polygons: central feature + stalls/huts/tents.
 */
public static function makeMarket(poly:Polygon, culture:Culture, ?preferredAngle:Null<Float>):Array<Polygon> {
    var out:Array<Polygon> = [];
    var c = poly.centroid;

    switch (culture) {
        case Culture.AFRICAN, Culture.TRIBAL, Culture.BARBARIAN:
            // Ringed hut-stalls around a central fire.
            var fire = Polygon.circle(1.2 + Random.float() * 0.8);
            fire.offset(c);
            out.push(fire);

            var ringR = Math.sqrt(poly.square / Math.PI) * 0.35;
            var n = 10 + Random.int(0, 8);
            for (i in 0...n) {
                var a = (Math.PI * 2) * (i / n) + Random.float() * 0.15;
                var hut = Polygon.circle(1.0 + Random.float() * 1.2);
                hut.offset(new Point(c.x + Math.cos(a) * ringR, c.y + Math.sin(a) * ringR));
                if (poly.containsPoint(hut.center)) out.push(hut);
            }
            // Some extra scattered stalls
            out = out.concat(makeRoundHuts(poly, 2, 6));
            return out;

        case Culture.TENT, Culture.NOMAD, Culture.FRONTIER:
            // Dense tent-stalls with a small central pole.
            var pole = Polygon.circle(0.7 + Random.float() * 0.5);
            pole.offset(c);
            out.push(pole);
            out = out.concat(makeTents(poly, 45 + Random.int(0, 25)));
            return out;

        case Culture.SAXON, Culture.VIKING, Culture.DARK_AGES, Culture.EUROPEAN_MEDIEVAL, Culture.HIGH_MEDIEVAL_CITY:
            var angle = preferredAngle;
            if (angle == null) angle = dominantAngle(poly);
            // Central feature: statue or well
            var feature = Random.bool(0.6) ? Polygon.rect(1.3, 1.3) : Polygon.circle(1.1);
            feature.rotate(angle);
            feature.offset(c);
            out.push(feature);

            // Stalls along a loose inner ring aligned to angle.
            var r = Math.sqrt(poly.square / Math.PI) * 0.42;
            var stalls = 22 + Random.int(0, 10);
            for (i in 0...stalls) {
                var a = (Math.PI * 2) * (i / stalls);
                var p = new Point(c.x + Math.cos(a) * r, c.y + Math.sin(a) * r);
                if (!poly.containsPoint(p)) continue;
                var w = 1.2 + Random.float() * 1.0;
                var h = 0.7 + Random.float() * 0.8;
                var stall = Polygon.rect(w, h);
                stall.rotate(angle + Random.float() * 0.25);
                stall.offset(p);
                out.push(stall);
            }
            return out;

        
		case Culture.IMPERIAL, Culture.RENAISSANCE_CITY:
			// Planned stalls: simple grid + central monument.
			out = out.concat(makeGrid(poly, 7 + Random.float() * 2));
			var obelisk = Polygon.rect(2, 6);
			obelisk.rotate(Random.float() * Math.PI);
			obelisk.offset(c);
			out.push(obelisk);

		case Culture.MERCHANT_REPUBLIC:
			// Dense stalls + warehouses on the edge.
			out = out.concat(Ward.createAlleys(poly, 28, 0.45, 0.6, 0.06));
			var bounds = poly.getBounds();
			for (i in 0...3) {
				var w = Polygon.rect(5 + Random.float() * 6, 3 + Random.float() * 4);
				w.offset(new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height));
				if (poly.containsPoint(w.center)) out.push(w);
			}

		case Culture.INDUSTRIAL, Culture.DWARVEN_HOLD:
			// Yards + sheds.
			out = out.concat(makeStoneBlocks(poly, 16));
			var yard = Polygon.regular(10, Math.sqrt(poly.square/Math.PI) * 0.18);
			yard.offset(c);
			out.push(yard);

		case Culture.ORCINOID:
			out = out.concat(makeShantytown(poly, 30));
			var pit = Polygon.circle(2.2);
			pit.offset(c);
			out.push(pit);

		case Culture.ELVEN_HIGH, Culture.ELVEN_WOOD, Culture.ELVEN_DARK:
			out = out.concat(makeElvenHomes(poly, 22));
			var grove = Polygon.circle(2.0);
			grove.offset(c);
			out.push(grove);

		case Culture.RELIGIOUS_ENCLAVE:
			// Processional market around a shrine.
			out = out.concat(Ward.createAlleys(poly, 22, 0.35, 0.55, 0.05));
			var shrine = Polygon.regular(8, 2.4);
			shrine.rotate(Random.float() * Math.PI);
			shrine.offset(c);
			out.push(shrine);

		case Culture.MARSH:
			out = out.concat(makeStiltHuts(poly, 20));
			var jetty = Polygon.rect(2, 10);
			jetty.rotate(Random.float() * Math.PI);
			jetty.offset(c);
			out.push(jetty);

		default:
            // Medieval default: booths + statue/fountain (classic Watabou vibe).
            var statue = Random.bool(0.6);
            var feature2 = statue ? Polygon.rect(1 + Random.float(), 1 + Random.float()) : Polygon.circle(1 + Random.float());
            if (statue) {
                var a0 = preferredAngle;
                if (a0 == null) a0 = dominantAngle(poly);
                feature2.rotate(a0);
            }
            feature2.offset(c);
            out.push(feature2);

            // A few small booths sprinkled, biased toward edges.
            var bounds = poly.getBounds();
            var booths = 18 + Random.int(0, 12);
            var tries = booths * 8;
            while (tries-- > 0 && out.length < booths + 1) {
                var p2 = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
                if (!poly.containsPoint(p2)) continue;
                // Bias toward edge by rejecting too-central samples
                if (Point.distance(p2, c) < Math.sqrt(poly.square / Math.PI) * 0.2 && Random.bool(0.7)) continue;
                var b = Polygon.rect(1.0 + Random.float() * 1.4, 0.8 + Random.float() * 1.2);
                b.rotate(Random.float() * Math.PI);
                b.offset(p2);
                out.push(b);
            }
            return out;
    }
}

/**
 * Culture-aware military layout.
 * Returns building polygons and (optionally) a courtyard/yard marker polygon.
 */
public static function makeMilitary(poly:Polygon, culture:Culture, ?preferredAngle:Null<Float>):Array<Polygon> {
    switch (culture) {
        case Culture.SAXON, Culture.VIKING, Culture.DARK_AGES, Culture.EUROPEAN_MEDIEVAL, Culture.HIGH_MEDIEVAL_CITY:
            var angle = preferredAngle;
            if (angle == null) angle = dominantAngle(poly);

            // Barracks compounds: a few longhouses aligned to angle, leaving a yard.
            var out = makeLonghouses(poly, angle, 14 + Random.int(0, 6));
            // Add a small square parade ground marker
            var yard = Polygon.rect(5, 5);
            yard.rotate(angle);
            yard.offset(poly.centroid);
            out.push(yard);
            return out;

        case Culture.AFRICAN, Culture.TRIBAL, Culture.BARBARIAN:
            // Fortified compound: clustered huts plus a palisade ring marker.
            var out2 = makeRoundHuts(poly, 3 + Random.int(0, 2), 10 + Random.int(0, 6));
            // Palisade ring is visual, thin
            out2 = out2.concat(Cutter.ring(poly, 1.2));
            return out2;

        case Culture.TENT, Culture.NOMAD, Culture.FRONTIER:
            // Regimented rows: tents on a loose grid.
            var out3:Array<Polygon> = [];
            var bounds = poly.getBounds();
            var step = 5.0;
            var angle2 = preferredAngle;
            if (angle2 == null) angle2 = 0.0;

            var x = bounds.left;
            while (x < bounds.right) {
                var y = bounds.top;
                while (y < bounds.bottom) {
                    var c = new Point(x + step * 0.5, y + step * 0.5);
                    if (poly.containsPoint(c)) {
                        var tent = new Polygon([
                            new Point(0, -1.8),
                            new Point(1.6, 0),
                            new Point(0, 1.8),
                            new Point(-1.6, 0)
                        ]);
                        tent.rotate(angle2);
                        tent.offset(c);
                        out3.push(tent);
                    }
                    y += step;
                }
                x += step;
            }
            // Command tent
            var cmd = Polygon.rect(4, 3);
            cmd.rotate(angle2);
            cmd.offset(poly.centroid);
            out3.push(cmd);
            return out3;

        
		case Culture.IMPERIAL, Culture.RENAISSANCE_CITY:
			// Regimented blocks aligned to preferred axis.
			out = out.concat(makeGrid(poly, 9 + Random.float() * 2));
			var parade = Polygon.rect(8, 8);
			parade.offset(c);
			out.push(parade);

		case Culture.MERCHANT_REPUBLIC:
			// Guardhouses and store yards.
			out = out.concat(makeStoneBlocks(poly, 10));
			out = out.concat(makeCourtyardBuilding(poly, 3.0));

		case Culture.INDUSTRIAL, Culture.DWARVEN_HOLD:
			// Fortified workshops.
			out = out.concat(makeStoneBlocks(poly, 18));
			var forge = Polygon.rect(6, 10);
			forge.offset(c);
			out.push(forge);

		case Culture.ORCINOID:
			out = out.concat(makeShantytown(poly, 22));
			var arena = Polygon.regular(12, Math.sqrt(poly.square/Math.PI) * 0.22);
			arena.offset(c);
			out.push(arena);

		case Culture.ELVEN_HIGH, Culture.ELVEN_WOOD:
			// Watch platforms + light barracks.
			out = out.concat(makeElvenHomes(poly, 14));
			var platform = Polygon.regular(6, 3.0);
			platform.offset(c);
			out.push(platform);

		case Culture.ELVEN_DARK:
			out = out.concat(makeStoneBlocks(poly, 16));
			var pit = Polygon.circle(2.0);
			pit.offset(c);
			out.push(pit);

		case Culture.RELIGIOUS_ENCLAVE:
			out = out.concat(makeCourtyardBuilding(poly, 3.0));
			var bell = Polygon.rect(3, 7);
			bell.rotate(Random.float() * Math.PI);
			bell.offset(c);
			out.push(bell);

		case Culture.RUINED:
			out = out.concat(makeRuinsScatter(poly, 14));

		default:
            // fallback: alleys-like blocks (original behaviour)
            return Ward.createAlleys(poly,
                Math.sqrt(poly.square) * (1 + Random.float()),
                0.2, 0.3,
                0.25
            );
    }
}

/**
 * Scatter trees inside a polygon as tiny circles. Returned as polygons so they render in both OpenFL and SVG.
 */
public static function makeTrees(poly:Polygon, density:Int, ?size:Float=1.0):Array<Polygon> {
    var out:Array<Polygon> = [];
    if (density <= 0) return out;

    var bounds = poly.getBounds();
    var tries = density * 10;
    while (tries-- > 0 && out.length < density) {
        var p = new Point(bounds.left + Random.float() * bounds.width, bounds.top + Random.float() * bounds.height);
        if (!poly.containsPoint(p)) continue;

        var r = (0.6 + Random.float() * 0.8) * size;
        var t = Polygon.circle(r);
        t.offset(p);
        out.push(t);
    }
    return out;
}



// --- Origin-specific landmark grammars -----------------------------------------

/** Timber yard: stacked logs + a sawpit. */
public static function makeTimberYard(poly:Polygon):Array<Polygon> {
    var out:Array<Polygon> = [];
    var c = poly.centroid;
    var ang = dominantAngle(poly);

    // Central sawpit
    var pit = Polygon.rect(3.5, 1.5);
    pit.rotate(ang);
    pit.offset(c);
    out.push(pit);

    // Log stacks
    var stacks = 6 + Random.int(0, 4);
    for (i in 0...stacks) {
        var len = 6 + Random.float() * 8;
        var w = 0.8 + Random.float() * 0.6;
        var s = Polygon.rect(w, len);
        s.rotate(ang + (Random.float() - 0.5) * 0.2);
        // offset near centre with some jitter
        var off = new Point((Random.float() - 0.5) * 10, (Random.float() - 0.5) * 10);
        s.offset(c.add(off));
        if (poly.containsPoint(s.center)) out.push(s);
    }
    return out;
}

/** Mine: a pit + spoil heaps + sheds. */
public static function makeMine(poly:Polygon):Array<Polygon> {
    var out:Array<Polygon> = [];
    var c = poly.centroid;

    // Pit
    var pitR = 3.0 + Math.sqrt(Math.max(10, poly.square)) * 0.03;
    var pit = Polygon.circle(pitR);
    pit.offset(c);
    out.push(pit);

    // Spoil heaps (small circles)
    out = out.concat(makeTrees(poly, 5 + Random.int(0, 3), 0.9));

    // Sheds
    var ang = dominantAngle(poly);
    var sheds = 3 + Random.int(0, 3);
    for (i in 0...sheds) {
        var sh = Polygon.rect(2.5, 4.5 + Random.float() * 4);
        sh.rotate(ang + (Random.float() - 0.5) * 0.3);
        var off = new Point((Random.float() - 0.5) * 12, (Random.float() - 0.5) * 12);
        sh.offset(c.add(off));
        if (poly.containsPoint(sh.center)) out.push(sh);
    }
    return out;
}

/** Waystation: a courtyard + stables/inn blocks. */
public static function makeWaystation(poly:Polygon, culture:com.watabou.towngenerator.building.Culture):Array<Polygon> {
    var out:Array<Polygon> = [];
    var c = poly.centroid;
    var ang = dominantAngle(poly);

    // Courtyard ring (cheap boolean-less style: outer + inner drawn on top)
    var outer = poly;
    var inner = poly.shrinkEq(3.0);
    if (inner != null && inner.square > 20) {
        out.push(outer);
        out.push(inner);
    } else {
        out.push(outer);
    }

    // Inn block
    var inn = Polygon.rect(5.0, 9.0);
    inn.rotate(ang);
    inn.offset(c.add(new Point(0, -6)));
    if (poly.containsPoint(inn.center)) out.push(inn);

    // Stables rows
    var rows = 2 + Random.int(0, 1);
    for (i in 0...rows) {
        var stable = Polygon.rect(3.0, 10.0);
        stable.rotate(ang);
        stable.offset(c.add(new Point((i==0?-6:6), 4)));
        if (poly.containsPoint(stable.center)) out.push(stable);
    }

    return out;
}

/**
 * Dominant angle based on the longest edge.
 */
private static inline function dominantAngle(poly:Polygon):Float {
    var maxLen = 0.0;
    var best = 0.0;
    poly.forEdge(function(p1:Point, p2:Point) {
        var d = Point.distance(p1, p2);
        if (d > maxLen) { maxLen = d; best = Math.atan2(p2.y - p1.y, p2.x - p1.x); }
    });
    return best;
}

}
