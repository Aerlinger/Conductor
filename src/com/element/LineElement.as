package com.element
{
	import com.event.*;
	
	import flash.display.LineScaleMode;
	import flash.geom.Point;

	import flash.filters.BlurFilter;
	
	
	/** Element representing a line between two points. The endpoints of a LineElement can be bound to parent objects, such 
	 * that when the parent objects move, so do the endpoints of the line.
	 * 
	 * @author Anthony Erlinger 
	 */
	public class LineElement extends BaseElement {
		
		// First point:
		protected var x1:Number;
		protected var y1:Number;
		
		// Second point:
		protected var x2:Number;
		protected var y2:Number;
		
		// Elements for the line to always point to.
		protected var mParentElement1:BaseElement;
		protected var mParentElement2:BaseElement;
		
		
		/** Creates new LineElement with the given endpoints, thickness, color and alpha. 
		 * 
		 * @param pOriginal If this variable is not null, a new line will be created as a copy of pOriginal. */
		public function LineElement(pOriginal:LineElement=null, x1:Number=0, y1:Number=0, x2:Number=0, y2:Number=0, 
									thickness:Number=2, color:uint=0xFF0000, alpha:Number=1)
		{
			super(pOriginal, 0, 0, thickness, color, alpha );
			
			mShapeFill = null;
			
			if(pOriginal==null) {
				mShapeOutline.graphics.lineStyle(thickness, color, alpha, false, LineScaleMode.NONE);
				
				this.x1 = x1;
				this.y1 = y1;
				this.x2 = x2;
				this.y2 = y2;
				
			} else {
				mShapeOutline.graphics.lineStyle(pOriginal.mBorderThickness, pOriginal.mBorderColor, pOriginal.mBorderAlpha, false, LineScaleMode.NONE);
				
				this.x1 = pOriginal.x1;
				this.y1 = pOriginal.y1;
				this.x2 = pOriginal.x2;
				this.y2 = pOriginal.y2;
			}
			
			setX1(this.x1);
			setY1(this.y1);
			setX2(this.x2);
			setY2(this.y2);
			
			this.addChild(mShapeOutline);
		}
		
		/** Static constructor: creates a line element to join the endpoints from existing elements */
		public static function createLineElements( pParent1:BaseElement, pParent2:BaseElement, thickness:Number=2, color:uint=0xFF0000, alpha:Number=1 ) : LineElement {
			
			var NewLineElement:LineElement = new LineElement(null, 0, 0, 0, 0, thickness, color, alpha);
			
			NewLineElement.setParent1(pParent1);
			NewLineElement.setParent2(pParent2);
			
			return NewLineElement;
			
		}
		
		/** Enables hit area for collision detection */
		/*override public function setEnableCollisions(enable:Boolean) : void
		{
			if(enable)
				this.hitArea = this;
			else
				this.hitArea = null;
		}*/
		
		/** Setter for the x value of the first endpoint */
		public function setX1(value:Number) : void {
			x1 = value;
			update();
		}
		
		/** Setter for the y value of the first endpoint */
		public function setY1(value:Number) : void {
			y1 = value;
			update();
		}
		
		/** Setter for the x value of the second endpoint */
		public function setX2(value:Number) : void {
			x2 = value;
			update();
		}
		
		/** Setter for the y value of the second endpoint */
		public function setY2(value:Number) : void {
			y2 = value;
			update();
		}
		
		/** Sets the position of the endpoints of this line */
		public function setPosition( x1:Number, y1:Number, x2:Number, y2:Number ) : void {
			setX1(x1);
			setY1(y1);
			setX2(x2);
			setY2(y2);
		}
		
		/** When a parent object is set the position of this line will be bound to the x,y position of that parent. */
		public function setParent1( pElement:BaseElement ) : void {
			this.mParentElement1 = pElement;
			setX1(mParentElement1.x);
			setY1(mParentElement1.y);
			
			// TODO: Add event listener
			this.mParentElement1.addEventListener( ElementEvent.MOVE, onParent1Move );
		}
		
		/** When a parent object is set the position of this line will be bound to the x,y position of that parent. */
		public function setParent2( pElement:BaseElement ) : void {
			this.mParentElement2 = pElement;
			setX2(mParentElement2.x);
			setY2(mParentElement2.y);
			
			// TODO: Add event listener
			this.mParentElement2.addEventListener( ElementEvent.MOVE, onParent2Move );
		}
		
		/** Listener: Called every time a parent object is moved */
		private function onParent1Move( ElementEvt:ElementEvent ) : void {
			setX1(ElementEvt.getX());
			setY1(ElementEvt.getY());
		}
		
		/** Listener: Called every time a parent object is moved */
		private function onParent2Move( ElementEvt:ElementEvent ) : void {
			setX2(ElementEvt.getX());
			setY2(ElementEvt.getY());
		}
		
		/** Called internally to update the endpoints of this line when this line is linked to a parent */
		private function update() : void {
			// if this line hasn't been initialized, return.
			if( isNaN(x1) || isNaN(x2) || isNaN(y1) || isNaN(y2) )
				return;
			
			mShapeOutline.graphics.clear();
			mShapeOutline.graphics.lineStyle(this.mBorderThickness, this.mBorderColor, this.mBorderAlpha, false, LineScaleMode.NONE);
			
			var AdjustedPt1:Point = this.globalToLocal( new Point(x1, y1) );
			var AdjustedPt2:Point = this.globalToLocal( new Point(x2, y2) );
			
			mShapeOutline.graphics.moveTo(AdjustedPt1.x, AdjustedPt1.y);
			mShapeOutline.graphics.lineTo(AdjustedPt2.x, AdjustedPt2.y);
			
		}
		
	}
}