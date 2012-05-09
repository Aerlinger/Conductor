package com.element
{
	import com.greensock.*;
	import com.time.ConductorTimeline;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	import flash.events.MouseEvent;
	
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.GroupElement;
	
	/** A circular element with a fill and outline. Rings can be created by setting the the fill variable to null. 
	 * 
	 * @author Anthony Erlinger
	 */
	public class CircleElement extends BaseElement
	{
		/** Radius of the circle */
		private var mRadius:Number;
		
		
		/** Creates a new circle element with the specified position, radius, outline thickness, fill color/alpha, and outline color/alpha */
		public function CircleElement( pOriginal:CircleElement=null, xPos:Number=0, yPos:Number=0, radius:Number=25, thickness:Number=3, 
									   	fillColor:uint=0xFFFFFF, fillAlpha:Number=1, 
										borderColor:uint=0xFF0000, borderAlpha:Number=1) 
		{
			
			super(pOriginal, fillColor, fillAlpha, thickness, borderColor, borderAlpha );
			
			if( pOriginal == null ) {
				
				this.x = xPos;
				this.y = yPos;
				
				// Draw the outline first:
				mShapeOutline.graphics.lineStyle(thickness, borderColor, borderAlpha, false, LineScaleMode.NONE);
				mShapeOutline.graphics.beginFill(0, 0);  // The outline and the fill are separate entities
				mShapeOutline.graphics.drawCircle(0, 0, radius);
				
				// Set the linestyle.
				mShapeFill.graphics.lineStyle(0, 0, 0, false, LineScaleMode.NONE );	// No outline for shape
				mShapeFill.graphics.beginFill(fillColor, fillAlpha);
				
				mShapeFill.graphics.drawCircle(0, 0, radius);
				
				// Draw tick on outline to show orientation:
				mShapeOutline.graphics.beginFill(0x993311, 1);
				mShapeOutline.graphics.lineStyle(thickness, (borderColor & (0xa0a0a0)), 1, false, LineScaleMode.NONE );
				mShapeOutline.graphics.moveTo(0, -radius);
				mShapeOutline.graphics.lineTo(0, -radius+5);
				
				this.mRadius = radius;
				this.mBorderThickness = thickness;
				
				// The default name of this object.
				this.name = "CircleElement"+mInstanceNumber;
			
			// If this is a copy constructor
			} else {
				
				mShapeFill.graphics.copyFrom( pOriginal.mShapeFill.graphics );
				mShapeOutline.graphics.copyFrom( pOriginal.mShapeOutline.graphics );
				
				this.mShapeFill.transform.colorTransform = pOriginal.mShapeOutline.transform.colorTransform;
				this.mShapeFill.alpha = pOriginal.mShapeFill.alpha; 
				
				this.mShapeOutline.transform.colorTransform = pOriginal.mShapeOutline.transform.colorTransform;
				this.mShapeOutline.alpha = pOriginal.mShapeOutline.alpha; 
				
				this.mFillAlpha 	= pOriginal.mFillAlpha;
				this.mBorderColor = pOriginal.mBorderColor;
				this.mBorderAlpha = pOriginal.mBorderAlpha;
				
				this.mRadius 	= pOriginal.mRadius;
				this.mBorderThickness = pOriginal.mBorderThickness;
				this.mFillColor = pOriginal.mFillColor;
				
			}
			
			this.addChild( this.mShapeFill );
			this.addChild( this.mShapeOutline );
		}
		
		/** Called when this Element is pressed */
		private function onPressElement(Evt:MouseEvent) : void {
			trace( this.toString() );
			
			Conductor.updateElementStatusTextInfo(this);
		}
		
		/** Creates a copy of this element. */
		override public function clone() : * {
			var NewCircle:CircleElement = new CircleElement(this);
			NewCircle.mRadius = this.mRadius;
			
			return NewCircle;
		}
		
	}
}