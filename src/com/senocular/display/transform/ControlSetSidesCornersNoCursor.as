﻿/*
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
	
	/**
	 * This control set has both rotation and scale controls, but does not
	 * include any cursors. As such, the rotation controls are visible rather
	 * than being invisible around scale controls as in many other control
	 * sets. Scale controls are available on the sides of the target object
	 * and rotation controls at the corners.
	 * @author Trevor McCauley
	 */
	public dynamic class ControlSetSidesCornersNoCursor extends Array {
		
		/**
		 * Constructor for creating new ControlSetSidesCornersNoCursor 
		 * instances.
		 */
		public function ControlSetSidesCornersNoCursor(){
			
			super(
				new ControlBorder(),
				new ControlMove(new CursorMove()),
				new ControlUVRotate(0, 0),
				new ControlUVRotate(0, 1),
				new ControlUVRotate(1, 0),
				new ControlUVRotate(1, 1),
				new ControlUVScale(.5, 0, ControlUVScale.Y_AXIS),
				new ControlUVScale(0, .5, ControlUVScale.X_AXIS),
				new ControlUVScale(1, .5, ControlUVScale.X_AXIS),
				new ControlUVScale(.5, 1, ControlUVScale.Y_AXIS),
				new ControlRegistration(new CursorRegistration())
			);
		}
	}
}