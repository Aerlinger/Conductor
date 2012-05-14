package com.event
{
	import flash.events.Event;

	/** This event is dispatched at the start and end of each beat.
	 * 
	 * @author Anthony Erlinger
	 * */
	public class BeatEvent extends Event {
		
		private var beatNum:uint;
		private var measureNum:uint;
		
		public static const BEAT_START:String 	= "beatStart";
		public static const BEAT_END:String 	= "beatEnd";
		
		public function BeatEvent(type:String, beatNum:uint, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.beatNum = beatNum;
		}
		
	}
}