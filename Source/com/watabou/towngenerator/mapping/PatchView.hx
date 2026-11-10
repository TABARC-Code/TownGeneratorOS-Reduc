package com.watabou.towngenerator.mapping;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.ui.Tooltip;
import com.watabou.utils.NameGenerator;

using com.watabou.utils.GraphicsExtender;

class PatchView extends Shape {

	private static var lastPatch : Patch = null;

	public var patch	: Patch;
	public var hotArea	: Sprite;

	// Cache the generated name so it doesn't change on every hover.
	public var districtName:String = null;

	public function new( patch:Patch ) {
		super();
		this.patch = patch;

		if (patch.ward != null) {
			if (patch.districtName == null) patch.districtName = NameGenerator.districtName(patch.ward.getLabel(), patch.shape.centroid);
			districtName = patch.districtName;
		}

		hotArea = new Sprite();
		hotArea.graphics.beginFill( 0, 0 );
		hotArea.graphics.drawPolygon( patch.shape );
		// Since 5.1.5 assigning a listener to ROLL_OVER here causes a crash
		hotArea.addEventListener( MouseEvent.MOUSE_OVER, onRollOver );
	}

	private function onRollOver( e:MouseEvent )
		if (patch != lastPatch) {
			lastPatch = patch;

			if (patch.isWater) {
				Tooltip.instance.set( "Water" );
				return;
			}

			if (patch.ward == null) return;

			if (districtName != null)
				Tooltip.instance.set( districtName + " (" + patch.ward.getLabel() + ")" );
			else
				Tooltip.instance.set( patch.ward.getLabel() );
		}
}
