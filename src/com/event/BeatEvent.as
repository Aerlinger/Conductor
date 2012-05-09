package com.event
{
	import flash.events.Event;

	/** Event handling for a Beat 
	 * 
	 * @author Anthony Erlinger*/
	public class BeatEvent extends Event
	{
		
		private var beatNum:uint;
		private var measureNum:uint;
		
		public static const BEAT_START:String 	= "beatStart";
		public static const BEAT_END:String 	= "beatEnd";
		
		public function BeatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}