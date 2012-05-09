package com.element
{
	import com.greensock.*;
	import com.time.ConductorTimeline;
	
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.GroupElement;
	
	/** A box-like element with variable width/height 
	 * 
	 * @author Anthony Erlinger
	 */
	public class RectangleElement extends BaseElement
	{
		// width and height of this rectangle element
		protected var mWidth:Number;
		protected var mHeight:Number;
		
		protected static var mRectangleInstances:uint = 0;
		
		/** Creates a new copy of a rectangle element at the given x,y position with the specified width, height and shape data */
		public function RectangleElement(pOriginal:RectangleElement=null, xPos:Number=0, yPos:Number=0, width:Number=50, height:Number=50, thickness:Number=3, 
					fillColor:uint=0xFFFFFF, fillAlpha:Number=1, 
					borderColor:uint=0xFF0000, borderAlpha:Number=1) 
		{
			super(pOriginal, fillColor, fillAlpha, thickness, borderColor, borderAlpha );
			
			if( pOriginal == null ) {
				
				this.x = xPos;
				this.y = yPos;
				
				// Draw the outline first:
				mShapeOutline.graphics.lineStyle(thickness, borderColor, borderAlpha, false, LineScaleMode.NONE);
				mShapeOutline.graphics.beginFill(0, 0);  // No fill for outline
				
				mShapeOutline.graphics.drawRect(-width/2, -height/2, width, height);
				
				// Set the linestyle.
				mShapeFill.graphics.lineStyle(0, 0, 0, false, LineScaleMode.NONE );	// No outline for shape
				mShapeFill.graphics.beginFill(fillColor, fillAlpha);
				
				mShapeFill.graphics.drawRect(-width/2, -height/2, width, height);
				
				// Draw tick on outline to show orientation:
				mShapeOutline.graphics.beginFill(0x993311, 1);
				mShapeOutline.graphics.lineStyle(thickness, (borderColor & (0xa0a0a0)), 1, false, LineScaleMode.NONE );
				mShapeOutline.graphics.moveTo(0, -height/2);
				mShapeOutline.graphics.lineTo(0, -height/2+5);
				
				this.mFillAlpha = alpha;
				this.mBorderColor = borderColor; 
				this.mBorderAlpha = borderAlpha;
				
				this.mWidth = width;
				this.mHeight = height;
				this.mBorderThickness = thickness;
				this.mFillColor = fillColor;
				
				this.name = "RectangleElement" + (++mRectangleInstances);
				
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
				
				this.mWidth = pOriginal.width;
				this.mHeight = pOriginal.height;
				this.mBorderThickness = pOriginal.mBorderThickness;
				this.mFillColor = pOriginal.mFillColor;
				
			}
			
			this.addChild( this.mShapeFill );
			this.addChild( this.mShapeOutline );
		}
		
		/** Creates an exact copy of this Rectangle Element */
		override public function clone() : * {
			return new RectangleElement(this);
		}
	}
}