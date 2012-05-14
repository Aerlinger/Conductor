package com.time
{
	
	/** Immutable class to store information about the time signature of the track 
	 * 
	 * @author Anthony Erlinger
	 */
	public class TimeSignatureData {
		
		private var mNumBeatsPerMinute:Number;	// Number of beats per minute
		private var mNumBeatsPerMeasure:uint;	// Beats per measure
		private var mNumMeasures:uint;			// Number of measures in the track
		
		private var mTrackTimeLength:Number;	// Total length of track in seconds
		private var mMeasureTimeLength:Number;	// Length of each measure in seconds.
		private var mBeatTimeLength:Number;		// Length of  each beat in seconds.
		
		
		/** Creates a new instance of TimeData. Values cannot be changed once the variables are created. */
		public function TimeSignatureData(pNumBeatsPerMinute:Number, pNumBeatsPerMeasure:uint, pNumMeasures:uint) {
			this.mNumBeatsPerMinute 	= pNumBeatsPerMinute;
			this.mNumBeatsPerMeasure 	= pNumBeatsPerMeasure;
			this.mNumMeasures 			= pNumMeasures;
		}
		
		/** @return The number of beats per minute (BPM) */
		public function getBPM() : Number {
			return mNumBeatsPerMinute;
		}
		
		/** @return The number of beats per measure. */
		public function getNumBeatsPerMeasure() : uint {
			return mNumBeatsPerMeasure;
		}

		/** @return the number of measures in this track */
		public function getNumMeasures() : uint {
			return mNumMeasures;
		}
		
		/** @return The duration in seconds of this track */
		public function getTrackDurationSeconds() : Number {
			if( isNaN(mTrackTimeLength) )
				mTrackTimeLength = (1/mNumBeatsPerMinute) * mNumBeatsPerMeasure * mNumMeasures * 60;
			
			return mTrackTimeLength;
		}
		
		/** @return The duration in seconds of each measure. All measures in the track
		 * will have the same duration */
		public function getMeasureDurationSeconds() : Number {
			if( isNaN(mMeasureTimeLength) )
				mMeasureTimeLength = getTrackDurationSeconds()/mNumMeasures;
			
			return mMeasureTimeLength;
		}
		
		/** @return The duration of each beat in seconds. */
		public function getBeatDurationSeconds() : Number {
			if( isNaN(mBeatTimeLength) )
				mBeatTimeLength = getMeasureDurationSeconds()/mNumBeatsPerMeasure;
				
			return mBeatTimeLength;
		}
		
		/** 
		 * Returns the duration in seconds of the number of beats specified.
		 * */
		public function beatToSeconds(measureNum:uint, beatNum:uint) : Number {
			
			if(beatNum>this.mNumBeatsPerMeasure)
				throw new Error("attempted to access a beat number that is larger than the quantity of beats per measure.");
			
			return ((measureNum-1) * mMeasureTimeLength) + ((beatNum-1) * mBeatTimeLength);
		}
		
		/**
		 * @param A duration in seconds
		 * @return the number of beats (or fraction thereof) that span the duration 
		 */
		public function secondsToBeat(pDurationInSeconds:Number) : Number {
			return (pDurationInSeconds/mBeatTimeLength);
		}
		
	}
}