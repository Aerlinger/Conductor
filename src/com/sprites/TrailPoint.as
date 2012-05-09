package com.sprites
{
	import com.element.*;
	import com.greensock.*;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/** Renders a single point in the schene at a moving object based on its position. When called every frame 
	 * this creates the illusion of a tail following the element 
	 * 
	 * @author Anthony Erlinger
	 * */
	public class TrailPoint extends Shape
	{
		public function TrailPoint(pParent:BaseElement, size:Number=0.8, lifetime:Number=3)
		{
			if(pParent.parent != null) {
				
				// The color of the trail is the same as the label color of the object.
				this.graphics.beginFill(0xFF00FF, 1);
				this.graphics.drawCircle(0, 0, size);
				
				var P:Point = pParent.localToGlobal( new Point(0, 0) );
				
				this.x = P.x;
				this.y = P.y;
				
				// Add the object to the parent
				Conductor.getInstance().addChild(this);
				
				// The point fades out over the lifetime in seconds
				var FadeOut:TweenLite = new TweenLite(this, lifetime, {alpha:0});
				var FadeOutTimeline:TimelineLite = new TimelineLite({autoRemoveChildren:true});
				FadeOutTimeline.append(FadeOut);
			}
		}
	}
}