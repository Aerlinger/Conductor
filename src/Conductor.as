package  {
	
	
	import com.anim.TweenConductor;
	import com.element.*;
	import com.element.CollisionManager;
	import com.event.BeatEvent;
	import com.event.MeasureEvent;
	import com.greensock.*;
	import com.greensock.events.*;
	import com.lyrics.*;
	import com.time.ConductorTimeline;
	import com.ui.BackgroundSprite;
	import com.ui.Metronome;
	import com.ui.TimelineSprite;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.media.Microphone;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	
	import org.osmf.events.TimeEvent;
	
	import spark.components.Button;
	
	
	/** Entry class. Contains all time graphics elements 
	 * 
	 * What is Conductor? 
	 * 
	 * Conductor is a music-visual effects synchronization application capable of producing rich interactive multimedia in Games, 
	 *  media. 
	 * 
	 * Important: This is the only class in the project that should extend MovieClip. All timing, events, and actions must be handled
	 *   by the com.time.Timeline class.
	 * 
	 * @author Anthony Erlinger
	 * */
	[SWF(backgroundColor="0x222222", width=480, height=320, frameRate="40", widthPercent="50",pageTitle="Conductor")] // Initialize the background color of the SWF to a dark grey.
	public final class Conductor extends MovieClip {
		
		// Define the track data
		public const FPS:Number = 40;
		public const BPM:uint 					= 124;	// Number of beats per minute
		public const BEATS_PER_MEASURE:uint 	= 4;	// Beats per measure
		public const NUM_MEASURES:uint			= 140;	// Number of measures in the track
		
		// Width and height of the stage, these dimensions must be the same as the width/height variables defined in the <MainProgram>-app.xml file
		private static var WIDTH:Number;
		private static var HEIGHT:Number;
		
		// Center of the stage.
		private static var CENTER_X:Number;
		private static var CENTER_Y:Number;
		
		
		// Member objects.
		private static var mMainTimeline:ConductorTimeline;
		private static var mBackgroundSprite:BackgroundSprite; 	// Graphical representation of the color wheel.
		
		// Reference to the single Instance of this class.
		private static var INSTANCE:Conductor;
		
		/** **************************************************
		 * ** KARAOKE STUFF:
		 * **************************************************/
		var numDisplayLines = 2; // Number of lines to do the karaoke with
		var timings = [[1.35,3.07,[[0,"What "],[0.07,"is "],[0.28,"love"]]],[3.07,5.26,[[0,"Baby, "],[0.18,"don't "],[0.4,"hurt "],[0.79,"me"]]],[5.26,6.94,[[0,"Don't "],[0.16,"hurt "],[0.65,"me"]]],[7.14,8.35,[[0,"no "],[0.22,"more"]]],[10.53,12.99,[[0,"Baby, "],[0.46,"don't "],[0.74,"hurt "],[1.22,"me"]]],[12.99,14.83,[[0,"Don't "],[0.2,"hurt "],[0.71,"me"]]],[14.83,16.11,[[0,"no "],[0.3,"more"]]],[24.34,26.19,[[0,"What "],[0.21,"is "],[0.45,"love"]]],[32.63,33.59,[[0,"Ye"],[0.18,"-eah"]]],[41.53,43.28,[[0,"I "],[0.24,"don't "],[0.72,"know"]]],[43.47,45.21,[[0,"you're "],[0.26,"not "],[0.73,"there"]]],[45.45,46.86,[[0,"I "],[0.21,"give "],[0.3,"you "],[0.45,"my "],[0.69,"love"]]],[46.86,48.85,[[0,"but "],[0.12,"you "],[1.02,"don't "],[1.26,"care"]]],[49.09,50.78,[[0,"So "],[0.23,"what "],[0.5,"is "],[0.98,"right"]]],[51.28,53,[[0,"what "],[0.23,"is "],[0.72,"wrong"]]],[53.2,55.31,[[0,"Give "],[0.26,"me "],[0.5,"a "],[0.74,"sign"]]],[55.39,56.62,[[0,"What "],[0.24,"is "],[0.5,"love"]]],[57.08,58.78,[[0,"Baby, "],[0.49,"don't "],[0.74,"hurt "],[1.22,"me"]]],[59.51,60.72,[[0,"Don't "],[0.24,"hurt "],[0.72,"me"]]],[61.43,62.41,[[0,"no "],[0.26,"more"]]],[63.15,64.59,[[0,"What "],[0.22,"is "],[0.47,"love"]]],[64.83,66.53,[[0,"Baby, "],[0.48,"don't "],[0.74,"hurt "],[1.19,"me"]]],[67.27,68.69,[[0,"Don't "],[0.25,"hurt "],[0.72,"me"]]],[69.18,70.15,[[0,"no "],[0.24,"more"]]],[103.59,105.02,[[0,"I "],[0.24,"don't "],[0.71,"know"]]],[105.18,106.97,[[0,"What "],[0.33,"can "],[0.6,"I "],[1.07,"do"]]],[107.34,108.92,[[0,"What "],[0.11,"else "],[0.37,"can "],[0.61,"I "],[0.85,"say"]]],[108.92,110.85,[[0,"it's "],[0.25,"up "],[0.97,"to "],[1.21,"you"]]],[111.31,112.78,[[0,"I "],[0.11,"know "],[0.27,"we're "],[0.73,"one"]]],[113.03,114.72,[[0,"just "],[0.24,"me "],[0.45,"and "],[0.98,"you"]]],[115.09,117.38,[[0,"I "],[0.12,"can't "],[0.6,"go "],[0.86,"on"]]],[117.39,118.82,[[0,"What "],[0.25,"is "],[0.49,"love"]]],[119.07,121.02,[[0,"Baby, "],[0.49,"don't "],[0.74,"hurt "],[1.23,"me"]]],[121.52,122.71,[[0,"Don't "],[0.22,"hurt "],[0.47,"me"]]],[123.45,124.41,[[0,"no "],[0.24,"more"]]],[125.12,126.72,[[0,"What "],[0.25,"is "],[0.52,"love"]]],[126.83,128.65,[[0,"Baby, "],[0.47,"don't "],[0.74,"hurt "],[1.2,"me"]]],[129.25,130.59,[[0,"Don't "],[0.25,"hurt "],[0.76,"me"]]],[131.2,132.17,[[0,"no "],[0.23,"more"]]],[148.39,149.96,[[0,"What "],[0.26,"is "],[0.48,"love"]]],[156.14,157.72,[[0,"What "],[0.23,"is "],[0.49,"love"]]],[163.89,165.59,[[0,"What "],[0.25,"is "],[0.49,"love"]]],[165.59,167.82,[[0,"Baby, "],[0.49,"don't "],[0.69,"hurt "],[1.17,"me"]]],[168,169.97,[[0,"Don't "],[0.24,"hurt "],[0.64,"me"]]],[169.97,171.09,[[0,"no "],[0.24,"more"]]],[181.8,183.26,[[0,"Don't "],[0.26,"hurt "],[0.73,"me"]]],[185.67,187.15,[[0,"Don't "],[0.26,"hurt "],[0.74,"me"]]],[188.82,190.76,[[0,"I "],[0.13,"want "],[0.49,"no "],[0.75,"other"]]],[190.76,192.58,[[0,"no "],[0.25,"other "],[0.74,"lover"]]],[192.96,194.53,[[0,"This "],[0.23,"is "],[0.49,"your "],[0.97,"life"]]],[194.9,196.09,[[0,"our "],[0.48,"time"]]],[196.45,198.41,[[0,"When "],[0.14,"we "],[0.41,"are "],[0.86,"together,"]]],[198.41,200.45,[[0,"I "],[0.12,"need "],[0.36,"you "],[0.59,"forever"]]],[200.71,202.63,[[0,"Is "],[0.22,"it "],[0.6,"love?"]]],[202.63,204.22,[[0,"What "],[0.26,"is "],[0.49,"love"]]],[204.32,206.51,[[0,"Baby, "],[0.49,"don't "],[0.75,"hurt "],[1.24,"me"]]],[206.76,208.46,[[0,"Don't "],[0.24,"hurt "],[0.73,"me"]]],[208.69,209.66,[[0,"no "],[0.24,"more"]]],[210.38,212.08,[[0,"What "],[0.25,"is "],[0.49,"love"]]],[212.08,214.02,[[0,"Baby, "],[0.48,"don't "],[0.72,"hurt "],[1.23,"me"]]],[214.49,215.84,[[0,"Don't "],[0.27,"hurt "],[0.74,"me"]]],[216.45,217.41,[[0,"no "],[0.24,"more"]]],[218.38,219.35,[[0,"Ye"],[0.35,"-eah"]]],[233.63,235.21,[[0,"What "],[0.24,"is "],[0.5,"love"]]],[235.33,237.15,[[0,"Baby, "],[0.5,"don't "],[0.74,"hurt "],[1.17,"me"]]],[237.75,239.09,[[0,"Don't "],[0.28,"hurt "],[0.69,"me"]]],[239.7,240.67,[[0,"no "],[0.24,"more"]]],[241.39,243.08,[[0,"What "],[0.25,"is "],[0.48,"love"]]],[243.08,245.01,[[0,"Baby, "],[0.5,"don't "],[0.73,"hurt "],[1.18,"me"]]],[245.5,246.86,[[0,"Don't "],[0.24,"hurt "],[0.67,"me"]]],[247.45,248.41,[[0,"no "],[0.23,"more"]]],[250.82,252.66,[[0,"Baby, "],[0.51,"don't "],[0.75,"hurt "],[1.2,"me"]]],[253.26,254.96,[[0,"Don't "],[0.26,"hurt "],[0.66,"me"]]],[255.19,256.18,[[0,"no "],[0.25,"more"]]],[258.57,260.76,[[0,"Baby, "],[0.49,"don't "],[0.76,"hurt "],[1.23,"me"]]],[260.99,262.7,[[0,"Don't "],[0.27,"hurt "],[0.68,"me"]]],[262.95,263.9,[[0,"no "],[0.25,"more"]]],[264.65,268,[[0,"What "],[0.22,"is "],[0.47,"love?"]]]];
		var musicPath = 'karaoke/what_is_love.mp3';
		
		var isScrubbing = false;
		var wasPaused = false;
		var show:RiceKaraokeShow = null;
		var player = null;
		var scrubber = null;
		var lastPosition = 0;
		
		public var KittyHead:BaseElement;
		public var KittyMouth:BaseElement;
		public var KittyBGLoader:Loader 	= new Loader();
		public var KittyHeadLoader:Loader 	= new Loader();
		public var KittyMouthLoader:Loader 	= new Loader();
		
		private var mFirstLineText:TextField;
		private var mSecondLineText:TextField;
		
		
		/** Starting point of the program. This is a singleton class so it should not be instantiated. */
		public function Conductor() {
			
			/* INSTANCE always points to the one and only implementation of the class.
			   Allows this class ot be accessed anywhere in the program */
			INSTANCE = this;
			
			trace("initializeStaticKeypoints(): Started");
			
			WIDTH 	= stage.stageWidth;
			HEIGHT 	= stage.stageHeight;
			
			// Origin is at the center of the stage (as opposed to the top-left).
			CENTER_X = WIDTH/2;
			CENTER_Y = HEIGHT/2;
			
			trace("Color wheel started:    X: " + stage.x + " Y: " + stage.y + " W: " + WIDTH + " H: " + HEIGHT + "  FR: " + stage.frameRate);
			
			stage.align 	= StageAlign.TOP_LEFT
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			KittyBGLoader.load( new URLRequest("images/kittyBG.png") );
			KittyHeadLoader.load( new URLRequest("images/kittyHead.png") );
			KittyMouthLoader.load( new URLRequest("images/kittyMouth.png") );
			
			KittyHead = new BaseElement();
			KittyMouth = new BaseElement();
			Conductor.getInstance().addChild(KittyBGLoader);
			
			KittyHead.addChild(KittyHeadLoader);
			KittyMouth.addChild(KittyMouthLoader);
			KittyHead.addChild(KittyMouth);
			KittyHead.setPivotPoint(357, 158);
			
			Conductor.getInstance().addChild(KittyHead);
			
			// Initializes the  timeline and adds it to the stage 
			mMainTimeline 	= new ConductorTimeline(this, BPM, BEATS_PER_MEASURE, NUM_MEASURES);
			
			// Render the color wheel and place it on the stage.
			mBackgroundSprite 	= new BackgroundSprite(mMainTimeline);
			mMainTimeline.addEventListener( TweenEvent.UPDATE, onTimerUpdate);
			
			// Listen every time a beat or measure is started in the timeline
			mMainTimeline.addEventListener( BeatEvent.BEAT_START, onBeatStart );
			mMainTimeline.addEventListener( MeasureEvent.MEASURE_START, onMeasureStart );
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			// Print information about this track
			trace("BPM: " + mMainTimeline.getBPM());
			trace("Beats per measure: " + mMainTimeline.getNumBeatsPerMeasure());
			trace("Number of measures: " + mMainTimeline.getNumMeasures() ); trace(" ");
			trace("Track Duration: " + mMainTimeline.totalDuration + "s");
			trace("Duration of each Measure: " + mMainTimeline.getDurationOfMeasure() + "s");
			trace("Duration of each Beat: " +  mMainTimeline.getDurationOfBeat() + "s");
			trace(" \n");
			
			mMainTimeline.resume();
			
			// Initialize pre-defined animations and their corresponding keypoints.
			//initializeStaticKeypoints();
			
			// Render text here:
			var karaoke:RiceKaraoke = new RiceKaraoke(RiceKaraoke.simpleTimingToTiming(timings));
			var renderer = new SimpleKaraokeDisplayEngine('karaoke-display', numDisplayLines);
			show = karaoke.createShow(renderer, numDisplayLines);
			
			if (ExternalInterface.available) {
				Security.allowDomain('*');
				Security.allowInsecureDomain('*');
				ExternalInterface.addCallback("startPlaying", function() {
					mMainTimeline.resume();
				});
				
				ExternalInterface.addCallback("stopPlaying", function() {
					mMainTimeline.paused = true;
				});
				
				ExternalInterface.addCallback("setURL", function(URL) {
					mMainTimeline.setMusic(URL);
				});
			}
			
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 22;
			myFormat.bold = true;
			myFormat.
			
			
			mFirstLineText = new TextField();
			mFirstLineText.defaultTextFormat = myFormat;
			mFirstLineText.x = CENTER_X-75;
			mFirstLineText.y = HEIGHT - 100;
			mFirstLineText.height = 30;
			mFirstLineText.width = 600;
			mFirstLineText.text = "";
			mFirstLineText.textColor = 0xFF0000;
			
			mSecondLineText = new TextField();
			mSecondLineText.x = 300;
			mSecondLineText.y = HEIGHT - 75;
			mSecondLineText.text = "Second line here";
			mSecondLineText.textColor = 0xFF0000;
			
			addChild(mFirstLineText)
			//addChild(mSecondLineText);
		}
		
		/** Returns the singleton instance of this class.*/
		public static function getInstance() : Conductor {
			return INSTANCE;
		}
		
		
		
		/** Test code for scripted animation. Called once at startup */
		private function initializeStaticKeypoints() : void {
			
			var LeftCircle:CircleElement 	= new CircleElement();
			var TopCircle:CircleElement 	= new CircleElement();
			var RightCircle:CircleElement 	= new CircleElement();
			var CenterCircle:CircleElement 	= new CircleElement();
			
			LeftCircle.setEnableCollisions(true);
			TopCircle.setEnableCollisions(true);
			CenterCircle.setEnableCollisions(true);
			RightCircle.setEnableCollisions(true);
			
			LeftCircle.name 	= "LEFT";
			TopCircle.name 		= "TOP";
			RightCircle.name 	= "RIGHT";
			CenterCircle.name 	= "CENTER";
			
			// Set Positions
			LeftCircle.x = CENTER_X-200;
			LeftCircle.y = CENTER_Y;
			
			TopCircle.x = CENTER_X;
			TopCircle.y = CENTER_Y-250;
			
			RightCircle.x = CENTER_X+200;
			RightCircle.y = CENTER_Y;
			
			CenterCircle.x = CENTER_X+100;
			CenterCircle.y = CENTER_Y-250;
			
			addChild(LeftCircle);
			addChild(TopCircle);
			addChild(RightCircle);
			addChild(CenterCircle);
			
			var TestLine:LineElement = new LineElement(null, -100, 0, 100, 0);
			
			addChild(TestLine);
			
			TestLine.setParent1(LeftCircle);
			TestLine.setParent2(RightCircle);
			
			var ClonedLeftCircle:CircleElement = LeftCircle.clone();
			
			addChild(ClonedLeftCircle);
			ClonedLeftCircle.moveBy(100, 100, 2);
			
			//CenterCircle.moveTo(CENTER_X, 100, 3);
			
			//LeftCircle.moveTo(CENTER_X - 100, CENTER_Y + 75, 2, 5);
			//RightCircle.moveTo(CENTER_X + 100, CENTER_Y - 75, 2, 5);
			
//			var TestGroup:Group = new Group(null, LeftCircle, TopCircle);
//			TestGroup.name = "TestGroup";
//			
//			var TestGroup2:Group = new Group(null, TestGroup, CenterCircle, RightCircle);
//			TestGroup2.name = "TestGroup2";
//			
//			TestGroup2.setPivotPoint(CENTER_X, CENTER_Y);
//			
//			TestGroup.moveBy(600, 0, 5);
//			TestGroup2.rotateBy(360, 5, 7);
			
			//mMainTimeline.insert( new TweenMax(CenterCircle, 3, {y:100}), 0 ); 
			
			//CenterCircle.enableHitArea(true);
			//CenterCircle.enableDrawHitArea(true);
			
			//CenterCircle.setHitRadius(10);
			//TopCircle.setHitRadius(10);
			
			//CenterCircle.addCollisionCandidate(TopCircle);
			//TopCircle.addCollisionCandidate(CenterCircle);
			
			
			//CenterCircle.scaleX = 10;
			//CenterCircle.scaleY = 10;
			//CenterCircle.addBlur();
			
//			var CenterFlower:TimelineMax = CenterCircle.rumble(20, 10, 50);
//			CenterFlower.resume();
//			CenterFlower.repeat = -1;
			
			//CenterFlower.reversed = true;
			
			//var Flower1:TimelineMax = TestGroup.flower(4, 2);
			//var FlareGroup:Group = TestGroup.flower(4, 2).data;
			
			//var TestTimeline:TimelineMax = new TimelineMax();
			
			//TestTimeline.insert(CenterFlower, 0);
			//TestTimeline.insert( FlareGroup.condense(), 4);
			
			//TestTimeline.insert( new TweenConductor(TestGroup, 2, {rotation:360}), 4);
			//mMainTimeline.insert(Flower1, 0);
			
		}
		
		/** Prints useful information about this class. */
		override public function toString() : String {
			var Msg:String = "";
			
			for( var i:uint=0; i<this.numChildren; ++i ) 
				Msg += "Child: " + this.getChildAt(i).name;
			
			return Msg;
		}
		
		///////////////////////////////////////
		// Event handling functions
		///////////////////////////////////////
		
		/** Main timeline Loop: 
		 * 
		 * Called every time the main timer updates. */
		private function onTimerUpdate( Evt:Event ) : void {
			mBackgroundSprite.setPlaybarRotation( mMainTimeline.totalProgress * 360 );
			
			mMainTimeline.getTimelineSprite().setTotalObjectsTxt( mMainTimeline.currentTime );
			//show.render(mMainTimeline.totalProgress, true);
			mFirstLineText.text = "" + mMainTimeline.currentTime;

			getLineByTime(mMainTimeline.currentTime);
			// Process collisions at each time step.
			CollisionManager.getInstance().processCollisions();
		}
		
		
		
		private function getLineByTime( time_in_seconds ) : Array {
			
			var timings = show._engine.timings;
			
			var firstLineString = "";
			var secondLineString = "";
			
			for( var i=0; i<timings.length; ++i ) {
				var start_time = timings[i].start;
				var end_time = timings[i].end;
				
				// Check if we are in our interval
				if( time_in_seconds > start_time && time_in_seconds < end_time ) {
					
					
					for( var m=0; m<timings[i].line.length; ++m ) {
						firstLineString += timings[i].line[m].text;
					}
					
					
				}
				
				mFirstLineText.x = CENTER_X - mFirstLineText.width/2;
				mFirstLineText.text = firstLineString;
				
				
			}
			
			return [firstLineString, secondLineString];
		}
		
		/** Read the position of the mouse cursor, used for debugging object placement. */
		private function onMouseMove( evt:MouseEvent ) : void {
			mBackgroundSprite.setCursorPositionText( evt.stageX, evt.stageY );
			/**mCursorPositionText.text = "" + evt.localX + ", " + evt.localY;*/
		}
		
		/** Beat Start Listener: Called at the start of each beat in the timeline */
		private function onBeatStart( BeatEvt:BeatEvent ) : void {
		}
		
		/** Beat Start Listener: Called at the start of each beat in the timeline */
		private function onMeasureStart( MeasureEvt:MeasureEvent ) : void {
		}
		
		///////////////////////////////////////
		// Getter functions
		///////////////////////////////////////
		public static function updateElementStatusTextInfo( pElement:BaseElement ) : void {
			mBackgroundSprite.updateElementStatusTextInfo(pElement);
		}
		
		/** Accessor function for the timeline. */
		public static function getTimeline() : ConductorTimeline {
			return mMainTimeline;
		}
		
		/** @return The number of seconds elapsed since the track has been started. */
		public function getTotalSecondsElapsed() : Number {
			return mMainTimeline.currentTime;
		}
		
		/** Returns the width of the main stage */
		public static function getWidth() : Number {
			return WIDTH;
		}
		
		/** Returns the height of the main stage */
		public static function getHeight() : Number {
			return HEIGHT;
		}
		
		/** Returns the center x position of the main stage */
		public static function getCenterX() : Number {
			return CENTER_X;
		}
		
		/** Returns the center y position of the main stage */
		public static function getCenterY() : Number {
			return CENTER_Y;
		}
		
	}
	
}