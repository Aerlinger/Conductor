package  {
	
	
	import com.element.*;
	import com.greensock.*;
	import com.greensock.events.*;
	import com.karaoke.KittyKaraoke;
	import com.lyrics.*;
	import com.sound.MusicPlayer;
	import com.time.ConductorTimeline;
	import com.ui.BackgroundSprite;
	import com.ui.Metronome;
	import com.ui.TimelineSprite;
	
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	
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
	 * @author Anthony Erlinger 2012
	 * */
	[SWF(backgroundColor="0x222222", width=480, height=320, frameRate="40", widthPercent="50", pageTitle="Conductor")] 
	public final class Conductor extends MovieClip {
		
		//=================================================
		// Track beat and time signature information
		//=================================================
		public const BPM:uint 					= 124;	// Number of beats per minute
		public const BEATS_PER_MEASURE:uint 	= 4;	// Beats per measure
		public const NUM_MEASURES:uint			= 140;	// Number of measures in the track
		
		// Tracks timing and stores beat information for this track.
		private var mMainTimeline:ConductorTimeline;
		private var mMusicPlayer:MusicPlayer; 		// Handles mp3 playback
		
		//=================================================
		// Visual elements
		//=================================================
		private var mMetronome:Metronome;					// Visual feedback for beat onsets, pulses each beat and measure.
		//private var mTimelineSprite:TimelineSprite;		// Visual object for the Timeline
		//private var mBackgroundSprite:BackgroundSprite; 	// Graphical representation of the color wheel
		
		//=================================================
		// Karaoke Stuff
		//=================================================
		private var mKittyKaraoke:KittyKaraoke = new KittyKaraoke();
		

		/** Starting point of the program. This is a singleton class so it should not be instantiated. */
		public function Conductor() {
			
			// =============================================================
			// Step 1: Declare constants, and define flash-specific rendering info
			// =============================================================
			trace("Started Conductor Application");
			stage.scaleMode = StageScaleMode.NO_SCALE;	
			
			// External callbacks (these functions can be called from JavaScript)
			if (ExternalInterface.available) {
				Security.allowDomain('*');
				Security.allowInsecureDomain('*');
				ExternalInterface.addCallback("startPlaying", function() : void {
					mMainTimeline.resume();
				});
				
				ExternalInterface.addCallback("stopPlaying", function() : void {
					mMainTimeline.paused = true;
				});
				
				ExternalInterface.addCallback("setURL", function(URL:String) : void {
					mMusicPlayer = new MusicPlayer(URL);
				});
			}
			
			// =============================================================
			// Step 2: Initialize and populate the stage
			// =============================================================
			
			// Initializes the timeline based on existing parameters
			mMainTimeline 		= new ConductorTimeline(BPM, BEATS_PER_MEASURE, NUM_MEASURES);
			
			// Creates the music player
			mMusicPlayer = new MusicPlayer("assets/music/what_is_love.mp3");
			mMusicPlayer.resume();
			
			mMetronome = new Metronome(100, 100, BEATS_PER_MEASURE);
			mMetronome.setTargetTimeline(mMainTimeline);
			
			mKittyKaraoke.setTargetTimeline(mMainTimeline);
			
			addChild(mKittyKaraoke);
			addChild(mMetronome);
			
			// Render the color wheel and place it on the stage.
			mMainTimeline.addEventListener(TweenEvent.UPDATE, onTimerUpdate);
			
			// Initialize pre-defined animations and their corresponding keypoints.
			//testRun();
			
			// Start the animation
			mMainTimeline.play();
		}
		
		public function resume() : void {
			this.resume();
			this.paused = false;
		}
		
		public function pause() : void {
			this.paused = true;
		}
		
		public function set paused(isPause:Boolean) : void {
			
			this.paused = isPause;
			if(mMusicPlayer != null) {
				if(isPause)
					mMusicPlayer.pause();
				else
					mMusicPlayer.resume();
			}
		}
		
		/** Test code for scripted animation. Called once at startup */
		private function testRun() : void {
			
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
			LeftCircle.x = stage.stageWidth/2-200;
			LeftCircle.y = stage.stageHeight/2;
			
			TopCircle.x = stage.stageWidth/2
			TopCircle.y = stage.stageHeight/2-250;
			
			RightCircle.x = stage.stageWidth/2+200;
			RightCircle.y = stage.stageHeight/2;
			
			CenterCircle.x = stage.stageWidth/2+100;
			CenterCircle.y = stage.stageHeight/2-250;
			
			addChild(LeftCircle);
			addChild(TopCircle);
			addChild(RightCircle);
			addChild(CenterCircle);
			
			var TestLine:LineElement = new LineElement(null, -100, 0, 100, 0);
			
			addChild(TestLine);
			
			TestLine.setParent1(LeftCircle);
			TestLine.setParent2(RightCircle);
			
			/*
			var ClonedLeftCircle:CircleElement = LeftCircle.clone();
			
			addChild(ClonedLeftCircle);
			ClonedLeftCircle.moveBy(100, 100, 2);
			
			CenterCircle.moveTo(CENTER_X, 100, 3);
			
			LeftCircle.moveTo(CENTER_X - 100, CENTER_Y + 75, 2, 5);
			RightCircle.moveTo(CENTER_X + 100, CENTER_Y - 75, 2, 5);
	
			var TestGroup:Group = new Group(null, LeftCircle, TopCircle);
			TestGroup.name = "TestGroup";
			
			var TestGroup2:Group = new Group(null, TestGroup, CenterCircle, RightCircle);
			TestGroup2.name = "TestGroup2";
			
			TestGroup2.setPivotPoint(CENTER_X, CENTER_Y);
			
			TestGroup.moveBy(600, 0, 5);
			TestGroup2.rotateBy(360, 5, 7);
		
			mMainTimeline.insert( new TweenMax(CenterCircle, 3, {y:100}), 0 ); 
			
			CenterCircle.enableHitArea(true);
			CenterCircle.enableDrawHitArea(true);
			
			CenterCircle.setHitRadius(10);
			TopCircle.setHitRadius(10);
			
			CenterCircle.addCollisionCandidate(TopCircle);
			TopCircle.addCollisionCandidate(CenterCircle);
			
			
			CenterCircle.scaleX = 10;
			CenterCircle.scaleY = 10;
			CenterCircle.addBlur();
		
			var CenterFlower:TimelineMax = CenterCircle.rumble(20, 10, 50);
			CenterFlower.resume();
			CenterFlower.repeat = -1;
		
			CenterFlower.reversed = true;
			
			var Flower1:TimelineMax = TestGroup.flower(4, 2);
			var FlareGroup:Group = TestGroup.flower(4, 2).data;
			
			var TestTimeline:TimelineMax = new TimelineMax();
			
			TestTimeline.insert(CenterFlower, 0);
			TestTimeline.insert( FlareGroup.condense(), 4);
			
			TestTimeline.insert( new TweenConductor(TestGroup, 2, {rotation:360}), 4);
			mMainTimeline.insert(Flower1, 0);
			*/
			
		}
		
		/** Prints useful information about this class. */
		override public function toString() : String {
			
			var Msg:String = "";
			
			// Print information about this track
			Msg.concat("BPM: " + mMainTimeline.getBPM());
			Msg.concat("Beats per measure: " + mMainTimeline.getNumBeatsPerMeasure());
			Msg.concat("Number of measures: " + mMainTimeline.getNumMeasures() ); trace(" ");
			Msg.concat("Track Duration: " + mMainTimeline.totalDuration + "s");
			Msg.concat("Duration of each Measure: " + mMainTimeline.getDurationOfMeasure() + "s");
			Msg.concat("Duration of each Beat: " +  mMainTimeline.getDurationOfBeat() + "s");
			Msg.concat(" \n");
			
			Msg.concat("Children: ");
			for( var i:uint=0; i<this.numChildren; ++i ) 
				Msg += "Child: " + this.getChildAt(i).name;
			
			return Msg;
		}
		
		///////////////////////////////////////
		// Event handling functions
		///////////////////////////////////////
		
		/** Main timeline Loop: 
		 * 
		 * Called every time the main timer updates (i.e. each frame). */
		private function onTimerUpdate( Evt:Event ) : void {
			
		}
		
		/** Read the position of the mouse cursor, used for debugging object placement. */
		private function onMouseMove( evt:MouseEvent ) : void {
		}
		
	}
	
}