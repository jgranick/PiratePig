package com.eclecticdesignstudio.piratepig;


import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.actuators.GenericActuator;
import com.eclecticdesignstudio.motion.easing.Quad;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.filters.BlurFilter;


/**
 * ...
 * @author Joshua Granick
 */
class Tile extends Sprite {
	
	
	public var column:Int;
	public var moving:Bool;
	public var removed:Bool;
	public var row:Int;
	public var type:Int;
	
	private static var images:Array <String> = [ "images/game_bear.png", "images/game_bunny_02.png", "images/game_carrot.png", "images/game_lemon.png", "images/game_panda.png", "images/game_piratePig.png" ];
	
	
	public function new () {
		
		super ();
		
		moving = false;
		type = Math.round (Math.random () * (images.length - 1));
		
		var image = new Bitmap (Assets.getBitmapData (images[type]));
		image.smoothing = true;
		addChild (image);
		
		#if !js
		filters = [ new BlurFilter (0, 0) ];
		#end
		
		mouseChildren = false;
		buttonMode = true;
		
		graphics.beginFill (0x000000, 0);
		graphics.drawRect (-5, -5, 66, 66);
		
	}
	
	
	public function moveTo (duration:Float, targetX:Float, targetY:Float):Void {
		
		moving = true;
		
		var blurX = 0;
		var blurY = 0;
		
		if (targetX != x) {
			
			blurX = Std.int (Math.abs (x - targetX) / 3);
			
		}
		
		if (targetY != y) {
			
			blurY = Std.int (Math.abs (y - targetY) / 3);
			
		}
		
		#if !js
		Actuate.effects (this, 0.001).filter (BlurFilter, { blurX: blurX, blurY: blurY } );
		Actuate.effects (this, duration * (2 / 3), false).filter (BlurFilter, { blurX: 0, blurY: 0 } ).delay (duration / 3);
		#end
		
		Actuate.tween (this, duration, { x: targetX, y: targetY } ).onComplete (this_onAnimationComplete).ease (Quad.easeOut);
		
	}
	
	
	public function remove (animate:Bool = true):Void {
		
		#if js
		animate = false;
		#end
		
		if (!removed) {
			
			if (animate) {
				
				parent.addChildAt (this, 0);
				Actuate.tween (this, 0.3, { scaleX: 0, scaleY: 0, x: x + width / 2, y: y + height / 2 } ).ease (Quad.easeOut).onComplete (parent.removeChild, [ this ]);
				
			} else {
				
				parent.removeChild (this);
				
			}
			
		}
		
		removed = true;
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function this_onAnimationComplete ():Void {
		
		moving = false;
		
	}
	
	
}