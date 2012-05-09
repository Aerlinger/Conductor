package com.time
{
	
	import com.anim.*;
	import com.element.*;
	import com.event.*;
	import com.sprites.*;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	
	/** Central timekeeper
	 * 
	 * @author Anthony Erlinger
	 */
	public class Timeline implements IEventDispatcher
	{
		
		// Member objects
		private var mParent:MovieClip;
		
		private var mTimeSignatureData:TimeSignatureData;
		
		private var mTimelineSprite:TimelineSprite;	// Visual object for the Timeline
		private var mMetronome:Metronome;			// Metronome object, pulses each beat and measure.
		
		private var mMainTimer:PreciseTimer;
		
		// When an action is called off the start time (eg. AnnulusElement.pulse())
		private var mStaticKeypoints:Vector.<Keypoint> = new Vector.<Keypoint>();
		// When an unscripted action is called (off the timeline eg. AnnulusElement.pulse()) The start time is recorded within this array.
		private var mDynamicKeypointStartTimes:Vector.<Number> = new Vector.<Number>();
		
		
		// Member Variables
		private var mCurrentBeatNum:uint 		= 0;	// How many beats have gone by since we started?
		private var mBeatNumForThisMeasure:uint = 0;	// How many beats have started this measure?
		private var mCurrentMeasureNum:uint 	= 0;	// How many measures have we started?
		
		private var mTotalSecondsElapsed:Number = 0;		// Number of seconds elapsed
		private var mMillisecondsElapsedThisMeasure:Number;	// Number of milliseconds elapsed this measure
		private var mMillisecondsElapsedThisBeat:Number;	// Number of milliseconds elapsed since the onset of this beat.
		
		
		// playback variables:
		private var mIsPaused:Boolean = false;
		
		// time tracking variables for beat and measure
		private var lastStartBeatTime:Number;
		private var lastMeasureStartTime:Number;
		
		private var mFrameDuration:Number; 		// Length of each frame in ms.
		
		public var name:String;
		
		// Stores all parent elements
		private var mElementList:Vector.<BaseElement>;
		
		
		
		/** Creates a new instance of our timeline.
		 * 
		 * @param pParent The MovieClip to which this timeline belongs to.
		 * @param pBpm Beats per minute
		 * @param pBeatsPerMeasure How many beats occur every measure
		 * @param pNumMeasures The number of measures in this track
		 * @param pFrameDurationMillis The internal timer of the Timeline dispatches an event every pFrameDurationMillis
		 */
		public function Timeline( pParent:MovieClip, pBpm:Number, pBeatsPerMeasure:Number, pNumMeasures:Number, pFrameDurationMillis:Number ) {
			
			mParent 		= pParent;
			mFrameDuration 	= pFrameDurationMillis;
			
			mTimeSignatureData 	= new TimeSignatureData( pBpm, pBeatsPerMeasure, pNumMeasures );
			mTimelineSprite 	= new TimelineSprite(pParent, mTimeSignatureData);
			mMetronome 			= new Metronome(pParent, 1000 - 100, 1000 - 200, pBeatsPerMeasure);
			
			mMainTimer 			= new PreciseTimer(mParent, pFrameDurationMillis);
			mMainTimer.addEventListener(TimerEvent.TIMER, onTimerUpdate);
			
			mMainTimer.start();
			
			lastStartBeatTime	 = getTimer();
			lastMeasureStartTime = getTimer();
			
			mTimeSignatureData.getMeasureDurationSeconds();
			
			mMillisecondsElapsedThisMeasure	= 2000*mTimeSignatureData.getMeasureDurationSeconds();  // Number of milliseconds elapsed this measure
			mMillisecondsElapsedThisBeat 	= 2000*mTimeSignatureData.getBeatDurationSeconds();		// Number of milliseconds elapsed since the onset of this beat.
			
			this.name = "TimelineDefault";
			
			mElementList = new Vector.<BaseElement>();
			
			pParent.addChild(mTimelineSprite);
		}
		
		
		/** Main loop of program: 
		 * 		This function is called internally within mMainTimer every time it
		 *      dispatches an event. */
		private function onTimerUpdate( TimerEvt:TimerEvent ) : void {
			
			if(!mIsPaused) {
			
				// Record the exact start time that we begin this handler
				var startTimerHandler:Number = getTimer();
				
				// Update the time of our metronome (to update the timer text label).
				mMetronome.updateTimer(mMainTimer.getTotalSecondsElapsed());
				
				// Update the progress position of the horizontal timeline.
				mTimelineSprite.redrawTimelineCursor( mMainTimer.getTotalSecondsElapsed() );
				
				
				// Iterate through each keypoint on this timeline to check if it needs to be run
				for( var i:uint=0; i< mStaticKeypoints.length; ++i ) {
					var mThisStartTime:Keypoint = mStaticKeypoints[i];
					
					if( mMainTimer.getTotalSecondsElapsed() > mThisStartTime.getStartTimeSeconds() )  {
						mThisStartTime.start();
					}
				}
				
				
				// Store a global variable for the number of seconds elapsed.
				mTotalSecondsElapsed = mMainTimer.getTotalSecondsElapsed();
				
				mMillisecondsElapsedThisMeasure += (getTimer()-lastStartBeatTime);
				lastMeasureStartTime = getTimer();
				
				var remainder:Number = 0;
				
				// Each time we start a new measure increment the number of elapsed measures. (This must execute at t=0);
				if(mMillisecondsElapsedThisMeasure >= mTimeSignatureData.getMeasureDurationSeconds() * 1000 ) {
					remainder =  mMillisecondsElapsedThisMeasure % (mTimeSignatureData.getMeasureDurationSeconds()*1000);
					mMillisecondsElapsedThisMeasure = remainder;
					this.mCurrentMeasureNum++;
					
					onMeasureStart();
					trace("\tMEAS " + mMainTimer.getTotalSecondsElapsed().toFixed(3) + " # "+ mCurrentMeasureNum + " started:   t= " + mTotalSecondsElapsed/1000 +  "  (r="+remainder+")");
				}
				
				
				mMillisecondsElapsedThisBeat += (getTimer()-lastStartBeatTime);
				lastStartBeatTime = getTimer();
				
				
				if(mMillisecondsElapsedThisBeat >= mTimeSignatureData.getBeatDurationSeconds()*1000 ) {
	
					remainder = mMillisecondsElapsedThisBeat % (mTimeSignatureData.getBeatDurationSeconds()*1000);
					// Reset the number of milliseconds elapsed this beat to whatever the remainder is.
					mMillisecondsElapsedThisBeat = remainder;
					
					// mCurrentBeatNum Repeats cyclically 1, 2, 3, 4, 5, 6, 1, 2...
					this.mBeatNumForThisMeasure = (mCurrentBeatNum % (mTimeSignatureData.getNumBeatsPerMeasure())) + 1;
					
					this.mCurrentBeatNum++;
					
					trace("\t\tBEAT: " + mMainTimer.getTotalSecondsElapsed().toFixed(3) + " # " + mBeatNumForThisMeasure + "/" + mTimeSignatureData.getNumBeatsPerMeasure() + "  (#"+this.mCurrentBeatNum + ") in measure " + mCurrentMeasureNum + " started: r="+remainder + " ms.");
					
					//if(mBeatNumForThisMeasure != 1 )
					onBeatStart(mBeatNumForThisMeasure);
					
				}
			
			}
		}
		
		/** Called at the start of every beat. */
		private function onBeatStart(beatNumber:Number) : void {
			
			this.dispatchEvent( new BeatEvent(BeatEvent.BEAT_START) );
			
			mMetronome.subBeat(beatNumber);
			//mPulseAction.start();
			
			//mBeatAnnulus.flower(6, 50);
			
			//mBeatAnnulus.dilate();
			//mBeatAnnulus.flare();
			//mBeatAnnulus.pulse();
			
			// TODO: Notify listeners of beat start event.
		}
		
		/** Called at the start of every measure. */
		private function onMeasureStart() : void {
			
			this.dispatchEvent( new MeasureEvent(MeasureEvent.MEASURE_START) );
			
			mMetronome.downBeat();
			
			//for( var i=0; i<mNumMeasuresElapsed; ++i ) {
			//	mBeatAnnulus.flower(2^i, (50*i)%(50*mNumMeasures), i/2  );
			//}
			
			// TODO: Notify listeners of Measure start event.
		}
		
		
		
		///////////////////////////////////////////////////////
		// Keypoint functions
		///////////////////////////////////////////////////////
		
		/** Adds a scripted (static) action to the timeline to act on a target element at the specified start time */
		public function addStaticKeypoint( pStartTime:Number, pAction:ActionNode, pTargetElements:BaseElement ) : Keypoint {
			
			var NewKeypoint:Keypoint = new Keypoint(pStartTime, pAction, pTargetElements)
			
			mStaticKeypoints.push( NewKeypoint );
			
			mTimelineSprite.addStaticKeypointShape( this, NewKeypoint );
			
			trace("Keypoint added: " + NewKeypoint.toString() );
			
			return NewKeypoint;
		}
		
		/** Adds an a action to the timeline to act on a target element at the specified start time */
		public function addDynamicKeypoint( pAction:ActionNode, pTargetElements:BaseElement ) : void {
			
			var NewKeypoint:Keypoint = new Keypoint(this.getTotalSecondsElapsed()+pAction.getStartTimeOfThisAction(), pAction, pTargetElements)
			trace(pAction.toString());
			mTimelineSprite.addDynamicKeypointShape( this, NewKeypoint );
		}
		
		public function numKeypoints() : uint {
			return mStaticKeypoints.length;
		}
		
		public function getKeypoint(index:Number) : Keypoint  {
			return (mStaticKeypoints[index] as Keypoint);
		}
		
		/*
		public function redrawKeypoints() : void {
			mTimelineSprite.redrawKeypoints(this);
		}*/
		
		
		/*
		public function addDynamicKeypoint(pAction:Action) : void {
			trace("Dynamic Keypoint Added: " + getTotalSecondsElapsed());
			var NewKeypoint:Keypoint = new Keypoint(getTotalSecondsElapsed());
			NewKeypoint.setAction(pAction);
			
			mDynamicKeypointStartTimes.push(NewKeypoint);
			mTimelineSprite.addKeypoint(this, NewKeypoint);
			//mTimelineSprite.redrawDynamicKeypoints(this);
		}
		
		public function getDynamicKeypoint(index:Number) : Keypoint {
			return (mDynamicKeypointStartTimes[index] as Keypoint);
		}
		
		public function numDynamicKeypoints() : uint {
			return mDynamicKeypointStartTimes.length;
		}
		*/
		
		///////////////////////////////////////////////////////
		// Accessor functions for objects
		///////////////////////////////////////////////////////
		public function getParent() : MovieClip {
			return mParent;
		}

		public function getTimelineSprite() : TimelineSprite {
			return mTimelineSprite;
		}
		
		public function getMainTimer() : PreciseTimer {
			return mMainTimer;
		}
		
		/** pauses this timeline and any actions associated with it */
		public function setPaused( isPaused:Boolean ) : void {
			mMainTimer.pause(isPaused);
			mIsPaused = isPaused;
		}
		
		public function getIsPaused() : Boolean {
			return mIsPaused;
		}
		
		/////////////////////////////////////////////////
		// Time signature accessor functions:
		/////////////////////////////////////////////////
		public function getBPM() : Number {
			return mTimeSignatureData.getBPM();
		}
		
		public function getNumBeatsPerMeasure() : uint {
			return mTimeSignatureData.getNumBeatsPerMeasure();
		}
		
		public function getNumMeasures() : uint {
			return mTimeSignatureData.getNumMeasures();
		}
		
		public function getDuration() : Number {
			return mTimeSignatureData.getTrackDurationSeconds();
		}
		
		public function getDurationOfMeasure() : Number {
			return mTimeSignatureData.getMeasureDurationSeconds();
		}
		
		public function getDurationOfBeat() : Number {
			return mTimeSignatureData.getBeatDurationSeconds();
		}
		
		public function getDurationOfTrack() : Number {
			return mTimeSignatureData.getTrackDurationSeconds();
		}
		
		///////////////////////////////////////////////////////
		// Accessor methods for variables
		///////////////////////////////////////////////////////
		
		public function getCurrentBeatNum() : uint {
			return this.mCurrentBeatNum;
		}
		
		public function getBeatNumForThisMeasure() : uint {
			return this.mBeatNumForThisMeasure;
		}
		
		public function getCurrentMeasureNum() : uint {
			return this.mCurrentMeasureNum;
		}
		
		public function getTotalSecondsElapsed() : Number {
			return this.mTotalSecondsElapsed;
		}
		
		public function getMillisElapsedThisMeasure() : Number {
			return this.mMillisecondsElapsedThisMeasure;
		}
		
		public function getMillisElapsedThisBeat() : Number {
			return this.mMillisecondsElapsedThisBeat;
		}
		
		public function getFrameDuration() : Number {
			return this.mFrameDuration;
		}
		
		
		
		///////////////////////////////////////////
		// Event handling: 
		///////////////////////////////////////////
		
		/** Callback function: When an Element is added to the stage it is registered with the ColorWheelMain class
		 *   through the mElementListArray.
		 *  
		 * This method should not be called manually, it is called from the BaseElement class listener. */
		public function registerElement( NewElement:BaseElement ) : void {
			mElementList.push( NewElement );
		}
		
		/** Callback function: When an Element is removed the stage it is removed from the mElementList array. 
		 * This method should not be called manually, it is called from the BaseElement class listener. */
		public function unregisterElement( RemovedElement:BaseElement ) : void {
			var removeIdx:uint = mElementList.lastIndexOf(RemovedElement);
			mElementList.splice(removeIdx, 1);
			
			RemovedElement = null;
		}
		
		
		/** Add an event listener to be executed each time the PreciseTimer (mMainTimer) ticks.
		 *   Events handled by the timeline will be directly bound to the mMainTimer Object.
		 */
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			mMainTimer.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return mMainTimer.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return mMainTimer.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			mMainTimer.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return mMainTimer.willTrigger(type);
		}
		
		
	}
}