package com.event
{
	import flash.events.Event;
	
	
	
	/** This event is dispatched when a musical measure is started or completed.
	 * 
	 * @author Anthony Erlinger
	 *  */
	public class MeasureEvent extends Event {
		private var measureNum:uint;
		
		public static const MEASURE_START:String = "measureStart";
		public static const MEASURE_END:String 	 = "measureEnd";
		
		public function MeasureEvent(measureNum:uint, type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
	}
}