package com.event
{
	
	import flash.events.Event;
	
	/** This event class is dispatched for specific Element-related events such as:
	 * An element is added to a group
	 * An element is removed from a group
	 * An element is moved
	 * An element Tween is started
	 * An element Tween is finished
	 * 
	 * @author Anthony Erlinger
	 * 
	 */
	public class ElementEvent extends Event {
		
		public static const ADD_TO_GROUP:String 		= "addToGroup";
		public static const REMOVE_FROM_GROUP:String 	= "removeFromGroup";
		public static const MOVE:String 				= "Move";
		public static const START:String 				= "Start";
		public static const COMPLETE:String 			= "Complete";
		
		// stores the x and y positions of the element when the event occurs
		private var x:Number;
		private var y:Number;
		
		public function ElementEvent(type:String, x:Number, y:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.x = x;
			this.y = y;
		}
		
		public function getX() : Number {
			return x;
		}
		
		public function getY() : Number {
			return y;
		}
	}
}