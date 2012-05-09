package com.time
{
	
	import com.element.*;
	import com.event.*;
	import com.greensock.*;
	import com.greensock.core.*;
	import com.greensock.events.TweenEvent;
	import com.sound.MusicPlayer;
	import com.ui.*;
	
	import fl.transitions.Tween;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	
	
	
	/** Central timeline of Conductor, only one instance of this class should exist in the program. The 
	 * timeline is uniquely tied to the timeline of a musical track. All animation should be done through 
	 * this class with the insert(), insertAll(), append() and appendAll() functions.
	 * 
	 * The parent of this timeline is _root
	 * 
	 * @author Anthony Erlinger
	 */
	public class ConductorTimeline extends TimelineMax
	{
		
		private var mTimeSignatureData:TimeSignatureData;
		
		private var mTimelineSprite:TimelineSprite;	// Visual object for the Timeline
		private var mMetronome:Metronome;			// Metronome object, pulses each beat and measure.
		private var mMusicPlayer:MusicPlayer; 
		
		
		// Member Variables
		private var mCurrentBeatNum:uint 		= 0;	// How many beats have gone by since we started?
		private var mBeatNumForThisMeasure:uint = 0;	// How many beats have started this measure?
		private var mCurrentMeasureNum:uint 	= 0;	// How many measures have we started?
		
		private var mTotalSecondsElapsed:Number = 0;	// Number of seconds elapsed
		private var mSecondsElapsedThisMeasure:Number;	// Number of milliseconds elapsed this measure
		private var mSecondsElapsedThisBeat:Number;		// Number of milliseconds elapsed since the onset of this beat.
		
		// time tracking variables for beat and measure
		private var lastStartBeatTime:Number;
		private var lastMeasureStartTime:Number;
		
		private static var mHasBeenInstantiated:Boolean = false;
		
		public var name:String = "TimelineDefault";
		
		
		
		/** Creates a new instance of our timeline.
		 * 
		 * @param pParent The MovieClip to which this timeline belongs to.
		 * @param pBpm Beats per minute
		 * @param pBeatsPerMeasure How many beats occur every measure
		 * @param pNumMeasures The number of measures in this track
		 * @param pFrameDurationMillis The internal timer of the Timeline dispatches an event every pFrameDurationMillis
		 */
		function ConductorTimeline( pParent:MovieClip, pBpm:Number, pBeatsPerMeasure:Number, pNumMeasures:Number ) {
			
			super({paused:true, onStart:this.onTimelineStart(), onComplete:this.onTimelineEnd()});
			
			if(mHasBeenInstantiated)
				throw new Error("Error: instantiation failed on singleton class Timeline, use Timeline.getInstance() instead");
			
			mHasBeenInstantiated = true;
			
			mTimeSignatureData 	= new TimeSignatureData( pBpm, pBeatsPerMeasure, pNumMeasures );
			mTimelineSprite 	= new TimelineSprite(pParent, mTimeSignatureData);
			mMetronome 			= new Metronome(Conductor.getCenterX(), Conductor.getCenterY()-25, pBeatsPerMeasure);
			setMusic("What_is_love.mp3");
			
			pParent.addChild(mMetronome);
			
			// Used to stretch the timeline 
			super.insert( new TweenLite({}, 0, {}), mTimeSignatureData.getTrackDurationSeconds() );
			
			lastStartBeatTime	 = 0;
			lastMeasureStartTime = 0;
			
			mTimeSignatureData.getMeasureDurationSeconds();
			
			mSecondsElapsedThisMeasure	= 2*mTimeSignatureData.getMeasureDurationSeconds(); // Number of milliseconds elapsed this measure
			mSecondsElapsedThisBeat 	= 2*mTimeSignatureData.getBeatDurationSeconds();	// Number of milliseconds elapsed since the onset of this beat.
			
			pParent.addChild(mTimelineSprite);
		}
		
		public function setMusic(name:String) {
			mMusicPlayer = new MusicPlayer(name);
		}
		
		override public function resume() : void
		{
			super.resume();
			mMusicPlayer.resume();
		}
		
		
		/** 
		 * TODO: Not yet implemented
		 */
		public function insertAtBeat(pTween:TweenCore, measureNum:Number, beatNum:Number ) : TweenCore  {
			var startTime:Number = mTimeSignatureData.beatToSeconds(measureNum, beatNum);
			
			return insert(pTween, startTime);
		}
		
		/** 
		 * TODO: Not yet implemented
		 */
		public function beatToTime(measureNum:uint, beatNumWithinMeasure:uint) : Number {
			
			return measureNum * mTimeSignatureData.getMeasureDurationSeconds() + beatNumWithinMeasure * mTimeSignatureData.getBeatDurationSeconds();
		}
		
		/** Retrieves the Element(s) which are associated with a tween 
		 * @param pTween the Tween object from which to retrieve the elements from this array*/
		public static function getElementsFromTweenCore(pTween:TweenCore) : Array {
			var ReturnElements : Array = new Array();
			
			if(pTween is TimelineLite) {
				var ThisTweenTimeline:TimelineLite = pTween as TimelineLite;
				
				ReturnElements.push( ThisTweenTimeline.getChildren() );
			} else if (pTween is TweenLite) {
				var ThisTween:TweenLite = pTween as TweenLite;
				
				ReturnElements.push(ThisTween.target);
			}
			
			return ReturnElements;
			
		}
		
		/** Inserts a tween at the specified time
		 */
		override public function insert(pTween:TweenCore, startTimeInBeats:*=0):TweenCore
		{	
			var startTimeInSeconds:Number = Conductor.getTimeline().beatsToSeconds(startTimeInBeats);
			
			var ReturnCore:TweenCore = super.insert(pTween, startTimeInSeconds);
			
			mTimelineSprite.addKeypointShape(this, pTween);
			trace( "Tween (" + name + ") added to timeline: " + pTween.startTime + " / " + pTween.totalDuration);
			
			return ReturnCore;
		}
		
		/** Same as insert() only the Tween is applied immediately (at the current time of the timeline)
		 */
		public function insertNow(pTween:TweenCore) : void {
			insert(pTween, this.currentTime);
		}
		
		/** Overrides the TimelineMax class to render each Tween in the timeline.
		 * @see TimelineMax */
		override public function insertMultiple(tweens:Array, timeOrLabel:*=0, align:String="normal", stagger:Number=0):Array
		{
			var ReturnValues:Array = super.insertMultiple(tweens, timeOrLabel, align, stagger);
			
			for ( var i:uint=0; i<tweens.length; ++i ) {
				var ThisTween:TweenCore = (tweens[i] as TweenCore);
				var ThisObject:Object = (ThisTween as TweenLite).target;
				
				if( !(ThisObject is BaseElement) ) {
					throw new Error("Attempted to add a non-Element to the main timeline");
				}
				
				var name:String = (ThisTween is TweenLite) ? ((ThisTween as TweenLite).target as BaseElement).name : "Default";
				
				trace( "Tween (" + name + ") added to timeline: " + ThisTween.startTime + " / " + ThisTween.totalDuration);
				
				// Add the tween to the main timeline
				mTimelineSprite.addKeypointShape(this, ThisTween);
			}
			
			return ReturnValues;
		}
		
		/** Called when this timeline begins */
		private function onTimelineStart() : void {
			trace(">>> Timeline Started <<<");
		}
		
		/** Called when this timeline begins */
		private function onTimelineEnd() : void {
			trace(">>> Timeline Completed <<<");
		}
		
		/** Called at the start of every beat. */
		private function onBeatStart(beatNumber:Number) : void {
			this.dispatchEvent( new BeatEvent(BeatEvent.BEAT_START) );
			
			mMetronome.subBeat(beatNumber);
		}
		
		/** Called at the start of every measure. */
		private function onMeasureStart() : void {
			this.dispatchEvent( new MeasureEvent(mCurrentMeasureNum, MeasureEvent.MEASURE_START) );
			
			mMetronome.downBeat();
		}
		
		
		///////////////////////////////////////////////////////
		// Accessor functions for objects
		///////////////////////////////////////////////////////

		/** Gets the graphical sprite associated with this timeline */
		public function getTimelineSprite() : TimelineSprite {
			return mTimelineSprite;
		}
		
		/////////////////////////////////////////////////
		// Time signature accessor functions:
		/////////////////////////////////////////////////
		/** Gets the beats per minute of this track */
		public function getBPM() : Number {
			return mTimeSignatureData.getBPM();
		}
		
		/** Gets the number of beats per measure */
		public function getNumBeatsPerMeasure() : uint {
			return mTimeSignatureData.getNumBeatsPerMeasure();
		}
		
		/** Gets the total number of measures in this track */
		public function getNumMeasures() : uint {
			return mTimeSignatureData.getNumMeasures();
		}
		
		/** Gets the total duration of this track */
		public function getDuration() : Number {
			return mTimeSignatureData.getTrackDurationSeconds();
		}
		
		/** Gets the duration of each measure in this track */
		public function getDurationOfMeasure() : Number {
			return mTimeSignatureData.getMeasureDurationSeconds();
		}
		
		/** Gets the duration of each beat in this track */
		public function getDurationOfBeat() : Number {
			return mTimeSignatureData.getBeatDurationSeconds();
		}
		
		///////////////////////////////////////////////////////
		// Accessor methods for variables
		///////////////////////////////////////////////////////
		/**
		 * The current beat number for this track 
		 */
		public function getCurrentBeatNum() : uint {
			return this.mCurrentBeatNum;
		}
		
		/**
		 * The current beat number for this measure (bound between 0-numMeasures)
		 */
		public function getBeatNumForThisMeasure() : uint {
			return this.mBeatNumForThisMeasure;
		}
		
		/**
		 * Get the current measure (starts at 0)
		 */
		public function getCurrentMeasureNum() : uint {
			return this.mCurrentMeasureNum;
		}
		
		/**
		 * Gets the number of seconds that have elapsed since the start of this measure
		 */
		public function getSecondsElapsedThisMeasure() : Number {
			return this.mSecondsElapsedThisMeasure;
		}
		
		/**
		 * Gets the number of seconds that have elapsed since the start of this beat
		 */
		public function getSecondsElapsedThisBeat() : Number {
			return this.mSecondsElapsedThisBeat;
		}
		
		/**
		 * Called every time that the internal timer updates this timeline.
		 */ 
		override public function renderTime(time:Number, suppressEvents:Boolean=false, force:Boolean=false):void
		{
			super.renderTime(time, suppressEvents, force);
			
			mSecondsElapsedThisMeasure += (time-lastMeasureStartTime);
			lastMeasureStartTime = time;
			
			var remainder:Number = 0;
			
			// Each time we start a new measure increment the number of elapsed measures. (This must execute at t=0);
			if(mSecondsElapsedThisMeasure >= mTimeSignatureData.getMeasureDurationSeconds() ) {
				remainder =  mSecondsElapsedThisMeasure % (mTimeSignatureData.getMeasureDurationSeconds());
				mSecondsElapsedThisMeasure = remainder;
				this.mCurrentMeasureNum++;
				
				onMeasureStart();
				trace("\tMEAS " + this.currentTime.toFixed(3) + " # "+ mCurrentMeasureNum + " started:   t= " + mTotalSecondsElapsed/1000 +  "  (r="+remainder+")");
			}
			
			mSecondsElapsedThisBeat += (time-lastStartBeatTime);
			lastStartBeatTime = time;
			
			if(mSecondsElapsedThisBeat >= mTimeSignatureData.getBeatDurationSeconds() ) {
				
				remainder = mSecondsElapsedThisBeat % (mTimeSignatureData.getBeatDurationSeconds());
				// Reset the number of milliseconds elapsed this beat to whatever the remainder is.
				mSecondsElapsedThisBeat = remainder;
				
				// mCurrentBeatNum Repeats cyclically 1, 2, 3, 4, 5, 6, 1, 2...
				this.mBeatNumForThisMeasure = (mCurrentBeatNum % (mTimeSignatureData.getNumBeatsPerMeasure())) + 1;
				
				this.mCurrentBeatNum++;
				
				trace("\t\tBEAT: " + this.currentTime.toFixed(3) + " # " + mBeatNumForThisMeasure + "/" + mTimeSignatureData.getNumBeatsPerMeasure() + "  (#"+this.mCurrentBeatNum + ") in measure " + mCurrentMeasureNum + " started: r="+remainder + " ms.");
				
				onBeatStart(mBeatNumForThisMeasure);
				
			}
			
			var rotationAngle:Number = this.currentTime/this.totalDuration * 360;
			
			this.dispatchEvent( new Event( TweenEvent.UPDATE ) );
			mTimelineSprite.redrawTimelineCursor( this.currentTime );
			
		}
		
		/**
		 * Each measure/beat has a specific duration in seconds, this function converts a number of measures to the duration in seconds
		 */
		public function measureNumberToSeconds(measureNum:Number, beatNum:Number) : Number {
			if(beatNum>mTimeSignatureData.getNumBeatsPerMeasure())
				throw new Error("attempted to access a beat number that is larger than the quantity of beats per measure.");
			
			return ((measureNum) * mTimeSignatureData.getMeasureDurationSeconds()) + ((beatNum) * mTimeSignatureData.getBeatDurationSeconds());
		}
		
		/**
		 * Each beat has a specific duration in seconds, this function converts a number of beats to its duration in seconds
		 */
		public function beatsToSeconds(beatNum:Number) : Number {
			return (beatNum * mTimeSignatureData.getBeatDurationSeconds());
		}
		
		/**
		 * @param A duration in seconds
		 * @return the number of beats (or fraction thereof) that span the duration 
		 */
		public function secondsToBeats(pDurationInSeconds:Number) : Number {
			return (pDurationInSeconds/mTimeSignatureData.getBeatDurationSeconds());
		}
		
		
		override public function set paused(isPause:Boolean):void
		{
			super.paused = isPause;
			if(mMusicPlayer != null) {
				if(isPause)
					mMusicPlayer.pause();
				else
					mMusicPlayer.resume();
			}
		}
		
		
	}
}