package com.ui
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import spark.primitives.Rect;

	public class SelectionBox extends Sprite {
		
		private var DRAGGING:uint = 0;
		private var FREE:uint = 1;
		
		private var mouseState:uint;
		
		public function SelectionBox() {
			super();
			
			this.graphics.lineStyle(3, 0xFF0000);
			this.x = 200;
			this.y = 200;
			this.width = 200;
			this.height = 200;

		}
		
		private function draw() : void {
			this.graphics.moveTo(this.x, this.y);
			this.graphics.lineTo(this.x+this.width, this.y);
			this.graphics.lineTo(this.x+this.width, this.y+this.height);
			this.graphics.lineTo(this.x, this.y+this.height);
			this.graphics.lineTo(this.x, this.y);
		}
		
		public function startDragging(localX:Number, localY:Number):void {
			mouseState = DRAGGING;
			this.visible = true;
			
			this.x = localX;
			this.y = localY;
			this.width = 1;
			this.height = 1;
		}
		
		public function mouseMove(localX:Number, localY:Number):void {
			if( mouseState == DRAGGING ) {
				this.width 	= (localX - this.x);
				this.height = (localY - this.y);
				
				this.graphics.clear();
				this.draw();
			}
			
		}
		
		public function stopDragging(localX:Number, localY:Number):void {
			this.visible = false;
			mouseState = FREE;
			
		}
	}
}