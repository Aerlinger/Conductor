package com.time
{
	import com.anim.ActionNode;
	import com.element.BaseElement;
	
	import flash.errors.IllegalOperationError;

	/** The Keypoint binds an action to an Element at a particular time
	 * in the timeline 
	 * 
	 * @author Anthony Erlinger*/
	public class Keypoint
	{
		
		private var mStartTime:Number;
		private var mKeypointAction:ActionNode;
		
		private var mTargetElements:Vector.<BaseElement> = new Vector.<BaseElement>();
		
		private var mIsStarted:Boolean = false;
		
		public var name:String;
		
		
		
		public function Keypoint(startTime:Number, pAction:ActionNode, pTargetElement:BaseElement )
		{
			this.mStartTime = startTime;
			this.mKeypointAction = pAction;
			
			
			//for( var i=0; i<pTargetElements.length; ++i ) {
				//if(pTargetElements[i] is BaseElement) {
					
					pTargetElement.setActionReference(pAction);
					pTargetElement.getKeypointReferences().push(this);
					
					mTargetElements.push(pTargetElement);
					
				//} else {
				//	throw new ArgumentError("Cannot create a keypoint from a non-Element object");
				//}
			//}
			/*
			for each (var ThisElement in pTargetElements) {
				
				ThisElement = (ThisElement as BaseElement);
				
				mTargetElements.push(ThisElement);
				ThisElement.setActionReference(pAction);
				ThisElement.getKeypointReferences().push(this);
			}*/
			
			this.name = "DefaultKeypoint";
		}
		
		public function setAction( targetAction:ActionNode ) : void {
			this.mKeypointAction = targetAction;
		}
		
		public function getAction() : ActionNode {
			return this.mKeypointAction;
		}
		
		public function getStartTimeSeconds() : Number {
			return mStartTime;
		}
		
		public function getDurationSeconds() : Number {
			return mKeypointAction.getTotalDurationSeconds();
		}
		
		public function getDurationAsArray() : Array {
			return mKeypointAction.getDurationAsArray();
		}
		
		public function toString() : String {
			var Message:String = name + ": \n";
			
			Message += " Start time: " + mStartTime;
			Message += " Duration: " + this.getDurationSeconds();
			
			return Message;
		}
		
		public function start() : void {
			
			
			if( mKeypointAction == null ) {
				trace(" Attempted to start keypoint before its action has been initialized");
				return;
			}
			
			if( !mIsStarted ) {
				
				
				// Start the action associated with this keypoint.
				//mKeypointAction.start();
				
				for each( var ThisObject:BaseElement in mTargetElements ) {
					trace("KEYPOINT " + this.name + " started \n");
					ThisObject.start();
				}
				
				mIsStarted = true;
			}
			
		}
	}
}