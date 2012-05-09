package com.ui
{

	import com.element.BaseElement;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;

	
	/** Visual element to indicate the onset of each beat and downbeat (first beat of the measure). 
	 * 
	 * @author Anthony Erlinger
	 * */
	public class Metronome extends Sprite
	{

		private var BeatOnsetShape:Shape;
		private var SubBeatShape:Shape;
		
		// Beat onset 
		private var mouthTween:Tween;
		
		private var DownbeatTweenScaleX:Tween;
		private var DownbeatTweenScaleY:Tween;
		
		private var SubBeatTweenScaleX:Tween;
		private var SubBeatTweenScaleY:Tween;

		private var radius:Number = 30;
		
		private var mNumBeatsPerMeasure:Number;
		
		private var mTitleTxt:TextField;
		private var mTimeSignatureTxt:TextField;
		private var mTimerTxt:TextField;
		
		public function moveMouth(duration:Number) {
			var MouthMovement:Tween = new Tween(Conductor.getInstance().KittyMouthLoader, "y", Strong.easeInOut, Conductor.getInstance().KittyMouthLoader.y, Conductor.getInstance().KittyMouthLoader.y+20, duration, true);
			MouthMovement.yoyo();
		}
		
		public function Metronome( xPos:Number, yPos:Number, beatsPerMeasure:Number )
		{
			
			// Create circles which pulse at the onset of every beat, and measure (downbeat).
			BeatOnsetShape 	= createDownBeatShape(xPos,yPos);
			SubBeatShape 	= createSubBeatShape(xPos,yPos);
			
			
			//DownbeatTweenScaleX = new Tween(Conductor.getInstance().KittyBackground, "rotation", Strong.easeIn, 0, 10, .5, true);
			
			DownbeatTweenScaleX = new Tween(BeatOnsetShape, "scaleX", Strong.easeIn, 1, 1.1, .5, true);
			DownbeatTweenScaleY = new Tween(BeatOnsetShape, "scaleY", Strong.easeIn, 1, 1.1, .5, true);
			
			mouthTween = new Tween(Conductor.getInstance().KittyMouth, "y", Strong.easeInOut, Conductor.getInstance().KittyMouth.y, Conductor.getInstance().KittyMouth.y+7, .5, true);
			SubBeatTweenScaleX = new Tween(Conductor.getInstance().KittyHead, "rotation", Strong.easeIn, 0, -7, .5, true);
			//SubBeatTweenScaleX = new Tween(SubBeatShape, "scaleX", Strong.easeOut, 1, 1.1, 2, true);
			SubBeatTweenScaleY = new Tween(SubBeatShape, "scaleY", Strong.easeOut, 1, 1.1, 2, true);
			
			DownbeatTweenScaleY.addEventListener(TweenEvent.MOTION_FINISH, startBeatTweenFinish);
			SubBeatTweenScaleY.addEventListener(TweenEvent.MOTION_FINISH, subBeatTweenFinish);
			
			//this.addChild( BeatOnsetShape );
			//this.addChild( SubBeatShape );
			
			// Create "Metronome" title
			mTitleTxt = new TextField();
			mTitleTxt.x = xPos - 1.45*radius;
			mTitleTxt.y = yPos-2*radius;
			mTitleTxt.scaleX = 1.6;
			mTitleTxt.scaleY = 1.6;
			mTitleTxt.thickness = 2;
			mTitleTxt.textColor = 0xeeeeee;
			mTitleTxt.text = "Metronome";
			mTitleTxt.selectable = false;
			//this.addChild( mTitleTxt );
			
			// Create beat signature
			mTimeSignatureTxt = new TextField();
			mTimeSignatureTxt.textColor = 0xeeeeee;
			mTimeSignatureTxt.x = xPos-.60*radius;
			mTimeSignatureTxt.y = yPos + 1.1*radius;
			mTimeSignatureTxt.scaleX = 2;
			mTimeSignatureTxt.scaleY = 2;
			mTimeSignatureTxt.text = "1/"+beatsPerMeasure;
			mTimeSignatureTxt.selectable = false;
			//this.addChild(mTimeSignatureTxt);
			
			// create and place timer below beat signature
			mTimerTxt = new TextField();
			mTimerTxt.textColor = 0xeeeeee;
			mTimerTxt.x = xPos-.5*radius;
			mTimerTxt.y = yPos + 2.4*radius;
			mTimerTxt.scaleX = 1.2;
			mTimerTxt.scaleY = 1.2;
			mTimerTxt.text = "" + beatsPerMeasure;
			mTimerTxt.selectable = false;
			//this.addChild(mTimerTxt);
			
			// TODO: Create timeline below Metronome
			this.mNumBeatsPerMeasure = beatsPerMeasure;
			
			this.name = "MetronomeDefault";
		}

		private function createDownBeatShape(xPos:Number, yPos:Number) : Shape
		{
			var BeatOnsetShape:Shape = new Shape();

			BeatOnsetShape.graphics.beginFill(0xAA3311);
			BeatOnsetShape.graphics.drawCircle(0, 0, radius);
			BeatOnsetShape.graphics.endFill();
			BeatOnsetShape.x = xPos;
			BeatOnsetShape.y = yPos;

			return BeatOnsetShape;
		}

		private function createSubBeatShape(xPos:Number, yPos:Number) : Shape
		{
			var BeatOnsetShape:Shape = new Shape();

			BeatOnsetShape.graphics.beginFill(0xCC9911);
			BeatOnsetShape.graphics.drawCircle(0, 0, radius);
			BeatOnsetShape.graphics.endFill();
			BeatOnsetShape.x = xPos;
			BeatOnsetShape.y = yPos;

			return BeatOnsetShape;
		}

		public function updateTimer( pSeconds:Number ) : void {
			mTimerTxt.text = "" + pSeconds.toFixed(2);
		}
		
		public function downBeat() : void 
		{
			
			DownbeatTweenScaleX.start();
			DownbeatTweenScaleY.start();
			
			mTimeSignatureTxt.text = "1/"+mNumBeatsPerMeasure;
		}

		public function subBeat( beatNum:Number ) : void
		{
			SubBeatTweenScaleX.start();
			SubBeatTweenScaleY.start();
			mouthTween.start();
			
			mTimeSignatureTxt.text = "" + beatNum + "/" + mNumBeatsPerMeasure;
		}
		
		private function startBeatTweenFinish(Evt:TweenEvent) : void {
			DownbeatTweenScaleX.removeEventListener(TweenEvent.MOTION_FINISH, startBeatTweenFinish );
			DownbeatTweenScaleY.removeEventListener(TweenEvent.MOTION_FINISH, startBeatTweenFinish );
			
			//Conductor.getInstance().rotation;
			
			//DownbeatTweenScaleX.yoyo();
			//DownbeatTweenScaleY.yoyo();
			
		}
		
		private function subBeatTweenFinish(Evt:TweenEvent) : void {
			
			Conductor.getInstance().KittyMouth.y -= 10;
			SubBeatTweenScaleX.removeEventListener(TweenEvent.MOTION_FINISH, subBeatTweenFinish );
			SubBeatTweenScaleY.removeEventListener(TweenEvent.MOTION_FINISH, subBeatTweenFinish );
			mouthTween.removeEventListener(TweenEvent.MOTION_FINISH, subBeatTweenFinish );
			
			mouthTween.yoyo();
			SubBeatTweenScaleX.yoyo();
			SubBeatTweenScaleY.yoyo();
			
		}

	}

}