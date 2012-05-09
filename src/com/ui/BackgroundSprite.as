
package com.ui
{
	import com.anim.*;
	import com.element.*;
	import com.time.*;
	
	import fl.transitions.easing.*;
	
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import mx.states.AddChild;
	
	
	
	/** Creates visual elements for ColorWheelMain.
	 * 
	 * @author Anthony Erlinger 
	 * */
	public final class BackgroundSprite extends Sprite
	{
		
		public static const RADIUS:Number = 250;	// Radius of the clock circle
		
		// Shapes and visual elements:
		private var mRotatingPlayBar:BaseElement;	// Line to track proress of track.
		private var mCursorPositionTxt:TextField;
		
		private var mElementText:ElementStatusSprite;
		
		
		/** Starting point of program */
		public function BackgroundSprite(pTimeline:ConductorTimeline)
		{
			this.name = "ColorWheel";
			
			initializeColorWheel(pTimeline);
		}
		
		/** Called at start to draw the color wheel */
		private function initializeColorWheel( pTimeline:ConductorTimeline ) : void {
			
			// Add sprite for the status of elements
			mElementText = new ElementStatusSprite();
			mElementText.x = Conductor.getWidth() - 300;
			mElementText.y = 20;
			
			//addChild(mElementText);
			
			// Add rotating playbar
			mRotatingPlayBar = new BaseElement();
			mRotatingPlayBar.x = Conductor.getCenterX();
			mRotatingPlayBar.y = Conductor.getCenterY();
			
			mRotatingPlayBar.setPivotPointLocal(0, 0, true);
			
			mRotatingPlayBar.name = "PlayBar";
			mRotatingPlayBar.graphics.lineStyle(3, 0x991111, 1.0);
			mRotatingPlayBar.graphics.lineTo(0, -RADIUS);
			addChild( mRotatingPlayBar );
			
			var angle:Number = 0;
			
			for( var k:Number=0; k<=90; k+=.1) 
				mRotatingPlayBar.rotation = k;
			
			//mRotatingPlayBar.rotation = k;
			
			mCursorPositionTxt = new TextField();
			mCursorPositionTxt.textColor = 0xFFFFFF;
			mCursorPositionTxt.selectable = false;
			mCursorPositionTxt.x = Conductor.getWidth() - 150;
			mCursorPositionTxt.y = 2;
			mCursorPositionTxt.text = "(,)";
			addChild(mCursorPositionTxt);
			
			var numMeasures:uint = pTimeline.getNumMeasures();
			var numBeatsPerMeasure:Number = pTimeline.getNumBeatsPerMeasure();
			
			// For each measure draw the measure line
			/*
			for( var i:int=0; i<numMeasures; i++ ) {
				
				var newMeasureStartLine:Shape = new Shape();
				
				newMeasureStartLine.x = Conductor.getCenterX();
				newMeasureStartLine.y = Conductor.getCenterY();
				
				newMeasureStartLine.graphics.lineStyle(2, 0xFF9944, 0.5);
				newMeasureStartLine.graphics.lineTo(0, -RADIUS);
				
				newMeasureStartLine.rotation = (i/numMeasures) * 360;
				addChild(newMeasureStartLine);
				
				
				// For each beat within the measure draw the beat line
				for( var j:int=1; j<numBeatsPerMeasure; ++j ) {
					var newSubLine:Shape = new Shape();
					
					newSubLine.x = Conductor.getCenterX();
					newSubLine.y = Conductor.getCenterY();
					
					newSubLine.graphics.lineStyle(1, 0xCCCCFF, .3);
					newSubLine.graphics.moveTo(0,0);
					newSubLine.graphics.lineTo(0, -RADIUS);
					
					newSubLine.rotation = newMeasureStartLine.rotation + j*((360/numMeasures)/numBeatsPerMeasure);
					
					addChild(newSubLine);
				}
				
			}
			
			// Draw the circle perimeter last
			this.graphics.beginFill(0x222211, 0.3);
			this.graphics.lineStyle(5, 0xAA5500);
			this.graphics.drawCircle(Conductor.getCenterX(), Conductor.getCenterY(), RADIUS);
			*/
			
		}
		
		/** Updates the rotation of this spinning play bar */
		public function setPlaybarRotation( rotationAngle:Number ) : void {
			this.mRotatingPlayBar.rotation = rotationAngle;
		}

		/** Sets the position to indicate the (x,y) position of the mouse cursor */
		public function setCursorPositionText( x:Number, y:Number ) : void {
			mCursorPositionTxt.text = "(" + x + ", " + y + ")";
		}
		
		public function updateElementStatusTextInfo( pElement:BaseElement ) : void {
			mElementText.setStatus(pElement);
		}
		
	}
}