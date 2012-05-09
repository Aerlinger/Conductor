package com.lyrics
{
	// $Id$
	/*
	* RiceKaraoke JavaScript karaoke engine 
	* <http://code.google.com/p/ricekaraoke/>
	* Licensed under the GNU General Public License version 3
	* Copyright (c) 2005-2009 sk89q <http://sk89q.therisenrealm.com>
	*/
	
	/**
	 * RiceKaraoke is a karaoke timing engine for JavaScript. All it does is
	 * take in the current time progress of a song and calls a renderer with
	 * to display the karaoke. It accepts timings in KRL format and will
	 * automatically generate preparation countdowns ("Ready... 3... 2... 1..."),
	 * generate notices of instrumental portions, and show upcoming lyrics. The
	 * timing engine supports for gradual fragment highlighting.
	 *  
	 */
	
	/**
	 * Instantiates a karaoke engine. This needs to be given the timings as a
	 * JavaScript data structure in KRL format. The constructor will not
	 * check the validity of the passed timings.
	 * 
	 * To actually show lyrics, look into the createShow() method.
	 * 
	 * @param {Array} timings
	 */
	
	
	public class RiceKaraoke
	{
		public var timings:Object;
		
		public function RiceKaraoke(timings)
		{
			// The timings need to be sorted due to the way that this works
			this.timings = timings.sort(function(a, b) {
				if (a.start == b.start) {
					return 0;
				}
				return a.start < b.start ? -1 : 1;
			});
		}
		
		
		/**
		 * Used to convert Simple KRL to KRL.
		 * 
		 * @param {Array} simpleTimings
		 * @return {Array}
		 */
		public static function simpleTimingToTiming(simpleTimings) {
			var timings = [];
			var y = 0;
			for (var i in simpleTimings) {
				timings[y++] = {
					start: simpleTimings[i][0],
					end: simpleTimings[i][1],
					line: RiceKaraoke.simpleKarakokeToKaraoke(simpleTimings[i][2]),
						renderOptions: simpleTimings[i].length >= 4 ? simpleTimings[i][3] : {}
				};
			}
			
			return timings;
		};
		
		
		/**
		 * Used to convert Simple KRL fragments to KRL fragments. See
		 * simpleTimingToTiming();
		 * 
		 * @param {Array} simpleKaraoke
		 * @return {Array}
		 */
		public static function simpleKarakokeToKaraoke(simpleKaraoke) {
			var karaoke = [];
			var y = 0;
			for (var i in simpleKaraoke) {
				karaoke[y++] = {
					start: simpleKaraoke[i][0],
					text: simpleKaraoke[i][1],
					end: simpleKaraoke[i].length >= 3 ? parseFloat(simpleKaraoke[i][2]) : null,
						renderOptions: simpleKaraoke[i].length >= 4 ? simpleKaraoke[i][3] : {}
				};
			}
			
			return karaoke;
		};
		
		/**
		 * Creates a "show." A show has a group of settings associated with it and
		 * you can create different shows if you want to use different settings (and
		 * have more than one karaoke display on the same page, for whatever reason).
		 * You also need a new show for every new display.
		 * 
		 * @param displayEngine Needs to be a karaoke renderer instance
		 * @param {Number} numLines Number of karaoke lines
		 * @returns {RiceKaraokeShow}
		 */
		public function createShow(displayEngine, numLines) {
			return new RiceKaraokeShow(this, displayEngine, numLines);
		};
		
	}
}