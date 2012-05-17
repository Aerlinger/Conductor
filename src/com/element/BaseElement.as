package com.element {
	
	import com.*;
	import com.anim.TweenConductor;
	import com.element.*;
	import com.event.CollisionEvent;
	import com.event.ElementEvent;
	import com.greensock.*;
	import com.greensock.core.*;
	import com.sprites.TrailPoint;
	
	import fl.motion.MatrixTransformer;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	
	/** Base class for all Elements. Conductor-specific Actions can only be performed
	 *  on Objects that extend from this type. By default, an instance of BaseElement
	 *  does not have shape information. 
	 * 
	 * For the sake of efficiency, elements are cached as bitmaps by default.
	 * 
	 * @author Anthony Erlinger
	 * */
	public class BaseElement extends SynchronizedSprite implements IEventDispatcher {

		protected static const DRAW_TWEEN_TRAIL:Boolean = false;
		
		// Keeps track of how many instances of type BaseElement Exist
		protected static var mInstanceNumber:uint = 0;
		
		private var mCurrentActionNumber:uint 	= 0;
		private var mTotalActionNumber:uint 	= 0;
		
		protected var mLabelColor:uint;
		protected var mNumClonesOfThisElement:uint = 0;
		
		//=========================================
		// Shape display data for this Element
		//=========================================
		// Fill data
		protected var mShapeFill:Shape = new Shape();
		protected var mFillColor:uint = 0xFF0000;
		protected var mFillAlpha:Number = 1;
		
		// Outline data
		protected var mShapeOutline:Shape = new Shape();
		protected var mBorderThickness:Number = 1;
		protected var mBorderColor:uint = 0x000000;
		protected var mBorderAlpha:Number = 1;
		
		//=========================================
		protected var mIsTweening:Boolean;
	
		//List of filter transforms to eb applied to this element
		protected var mFilterArray:Array = new Array();
		
		// Pivot point for rotation
		protected var mPivot:Point 		= new Point();
		protected var mRotation:Number 	= 0;	// Rotation angle
		protected var mHitRadius:Number = 3;	// Object is not collideable if this number is less than 0.
		
		
		//=========================================
		// Element-specific timeline
		//=========================================
		
		protected var mElementTimeline:TimelineMax;
		
		
		/** Creates a new instance of BaseElement. Note that the first argument of the constructor is to apply a deep-copy of an existing Element.
		 * The first parameter should be null unless you wish to create a copy of an existing element
		 * 
		 * As a copy-constructor:
		 * 	var BaseElementCopy = new BaseElement( Original );
		 * 
		 * As a new instance of BaseElement:
		 * 	var BaseElement = new BaseElement(null, 
		 * 
		 * @param pOriginalElement Original element to copy from if applicable
		 * 
		 * @param pFillColor The Fill color of this element.
		 * @param pFillAlpha The transparency (0-1) of this element.
		 * @param pBorderThickness Thickness in pixels of our object's border
		 * @param pBorderThickness Thickness in pixels of our object's border
		 */
		public function BaseElement( pOriginalElement:BaseElement = null, pFillColor:uint=0xFFFFFF, pFillAlpha:Number=1, 
									 pBorderThickness:Number=1, pBorderColor:Number=0xFF0000, pBorderAlpha:Number=1 ) {
			
			
			// Add event listeners for this object on creation
			this.addEventListener( Event.ADDED_TO_STAGE, 	onAddedToStage );
			this.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
			this.addEventListener( Event.SELECT, onRemovedFromStage );
			this.addEventListener( ElementEvent.MOVE, 		onMove );
			this.addEventListener( ElementEvent.START, 		onStartedTween );
			this.addEventListener( ElementEvent.COMPLETE, 	onFinishedTween );
			this.addEventListener( CollisionEvent.COLLIDE, 	onCollide );
			
			// Label color is currently a random value (it is ORed with 0x303030 to give it a minimum brightness for visibility)
			mLabelColor = (Math.random() * Math.pow(2, 24)) | 0x303030;
			
			this.name = "BaseElement" + (++mInstanceNumber);
			
			// Cache as bitmap by default for efficiency
			this.cacheAsBitmap = true;
			
			this.mFillColor = pFillColor;
			this.mFillAlpha = pFillAlpha;
			
			this.mBorderThickness = pBorderThickness;
			this.mBorderColor = pBorderColor;
			this.mBorderAlpha = pBorderAlpha;
			
			this.filters = new Array();
			
			// Collisions are disabled by default
			this.setEnableCollisions(false);		
			
		}
		
		/** Performs a deep copy on this BaseElement and returns the result */
		public function clone() : * {
			
			var clonedElement:BaseElement = new BaseElement();
			
			clonedElement.mLabelColor = this.mLabelColor;
			this.mNumClonesOfThisElement++;
			
			// duplicate properties of original object
			clonedElement.transform.matrix 	= this.transform.matrix.clone();
			clonedElement.filters 			= this.filters;
			clonedElement.cacheAsBitmap 	= this.cacheAsBitmap;
			clonedElement.opaqueBackground 	= this.opaqueBackground;
			
			//this.filters = Utils.copyArray( pOriginalElement.filters );
			clonedElement.filters = this.cloneFilters();
			
			if( this.isCollisionEnabled() ) {
				setEnableCollisions(true);
				clonedElement.hitArea.graphics.copyFrom(this.hitArea.graphics);
			} else {
				setEnableCollisions(false);
			}
			
			if (this.scale9Grid) {
				var rect:Rectangle = this.scale9Grid;
				// A bug existed in Flash 9 where the scale9Grid was 20x larger than assigned
				// rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
				clonedElement.scale9Grid = rect;
			}
			
			mNumClonesOfThisElement++;
			
			clonedElement.name = this.name + "-" + this.mNumClonesOfThisElement;
			
			clonedElement.x = this.x;
			clonedElement.y = this.y;
			
			clonedElement.mPivot = this.mPivot;
			
			return clonedElement;
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Collision detection/handling
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/** Enables the hit area of this Element for collision detection to occur */
		public function setEnableCollisions(enable:Boolean) : void {
			if(enable) {
				// If collisions are already enabled do nothing
				if( isCollisionEnabled() ) return;
				
				// Create the hit area
				this.hitArea = new Sprite();
				this.hitArea.mouseEnabled = false;
				this.hitArea.graphics.lineStyle(1, 0xFF0000, 1);
				this.hitArea.graphics.drawCircle(0, 0, 5);
				this.hitArea.graphics.beginFill(0xFF0000, .4);
				
				this.hitArea.visible = true;
				this.hitArea.alpha = 1;
				this.addChild(this.hitArea);
				
				// Add this element to the Collision Manager
				CollisionManager.getInstance().addCollisionCandidate(this);
			} else {
				// If collisions are already disabled, do nothing.
				if( !isCollisionEnabled() ) return;
				
				// Remove the hit area
				if( hitArea != null ) {
					try {
						this.removeChild(hitArea);
					} catch( E:ArgumentError ) {}
					
					this.hitArea = null;
				}
				
				// Remove this element from the Collision Manager
				CollisionManager.getInstance().removeCollisionCandidate(this);
			}
		}
		
		/** Perform collision detection on this object? */
		public function isCollisionEnabled() : Boolean {
			return (hitArea != null);
		}
		
		/** How close to the origin of this Element do we check for collisions? */
		public function setHitRadius(radius:Number) : void {
			if( !isCollisionEnabled() ) 
				throw new Error("Enable collisions for this element before setting the hit radius");
			
			this.mHitRadius = radius;
		}
		
		/** Checks the collision of this Element with another Element */
		public function checkCollision( OtherElement:BaseElement ) : Boolean {
			if(OtherElement === this) return false;
			
			var minDistSquared:Number = (OtherElement.mHitRadius + this.mHitRadius) * (OtherElement.mHitRadius + this.mHitRadius);
			
			var thisGlobal:Point = this.localToGlobal(new Point(0, 0));
			var otherElementGlobal:Point = OtherElement.localToGlobal(new Point(0, 0));
			
			var thisDistSquared:Number = (thisGlobal.x-otherElementGlobal.x)*(thisGlobal.x-otherElementGlobal.x) + (thisGlobal.y-otherElementGlobal.y)*(thisGlobal.y-otherElementGlobal.y); 
			
			return (thisDistSquared < minDistSquared);
		}
		
		/** TODO: Collision event listener does not seem to work*/
		private function onCollide(CollisionEvt:CollisionEvent) : void {
			// Mark the location of the collision
			var CollisionMarker:Shape = new Shape();
			CollisionMarker.x = CollisionEvt.getX();
			CollisionMarker.y = CollisionEvt.getY();
			
			CollisionMarker.graphics.beginFill(0xFF0000, 1.0);
			CollisionMarker.graphics.drawCircle(0, 0, 10);
			
			if(this.parent != null)
				this.parent.addChild(CollisionMarker);
			
			CollisionEvt.getFirstElement().alpha 	= .5;
			CollisionEvt.getSecondElement().alpha 	= .5;
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Pivot point/rotation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/** Sets the pivot point locally, based on the coordinates of this object */
		public function setPivotPointLocal(localX:Number, localY:Number, showRegistration:Boolean=true) : void {
			mPivot.x = localX;
			mPivot.y = localY;
			
			//registration point.
			if (showRegistration)
			{
				var mark:Sprite = new Sprite();
				mark.graphics.lineStyle(1, 0x00FF00);
				mark.graphics.moveTo(mPivot.x-5, mPivot.y-5);
				mark.graphics.lineTo(mPivot.x+5, mPivot.y+5);
				mark.graphics.moveTo(mPivot.x-5, mPivot.y+5);
				mark.graphics.lineTo(mPivot.x+5, mPivot.y-5);
				if( this.parent != null )
					this.addChild(mark);
			}
		}
		
		/** Sets the pivot point relative to the stage */
		public function setPivotPointGlobal(globalX:Number, globalY:Number, showRegistration:Boolean=true) : void {
			var LocalPivot:Point = this.globalToLocal( new Point(globalX, globalY) );
			
			setPivotPointLocal(LocalPivot.x, LocalPivot.y, showRegistration);
		}
		
		/** Sets the rotation of this object relative to its pivot point. */
		override public function set rotation(angleInDegrees:Number) : void {
			var RotMatrix:Matrix = this.transform.matrix.clone();
			var deltaRotation:Number = (angleInDegrees - mRotation);
			
			MatrixTransformer.rotateAroundInternalPoint(RotMatrix, mPivot.x, mPivot.y, deltaRotation);
			this.transform.matrix = RotMatrix;
			this.mRotation = angleInDegrees;
		}
		
		/** Gets the rotation (in degrees) of this object. */
		override public function get rotation() : Number {
			return this.mRotation;
		}
		
		/** Remove this Element by destroying all references to this Element, removing it from the stage,
		 *  and setting it to null */
		public function destroy() : void {
			parent.removeChild(this);
			delete this;
		}
		
		/** Returns true if this Element is currently animating. This
		 * flag is set through the Action class. */
		public function isTweening() : Boolean {
			return mIsTweening;
		}

		/** Returns the 24-bit color label of this Element */
		public function getLabelColor() : uint {
			return mLabelColor;
		}
		
		/** Retrieves the string data for this element. */
		public override function toString() : String {
			
			var Global:Point = this.localToGlobal( new Point(0, 0) );
			
			var Message:String = " "+name + ":\n";
			
			Message += "Parent: " + this.parent.name + "\n";
			Message += "parent (x,y):  [" + this.x + ", " +this.y + "]" + "\n";
			Message += "global (x,y):  [" + Global.x + ", " +Global.y + "]" + "\n";
			
			Message += "Children:  " + "\n";
			for( var i:uint=0; i<this.numChildren; ++i) {
				Message += " " + this.getChildAt(i).name;
			}
			
			return Message;
		}
		
		/** TODO: Check if the performance improve when alpha = 0 */
		public function removeFill() : void {
			mShapeFill.alpha = 0;
		}
		
		public function removeOutline() : void {
			mShapeOutline.alpha = 0;
		}
		
		public function destroyShapeData() : void {
			mShapeFill 		= null;
			mShapeOutline 	= null;
		}
		
		public function setOutlineColor(color:Number) : void {
			mShapeOutline.transform.colorTransform.color = color;
		}
		
		public function setOutlineAlpha(alpha:Number) : void {
			mShapeOutline.alpha = alpha;
		}
		
		public function setFillColor(color:Number) : void {
			mShapeFill.transform.colorTransform.color = color;
		}
		
		public function setFillAlpha(alpha:Number) : void {
			mShapeFill.alpha = alpha;
		}
		
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Transform animations
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function moveTo( destinationX:Number, destinationY:Number, durationInBeats:Number, startTimeInBeats:Number=Number.NaN ) : TweenConductor {
			
			var MoveTween:TweenConductor = new TweenConductor(this, durationInBeats, {x:destinationX, y:destinationY});
			
			if( isNaN(startTimeInBeats) ) // Start immediately
				mMainTimeline.insertNow( MoveTween );
			else 
				mMainTimeline.insert(MoveTween, startTimeInBeats);
			
			return MoveTween;
		}
		
		public function moveBy( deltaX:Number, deltaY:Number, durationInBeats:Number, startTimeInBeats:Number=Number.NaN ) : TweenConductor {
			return moveTo( this.x + deltaX, this.y + deltaY, durationInBeats, startTimeInBeats );
		}
		
		public function scaleTo( scalX:Number, scalY:Number, durationInBeats:Number, startTimeInBeats:Number=Number.NaN ) : TweenConductor {
			
			var ScaleTween:TweenConductor = new TweenConductor(this, durationInBeats, {scaleX:scalX, scaleY:scalY});
			
			if( isNaN(startTimeInBeats) ) {	// Start immediately
				mMainTimeline.insertNow( ScaleTween );
			} else {
				mMainTimeline.insert(ScaleTween, startTimeInBeats);
			}
			
			return ScaleTween;
		}
		
		public function scaleBy( deltaX:Number, deltaY:Number, durationInBeats:Number, startTimeInBeats:Number=Number.NaN ) : TweenConductor {
			return scaleTo( this.scaleX + deltaX, this.scaleX + deltaY, durationInBeats, startTimeInBeats );
		}
		
		public function rotateTo( thetaInDeg:Number, durationInBeats:Number, startTimeInBeats:Number=Number.NaN ) : TweenConductor {
			
			var RotateTween:TweenConductor = new TweenConductor(this, durationInBeats, {rotation:thetaInDeg});
			
			if( isNaN(startTimeInBeats) ) // Start immediately
				mMainTimeline.insertNow( RotateTween );
			else 
				mMainTimeline.insert(RotateTween, startTimeInBeats);
			
			return RotateTween;
		}
		
		public function rotateBy( deltaThetaInDeg:Number, durationInBeats:Number, startTimeInBeats:Number=Number.NaN ) : TweenConductor {
			return rotateTo( this.rotation + deltaThetaInDeg, durationInBeats, startTimeInBeats );
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EFFECTS
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/** Translates multiple copies of this element outward in a radial fashion */
		public function flower(numPetals:uint=4, durationInBeats:Number=1, radius:Number=100, useSeconds:Boolean=false) : TimelineMax {
			
			var FlowerGroup:Group = Group.createGroupFromElement(this, numPetals);
			
			var FlowerTimeline:TimelineMax = new TimelineMax();
			
			if(useSeconds) {
				// Convert time from beats to seconds so that it can be used by the tween engine.
				durationInBeats = mMainTimeline.secondsToBeats(durationInBeats);
			}
			
			for(var i:uint=0; i<numPetals; ++i) {
				
				var angle:Number = (i/numPetals) * 2 * Math.PI;
				
				var ThisPetal:BaseElement = FlowerGroup.getChildElementAt(i);
				ThisPetal.x = 0;
				ThisPetal.y = 0;
				
				var xDest:Number = ThisPetal.x + radius*Math.sin(angle);
				var yDest:Number = ThisPetal.y + radius*Math.cos(angle);
				
				FlowerTimeline.insert( new TweenConductor(ThisPetal, durationInBeats, {x:xDest, y:yDest}), 0 );
				
			}
			
			FlowerTimeline.data = FlowerGroup;
			
			return FlowerTimeline;
		}
		
		/** Creates a vibration effect with the given frequency, beat duration and magnitude */
		public function rumble(frequency:Number=2, durationInBeats:Number=1, magnitude:Number=6, useSeconds:Boolean=false) : TimelineMax {
			
			if(useSeconds) {
				// Convert time from beats to seconds if applicable
				durationInBeats = mMainTimeline.secondsToBeats(durationInBeats);
			}
			
			var timeStep:Number = 1.0/frequency;
			var numSteps:uint = durationInBeats/timeStep;
			
			var RumbleTimeline:TimelineMax = new TimelineMax();
			
			var centerX:Number = this.x;
			var centerY:Number = this.y;
			
			for( var i:uint=0; i<numSteps-1; ++i ) {
				// Creates an ease in/out effect
				var fraction:Number = .5 - Math.abs((i-(numSteps-1)/2)/(numSteps-1));
				
				var deltaX:Number = centerX + magnitude*fraction*(Math.random()-0.5);
				var deltaY:Number = centerY + magnitude*fraction*(Math.random()-0.5);
				
				RumbleTimeline.append( new TweenConductor( this, timeStep, {x:deltaX, y:deltaY}) );
			}
			
			RumbleTimeline.append( new TweenConductor(this, timeStep, {x:centerX, y:centerY}) );
			
			return RumbleTimeline;
		}
		
		/** Creates a copy of this object which is scaled outward and simulatenously faded out */
		public function flare(scale:Number=1.15, durationInBeats:Number=1.0, alpha:Number=0, useSeconds:Boolean=false) : TimelineMax {
			var FlareGroup:Group = Group.createGroupFromElement(this, 2);
			
			var FlareOutElement:BaseElement = FlareGroup.getChildElementAt(0);
			var FlareInElement:BaseElement 	= FlareGroup.getChildElementAt(1);
			
			FlareOutElement.x = 0;
			FlareOutElement.y = 0;
			FlareInElement.x = 0;
			FlareInElement.y = 0;
			
			// Convert time from beats to seconds so that it can be used by the tween engine.
			if(useSeconds)
				durationInBeats = mMainTimeline.secondsToBeats(durationInBeats);
			
			
			var ScaleTweenOut:TweenConductor = new TweenConductor( FlareOutElement, durationInBeats, {scaleX:scale, scaleY:scale,alpha:alpha} );
			var ScaleTweenIn:TweenConductor = new TweenConductor( FlareInElement, durationInBeats, {scaleX:(1/scale), scaleY:(1/scale),alpha:alpha} );
			
			var FlareTimeline:TimelineMax = new TimelineMax();
			
			FlareTimeline.insertMultiple([ScaleTweenOut, ScaleTweenIn], 0, TweenAlign.START);
			
			return FlareTimeline;
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// FILTERS:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		
		public function addBlur(blurX:Number=4, blurY:Number=4, quality:Number=1) : BlurFilter {
			var NewBlur:BlurFilter = new BlurFilter(blurX, blurY, quality);
			
			mFilterArray.push(NewBlur);
			
			if(mShapeFill != null)
				mShapeFill.filters = mFilterArray;
			if(mShapeOutline != null)
				mShapeOutline.filters = mFilterArray;
			
			return NewBlur;
		}
		
		public function addBlurToOutline(blurX:Number=4, blurY:Number=4, quality:Number=1) : BlurFilter {
			var NewBlur:BlurFilter = new BlurFilter(blurX, blurY, quality);
			
			if(mShapeOutline != null)
				mShapeOutline.filters = [NewBlur];
			
			return NewBlur;
		}
		
		public function addBlurToFill(blurX:Number=4, blurY:Number=4, quality:Number=1) : BlurFilter {
			var NewBlur:BlurFilter = new BlurFilter(blurX, blurY, quality);
			
			if(mShapeFill != null)
				mShapeFill.filters = [NewBlur];
			
			return NewBlur;
		}
		
		public function addGlow( color:uint=0xFF0000, alpha:Number=1.0, blurX:Number=6.0, blurY:Number=6.0, strength:Number=2, quality:int=1, inner:Boolean=false, knockout:Boolean=false ) : GlowFilter {
			var NewGlow:GlowFilter = new GlowFilter( color, alpha, blurX, blurY, strength, quality, inner, knockout );
			
			if(mShapeFill != null)
				mShapeFill.filters = [NewGlow];
			if(mShapeOutline != null)
				mShapeOutline.filters = [NewGlow];
			
			return NewGlow;
		}
		
		public function clearFilters() : void {
			this.filters = [];
		}
		
		public function cloneFilters() : Array {
			var clonedFilters:Array = new Array();
			
			for(var i:uint=0; i<this.mFilterArray.length; ++i ) {
				clonedFilters.push((this.mFilterArray[i] as BitmapFilter).clone());
			}
			
			return clonedFilters;
		}
		
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// EVENTS:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/** Called when this Element is pressed */
		private function onPressElement(Evt:MouseEvent) : void {
			trace( this.toString() );
		}
		
		/** Listener: Called every time this Element is added to the stage 
		 *  By convention any object extending BaseElement can only be added as a child to:
		 * 		1) The main stage
		 * 		2) A child of another BaseElement
		 *      3) A child of a group 
		 * */
		public function onAddedToStage( Evt:Event ) : void {
			if( this.parent is BaseElement || this.parent is Conductor ) 
				trace(">>> Element added to stage: " + this.name);
			else 
				trace("Warning: " + this.name + " parent object should be either the main stage, another BaseElement, or a Group. Parent is " + this.parent.name);
			
			// When added to the stage register this element with the ElementManager
			if( this is Group ) 
				ElementManager.getInstance().registerGroup(this as Group);
			else
				ElementManager.getInstance().registerElement(this);
			//if(mTweens != null)
				//Conductor.getTimeline().insert(mTweens);
		}
		
		/** Listener: Called every time this Element is removed from the stage */
		public function onRemovedFromStage( ActionEvt:Event ) : void {
			//if(mTweens != null)
				//Conductor.getTimeline().remove(mTweens);
		}
		
		/** Listener: Called every time this Element is removed from the stage */
		public function onSelected( ActionEvt:Event ) : void {
			//if(mTweens != null)
			//Conductor.getTimeline().remove(mTweens);
		}
		
		public function onStartedTween(ActionEvt:Event) : void {
			//trace("\t> Subaction (" + this.mCurrentActionNumber + "/" + this.mTotalActionNumber + ") started for: " + this.name + " @: " + Conductor.getTimeline().currentTime);
			mCurrentActionNumber++;
			this.mIsTweening = true;
			
			var TweeningColor:ColorTransform  = new ColorTransform(0, 1, 0);
			TweeningColor.color = 0x00FF00;

		}
		
		public function onFinishedTween(ActionEvt:Event) : void {
			//trace("\t> Subaction (" + this.mCurrentActionNumber + "/" + this.mTotalActionNumber + ") finished for: " + this.name + " @: " + Conductor.getTimeline().currentTime);
			this.mIsTweening = false;
			
			var TweeningColor:ColorTransform  = new ColorTransform(0, 1, 0);
			TweeningColor.color = 0xFFFF00;
	
		}
		
		public function onAddedNewAction(ActionEvt:Event) : void {
			mTotalActionNumber++;
		}
		
		public function onRemovedAction(ActionEvt:Event) : void {
		}
		
		/** Called every time this element is moved *BY A TWEEN* */
		private function onMove(ElementEvt:ElementEvent) : void {
			
			if(DRAW_TWEEN_TRAIL) {
				// Draws a point at the element's position each time it is moved.
				new TrailPoint(this);
			}
			
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Misc getters and setters:
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		override public function set x(value:Number) : void {
			super.x = value;
			
			if(DRAW_TWEEN_TRAIL) {
				// Draws a point at the element's position each time it is moved.
				new TrailPoint(this);
			}
		}
		
		override public function set y(value:Number) : void {
			super.y = value;
			
			if(DRAW_TWEEN_TRAIL) {
				// Draws a point at the element's position each time it is moved.
				new TrailPoint(this);
			}
		}
		
		/** Returns the bounding rect of this object with respect to the targetCoordinateSpace */
		override public function getRect(targetCoordinateSpace:DisplayObject):Rectangle
		{
			// If it's not a group we don't need to loop through each child.
			if( mShapeOutline != null )
				return mShapeOutline.getRect(targetCoordinateSpace);
			else 
				return mShapeFill.getRect(targetCoordinateSpace);
		}
		
		/** Returns the left most position of this object **relative to its parent**. 
		 * Must be overridden in the Group class.*/
		public function getMinX() : Number {
			var fillX:Number;
			var outlineX:Number;
			
			(mShapeFill != null) ? (fillX = this.x - mShapeFill.width/2) : 0;
			(mShapeOutline != null) ? (outlineX = this.x - mShapeOutline.width/2) : 0;
			
			return Math.min(fillX, outlineX);
		}
		
		/** Returns the top position of this object **relative to its parent**. 
		 * Must be overridden in the group class*/
		public function getMinY() : Number {
			var fillY:Number;
			var outlineY:Number;
			
			(mShapeFill != null) ? (fillY = this.y - mShapeFill.height/2) : 0;
			(mShapeOutline != null) ? (outlineY = this.y - mShapeOutline.height/2) : 0;
			
			return Math.min(fillY, outlineY);
		}
		
		public function getMinXGlobal() : Number {
			return localToGlobal( new Point(getMinX(), getMinY()) ).x;
		}
		
		public function getMinYGlobal() : Number {
			return localToGlobal( new Point(getMinX(), getMinY()) ).y;
		}
		
		/** Returns the height dimension of this object (Assumes the outline is matched to the position of the fill) */
		override public function get width():Number
		{
			var fillWidth:Number;
			var outlineWidth:Number;
			
			(mShapeFill != null) ? (fillWidth = mShapeFill.width) : 0;
			(mShapeOutline != null) ? (outlineWidth = mShapeOutline.width) : 0;
			
			return Math.max(fillWidth, outlineWidth); 
		}
		
		/** Returns the height dimension of this object (Assumes the outline is matched to the position of the fill) */
		override public function get height():Number
		{
			var fillHeight:Number;
			var outlineHeight:Number;
			
			(mShapeFill != null) ? (fillHeight = mShapeFill.height) : 0;
			(mShapeOutline != null) ? (outlineHeight = mShapeOutline.height) : 0;
			
			return Math.max(fillHeight, outlineHeight);
		}
		
		
	}
	
}
