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
	
	/**
	 * This control set contains a full set of scaling controls on both the
	 * corners and the sides of the target object. There are no rotation
	 * controls and no cursors.
	 * @author Trevor McCauley
	 */
	public dynamic class ControlSetScaleFullNoCursor extends Array {
		
		/**
		 * Constructor for creating new ControlSetScaleFullNoCursor instances.
		 */
		public function ControlSetScaleFullNoCursor() {
			
			super(
				new ControlBorder(),
				new ControlMove(),
				new ControlUVScale(.5, 0, ControlUVScale.Y_AXIS),
				new ControlUVScale(0, .5, ControlUVScale.X_AXIS),
				new ControlUVScale(1, .5, ControlUVScale.X_AXIS),
				new ControlUVScale(.5, 1, ControlUVScale.Y_AXIS),
				new ControlUVScale(0, 0, ControlUVScale.BOTH),
				new ControlUVScale(0, 1, ControlUVScale.BOTH),
				new ControlUVScale(1, 0, ControlUVScale.BOTH),
				new ControlUVScale(1, 1, ControlUVScale.BOTH),
				new ControlRegistration()
			);
		}
	}
}