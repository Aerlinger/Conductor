package com.anim
{
	import com.element.*;
	import com.event.ElementEvent;
	import com.greensock.*;
	
	import flash.events.*;
	import flash.geom.Point;
	
	
	/**
	 * TweenConductor is an adaptation of the TweenMax class adapted to use beats as a basis
	 * of time rather than seconds.
	 * 
	 * @author Anthony Erlinger
	 */
	public class TweenConductor extends TweenMax
	{
		// Events will propagate to children only if this flag is set to true
		protected var propagateEventsToChildren:Boolean = true;
		
		
		
		/** 
		 * Creates a new instance of the TweenMax class and binds the update, start, and complete
		 * functions to listeners.
		 */
		public function TweenConductor(target:BaseElement, durationInBeats:Number, vars:Object )
		{
			super(target, Conductor.getTimeline().beatsToSeconds(durationInBeats), vars);
			
			vars.onUpdate 	= onUpdate;
			vars.onStart 	= onStartTween;
			vars.onComplete = onCompleteTween;
		}
		
		/** 
		 * Called internally every time this Timeline updates. If the propagateEventsToChildren flag
		 *  is true, events will be recursively applied to every child of the target being tweened. 
		 */
		private function onUpdate() : void {
			
			var Evt:ElementEvent = new ElementEvent(ElementEvent.MOVE, target.x, target.y, true);
			
			target.dispatchEvent( Evt );
			
			if( this.target is Group && propagateEventsToChildren ) {
				onUpdateHelper( Group(this.target), ElementEvent.MOVE );
			}
		}
		
		/** 
		 * Called internally every time this Timeline starts 
		 */
		private function onStartTween() : void {
			target.dispatchEvent( new ElementEvent(ElementEvent.START, target.x, target.y) );
		}
		
		/** 
		 * Called internally every time this Timeline updates 
		 */
		private function onCompleteTween() : void {
			target.dispatchEvent( new ElementEvent(ElementEvent.COMPLETE, target.x, target.y) );
		}
		
		/** Internal recursive function used to propagate events to children of the object if necessary */
		private function onUpdateHelper( TargetElement:Group, EventType:String ) : void {
			
			for( var i:uint=0; i<TargetElement.getSize(); ++i ) {
				
				var SubTarget:BaseElement = TargetElement.getChildElementAt(i);
				
				if(SubTarget is Group)
					onUpdateHelper( Group(SubTarget), EventType );
				else {
					var GlobalCoords:Point = SubTarget.localToGlobal( new Point(0, 0) );
					
					SubTarget.dispatchEvent( new ElementEvent(EventType, GlobalCoords.x, GlobalCoords.y, true) );
				}
				
			}
			
		}
		
		/** Events will propagate to children only if this flag is set to true */
		private function setPropagateEventsToChildren(isPropagateToChildren:Boolean) : void {
			this.propagateEventsToChildren = isPropagateToChildren;
		}
	}
}