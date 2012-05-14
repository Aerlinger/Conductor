package com.time
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;

	/** Guaranteed to dispatch an event every interval. A PreciseTimer
	 *   updates ever Event.ENTER_FRAME. The ENTER_FRAME event should be bound to the
	 *   Root MovieClip.
	 * 
	 * @see ColorWheelMain
	 * 
	 * @author Anthony Erlinger
	 */
	public class PreciseTimer implements IEventDispatcher {
		
		private var mEventDispatcher:EventDispatcher;	// Event storage n' shit.
		
		private var mIsRunning:Boolean; // Indicates if the timer is running.
		
		private var mSecondsElapsed:Number; 				// Time in seconds elapsed since the timer has been started
		private var mMillisecondsElapsedThisInterval:uint = 0; 	// Time in seconds elapsed since the timer has been started
		
		private var mTickIntervalInMilliseconds:Number; 	// This timer dispatches an event every mTickInterval in ms.
		
		// Time tracking variables.
		private var mPreviousTimeInMilliseconds:Number = Number.NaN;
		private var mDeltaMillisecondsLastTick:Number = 0;
		private var lastEventTime:Number;
		
		
		/**
		 * Creates a new instance of a precise timer.
		 *
		 *	@param mParent The parent of the timer, used for Event.ENTER_FRAME event handling
		 *  @param tickInterval Length in milliseconds of each interval
		 *	@return void
		 */
		public function PreciseTimer(mParent:MovieClip, tickInterval:Number) {
			this.mIsRunning = false;
			this.mTickIntervalInMilliseconds = tickInterval;
			this.mSecondsElapsed = 0;
			
			this.mEventDispatcher = new EventDispatcher(this);
			
			lastEventTime = getTimer();
			
			mParent.addEventListener( Event.ENTER_FRAME, onEnterFrame );

		}
		
		
		/** Starts this timer.
		 */
		public function start(): void {
			// Remove an existing interval
			if (this.mIsRunning) {
				this.pause(true);
			}
			
			lastEventTime = getTimer();
			
			trace("*** Precise Timer started: " + getTimer());

			this.mIsRunning = true;
		}
		
		/**
		 * Pauses the timer on its current value.
		 *
		 *	@param Void
		 *	@return Void
		 */
		public function pause(isPaused:Boolean):void {
			this.mIsRunning = !isPaused;
		}
		
		
		/**
		 * Resets the Timer back to 0 and pauses it.
		 *
		 *	@param Void
		 *	@return Void
		 */
		public function reset():void {
			this.pause(true);
			this.mSecondsElapsed = 0;
		}
		
		
		/**
		 * Accessor method for getting the number of seconds elapsed since the timer was started.
		 *
		 *	@param void
		 *	@return Number of seconds elapsed since timer was started.
		 */
		public function getTotalSecondsElapsed() : Number {
			return this.mSecondsElapsed
		}
		
		/**
		 * Accessor method for getting how many milliseconds have elapsed since an event was dispatched
		 *
		 *	@param void
		 *	@return Number of seconds elapsed since timer was started.
		 */
		public function getMillisecondsElapsedThisInterval() : Number {
			return this.mMillisecondsElapsedThisInterval;
		}
		
		
		
		/** Updates the internal clock on this timer and dispatches an event if the time has exceeded the interval time.
		 *    Any leftover time will be added to the next interval. 
		 * 
		 * @param pMillisecondsSinceLastUpdate The number of milliseconds since this method was last called.
		 * */
		public function update(pMillisecondsSinceLastUpdate:Number) : void {
			
			// Don't update if we are paused or we haven't started.
			if( mIsRunning ) {
				
				// If this is the first update.
				if( isNaN(mPreviousTimeInMilliseconds) ) {
					// Initialize the timer to the current time;
					mPreviousTimeInMilliseconds = getTimer();
				}
				
				// Increment the number of seconds elapsed since our last update.
				mSecondsElapsed += (pMillisecondsSinceLastUpdate / 1000);
				
				// Increment the number of milliseconds in this interval.
				mMillisecondsElapsedThisInterval += pMillisecondsSinceLastUpdate;
	
				// EVENT: when the time elapsed (ms) interval exceeds the alotted time, we 
				//        dispatch all events listening on this time.
				if ( mMillisecondsElapsedThisInterval >= mTickIntervalInMilliseconds ) {
					
					// How long has it been since we STARTED our last event?
					mDeltaMillisecondsLastTick = (getTimer() - mPreviousTimeInMilliseconds);
					mPreviousTimeInMilliseconds = getTimer();
					
					// Call any event handlers attached to this timer.
					this.dispatchEvent( new TimerEvent(TimerEvent.TIMER) );
					
					// The remaining time is any time left over (in other words mMillisecondsElapsedThisInterval will be greater than mTickIntervalInMilliseconds
					
					// Reset the number of milliseconds this interval.
					mMillisecondsElapsedThisInterval = (mMillisecondsElapsedThisInterval - mTickIntervalInMilliseconds);
					
					
				}
				
			}
			
		}
		
		/** @return The duration of the last tick in milliseconds */
		public function deltaMillisecondsLastTick() : Number {
			return mDeltaMillisecondsLastTick;
		}
		
		/** Retrieves the update duration of this time in milliseconds  
		 * 
		 * @return The constant duration of the update time */
		public function getTickIntervalInMilliseconds() : Number {
			return mTickIntervalInMilliseconds;
		}
		
		/** Retrieves the timestamp of the last update execution  
		 * 
		 * @return The start time of the last update. Measured in milliseconds 
		 *   since the start of this program*/
		public function getPreviousTimeInMilliseconds() : Number {
			return mPreviousTimeInMilliseconds;
		}
		
		/** Event handler: Attached to main stage, this method executes ONCE PER FRAME as defined in the corresponding .fla 
		 *    All events begin at the onset of this method. */
		private function onEnterFrame( Evt:Event ) : void {
			
			// Record the start time of this event.
			var thisEventStartTime:Number 	= getTimer();
			
			// The change in time is the new time
			var deltaTime:Number 	= (thisEventStartTime - lastEventTime);
			
			// Run our update
			update(deltaTime);
			
			lastEventTime = thisEventStartTime;
		}
		
		
		///////////////////////////////////////////
		// Event handling:
		///////////////////////////////////////////
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			mEventDispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return mEventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean {
			return mEventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			mEventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return mEventDispatcher.willTrigger(type);
		}
		
		
	}
}