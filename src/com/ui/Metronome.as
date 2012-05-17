package com.ui
{

	import com.element.SynchronizedSprite;
	import com.event.BeatEvent;
	import com.event.MeasureEvent;
	import com.greensock.TweenMax;
	
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;

	
	/** Visual element to indicate the onset of each beat and downbeat (first beat of the measure). 
	 * 
	 * @author Anthony Erlinger
	 * */
	public class Metronome extends SynchronizedSprite {

		private var BeatOnsetShape:Shape;
		private var SubBeatShape:Shape;

		private var radius:Number = 30;
		
		private var mNumBeatsPerMeasure:Number;
		
		private var mTitleTxt:TextField;
		private var mTimeSignatureTxt:TextField;
		private var mTimerTxt:TextField;
		
		
		public function Metronome( xPos:Number, yPos:Number, beatsPerMeasure:Number ) {
			
			// Create circles which pulse at the onset of every beat, and measure (downbeat).
			BeatOnsetShape 	= createDownBeatShape(xPos,yPos);
			SubBeatShape 	= createSubBeatShape(xPos,yPos);
			
			this.addChild( BeatOnsetShape );
			this.addChild( SubBeatShape );
			
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
		
		private function createDownBeatShape(xPos:Number, yPos:Number) : Shape {
			var BeatOnsetShape:Shape = new Shape();

			BeatOnsetShape.graphics.beginFill(0xAA3311);
			BeatOnsetShape.graphics.drawCircle(0, 0, radius);
			BeatOnsetShape.graphics.endFill();
			BeatOnsetShape.x = xPos;
			BeatOnsetShape.y = yPos;

			return BeatOnsetShape;
		}

		private function createSubBeatShape(xPos:Number, yPos:Number) : Shape {
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
		
		/** Called at the start of each measure */
		override protected function beatStart(event:BeatEvent) : void {
			
			TweenMax.to(SubBeatShape, .1, {yoyo:true, repeat:1, scaleX:.1, scaleY:.1});
			TweenMax.to(BeatOnsetShape, .1, {yoyo:true, repeat:1, scaleX:1.5, scaleY:1.5});
			
			mTimeSignatureTxt.text = "1/"+mNumBeatsPerMeasure;
		}
		
		override protected function measureStart(measureEvent:MeasureEvent):void {
			//TweenMax.to(SubBeatShape, .5, {yoyo:true, scaleX:1.1, scaleY:1.1, alpha:0});
			//TweenMax.to(BeatOnsetShape, .5, {yoyo:true, scaleX:1.1, scaleY:1.1, alpha:0});
			// TODO Auto Generated method stub
			super.measureStart(measureEvent);
		}
		

	}

}