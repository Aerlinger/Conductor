package com.event
{
	import com.element.BaseElement;
	
	import flash.events.Event;

	/**
	 * This event is dispatched whenever a collision occurs between two elements 
	 * 
	 * @author Anthony Erlinger
	 */
	public class CollisionEvent extends Event {
		public static const COLLIDE:String 	= "collide";
		
		// Stores the x and y positions of the collision
		private var x:Number;
		private var y:Number;
		
		// The elements which are colliding
		private var Element1:BaseElement;
		private var Element2:BaseElement;
		
		public function CollisionEvent(type:String, x:Number, y:Number, pElement1:BaseElement, pElement2:BaseElement, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.x = x;
			this.y = y;
			
			this.Element1 = pElement1;
			this.Element2 = pElement2;
		}
		
		public function getX() : Number {
			return x;
		}
		
		public function getY() : Number {
			return y;
		}
		
		
		public function getFirstElement() : BaseElement {
			return Element1;
		}
		
		public function getSecondElement() : BaseElement {
			return Element2;
		}
		
	}
}