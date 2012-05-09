package com.sprites
{
	import com.anim.*;
	import com.element.*;
	import com.time.*;
	
	import fl.transitions.easing.*;
	
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	
	
	/** Creates visual elements for ColorWheelMain.
	 * 
	 * @author Anthony Erlinger 
	 * */
	public class ColorWheelSprite extends Sprite
	{
		
		public static const RADIUS:Number = 390;	// Radius of the clock circle
		
		// Shapes and visual elements:
		private var mPlayBar:Sprite;			// Line to track proress of track.		
		
		
		
		
		/** Starting point of program */
		public function ColorWheelSprite(pTimeline:Timeline)
		{
			this.name = "ColorWheel";
			
			initializeColorWheel(pTimeline);
		}
		
		/** Called at start to draw the color wheel */
		private function initializeColorWheel( pTimeline:Timeline ) : void {
			
			// Add rotating playbar
			mPlayBar = new BaseElement();
			mPlayBar.x = ColorWheelMain.getCenterX();
			mPlayBar.y = ColorWheelMain.getCenterY();
			
			mPlayBar.name = "PlayBar";
			mPlayBar.graphics.lineStyle(3, 0x991111, 1.0);
			mPlayBar.graphics.lineTo(0, -RADIUS);
			addChild( mPlayBar );
			
			
			// Place the cursor label at the bottom left
			/**
			mCursorPositionText.textColor = 0xAA7722;
			mCursorPositionText.y = stage.stageHeight-20;
			addChild(mCursorPositionText);
			*/
			
			var numMeasures:uint = pTimeline.getNumMeasures();
			var numBeatsPerMeasure:Number = pTimeline.getNumBeatsPerMeasure();
			
			// For each measure draw the measure line
			for( var i:int=0; i<numMeasures; i++ ) {
				
				var newMeasureStartLine:Shape = new Shape();
				
				newMeasureStartLine.x = ColorWheelMain.getCenterX();
				newMeasureStartLine.y = ColorWheelMain.getCenterY();
				
				newMeasureStartLine.graphics.lineStyle(2, 0xFF9944, 0.5);
				newMeasureStartLine.graphics.lineTo(0, -RADIUS);
				
				newMeasureStartLine.rotation = (i/numMeasures) * 360;
				addChild(newMeasureStartLine);
				
				
				// For each beat within the measure draw the beat line
				for( var j:int=1; j<numBeatsPerMeasure; ++j ) {
					var newSubLine:Shape = new Shape();
					
					newSubLine.x = ColorWheelMain.getCenterX();
					newSubLine.y = ColorWheelMain.getCenterY();
					
					newSubLine.graphics.lineStyle(1, 0xCCCCFF, .3);
					newSubLine.graphics.moveTo(0,0);
					newSubLine.graphics.lineTo(0, -RADIUS);
					
					newSubLine.rotation = newMeasureStartLine.rotation + j*((360/numMeasures)/numBeatsPerMeasure);
					
					addChild(newSubLine);
				}
				
			}
			
			// Create "pulsing ring" element.
			/*
			mPulsingRingBeat = new BaseElement();
			mPulsingRingBeat.x = ColorWheelMain.getCenterX();
			mPulsingRingBeat.y = ColorWheelMain.getCenterY();
			mPulsingRingBeat.graphics.lineStyle(3, 0x996699, 1.0, true, LineScaleMode.NONE);
			mPulsingRingBeat.graphics.beginFill(0xFFFFFF, 0);
			
			mPulsingRingBeat.graphics.drawCircle(0, 0, 50);
			
			var beatTimeInSeconds = pTimeline.getDurationOfBeat();
			
			mPulseAction = (new Action(mPulsingRingBeat, beatTimeInSeconds)).setDestinationPosition(200, 200).setDestinationAlpha(.5);
			mPulseAction.setEasingFunction( None.easeInOut );
			mPulseAction.setNextAction( ( new Action(mPulsingRingBeat, .01) ).setDestinationScale(1, 1).setDestinationAlpha(1), mPulsingRingBeat );
			
			
			addChild(mPulsingRingBeat);
			*/
			
			// Draw the circle perimeter last
			this.graphics.beginFill(0x222211, 0.3);
			this.graphics.lineStyle(5, 0xAA5500);
			this.graphics.drawCircle(ColorWheelMain.getCenterX(), ColorWheelMain.getCenterY(), RADIUS);
			
		}
		
		public function setPlaybarRotation( rotationAngle:Number ) : void {
			this.mPlayBar.rotation = rotationAngle;
		}
		
		
	}
}