package com.element
{
	import com.event.CollisionEvent;
	
	import flash.events.EventDispatcher;
	
	
	
	public class CollisionManager {
		
		
		private var mCollideableElements:Array 		= new Array();
		private var mEvtDispatcher:EventDispatcher 	= new EventDispatcher();
	
		private static var INSTANCE:CollisionManager;
		
		public function CollisionManager() {}
		
		public static function getInstance() : CollisionManager {
			if( INSTANCE == null ) 
				INSTANCE = new CollisionManager();
			
			return INSTANCE;
		}
		
		public function processCollisions() : void {
			
			for( var i:uint=0; i<mCollideableElements.length; ++i ) {
				
				var Element1:BaseElement = mCollideableElements[i] as BaseElement;
				
				for( var j:uint=i+1; j<mCollideableElements.length; ++j ) {
					
					var Element2:BaseElement = mCollideableElements[j] as BaseElement;
					
					if( Element1.checkCollision(Element2) ) {
						// TODO: Collision should probably not be the average of the two element positions
						var xCollide:Number = (Element1.x + Element2.x)/2;
						var yCollide:Number = (Element1.y + Element2.y)/2;
						
						mEvtDispatcher.dispatchEvent( new CollisionEvent(CollisionEvent.COLLIDE, xCollide, yCollide, Element1, Element2) );
					}
					
				}
			}
				
		}
		
		public function addCollisionCandidate( pElement:BaseElement ) : void {
			mCollideableElements.push(pElement);
		}
		
		public function removeCollisionCandidate( pElement:BaseElement ) : BaseElement {
			var idx:int = mCollideableElements.indexOf(pElement);
			
			if( idx < 0 ){
				trace("Element " + pElement.name + " not found for removal from CollisionManager");
				return null;
			}
			
			return mCollideableElements.splice(idx, 1);
		}
		
		
	}
}