package  {
	
	
	import com.anim.ActionNode;
	import com.element.AnnulusElement;
	import com.element.BaseElement;
	import com.event.BeatEvent;
	import com.event.MeasureEvent;
	import com.sprites.ColorWheelSprite;
	import com.sprites.Metronome;
	import com.sprites.TimelineSprite;
	import com.time.Keypoint;
	import com.time.PreciseTimer;
	import com.time.Timeline;
	
	import fl.transitions.Tween;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Microphone;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	
	
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
	public class ColorWheelMain extends MovieClip {
		
		/** Moved these to TimeData class */
		public const BPM:uint 					= 30;	// Number of beats per minute
		public const BEATS_PER_MEASURE:uint 	= 6;	// Beats per measure
		public const NUM_MEASURES:uint			= 10;	// Number of measures in the track
		
		public const FRAME_DURATION:Number		= 40;
		
		// Width and height of the stage:
		private static var WIDTH:Number;
		private static var HEIGHT:Number;
		
		// Center of the stage.
		private static var CENTER_X:Number;
		private static var CENTER_Y:Number;
		
		
		// Member objects.
		private var mMainTimeline:Timeline; 				// Instance of the timeline.
		private var mColorWheelSprite:ColorWheelSprite; 	// Graphical representation of the color wheel.
		
		// Reference to the single Instance of this class.
		private static var INSTANCE:ColorWheelMain;
		
		// TEST ELEMENTS
		private var mTestAnnulus:AnnulusElement;
		
		
		
		
		
		/** Starting point of the program. I'd make this private if I could: DO NOT INSTANTIATE */
		public function ColorWheelMain() {
			
			
			// INSTANCE always points to the one and only implementation of the class.
			INSTANCE = this;
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			// Width/height of the stage.
			WIDTH  	= stage.stageWidth;
			HEIGHT 	= stage.stageHeight;
			
			// Center of the stage.
			CENTER_X = WIDTH/2;
			CENTER_Y = HEIGHT/2;
			
			// Initialize timeline first:
			mMainTimeline 	= new Timeline(this, BPM, BEATS_PER_MEASURE, NUM_MEASURES, FRAME_DURATION);
			
			// Render the color wheel and place it on the stage.
			mColorWheelSprite 	= new ColorWheelSprite(mMainTimeline);
			addChild(mColorWheelSprite);
			
			// Every time the Timeline updates we update the ColorWheelSprite
			mMainTimeline.addEventListener( TimerEvent.TIMER, onTimerTick );
			
			// Listen every time a beat or measure is started in the timeline
			mMainTimeline.addEventListener( BeatEvent.BEAT_START, onBeatStart );
			mMainTimeline.addEventListener( MeasureEvent.MEASURE_START, onMeasureStart );
			
			
			trace("Duration of each frame: " + FRAME_DURATION + "ms");
			trace("BPM: " + mMainTimeline.getBPM());
			trace("Beats per measure: " + mMainTimeline.getNumBeatsPerMeasure());
			trace("Number of measures: " + mMainTimeline.getNumMeasures() ); trace(" ");
			trace("Track Duration: " + mMainTimeline.getDurationOfTrack() + "s");
			trace("Duration of each Measure: " + mMainTimeline.getDurationOfMeasure() + "s");
			trace("Duration of each Beat: " +  mMainTimeline.getDurationOfBeat() + "s");
			trace(" \n");
			
			// Initialize pre-defined animations and their corresponding keypoints.
			initializeStaticKeypoints();
			
			mTestAnnulus = new AnnulusElement();
			addChild(mTestAnnulus);
			
		}
		
		/** Update the rotation of the playbar every frame */
		public function onTimerTick(TimerEvt:TimerEvent) : void {
			mColorWheelSprite.setPlaybarRotation( (mMainTimeline.getTotalSecondsElapsed() / mMainTimeline.getDurationOfTrack()) * 360 );
		}
		
		/** Returns the singleton instance of this class.*/
		public static function getInstance() : ColorWheelMain {
			return INSTANCE;
		} 
		
		/** Test code for scripted animation. Called once at startup */
		private function initializeStaticKeypoints() : void {
			
			// Element to be added.
			//var TestAnnulus:AnnulusElement = new AnnulusElement();
			//addChild(TestAnnulus);
			
			// Define action for the keypoint
			//var TestKeypointAction:Action = new Action(TestAnnulus, 3);
			//TestKeypointAction.setDestinationPosition(0, 0);
			//TestKeypointAction.setDestinationPosition(0, 0);
			
			// Initialize keypoint at 5 seconds.
			//var TestKeypoint:Keypoint = new Keypoint(5);
			//TestKeypoint.setAction(TestKeypointAction);
			
			// Add the keypoint to our main timeline
			//mMainTimeline.addKeypoint( TestKeypoint );
			
			
			// Create a list of objects
			// Create the first object at 150, CENTER_Y
			
			
			var TestAnnulus1:AnnulusElement = new AnnulusElement(150, CENTER_Y);
			TestAnnulus1.name = "TestAnnulus";
			addChild(TestAnnulus1);
			
			// This queues 4 move actions
			TestAnnulus1.moveTo(500, 500, 6).moveTo(800, 100, 3).moveTo(100, 800, 1).moveTo(100, 100, 2).moveTo(800, 800, 2.5);
			//TestAnnulus1.getActionByIndex(1).setDestinationScale(2, 2);
			
			
			//var TestAnnulus2:AnnulusElement = new AnnulusElement(350, CENTER_Y);
			
			// First action:
			var TestAction1:ActionNode = new ActionNode();
			TestAction1.setDestinationPosition(500, 500);
			TestAction1.setDestinationScale(2, 2);
			
			var TestAction2:ActionNode = new ActionNode();
			TestAction2.setDestinationPosition(100, 500);
			TestAction2.setDestinationScale(.5, .5);
			
			var TestAction3:ActionNode = new ActionNode();
			TestAction3.setDestinationPosition(500, 100);
			TestAction3.setDestinationScale(2, 2);
			
			TestAction1.setLastAction(TestAction2);
			TestAction2.setLastAction(TestAction3);
			
			trace(TestAction1.toString());
			trace(TestAction2.toString());
			trace(TestAction3.toString());
			
			//var TestKpt:Keypoint = new Keypoint(3, TestAction1, TestAnnulus1);
			
			//TestKpt.name = "TestKpt";
			
			//mMainTimeline.addStaticKeypoint( 1, TestAction1, TestAnnulus1 );
			
			
			
			//var TestAction2:ActionNode = ( new Action(TestAnnulus1, 1) ).setDestinationPosition(800, 200);
			//var TestAction3:ActionNode = ( new Action(TestAnnulus1, 1) ).setDestinationPosition(800, 800);
			//var TestAction4:ActionNode = ( new Action(TestAnnulus1, 3) ).setDestinationPosition(200, 800);
			
			// Second action:
			//TestAction1.setNextAction( TestAction2 ).setNextAction(TestAction3).setNextAction(TestAction4);
			
			
			
			
			// Third action:
			//TestKeypointAction1.setNextAction( (new Action(TestAnnulus1, 1) ).setDestinationPosition(800, 800) );
			
			// Last action: Return to starting position
			//TestKeypointAction1.setNextAction( (new Action(TestAnnulus1, 1) ).setDestinationPosition(150, CENTER_Y) );
			
			
			//var TestKeypoint1:Keypoint = new Keypoint(2);
			//TestKeypoint1.setAction(TestAction1);
			
			//trace("K #: " + TestAction1.getNumFollowingActions()+ " keypoint duration: " + TestAction1.getTotalDurationSeconds() );
			
			//mMainTimeline.addKeypoint(TestKeypoint1);
			
			//mMainTimeline.redrawKeypoints();
		}
		
		/** Prints useful information about this class. */
		override public function toString() : String {
			var Msg:String = "";
			
			for( var i:uint=0; i<this.numChildren; ++i ) 
				Msg += "Child: " + this.getChildAt(i).name;
			
			return Msg;
		}
		
		/** Read the position of the mouse cursor, used for debugging object placement. */
		private function mouseMove( evt:MouseEvent ) : void {
			/**mCursorPositionText.text = "" + evt.localX + ", " + evt.localY;*/
		}
		
		
		
		/** Beat Start Listener: Called at the start of each beat in the timeline */
		private function onBeatStart( BeatEvt:BeatEvent ) : void {
			//mTestAnnulus.flare();
		}
		
		/** Beat Start Listener: Called at the start of each beat in the timeline */
		private function onMeasureStart( MeasureEvt:MeasureEvent ) : void {
			//mTestAnnulus.dilate();
		}
		
		/** Accessor function for the timeline. */
		public function getTimeline() : Timeline {
			return mMainTimeline;
		}
		
		
		
		
		///////////////////////////////////////
		// Getter functions
		///////////////////////////////////////
		
		/** @return The number of seconds elapsed since the track has been started. */
		public function getTotalSecondsElapsed() : Number {
			return mMainTimeline.getTotalSecondsElapsed();
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
