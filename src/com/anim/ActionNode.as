package com.anim
{
	import com.element.BaseElement;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	
	/**  Action
	 * 
     * An Action defines an animated event for an Element such as scaling, moving, fading, etc... Such actions can be executed sequentially 
	 *  through the setNextAction() function (i.e. move to a location, then rotate, then fade out). Actions can also take place in parallel by declaring the variables
	 *  to be animated for each action (i.e. move while scaling while fading out). Additionally, Action events can be chained to other actions or can also trigger actions 
	 *  to start in one or more other Elements.
	 * 
	 * Actions are declared within Element objects and similarly can only act on Element objects. However, Actions can be declared on their own when bound to 
	 *  keypoints and later bound to an Element.
	 * 
	 * Actions can be started in two ways:
	 * 
	 * 
	 *  Asynchronously:
	 *    Can be called on an Element at any time for unscripted animation.. 
	 * 
	 *  Synchronously:
	 *    Actions can be bound to keypoints and attached to the timeline for scripted animation.
	 * 
	 *  
	 * This class is implemented as a doubly linked list structure so that sequential Actions can be chained one after another.
	 * In other words, when this action is finished, the next action in the list is executed until the end 
	 * of the list is reached
	 * 
	 * The head of the list has the mPrevAction variable==null
	 * 
	 *  
	 * Action Types:
	 * 
	 *   Transforms:
	 *	 	x, y
	 *	 	scale
	 *	 	rotation
	 *	
	 *	 Modifiers:
	 *	 	Color 
	 *	 	Alpha
	 *	    Gradient
	 *	
	 * 	 Effects:
	 *	 	Blur
	 *	 	Glow
	 *	 	Shadow
	 *	 	Bevel
	 *	 	Gradient Glow
	 *	 	Gradient Bevel
	 *
	 * 	 Composite actions:
	 *   	Flare:
	 *   	Flower:
	 *   	Pulse:
	 * 
	 * 
	 *   
	 *	@author Anthony Erlinger
	 */
	public class ActionNode implements IEventDispatcher
	{
		
		// TWEEN DESTINATION VARIABLES:
		// 	These are lazily initialized. They are only tweened if they contain value.
		private var xFinal:Number 	= Number.NaN;
		private var yFinal:Number 	= Number.NaN;
		private var rotation:Number = Number.NaN;
		private var scaleX:Number 	= Number.NaN;
		private var scaleY:Number 	= Number.NaN;
		
		private var color:uint		= Number.NaN;	// 24 bit representation of the color for this object
		private var alpha:Number	= Number.NaN;	
		
		
		// Element to be affected by this action
//		private var mTargetElements:Vector.<BaseElement> = new Vector.<BaseElement>();
		private var mTargetElement:BaseElement;// = new Vector.<BaseElement>();
		
		private var mDurationInSeconds:Number = 1;
		// How many seconds from when the first action started until this one started? (the firstAction will always be 0 for this variable).
		private var mRelativeStartTimeInSeconds:Number = 0;
		
		// Easing function to use for all tweens in this action:
		private var mTweenEaseFunction:Function = Strong.easeInOut;
		
		// The Action class can be implemented as queue through a doubly-linked list.
		private var mNextAction : ActionNode = null;
		private var mPrevAction : ActionNode = null;
		
		// A pointer referencing whatever node is being animated.
		private var mActiveNode : ActionNode = null;
		
		// This pointer always points to the first and last object in the queue, this allows the action chain to be 
		private var mFirstAction : ActionNode = null;
		//private var mLastAction : Action = null;
		
		// Only true when this action has been started.
		private var mIsActive : Boolean = false;
		
		private var mDestroyObjectOnFinish:Boolean = false;
		
		// It is recommended at all actions be named through this variable.
		public var name:String = "DefaultAction";
		
		public static var uid:Number = 0;
		
		// List of active tweens for this action
		private var mTweenList:Vector.<Tween> = new Vector.<Tween>();
		
		private var mEventDispatcher:EventDispatcher;	// Event storage n' shit.
		
		
		
		
		/** Creates a new Action object with a target object
		 * 
		 * @param pTargetObject The Element which will be affected by this action 
		 * @pDurationInSeconds Number of seconds it will take this action to complete.
		 */
		public function ActionNode( pTargetElement:BaseElement = null, pDurationInSeconds:Number=1, pEasingFunction:Function=null ){
			this.mTargetElement = pTargetElement;
			this.mDurationInSeconds = pDurationInSeconds;
			this.mTweenEaseFunction = pEasingFunction;
			
			// Set the first action to this one by default.
			this.mFirstAction = this;
			
			this.name = "Action" + uid;
			
			uid++;
		}
		
//		/** Each action belongs to one or more objects
//		 * @param pTarget The target Object for this Action to run. */
//		public function addTargetElement(pElement:BaseElement) {
//			//setTargetElements.apply(null, Elements);
//			
//			//this.mTargetElements.push(Elements);
//			
//			// Link the Element to this action as well.
//			
//				pElement.setActionReference(this);
//			
//		}
		
//		/** Removes this element from the action and stops all associated tweens. */
//		public function removeTargetElement( index:uint ) : BaseElement {
//			
//			var Removed:BaseElement = mTargetElements[index];
//			
//			mTargetElements.splice( index, 1);
//			
//			return Removed;
//		}
		
		
		/** An action can only be run if it has a target Element. 
		 * @param pTarget The target Element for this Action to run. */
		public function hasTargetElement( ) : Boolean {
			return (mTargetElement != null /*&& (mTargetElements.length > 0)*/);
		}
		
		
		/** @return A reference to the target element */
		public function setTargetElement( pElement:BaseElement ) : void/*Vector.<BaseElement>*/ {
			this.mTargetElement = pElement;
		}
		
		/** @return A reference to the target element */
		public function getTargetElement() : BaseElement/*Vector.<BaseElement>*/ {
			return mTargetElement;
		}
		
		/** Is this the first action of this list? */
		public function isStartingAction() : Boolean {
			return (mPrevAction==null);
		}
		
		/** Is this the last action of this list?
		 * 
		 * TODO: Optimize by creating a reference to the first action in this list. */
		public function isLastAction() : Boolean {
			return (mNextAction == null /*|| mNextAction == getFirstAction()*/);
		}
		
		/** If this flag is set to true, the action queue repeats itself */
		public function setRepeating(repeat:Boolean) : void {
						
			//getLastAction().setNextAction( repeat ? getFirstAction() : null );
			
		}
		
		/*
		private function applyTweenToElements( Property:String, pEaseFunction:Function, startProperty:Number, endProperty:Number, mDurationInSeconds:Number, useSeconds, ...mElements ) : void {
			
			for( var i=0; i<mElements.length; ++i ) {
				var CurrentElement:BaseElement = (mElements[i] as BaseElement);
				
				if(CurrentElement is BaseElement) {
				
					var mTween:Tween = new Tween(CurrentElement, "x", pEaseFunction, CurrentElement., xFinal, mDurationInSeconds, true);
					mTweenList.push( mTween );
					
				} else {
					throw new ArgumentError("Objects passed to applyTweenToElements must be of type BaseElement");
				}
				 
			}
			
		}*/
		
		/** Executes the relevant Tweens for this action. All variables that have been declared will be tweened. 
		 * @return An array of the tweened events. */ 
		public function start() : Vector.<Tween> {
			
			
			// If there is no TargetElement we cannot proceed
			if(mTargetElement == null) {
				trace("Action started without target Element");
				
				return mTweenList;
			}
			
//			for each( var ThisElement:BaseElement in mTargetElements ) {
				
				// All tweens here have the same duration.
				if( !isNaN(xFinal) ) {
					mTweenList.push( new Tween(mTargetElement, "x", mTweenEaseFunction, mTargetElement.x, xFinal, mDurationInSeconds, true) );
				}
				if( !isNaN(yFinal) ) {
					//applyTweenToElements( "y", mTweenEaseFunction, mTargetElement.y, yFinal, mDurationInSeconds, true, pTargetElements );
					mTweenList.push( new Tween(mTargetElement, "y", mTweenEaseFunction, mTargetElement.y, yFinal, mDurationInSeconds, true) );
				}
				if( !isNaN(rotation) ) {
					mTweenList.push( new Tween(mTargetElement, "rotation", mTweenEaseFunction, mTargetElement.rotation, rotation, mDurationInSeconds, true) );
				}
				if( !isNaN(scaleX) ) {
					mTweenList.push( new Tween(mTargetElement, "scaleX", mTweenEaseFunction, mTargetElement.scaleX, scaleX, mDurationInSeconds, true) );
				}
				if( !isNaN(scaleY) ) {
					mTweenList.push( new Tween(mTargetElement, "scaleY", mTweenEaseFunction, mTargetElement.scaleY, scaleY, mDurationInSeconds, true) );
				}
				if( !isNaN(alpha) ) {
					mTweenList.push( new Tween(mTargetElement, "alpha", mTweenEaseFunction, mTargetElement.alpha, alpha, mDurationInSeconds, true) );
				}
				
//			}
		
			/////////////////////////////////////////////////////////////////////////
			// If this action is valid then we proceed.
			//
			//   The action itself if executed when this condition is true
			/////////////////////////////////////////////////////////////////////////
			if( mTweenList.length > 0 ) {
				
				// If our object is already tweening issue a warning. (previous tween will be overidden with this one
				//if( mTargetElement.isTweening() ) 
				//	trace( "*** start() warning: " + mTargetElement.name + " tween event was interrupted before it finished. ***" );  // TODO: Print the time and tween details
				//else
				//	trace("\t\tAction started: " + toString());
				
				
				
				// Listen when this action completes to execute the next event.
				(mTweenList[0] as Tween).addEventListener(TweenEvent.MOTION_START, onThisActionStarted);
				
				// Listen when this action completes to execute the next event.
				(mTweenList[0] as Tween).addEventListener(TweenEvent.MOTION_FINISH, onThisActionFinished);
				
				this.mIsActive = true;
				
			} else {
				trace( "ERROR: start(): This action is not yet initialized.");
			}
			
			return mTweenList;
		}
		
		/** Event callback run when the tweens in this Action are started. */
		private function onThisActionStarted() : void {
			trace( "ACTION: Started action " + this.name + "\n" + this.toString());
			mTargetElement.incrementActionNumber();
		}
		
		/** Event callback run when the tweens in this Action are finished. */
		private function onThisActionFinished(Evt:TweenEvent) : void {
			
			// Call the next action if it is available.
			if( mNextAction != null && mNextAction.hasTargetElement() ) {
				mNextAction.start();
			} else {
				trace("\t\tAction " + this.name + " finished");
				mTargetElement.incrementActionNumber();
				mIsActive = false;
			}
			
			// TODO: Notify listeners waiting on this event to finish.
		}
		
		/** TODO: Implement */
		public function reset() : void {
			
		}
		
		/** Prints useful information about each Action */
		public function toString() : String {
			
			var Message:String = "\n\n\tACTION: " + name + " on " + ((mTargetElement==null) ? "undefined" : mTargetElement.name) + "\n";
			
			Message += " \t " + getIndexOfThisAction() + " / " + getTotalNumActions() + "\n";
			
			Message += "\tNextAction: " + ((mNextAction==null) ? "undefined" : mNextAction.name)
				      + " PrevAction: " + ((mPrevAction==null) ? "undefined" : mPrevAction.name) + "\n";
			
			Message += "\tFirst: " + getFirstAction().name + "\n";
			Message += "\tTotal duration: " + getTotalDurationSeconds() + "\n";
			Message += "\tNum following actions: " + getNumFollowingActions() + "\n";
			Message += "\tRelative start time: " + mRelativeStartTimeInSeconds + "\n";
			
			if( !isNaN(xFinal) )  
				Message += " toX: " + xFinal;
			if( !isNaN(yFinal) ) 
				Message += " toY: " + yFinal;
			if( !isNaN(rotation) ) 
				Message += " toRot: " + rotation;
			if( !isNaN(scaleX) ) 
				Message += " toScaleX: " + scaleX;
			if( !isNaN(scaleY) ) 
				Message += " toScaleY: " + scaleY;
			
			Message += " t=" + mDurationInSeconds;
			
			return Message;
		}
		
		/**
		 * @param pEasing The easing method to use for this tween.
		 */
		public function setEasingFunction( pEasing:Function ) : void {
			this.mTweenEaseFunction = pEasing;
		}
		
		/** What is the next action to perform when this one is complete?
		 * 
		 * TODO: Allow nodes to be inserted
		 * 
		 * @param pNextAction The next action to be run
		 * @param Elements A list of elements to which to apply this Action.
		 * @deprecated
		 */
		
		
//		public function setNextAction( pNextAction:ActionNode, ...Elements ) : ActionNode {
//			
//			if(Elements.length===0)
//				Elements.push(mTargetElement);
//			
//			//TODO: This needs fixing
//			for( var i=0; i<Elements.length; ++i ) {
//				pNextAction.setTargetElement(Elements[i]);
//			}
//			
//			
//			if(mIsActive)
//				trace("Warning: Attempted to add NextAction when this action was already started. TODO: Implement Solution");
//			
//			// Chain the next action to this list.
//			this.mNextAction = pNextAction;
//			
//			pNextAction.mRelativeStartTimeInSeconds = this.mRelativeStartTimeInSeconds + this.mDurationInSeconds;
//			// Update the pointer to the first action.
//			pNextAction.mFirstAction = this.mFirstAction; 
//			// Update the pointer to the last action.
//			//this.mLastAction = pNextAction;
//			
//			
//			
//			pNextAction.mPrevAction = this;
//			
//			trace(" Added: " + pNextAction.name + " Previous: " + pNextAction.getPreviousAction().name + " First: " + pNextAction.getFirstAction());
//			trace(" This: " + this.name + " Next: " + this.getNextAction().name + " First: " + this.getFirstAction());
//			
//			return pNextAction;
//		}
		
		
		/** What is the next action to perform when this one is complete?
		 * 
		 * @param pNextAction The next action to be run
		 * @param Elements A list of elements to which to apply this Action.
		 */
		public function setLastAction( pNewLastAction:ActionNode, pElement:BaseElement=null ) : ActionNode {
			
			
//			if(mTargetElements==null) {
//				trace("Warning: Attempted to create next action without setting mTargetElement");
//			}
			
			var CurrentLastAction:ActionNode = getLastAction();
			
			// Set the target element for this action the same as the previous element by default.
			if(pElement == null)
				pNewLastAction.setTargetElement(CurrentLastAction.getTargetElement()); //Element.push(mTargetElements);
			

//			for( var i=0; i<Element.length; ++i ) {
//				getLastAction().addTargetElement( Element[i] );
//			}
			
			
			if(mIsActive)
				trace("Warning: Attempted to add NextAction when this action was already started. TODO: Implement Solution");
			
			pNewLastAction.mPrevAction = CurrentLastAction; 
			
			CurrentLastAction.mNextAction = pNewLastAction;
			
			pNewLastAction.mRelativeStartTimeInSeconds = (CurrentLastAction.mRelativeStartTimeInSeconds + CurrentLastAction.mDurationInSeconds);
			pNewLastAction.mFirstAction = CurrentLastAction.mFirstAction; 
			
			trace(" Added: " + pNewLastAction.name + " Previous: " + pNewLastAction.getPreviousAction().name + " First: " + pNewLastAction.getFirstAction().name);
			trace(" This: " + CurrentLastAction.name + " Next: " + CurrentLastAction.getNextAction().name + " First: " + CurrentLastAction.getFirstAction().name);
			
			return pNewLastAction;
			
		}
		
		/** Get the action by index number 
		 */
		public function getActionByIndex( index:Number ) : ActionNode {
			var TempAction:ActionNode = getFirstAction();
			
			for( var i:uint=0; i<index; ++i ) {
				TempAction = TempAction.mNextAction;
				if(TempAction == null)
					throw new RangeError("Index exceeds size of Action List");
			}
			
			return TempAction;
		}
		
		/** What is the next action to perform when this one is complete?
		 * 
		 * @return Elements A list of elements to which to apply this Action.
		 */
		public function getNextAction( ) : ActionNode {
			return this.mNextAction;
		}
		
		/** What is the next action to perform when this one is complete?
		 * 
		 * @return Elements A list of elements to which to apply this Action.
		 */
		public function getPreviousAction( ) : ActionNode {
			return this.mPrevAction;
		}
		
		/** Iteratively traverses the list to the first element
		 * 
		 * @return Elements A list of elements to which to apply this Action.
		 */
		private function getFirstAction( ) : ActionNode {
			var PreviousElement:ActionNode = this;
			
			while(PreviousElement.mPrevAction != null) {
				PreviousElement = PreviousElement.mPrevAction;
			}
			
			return PreviousElement;
		}
		
		/** Iteratively traverses this list until the last element is reached.
		 * 
		 * @return Elements A list of elements to which to apply this Action.
		 */
		private function getLastAction( ) : ActionNode {
			var NextAction:ActionNode = this;
			
			while(NextAction.mNextAction != null) {
				NextAction = NextAction.mNextAction;
			}
			
			return NextAction;
		}
		
		/** Each tween in the action has a fixed duration
		 *  
		 * @param pDuration The duration of the action in seconds. */
		public function setDuration( pDuration:Number ) : ActionNode {
			this.mDurationInSeconds = pDuration;
			return this;
		}
		
		/** Returns the total length of ONLY this action (does not include following actions). */
		public function getDurationOfThisAction() : Number {
			return mDurationInSeconds;
		}
		
		/** How long from when the first action begins to when this action begins? */
		public function getStartTimeOfThisAction() : Number {
			return mRelativeStartTimeInSeconds;
		}
		
		/** Returns the total length of this action, starting from the beginning.
		 * (the length of this action including any actions that follow it) */
		public function getTotalDurationSeconds() : Number {
			
			var duration:Number = 0;
			
			var CurrentAction:ActionNode = mFirstAction;
			
			
			for( var i:uint=0; i<mFirstAction.getNumFollowingActions(); ++i ) {
				duration += CurrentAction.mDurationInSeconds;
				CurrentAction = CurrentAction.mNextAction;
			}
			
			return duration
		}
		
		/** @return The total number of actions in this list. */
		public function getIndexOfThisAction() : int {
			var index:uint = 0;
			
			var CurrentAction:ActionNode = this.mFirstAction;
			
			while( CurrentAction != this ) {
				CurrentAction = CurrentAction.getNextAction();
				index++;
				
				if(CurrentAction==null)
					return -1;
					
			}
			
			return index;
		}
		
		/** @return The total number of actions in this list. */
		public function getTotalNumActions() : uint {
			var count:uint = 1;
			
			var CurrentAction:ActionNode = this.mFirstAction;
			
			while( !CurrentAction.isLastAction() ) {
				CurrentAction = CurrentAction.getNextAction();
				count++;
			}
			
			return count;
		}
		
		/** @return the number of actions following this one. */
		public function getNumFollowingActions() : uint {
			var count:uint = 0;
			
			var CurrentAction:ActionNode = this;
			
			while( !CurrentAction.isLastAction() ) {
				CurrentAction = CurrentAction.getNextAction();
				count++;
			}
			
			return count;
		}

//		/** @return the number of actions following this one */
//		public function getNumFollowingActions() : uint {
//			return getNumFollowingActionHelper(this);
//		}
//		
//		/** Recursively gets the number of actions following this one
//		 * 
//		 * Note: must use the syntax:
//		 * 	   var duration = <ActionInstance>.getDuration(ActionInstance);
//		 * */
//		private function getNumFollowingActionHelper( NextAction:ActionNode ) : uint {
//			var num:uint = 0;
//			
//			if( NextAction == null ) {
//				return 0;
//			} else {
//				num += 1 + getNumFollowingActionHelper(NextAction.mNextAction);
//			}
//			
//			return num;
//		}
		
		/** Returns a list of duration times for this action and all actions that queue from it.
		 */
		public function getDurationAsArray() : Array {
			return getDurationAsArrayHelper(this, new Array());
		}
		
		/** Recursively retrieves a list with each element of the list being the duration
		 *    of each Action 
		 * 
		 * var DurationList:Array = <ActionInstance>.getDuration(ActionInstance, new Array());
		 * */
		private function getDurationAsArrayHelper( NextAction:ActionNode, DurationList:Array ) : Array {
			if( this.mNextAction == null ) {
				DurationList = new Array();
				DurationList.push( this.mDurationInSeconds );
				return DurationList;
			} else {
				return getDurationAsArrayHelper(this.mNextAction, DurationList);
			}
		}
		
		/** Returns true if objects associated with this action will be destroyed when the action is finished. */
		public function getIsDestroyObjectOnFinish() : Boolean {
			return mDestroyObjectOnFinish;
		}
		
		/** Removes the object from the scene and destroys it when this action is finished. */
		public function setDestroyObjectOnFinish(value:Boolean) : void {
			mDestroyObjectOnFinish = value;
		}
		

		
		/////////////////////////////////////////
		// Setters for action destinations
		/////////////////////////////////////////
		
		public function setDestinationX( xFinal:Number ) : ActionNode {
			this.xFinal = xFinal;
			return this;
		}
		
		public function setDestinationY( yFinal:Number ) : ActionNode {
			this.yFinal = yFinal;
			return this;
		}
		
		public function setDestinationPosition( xPos:Number, yPos:Number ) : ActionNode {
			setDestinationX(xPos);
			return setDestinationY(yPos);
		}
		
		public function setDestinationRotation( rotation:Number ) : ActionNode {
			this.rotation = rotation;
			return this;
		}
		
		public function setDestinationScaleX( scaleX : Number ) : ActionNode {
			this.scaleX = scaleX;
			return this;
		}
		
		public function setDestinationScaleY( scaleY : Number ) : ActionNode {
			this.scaleY = scaleY;
			return this;
		}
		
		public function setDestinationScale( scaleX : Number, scaleY : Number ) : ActionNode {
			setDestinationScaleX(scaleX);
			return setDestinationScaleY(scaleY);
		}
		
		public function setDestinationColor( color : uint ) : ActionNode {
			this.color = color;
			
			return this;
		}
		
		public function setDestinationAlpha( alpha : Number ) : ActionNode {
			this.alpha = alpha;
			return this;
		}
		
		/////////////////////////////////
		// Shift functions
		/////////////////////////////////
		
		/*
		public function shiftX( deltaX:Number ) : ActionNode {
			return setDestinationX( mTargetElement.x + deltaX );
		}
		
		public function shiftY( deltaY : Number ) : ActionNode {
			return setDestinationY( mTargetElement.y + deltaY );
		}
		
		public function shiftPosition( deltaX : Number, deltaY : Number ) : ActionNode {
			shiftX(deltaX);
			return shiftY(deltaY);
		}
		
		public function shiftRotation( deltaRotation:Number ) : ActionNode {
			return setDestinationRotation( this.rotation + deltaRotation );
		}
		
		public function shiftScaleX( deltaScaleX: Number ) : ActionNode {
			return setDestinationScaleX( mTargetElement.scaleX + deltaScaleX );
		}
		
		public function shiftScaleY( deltaScaleY : Number ) : ActionNode {
			return setDestinationScaleY( mTargetElement.scaleY + deltaScaleY );
		}
		
		public function shiftScale( deltaScaleX : Number , deltaScaleY : Number ) : ActionNode {
			shiftScaleX( deltaScaleX );
			return shiftScaleY( deltaScaleY );
		}
		
		public function shiftAlpha( deltaAlpha : Number ) : ActionNode {
			return setDestinationAlpha( this.alpha + deltaAlpha );
		}
		*/
		
		/////////////////////////////////////////
		// EVENT LISTENERS:
		/////////////////////////////////////////
		
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			mEventDispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return mEventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return mEventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			mEventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return mEventDispatcher.willTrigger(type);
		}
		
		
		
	}
}