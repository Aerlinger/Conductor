package com.element
{
	import com.event.BeatEvent;
	import com.event.MeasureEvent;
	import com.greensock.events.TweenEvent;
	import com.time.ConductorTimeline;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 
	 * @author Aerlinger
	 * 
	 */	
	public class SynchronizedSprite extends Sprite {
		
		protected var mMainTimeline:ConductorTimeline;
		
		public function SynchronizedSprite() {
		}
		
		public function setTargetTimeline(pTimeline:ConductorTimeline) : void {
			
			pTimeline.addEventListener(BeatEvent.BEAT_START, 	beatStart);
			pTimeline.addEventListener(BeatEvent.BEAT_END, 		beatEnd);
			pTimeline.addEventListener(MeasureEvent.MEASURE_START, 	measureStart);
			pTimeline.addEventListener(MeasureEvent.MEASURE_END, 	measureEnd);
			pTimeline.addEventListener( TweenEvent.UPDATE, onUpdate );
			
			mMainTimeline = pTimeline;
		}
		
		public function getTimeline() : ConductorTimeline {
			return mMainTimeline;
		}
		
		protected function onUpdate(event:Event):void {
			// TODO Auto-generated method stub
			
		}
		
		protected function beatEnd(beatEvent:BeatEvent) : void {
			// TODO Auto-generated method stub
			
		}
		
		protected function beatStart(beatEvent:BeatEvent) : void {
			// TODO Auto-generated method stub
			
		}
		
		protected function measureEnd(measureEvent:MeasureEvent) : void {
			// TODO Auto-generated method stub
			
		}
		
		protected function measureStart(measureEvent:MeasureEvent) : void {
			// TODO Auto-generated method stub
			
		}
		
	}
}