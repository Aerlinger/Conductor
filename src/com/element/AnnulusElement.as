package com.element {
	import com.anim.ActionNode;
	import com.anim.ActionQueue;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.engine.GroupElement;
	
	
	
	/**
	 * 
	 * @author Anthony Erlinger
	 */
	public class AnnulusElement extends BaseElement {

		private var mRadius:Number;
		private var mThickness:Number;
		private var mColor:uint;
		
		
		
		/** Creates a new AnnulusElement with a given xPos, yPos, radius, thickness, and color
		 */
		public function AnnulusElement( xPos:Number=200, yPos:Number=200, radius:Number=50, thickness:Number=3, color:uint=0xFFFFFF ) {
			
			mRadius 	= radius;
			mThickness 	= thickness;
			mColor 		= color;
			
			this.x = xPos;
			this.y = yPos;
			
			var mShape : Shape; mShape = new Shape();
			
			// Set the linestyle.
			mShape.graphics.lineStyle(thickness, color, 1, false, LineScaleMode.NONE );
			
			// No fill.
			mShape.graphics.beginFill(0, 0);
			
			mShape.graphics.drawCircle(0, 0, radius);
			mShape.graphics.beginFill(0x993311, 1);
			
			mShape.graphics.lineStyle(thickness, color, 1, false, LineScaleMode.NORMAL );
			mShape.graphics.drawCircle(0, -radius, 5);
			
			// Put the registration point in the center
			mShape.x = 0;
			mShape.y = 0;
			
			this.name = "AnnulusElement"+mInstanceNumber;
			
			this.addChild(mShape);
		}
		
		public function clone() : AnnulusElement {
			return new AnnulusElement(this.x, this.y, this.mRadius, this.mThickness, this.mColor);
		}
		
		public function dilate() : ActionNode {
			var DilateAction:ActionNode = new ActionNode(this, .99);
			DilateAction.setDestinationScale(2, 2);
			DilateAction.start();
			
			return DilateAction;
		}
		
		public function flare() : void
		{
			var FlareOutElement : AnnulusElement = this.clone();
			this.addChild( FlareOutElement );
			
			var ScaleActionOut:ActionNode = new ActionNode(FlareOutElement, .5);
			
			ScaleActionOut.setDestinationScale(1.15, 1.15);
			ScaleActionOut.setDestinationAlpha(0);
			ScaleActionOut.start();

			// TODO: Remove flare object on finish
			var FlareInElement : AnnulusElement = this.clone();
			
			this.addChild( FlareInElement );
			
			var ScaleActionIn:ActionNode = new ActionNode(FlareInElement, .5);
			ScaleActionIn.setDestinationScale(.85, .85);
			ScaleActionIn.setDestinationAlpha(0);
			
			ScaleActionIn.start();
			// TODO: Remove flare object on finish
		}
		
		
		public function flower(numPetals:uint=7, radius:Number = 50, duration:Number=1) : Sprite {
			
			// Create a container for the new elements;
			
			var PetalContainer:Group = new Group();
			PetalContainer.x = this.x;
			PetalContainer.y = this.y;
			
			
			for(var i:uint=0; i<numPetals; ++i) {
				
				var angle:Number = (i/numPetals) * 2 * Math.PI;
				
				var x:Number = Math.sin(angle);
				var y:Number = Math.cos(angle);
				
				var NewlySpawnedElement : AnnulusElement = this.clone();
				NewlySpawnedElement.x = 0;
				NewlySpawnedElement.y = 0;
				
				PetalContainer.addChild(NewlySpawnedElement);
				
				
				var TempAction:ActionNode = new ActionNode(this, duration);
				var TempAction2:ActionNode = new ActionNode(this, duration);
				
				TempAction.setDestinationPosition(radius*x, radius*y);
				TempAction2.setDestinationPosition(-radius*x, -radius*y);
				
				TempAction.setLastAction( (new ActionNode(PetalContainer, 2.95)).setDestinationRotation(360), this );
				TempAction.start();
				
			}
			
			
			parent.addChild(PetalContainer);
			
			return PetalContainer;
			
		}
		
		public function pulse() : ActionQueue {
			
			var PulseActionOut:ActionNode 	= new ActionNode(this);
			var PulseActionIn:ActionNode 	= new ActionNode(this);
			
			PulseActionOut.setDestinationScale( 1.3, 1.3 ) ;
			PulseActionOut.setDuration(1);
			
			PulseActionIn.setDestinationScale(1/1.3, 1/1.3);
			PulseActionIn.setDuration(1);
			
			var PulseAction:ActionQueue = new ActionQueue(); 
			
			PulseAction.queueAction(PulseActionOut);
			PulseAction.queueAction(PulseActionIn);
			
			PulseAction.start();
			
			return PulseAction;
			
		}
		
		/*
		public function simpleMotionTween( xDestination:Number, yDestination:Number, EaseFunction:Function, duration:Number ) : Action {
			
			var SimpleMotionAction:Action = new Action( this, duration );
			
			SimpleMotionAction.setEasingFunction(EaseFunction);
			SimpleMotionAction.setDestinationPosition(xDestination, yDestination);
			
			return SimpleMotionAction;
		}
		
		public function simpleScaleTween( xScaleDestination:Number, yScaleDestination:Number, EaseFunction:Function, duration:Number ) : Action {
			var SimpleScaleAction:Action = new Action( this, duration );
			
			SimpleScaleAction.setEasingFunction(EaseFunction);
			SimpleScaleAction.setDestinationScale(xScaleDestination, yScaleDestination);
			
			return SimpleScaleAction;
		}
		
		public function simpleAlphaTween( alphaFinal:Number, EaseFunction:Function, duration:Number ) : Action {
			
			var SimpleAlphaAction:Action = new Action( this, duration );
			
			SimpleAlphaAction.setEasingFunction(EaseFunction);
			SimpleAlphaAction.setDestinationAlpha( alphaFinal );
			
			return SimpleAlphaAction;
			
		}*/
		
		
	}
	
}
