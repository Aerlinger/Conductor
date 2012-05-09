package com.anim
{
	
	/** A list of actions 
	 * 
	 * @author Anthony Erlinger
	 * */
	public class ActionQueue
	{
		// Queue of actions
		private var mActionsQueue : Array = new Array();
		
		public function ActionQueue(){}
		
		public function queueAction(NextAction:ActionNode) : void {
			
			if(ActionNode == null) {
				trace("Attempted to add a null Action to the ActionQueue");
				return;
			}
			
			// Previous action is on "top" of the mActionsQueue
			var PrevAction:ActionNode = mActionsQueue[mActionsQueue.length-1];
			
			// Set the previous action to execute NextAction when it is finished.
			// If this is the first element in the list, the Previous Action will be null.
			if(PrevAction != null)
				//PrevAction.setNextAction( NextAction, PrevAction.getTargetElement() );
			//else
			//	trace("ActionQueue: Created new queue");
			
			// Update the queue
			mActionsQueue.push(NextAction);
			trace("NextAction: " + NextAction + " added to the ActionQueue");
			
		}
		
		/** Appends an existing queue to this one. NOTE: the original queue should be destroyed in most cases for proper GC. */
		public function addExistingQueue(NextQueue:ActionQueue) : Boolean {
			
			if(NextQueue.isEmpty() || this.isEmpty())
				return false;
			
			var NextQueueAction:ActionNode = (this.mActionsQueue[mActionsQueue.length-1] as ActionNode);
			
			// Connect the last element of this Queue to the first element of the queue to be added (NextQueue).
			//NextQueueAction.setNextAction( NextQueue.mActionsQueue[0], NextQueueAction.getTargetElement() );
			
			// Push the other Queue onto this stack
			this.mActionsQueue.push( NextQueue.mActionsQueue );
			
			return true;
		}
		
		/** True if this Queue is currently empty */
		public function isEmpty() : Boolean {
			return (mActionsQueue == null || mActionsQueue.length == 0);
		}
		
		/** Starts the first action in the queue */
		public function start() : void {
			if( mActionsQueue != null )
				(mActionsQueue[0] as ActionNode).start();
		}
	}
}