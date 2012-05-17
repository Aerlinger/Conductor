/*
Copyright (c) 2010 Trevor McCauley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
*/
package com.senocular.display.transform {
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Resets a target object's transform back to its original, untransformed
	 * state. This control automatically positions itself at the lower-right
	 * of the target object's bounding box.
	 * @author Trevor McCauley
	 */
	public class ControlReset extends Control {
		
		private const OFFSET_X:int = 12;
		private const OFFSET_Y:int = 12;
		
		/**
		 * Constructor for creating new ControlReset instances.
		 */
		public function ControlReset() {
			super();
			buttonMode = true;
			useHandCursor = true;
			lineThickness = 2;
			addEventListener(MouseEvent.CLICK, click);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			graphics.clear();
			
			// don't draw anything if something
			// has been added as a child to
			// this display object as a "skin"
			if (numChildren) return;
			
			with (graphics){
				// top arrow
				beginFill(this.lineColor, this.lineAlpha);
				moveTo(2, -4);
				lineTo(0, -7);
				lineTo(4, -7);
				lineTo(2, -4);
				endFill();
				// right arrow
				beginFill(this.lineColor, this.lineAlpha);
				moveTo(4, -2);
				lineTo(7, -4);
				lineTo(7, 0);
				lineTo(4, -2);
				endFill();
				// box
				beginFill(this.fillColor, this.fillAlpha);
				lineStyle(this.lineThickness, this.lineColor, this.lineAlpha);
				drawRect(-3, -3, 6, 6);
				endFill();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function redraw(event:Event):void {
			super.redraw(event);
			
			var tool:TransformTool = this.tool;
			if (tool == null){
				return;
			}
			
			var maxX:Number = tool.topLeft.x;
			if (tool.topRight.x > maxX) maxX = tool.topRight.x;
			if (tool.bottomRight.x > maxX) maxX = tool.bottomRight.x;
			if (tool.bottomLeft.x > maxX) maxX = tool.bottomLeft.x;
			
			var maxY:Number = tool.topLeft.y;
			if (tool.topRight.y > maxY) maxY = tool.topRight.y;
			if (tool.bottomRight.y > maxY) maxY = tool.bottomRight.y;
			if (tool.bottomLeft.y > maxY) maxY = tool.bottomLeft.y;
			
			x = OFFSET_X + maxX;
			y = OFFSET_Y + maxY;
		}
		
		/**
		 * Handler for the MouseEvent.CLICK event. When clicked, the
		 * ControlReset instance resets the Transform Tool's transform
		 * and then updates it.
		 */
		protected function click(event:MouseEvent):void {
			tool.resetTransform();
			tool.update();
		}
	}
}