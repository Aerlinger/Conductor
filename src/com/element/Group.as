package com.element 
{
	import com.anim.TweenConductor;
	import com.event.*;
	import com.event.ElementEvent;
	import com.greensock.*;
	import com.time.ConductorTimeline;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	
	
	/** A group is Container used to hold Elements such that multiple elements can be translated, rotated, and scaled
	 * as though they were a single Element. Since elements are children of the group, they will inherit all of its transforms.
	 * In addition to containing elements, groups are <i>themselves</i> elements can therefore contain other groups as children. 
	 * Likewise, a group can also have another group as its parent.
	 * 
	 * A group is initially created from multiple Element objects. Upon creation, the position of the group is set to be the 
	 * center of the bounding box of the children it contains. 
	 * 
	 * Current Version: Once created, elements cannot be added to or removed from a group, although this may change in the future. 
	 * 
	 * Unlike Elements, Groups do not have shape data.
	 * 
	 * 
	 * @author Anthony Erlinger
	 */
	public class Group extends BaseElement {
		// Cache to store the members of this group for easy access (these elements will also exist in the Display List).
		private var mGroupChildren:Array = new Array();

		// A point to remember the center position of this Group.
		private var mBoundingBox:Rectangle;
		
		private static var mGroupInstanceNumber:uint = 0;
		
		
		/** Creates a new group from a list of elements */
		public function Group(...Elements) {
			super();
			
			// Groups do not have shape data by default
			destroyShapeData();
			
			mGroupChildren.push(Elements);
			
			// The center of this group is set to be the center of the bounding box of the children which it contains.
			mBoundingBox = getBoundingBoxFromList.apply(null, Elements);
			
			// Default name
			this.name = "Group" + (++mGroupInstanceNumber);
			
			this.x = mBoundingBox.x + mBoundingBox.width/2;
			this.y = mBoundingBox.y + mBoundingBox.height/2;
			
			for( var i:uint = 0; i<Elements.length; ++i ) {
				
				if( (Elements[i] as BaseElement).parent != null )
					(Elements[i] as BaseElement).parent.removeChild(Elements[i]);
				
				addElement(Elements[i]);
			}
			
			this.addEventListener(ElementEvent.ADD_TO_GROUP, this.onAddToGroup);
			this.addEventListener(ElementEvent.REMOVE_FROM_GROUP, this.onRemoveFromGroup);
		}
		
		/** Returns an exact copy of this group */
		override public function clone() : * {
			var clonedGroup:Group;
			
			clonedGroup.x = this.x;
			clonedGroup.y = this.y;
			
			clonedGroup.name = this.name + "-" + mNumClonesOfThisElement;
			
			clonedGroup.mBoundingBox = this.mBoundingBox.clone();
			
			this.parent.addChild(this);
			
			for( var j:uint=0; j<this.mGroupChildren.length; ++j ) {
				var ClonedElement:BaseElement = (this.mGroupChildren[j]).clone();
				
				clonedGroup.addChild(ClonedElement);
				clonedGroup.mGroupChildren.push( ClonedElement );
			}
		}
		
		/** Static initializer method to copy a BaseElement into a group. */
		public static function createGroupFromElement( pElement:BaseElement, pNumCopies:uint ) : Group {
			
			var TempGroup:Group = new Group(null, pElement);
			
			for( var i:uint=0; i<pNumCopies; ++i ) {
				TempGroup.addElement( pElement.clone());
			}
			
			return TempGroup;
		}
		
		/** Adds an Element to this group */
		private function addElement( pElement:BaseElement ) : void {
			
			// add the most recent element to the front of the array.
			mGroupChildren.unshift( pElement );
			
			// Translate the new Element's coordinate so that it can be placed properly by the group
			var GlobalElementPoint:Point = pElement.localToGlobal( new Point(0, 0) );
			var NewLocalPoint:Point = globalToLocal(GlobalElementPoint);
			
			pElement.x = NewLocalPoint.x;
			pElement.y = NewLocalPoint.y;

			this.addChild( pElement );
			
			dispatchEvent( new ElementEvent(ElementEvent.ADD_TO_GROUP, pElement.x, pElement.y) );
			
		}
		
		/** Removes an Element to this group */
		public function removeElement( pElement:BaseElement ) : BaseElement {
			var idx:uint = mGroupChildren.indexOf( pElement );
			
			if(idx > -1) {
				var Removed:BaseElement = (mGroupChildren.splice(idx, 1)).pop() as BaseElement;
				
				this.removeChild( pElement );
				
				dispatchEvent( new ElementEvent(ElementEvent.REMOVE_FROM_GROUP, Removed.x, Removed.y) );
				
				return Removed;
			}
			else {
				trace("Error: Element: " + pElement.name + " was not found");
				return null;
			}
		}
		
		/** Returns a copy of the group's children as an ordered array */
		public function getChildElements() : Array {
			var Elements:Array = new Array();
			
			for( var i:uint=0; i<mGroupChildren.length; ++i ) {
				Elements.push( mGroupChildren[i].clone() );
			}
			
			return Elements;
		}
		
		/** Returns the child at a particular index */
		public function getChildElementAt( index:uint ) : BaseElement {
			return mGroupChildren[index];
		}
		
		/** Removes the group, child members of the group are preserved by attaching them to the parent of the group.
		 * All other (non-child) fields of the group are destroyed with the group Element. 
		 * 
		 * TODO: Test*/
		public function unGroup() : Array {
			var Parent:Sprite = this.parent as Sprite;
			
			for( var i:uint=0; i<mGroupChildren.length; ++i ) {
				Parent.addChild(mGroupChildren[i]);
			}
			
			Parent.removeChild(this);
			delete this;
			
			return mGroupChildren;
		}
		
		/** Returns the bounds of a list of elements (the min and max bounds of that variable) */
		public function getBoundingBoxFromList(...List) : Rectangle {
			
			//List = List[0];
			
			var xMin:Number = Number.MAX_VALUE;
			var yMin:Number = Number.MAX_VALUE;
			var xMax:Number = Number.MIN_VALUE;
			var yMax:Number = Number.MIN_VALUE;
			
			// Loop through each element in the group:
			for( var i:uint=0; i<List.length; ++i) {
				
				var ThisChild:BaseElement = (List[i] as BaseElement);
				
				if( ThisChild.getMinX() < xMin ) {
					xMin = ThisChild.getMinX();
				}
				if( ThisChild.getMinY() < yMin ) {
					yMin = ThisChild.getMinY();
				}
				if( (ThisChild.getMinX() + ThisChild.width) > xMax ) {
					xMax = (ThisChild.getMinX() + ThisChild.width);
				}
				if( (ThisChild.getMinY() + ThisChild.height) > yMax ) {
					yMax = (ThisChild.getMinY() + ThisChild.height);
				}
				
			}
			
			return new Rectangle( xMin, yMin, (xMax-xMin), (yMax-yMin) );
		}
		
		
		/** TODO: Test this function 
		 * Translates each element in the group towards a shared point (CoM by default). 
		 *   All elements but one are then removed. */
		public function condense( durationInBeats:Number ) : TimelineMax {
			
			var condenseAction:TimelineMax = new TimelineMax();
			
			condenseAction.autoRemoveChildren = true;
			for( var i:uint=0; i<this.numChildren; ++i ) {
				condenseAction.insert( new TweenConductor( this.getChildElementAt(i), durationInBeats, {x:0, y:0, alpha:0} ) , 0);
			}
			
			return condenseAction;
			
		}
		
		/** Gets the bounds of this Group relative to the stage coordinates. */
		override public function getRect(targetCoordinateSpace:DisplayObject) : Rectangle {
			var Minimum:Point = new Point(targetCoordinateSpace.x, targetCoordinateSpace.y);
			var GlobalMinimum:Point = this.localToGlobal(Minimum);
			
			var LocalMinimum:Point = targetCoordinateSpace.globalToLocal(GlobalMinimum);
			
			return new Rectangle(LocalMinimum.x, LocalMinimum.y, this.mBoundingBox.width, this.mBoundingBox.height);
		}
		
		/** Returns the number of elements in this group */
		public function getSize() : uint {
			return mGroupChildren.length;
		}
		
		/** Returns true if this group does not have any children */
		public function getIsEmpty() : Boolean {
			return (getSize() == 0);
		}
		
		/** Called whenever an element is added to the group */
		protected function onAddToGroup(ElementEvt:ElementEvent) : void {
			trace("Added Element to group");
		}
		
		/** Called whenever an element is removed from the group */
		protected function onRemoveFromGroup(ElementEvt:ElementEvent) : void {
			trace("Removed Element from group");
		}
		
		override public function flower(numPetals:uint=4, durationInBeats:Number=1, radius:Number=50, useSeconds:Boolean=false) : TimelineMax {
			var FlowerTimeline:TimelineMax = new TimelineMax();
			
			if(useSeconds) {
				// Convert time from beats to seconds so that it can be used by the tween engine.
				durationInBeats = mMainTimeline.beatsToSeconds(durationInBeats);
			}
			
			var FlowerGroupArray:Array = new Array();
			
			for(var i:uint=0; i<numPetals; ++i) {
				
				var angle:Number = (i/numPetals) * 2 * Math.PI;
				
				var ThisPetal:Group = this.clone();
				this.parent.addChild(ThisPetal);
				
				var xDest:Number = radius*Math.sin(angle);
				var yDest:Number = radius*Math.cos(angle);
				
				FlowerGroupArray.push( ThisPetal );
				FlowerTimeline.insert( new TweenConductor( ThisPetal, durationInBeats, {x:xDest, y:yDest}), 0);
			}
			
			FlowerTimeline.data = new Group(null, FlowerGroupArray);
			
			FlowerTimeline.resume();
			
			return FlowerTimeline;
		}
		
		override public function toString() : String {
			var Message:String = "";
			var tabs:String = "";
			
			Message += "\n";
			
			if( this.mGroupChildren != null ) {
				tabs += "\t";
				
				for( var i:uint=0; i<mGroupChildren.length; ++i ) {
					if(mGroupChildren[i] is Group) {
						tabs+= "\t";
						Message += tabs + ">" + mGroupChildren[i].name + mGroupChildren[i].toString() + "\n";
					} else {
						Message += tabs + "-" + mGroupChildren[i].name + "\n";
					}
					
				}
			}
			
			return Message;
				
		}
		
		/** Gets the minimum x position of this group relative to its own coordinate system */
		override public function getMinX() : Number {
			return mBoundingBox.x;
		}
		
		/** Gets the minimum y position of this group relative to its own coordinate system */
		override public function getMinY() : Number {
			return mBoundingBox.y;
		}
		
		/** Gets the bounding box width of this group */
		override public function get width() : Number {
			return mBoundingBox.width;
		}
		
		/** Gets the bounding box height of this group */
		override public function get height() : Number {
			return mBoundingBox.height;
		}

	}
	
	
}