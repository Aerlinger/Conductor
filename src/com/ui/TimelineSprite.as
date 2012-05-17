package com.ui
{
	import com.anim.*;
	import com.element.BaseElement;
	import com.greensock.*;
	import com.greensock.core.*;
	import com.time.ConductorTimeline;
	import com.time.TimeSignatureData;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/** Singleton graphical class for the timeline. The top-left point of the screen should align with the top-left point of the stage. 
	 * 
	 * @author Anthony Erlinger
	 * */
	public class TimelineSprite extends Sprite {
		
		// constant dimensions for the timeline:
		private var TIMELINE_WIDTH:Number = (.8 * stage.stageWidth);
		private var TIMELINE_HEIGHT:Number = 30;
		
		private var TIMELINE_X:Number;
		private var TIMELINE_Y:Number;
		
		private var mTimeLineBG:Sprite;
		private var mTimeCursor:Sprite;
		
		// Used to reference any drawn keypoints on the timeline.
		private var mKeypointMarkers:Array			= new Array();
		private var mDynamicKeypointMarkers:Array	= new Array();
		
		// Information labels
		private var mTotalObjectsTxt:TextField;
		private var mActiveObjectsTxt:TextField;
		private var mStaticKeypointsTxt:TextField;
		
		// Time signature information
		private var mTimeSignatureData:TimeSignatureData;
		private var mMainTimeline:ConductorTimeline;
		
		private var mPauseButton:Sprite;
		private var mPlayButton:Sprite;
		private var mReverseButton:Sprite;
		private var mStepForwardButton:Sprite;
		private var mStepBackwardButton:Sprite;
		
		
		
		/** Renders a new TimelineSprite */
		public function TimelineSprite( pTimeData:TimeSignatureData, pMainTimeline:ConductorTimeline ) { 
			this.mTimeSignatureData 	= pTimeData;
			
			TIMELINE_WIDTH = (.8*stage.width);
			
			TIMELINE_X = stage.width/2-TIMELINE_WIDTH/2;
			TIMELINE_Y = stage.height-2.5*TIMELINE_HEIGHT;
			
			this.name = "TimelineSpriteDefault";
			
			initialize();
		}
		
		/** Draws the elements of this sprite */
		private function initialize(  ) : void {
			
			// Begin by drawing all static features of the timeline
			
			// Draw the timeline bar
			mTimeLineBG = new Sprite();
			mTimeLineBG.graphics.beginFill(0x000000, 1.0);
			mTimeLineBG.graphics.lineStyle(1, 0xDDDDDD, 1.0);
			mTimeLineBG.graphics.drawRect( TIMELINE_X, TIMELINE_Y, TIMELINE_WIDTH, TIMELINE_HEIGHT );
			//addChild(mTimeLineBG);
			
			// Draw the time cursor
			mTimeCursor = new Sprite();
			mTimeCursor.graphics.lineStyle(3, 0x990000, 1.0);
			mTimeCursor.graphics.moveTo(TIMELINE_X, TIMELINE_Y);
			mTimeCursor.graphics.lineTo(TIMELINE_X, TIMELINE_Y+TIMELINE_HEIGHT);
			mTimeCursor.graphics.lineStyle(1, 0x996633, 1.0);
			mTimeCursor.graphics.lineTo(TIMELINE_X+1, TIMELINE_Y+TIMELINE_HEIGHT);
			
			initializeTextMarkers();
			drawBeatIntervals();
			//addChild(mTimeCursor);
			
			drawPlayButton();
			drawPauseButton();
			drawReverseButton();
			drawStepBackButton();
			drawStepForwardButton();
			
			mTimeLineBG.addEventListener(MouseEvent.MOUSE_UP, onScrubRelease);
			mTimeLineBG.addEventListener(MouseEvent.MOUSE_MOVE, onScrub);
		}
		
		private function onScrub(Evt:MouseEvent) : void {
			
			if(Evt.buttonDown) {
				var percentage:Number = (Evt.stageX - TIMELINE_X) / TIMELINE_WIDTH;
				mMainTimeline.gotoAndStop( percentage * mMainTimeline.duration );
			}
		}
		
		/** TODO: Doesn't seem to work for an unknown reason */
		private function onScrubRelease(Evt:MouseEvent) : void {
			mMainTimeline.paused = false;
			mMainTimeline.resume();
		}
		
		/** Initializes and places the text labels on this stage. */
		private function initializeTextMarkers() : void {
			
			var leftAlign:Number  = 10;
			var topAlign:Number  = 20;
			
			mTotalObjectsTxt 	= new TextField();
			mActiveObjectsTxt 	= new TextField();
			mStaticKeypointsTxt = new TextField();
			
			var verticalSpace:Number  = 13;
			
			mTotalObjectsTxt.x = leftAlign;
			mTotalObjectsTxt.y = topAlign;
			
			mActiveObjectsTxt.x = leftAlign;
			mActiveObjectsTxt.y = topAlign + verticalSpace;
			
			mStaticKeypointsTxt.x = leftAlign;
			mStaticKeypointsTxt.y = topAlign + 2*verticalSpace;
			
			mTotalObjectsTxt.text 		= "Objects: ";
			mActiveObjectsTxt.text 		= "Active KeyPt: ";
			mStaticKeypointsTxt.text 	= "Static KeyPt: ";
			
			mTotalObjectsTxt.selectable 	= false;
			mActiveObjectsTxt.selectable 	= false;
			mStaticKeypointsTxt.selectable 	= false;
			
			mTotalObjectsTxt.textColor 		= 0xDDFFDD;
			mActiveObjectsTxt.textColor 	= 0xDDFFDD;
			mStaticKeypointsTxt.textColor 	= 0xDDFFDD;
			
			var textScaleFactor:Number = .9;
			
			mTotalObjectsTxt.scaleX 	= textScaleFactor;
			mTotalObjectsTxt.scaleY 	= textScaleFactor;
			
			mActiveObjectsTxt.scaleX 	= textScaleFactor;
			mActiveObjectsTxt.scaleY 	= textScaleFactor;
			
			mStaticKeypointsTxt.scaleX 	= textScaleFactor;
			mStaticKeypointsTxt.scaleY 	= textScaleFactor;
			
			addChild(mTotalObjectsTxt);
//			addChild(mActiveObjectsTxt);
//			addChild(mStaticKeypointsTxt);
			
		}
		
		/** Set the text label for the total number of objects. */
		public function setTotalObjectsTxt( value:Number ) : void {
			mTotalObjectsTxt.text 	= "Time: " + value.toFixed(2);
		}
		
		/** Set the text label for the total number of active objects. */
		public function setActiveObjectsTxt( value:uint ) : void{
			mActiveObjectsTxt.text 	= "Active KeyPt: " + value;
		}
		
		/** Set the text label for the total number of static keypoints. */
		public function setStaticKeypointsTxt( value:uint ) : void {
			mStaticKeypointsTxt.text = "Static KeyPt: " + value;
		}
		
		/** Draw vertical tick marks indicate the timeline position of each beat and measure. */
		private function drawBeatIntervals( ) : void {
			
			var numMeasures : Number 		=  mTimeSignatureData.getNumMeasures();
			var numBeatsPerMeasure:Number 	= mTimeSignatureData.getNumBeatsPerMeasure();
			
			// For each measure draw the measure line
			for( var i:uint=0; i<numMeasures; i++ ) {
				
				var measureFraction:Number = (i/numMeasures);
				var newMeasureStartLine:Shape = new Shape();
				
				newMeasureStartLine.x = TIMELINE_X + measureFraction*(TIMELINE_WIDTH);
				newMeasureStartLine.y = TIMELINE_Y;
				
				newMeasureStartLine.graphics.lineStyle(2, 0xFF9944, 0.5);
				newMeasureStartLine.graphics.lineTo( 0, TIMELINE_HEIGHT );
				
				addChild(newMeasureStartLine);
				
				// For each beat within the measure draw the beat line
				for( var j:uint=1; j<numBeatsPerMeasure; ++j ) {
					var newSubLine:Shape = new Shape();
					
					var beatFraction:Number = j*((TIMELINE_WIDTH/numMeasures)/numBeatsPerMeasure);
					
					newSubLine.x = newMeasureStartLine.x + (beatFraction);
					newSubLine.y = TIMELINE_Y;
					
					newSubLine.graphics.lineStyle(1, 0xCCCCFF, .3);
					newSubLine.graphics.lineTo(0, TIMELINE_HEIGHT);
					
					addChild(newSubLine);
				}
				
			}
		}
		
		/** Removes all keypoint shapes from the timeline*/
		public function clearKeypointShapes() : void {
			// clear any existing keypoint markers on the timeline.
			for(var i:uint=0; i<mKeypointMarkers.length; ++i) {
				var Temp:Sprite = mKeypointMarkers.pop();
				this.removeChild( Temp );
				Temp = null;
			}
		}
		
		/** Removes all dynamic keypoint shapes from the timeline*/
		public function clearDynamicKeypointShapes() : void {
			// clear any existing dynamic keypoint markers on the timeline.
			for(var i:uint=0; i<mDynamicKeypointMarkers.length; ++i) {
				var Temp:Shape = mDynamicKeypointMarkers.pop();
				this.removeChild( Temp );
				Temp = null;
			}
		}
		
		/** 
		 * Todo: 
		 * When an action is performed visual tick is rendered in the timeline. 
		 */ 
		public function addKeypointShape( pTimeline:ConductorTimeline, pNewTween:TweenCore, startTime:Number = 0 ) : void {
			
			if(pNewTween is SimpleTimeline ) {
				var ChildList:Array = (pNewTween as TimelineLite).getChildren();
				
				for(var i:uint=0; i<ChildList.length; ++i) {
					addKeypointShape(pTimeline, (ChildList[i] as TweenCore), startTime );
				}
			}
			
			while(pNewTween != null) {
				
				var NewTweenSprite:Sprite = new Sprite();
				
				var timeStartFraction:Number;
				
				timeStartFraction 	= (startTime+pNewTween.startTime) / pTimeline.totalDuration;
				
				var durationFraction:Number 	= pNewTween.totalDuration / pTimeline.totalDuration;
				
				NewTweenSprite.x = (TIMELINE_X) + ( timeStartFraction * TIMELINE_WIDTH );
				NewTweenSprite.y = TIMELINE_Y+1;
				
				var color:uint = Math.random() * Math.pow( 2, 24 );
				
				NewTweenSprite.graphics.lineStyle(1, 0x0000FF, 1);
				
				NewTweenSprite.graphics.beginFill( color, 0.2 );
				NewTweenSprite.graphics.drawRect(0, 0, durationFraction*TIMELINE_WIDTH, TIMELINE_HEIGHT-2);
				
				//NewTweenSprite.addEventListener(MouseEvent.MOUSE_MOVE, onScrub);
				mTimeLineBG.addChild(NewTweenSprite);
				
				pNewTween = pNewTween.nextNode;
			}
		}
		
		
		/** Updates the position of the timeline cursor on the timeline */
		public function redrawTimelineCursor( mTotalTimeElapsed:Number ) : void {
			var timeFraction:Number = mTotalTimeElapsed / mTimeSignatureData.getTrackDurationSeconds();
			
			mTimeCursor.x = timeFraction*(TIMELINE_WIDTH) % TIMELINE_WIDTH;
		}
		
		/** Renders the graphical elements for the play button and places them on the timeline. */
		private function drawPlayButton() : void {
			mPlayButton = new Sprite();
			
			mPlayButton.x = TIMELINE_X + TIMELINE_WIDTH/2 + 40;
			mPlayButton.y = TIMELINE_Y + TIMELINE_HEIGHT + 18;
			
			mPlayButton.graphics.beginFill(0x55FF55, 1.0);
			mPlayButton.graphics.drawCircle(0, 0, 15);
			mPlayButton.graphics.lineStyle(1, 0x000000);
			mPlayButton.graphics.moveTo(-5, -5);
			mPlayButton.graphics.lineTo(7, 0);
			mPlayButton.graphics.lineTo(-5, 7);
			mPlayButton.graphics.lineTo(-5, -5);
			mPlayButton.graphics.beginFill(0xFF3311, 1.0);
			
			//addChild(mPlayButton);
			
			mPlayButton.addEventListener(MouseEvent.MOUSE_DOWN, onPressPlayBtn );
		}
		
		/** Renders the graphical elements for the play button and places them on the timeline. */
		private function drawPauseButton() : void {
			mPauseButton = new Sprite();
			
			mPauseButton.x = TIMELINE_X + TIMELINE_WIDTH/2;
			mPauseButton.y = TIMELINE_Y + TIMELINE_HEIGHT + 18;
			
			mPauseButton.graphics.beginFill(0xFFFF22, 1.0);
			mPauseButton.graphics.drawCircle(0, 0, 15);
			mPauseButton.graphics.lineStyle(1, 0x000000);
			mPauseButton.graphics.moveTo(-5, -5);
			mPauseButton.graphics.lineTo(7, 0);
			mPauseButton.graphics.lineTo(-5, 7);
			mPauseButton.graphics.lineTo(-5, -5);
			mPauseButton.graphics.beginFill(0xFF3311, 1.0);
			
			//addChild(mPauseButton);
			
			mPauseButton.addEventListener(MouseEvent.MOUSE_DOWN, onPressPauseBtn );
		}
		
		/** Renders the graphical elements for the play button and places them on the timeline. */
		private function drawReverseButton() : void {
			mReverseButton = new Sprite();
			
			mReverseButton.x = TIMELINE_X + TIMELINE_WIDTH/2-40;
			mReverseButton.y = TIMELINE_Y + TIMELINE_HEIGHT + 18;
			
			mReverseButton.graphics.beginFill(0xFF3311, 1.0);
			mReverseButton.graphics.drawCircle(0, 0, 15);
			mPlayButton.graphics.lineStyle(1, 0x000000);
			mReverseButton.graphics.moveTo(5, 5);
			mReverseButton.graphics.lineTo(-7, 0);
			mReverseButton.graphics.lineTo(5, -7);
			mReverseButton.graphics.lineTo(5, 5);
			mReverseButton.graphics.beginFill(0xFF3311, 1.0);
			
			//addChild(mReverseButton);
			
			mReverseButton.addEventListener(MouseEvent.MOUSE_DOWN, onPressReverseBtn );
		}
		
		/** Renders the graphical elements for the play button and places them on the timeline. */
		private function drawStepForwardButton() : void {
			mStepForwardButton = new Sprite();
			
			mStepForwardButton.x = TIMELINE_X + TIMELINE_WIDTH/2+80;
			mStepForwardButton.y = TIMELINE_Y + TIMELINE_HEIGHT + 18;
			
			mStepForwardButton.graphics.beginFill(0x11FF11, 1.0);
			mStepForwardButton.graphics.drawCircle(0, 0, 15);
			mStepForwardButton.graphics.beginFill(0xFF3311, 1.0);
			
			//addChild(mStepForwardButton);
			
			mStepForwardButton.addEventListener(MouseEvent.MOUSE_DOWN, onPressStepForwardBtn );
		}
		
		/** Renders the graphical elements for the play button and places them on the timeline. */
		private function drawStepBackButton() : void {
			mStepBackwardButton = new Sprite();
			
			mStepBackwardButton.x = TIMELINE_X + TIMELINE_WIDTH/2-80;
			mStepBackwardButton.y = TIMELINE_Y + TIMELINE_HEIGHT + 18;
			
			mStepBackwardButton.graphics.beginFill(0x11FF11, 1.0);
			mStepBackwardButton.graphics.drawCircle(0, 0, 15);
			mStepBackwardButton.graphics.beginFill(0xFF3311, 1.0);
			
			//addChild(mStepBackwardButton);
			
			mStepBackwardButton.addEventListener(MouseEvent.MOUSE_DOWN, onPressStepBackwardBtn );
		}
		
		private function onPressPlayBtn(Evt:MouseEvent) : void {
			
			mMainTimeline.paused = false;
			mMainTimeline.reversed = false;
			mMainTimeline.resume();
		}
		
		private function onPressPauseBtn(Evt:MouseEvent) : void {
			
			mMainTimeline.paused = true;
			mMainTimeline.pause();
		}
		
		private function onPressReverseBtn(Evt:MouseEvent) : void {
			mMainTimeline.paused = false;
			mMainTimeline.reversed = true;
			mMainTimeline.reverse(true);
		}
		
		private function onPressStepForwardBtn(Evt:MouseEvent) : void {
			
			mMainTimeline.gotoAndStop( mMainTimeline.currentTime + 1/stage.frameRate );
		}
		
		private function onPressStepBackwardBtn(Evt:MouseEvent) : void {
			mMainTimeline.gotoAndStop( mMainTimeline.currentTime - 1/stage.frameRate );
		}
		
		public function getWidth() : Number {
			return TIMELINE_WIDTH;
		}
		
		public function getHeight() : Number {
			return TIMELINE_HEIGHT;
		}
		
		
	}
}