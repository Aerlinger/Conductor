package com.karaoke
{
	import com.element.BaseElement;
	import com.element.SynchronizedSprite;
	import com.event.BeatEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.Strong;
	import com.greensock.events.TweenEvent;
	import com.lyrics.RiceKaraoke;
	import com.lyrics.RiceKaraokeShow;
	import com.lyrics.SimpleKaraokeDisplayEngine;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class KittyKaraoke extends SynchronizedSprite {
		
		public var KittyHead:BaseElement;
		public var KittyMouth:BaseElement;
		public var KittyBGLoader:Loader 	= new Loader();
		public var KittyHeadLoader:Loader 	= new Loader();
		public var KittyMouthLoader:Loader 	= new Loader();
		
		private var numDisplayLines:uint = 2; // Number of lines to do the karaoke with
		private var timings:Array = [[1.35,3.07,[[0,"What "],[0.07,"is "],[0.28,"love"]]],[3.07,5.26,[[0,"Baby, "],[0.18,"don't "],[0.4,"hurt "],[0.79,"me"]]],[5.26,6.94,[[0,"Don't "],[0.16,"hurt "],[0.65,"me"]]],[7.14,8.35,[[0,"no "],[0.22,"more"]]],[10.53,12.99,[[0,"Baby, "],[0.46,"don't "],[0.74,"hurt "],[1.22,"me"]]],[12.99,14.83,[[0,"Don't "],[0.2,"hurt "],[0.71,"me"]]],[14.83,16.11,[[0,"no "],[0.3,"more"]]],[24.34,26.19,[[0,"What "],[0.21,"is "],[0.45,"love"]]],[32.63,33.59,[[0,"Ye"],[0.18,"-eah"]]],[41.53,43.28,[[0,"I "],[0.24,"don't "],[0.72,"know"]]],[43.47,45.21,[[0,"you're "],[0.26,"not "],[0.73,"there"]]],[45.45,46.86,[[0,"I "],[0.21,"give "],[0.3,"you "],[0.45,"my "],[0.69,"love"]]],[46.86,48.85,[[0,"but "],[0.12,"you "],[1.02,"don't "],[1.26,"care"]]],[49.09,50.78,[[0,"So "],[0.23,"what "],[0.5,"is "],[0.98,"right"]]],[51.28,53,[[0,"what "],[0.23,"is "],[0.72,"wrong"]]],[53.2,55.31,[[0,"Give "],[0.26,"me "],[0.5,"a "],[0.74,"sign"]]],[55.39,56.62,[[0,"What "],[0.24,"is "],[0.5,"love"]]],[57.08,58.78,[[0,"Baby, "],[0.49,"don't "],[0.74,"hurt "],[1.22,"me"]]],[59.51,60.72,[[0,"Don't "],[0.24,"hurt "],[0.72,"me"]]],[61.43,62.41,[[0,"no "],[0.26,"more"]]],[63.15,64.59,[[0,"What "],[0.22,"is "],[0.47,"love"]]],[64.83,66.53,[[0,"Baby, "],[0.48,"don't "],[0.74,"hurt "],[1.19,"me"]]],[67.27,68.69,[[0,"Don't "],[0.25,"hurt "],[0.72,"me"]]],[69.18,70.15,[[0,"no "],[0.24,"more"]]],[103.59,105.02,[[0,"I "],[0.24,"don't "],[0.71,"know"]]],[105.18,106.97,[[0,"What "],[0.33,"can "],[0.6,"I "],[1.07,"do"]]],[107.34,108.92,[[0,"What "],[0.11,"else "],[0.37,"can "],[0.61,"I "],[0.85,"say"]]],[108.92,110.85,[[0,"it's "],[0.25,"up "],[0.97,"to "],[1.21,"you"]]],[111.31,112.78,[[0,"I "],[0.11,"know "],[0.27,"we're "],[0.73,"one"]]],[113.03,114.72,[[0,"just "],[0.24,"me "],[0.45,"and "],[0.98,"you"]]],[115.09,117.38,[[0,"I "],[0.12,"can't "],[0.6,"go "],[0.86,"on"]]],[117.39,118.82,[[0,"What "],[0.25,"is "],[0.49,"love"]]],[119.07,121.02,[[0,"Baby, "],[0.49,"don't "],[0.74,"hurt "],[1.23,"me"]]],[121.52,122.71,[[0,"Don't "],[0.22,"hurt "],[0.47,"me"]]],[123.45,124.41,[[0,"no "],[0.24,"more"]]],[125.12,126.72,[[0,"What "],[0.25,"is "],[0.52,"love"]]],[126.83,128.65,[[0,"Baby, "],[0.47,"don't "],[0.74,"hurt "],[1.2,"me"]]],[129.25,130.59,[[0,"Don't "],[0.25,"hurt "],[0.76,"me"]]],[131.2,132.17,[[0,"no "],[0.23,"more"]]],[148.39,149.96,[[0,"What "],[0.26,"is "],[0.48,"love"]]],[156.14,157.72,[[0,"What "],[0.23,"is "],[0.49,"love"]]],[163.89,165.59,[[0,"What "],[0.25,"is "],[0.49,"love"]]],[165.59,167.82,[[0,"Baby, "],[0.49,"don't "],[0.69,"hurt "],[1.17,"me"]]],[168,169.97,[[0,"Don't "],[0.24,"hurt "],[0.64,"me"]]],[169.97,171.09,[[0,"no "],[0.24,"more"]]],[181.8,183.26,[[0,"Don't "],[0.26,"hurt "],[0.73,"me"]]],[185.67,187.15,[[0,"Don't "],[0.26,"hurt "],[0.74,"me"]]],[188.82,190.76,[[0,"I "],[0.13,"want "],[0.49,"no "],[0.75,"other"]]],[190.76,192.58,[[0,"no "],[0.25,"other "],[0.74,"lover"]]],[192.96,194.53,[[0,"This "],[0.23,"is "],[0.49,"your "],[0.97,"life"]]],[194.9,196.09,[[0,"our "],[0.48,"time"]]],[196.45,198.41,[[0,"When "],[0.14,"we "],[0.41,"are "],[0.86,"together,"]]],[198.41,200.45,[[0,"I "],[0.12,"need "],[0.36,"you "],[0.59,"forever"]]],[200.71,202.63,[[0,"Is "],[0.22,"it "],[0.6,"love?"]]],[202.63,204.22,[[0,"What "],[0.26,"is "],[0.49,"love"]]],[204.32,206.51,[[0,"Baby, "],[0.49,"don't "],[0.75,"hurt "],[1.24,"me"]]],[206.76,208.46,[[0,"Don't "],[0.24,"hurt "],[0.73,"me"]]],[208.69,209.66,[[0,"no "],[0.24,"more"]]],[210.38,212.08,[[0,"What "],[0.25,"is "],[0.49,"love"]]],[212.08,214.02,[[0,"Baby, "],[0.48,"don't "],[0.72,"hurt "],[1.23,"me"]]],[214.49,215.84,[[0,"Don't "],[0.27,"hurt "],[0.74,"me"]]],[216.45,217.41,[[0,"no "],[0.24,"more"]]],[218.38,219.35,[[0,"Ye"],[0.35,"-eah"]]],[233.63,235.21,[[0,"What "],[0.24,"is "],[0.5,"love"]]],[235.33,237.15,[[0,"Baby, "],[0.5,"don't "],[0.74,"hurt "],[1.17,"me"]]],[237.75,239.09,[[0,"Don't "],[0.28,"hurt "],[0.69,"me"]]],[239.7,240.67,[[0,"no "],[0.24,"more"]]],[241.39,243.08,[[0,"What "],[0.25,"is "],[0.48,"love"]]],[243.08,245.01,[[0,"Baby, "],[0.5,"don't "],[0.73,"hurt "],[1.18,"me"]]],[245.5,246.86,[[0,"Don't "],[0.24,"hurt "],[0.67,"me"]]],[247.45,248.41,[[0,"no "],[0.23,"more"]]],[250.82,252.66,[[0,"Baby, "],[0.51,"don't "],[0.75,"hurt "],[1.2,"me"]]],[253.26,254.96,[[0,"Don't "],[0.26,"hurt "],[0.66,"me"]]],[255.19,256.18,[[0,"no "],[0.25,"more"]]],[258.57,260.76,[[0,"Baby, "],[0.49,"don't "],[0.76,"hurt "],[1.23,"me"]]],[260.99,262.7,[[0,"Don't "],[0.27,"hurt "],[0.68,"me"]]],[262.95,263.9,[[0,"no "],[0.25,"more"]]],[264.65,268,[[0,"What "],[0.22,"is "],[0.47,"love?"]]]];
		
		
		private var isScrubbing:Boolean = false;
		private var wasPaused:Boolean 	= false;
		private var show:RiceKaraokeShow = null;
		
		private var mFirstLineText:TextField;
		private var mSecondLineText:TextField;
		
		//////////////////////////////////////////////////////
		// Tweening variables:
		//////////////////////////////////////////////////////

		
		
		public function KittyKaraoke() {
			
			KittyBGLoader.load( new URLRequest("images/kittyBG.png") );
			KittyHeadLoader.load( new URLRequest("images/kittyHead.png") );
			KittyMouthLoader.load( new URLRequest("images/kittyMouth.png") );
			
			KittyHead = new BaseElement();
			KittyMouth = new BaseElement();
			addChild(KittyBGLoader);
			
			KittyHead.addChild(KittyHeadLoader);
			KittyMouth.addChild(KittyMouthLoader);
			KittyHead.addChild(KittyMouth);
			KittyHead.setPivotPointGlobal(357, 158);
			
			addChild(KittyHead);
			
			// Render text here:
			var karaoke:RiceKaraoke = new RiceKaraoke(RiceKaraoke.simpleTimingToTiming(timings));
			var renderer:SimpleKaraokeDisplayEngine = new SimpleKaraokeDisplayEngine('karaoke-display', numDisplayLines);
			show = karaoke.createShow(renderer, numDisplayLines);
			
			// Add the text
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 22;
			myFormat.align = "center";
			myFormat.bold = true;
			
			mFirstLineText = new TextField();
			mFirstLineText.defaultTextFormat = myFormat;
			mFirstLineText.x = -150;
			mFirstLineText.y = 275;
			mFirstLineText.height = 30;
			mFirstLineText.width = 600;
			mFirstLineText.textColor = 0xFF0000;
			
			mSecondLineText = new TextField();
			mSecondLineText.x = 300;
			mSecondLineText.y = this.height - 75;
			mSecondLineText.textColor = 0xFF0000;
			
			this.addChild(mFirstLineText)
		}
		
		public function moveMouth(duration:Number) : void {
			TweenMax.to(KittyMouthLoader, .5, {repeat:-1, yoyo:true, y:(KittyMouthLoader.y+10)});
		}
		
		/** Gets the current lyrics corresponding to a time in the playback */
		private function getLineByTime( time_in_seconds:Number ) : Array {
			
			var timings:Array = show._engine.timings;
			
			var firstLineString:String 	= "";
			var secondLineString:String 	= "";
			
			for( var i:uint=0; i<timings.length; ++i ) {
				var start_time:Number = timings[i].start;
				var end_time:Number = timings[i].end;
				
				// Check if we are in our interval
				if( time_in_seconds > start_time && time_in_seconds < end_time ) {
					// If so, find our line and display it.
					for( var m:uint=0; m<timings[i].line.length; ++m ) {
						firstLineString += timings[i].line[m].text;
					}
				}
				mFirstLineText.x = this.width/2 - mFirstLineText.width/2;
				mFirstLineText.text = firstLineString;
				
			}
			
			return [firstLineString, secondLineString];
		}
		
		override protected function beatStart(beatEvent:BeatEvent):void {
			TweenMax.to(KittyHead, .2, {repeat:1, yoyo:true, rotation:-10});
			TweenMax.to(KittyMouthLoader, .2, {repeat:1, yoyo:true, y:(KittyMouthLoader.y+10)});
		}
		
		override protected function onUpdate(event:Event):void {
			getLineByTime(mMainTimeline.currentTime);
		}
	}
}