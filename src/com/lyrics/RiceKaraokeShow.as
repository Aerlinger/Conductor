package com.lyrics
{
	/**
	 * Represents a show. Use RiceKaraoke's createShow() method to create an
	 * instance of this. You should not need to create an instance of this
	 * yourself.
	 * 
	 * @param {RiceKaraoke} engine
	 * @param displayEngine
	 * @param {Number} numLines
	 */
	public class RiceKaraokeShow
	{
		
		
		/**
		 * Represents a karaoke line. This is used for the renderer, and it is not
		 * used for anything else as each line is a specific object in this
		 * class.
		 * 
		 */
		public static var TYPE_KARAOKE:uint = 0;
		/**
		 * Represents an upcoming line. This is used for the renderer, and it is not
		 * used for anything else as each line is a specific object in this
		 * class.
		 * 
		 */
		public static var TYPE_UPCOMING = 1;
		/**
		 * Represents a preparation line. This is used for the renderer, and it is not
		 * used for anything else as each line is a specific object in this
		 * class.
		 * 
		 */
		public static var TYPE_READY = 2;
		/**
		 * Represents an instrumental line. This is used for the renderer, and it is not
		 * used for anything else as each line is a specific object in this
		 * class.
		 * 
		 */
		public static var TYPE_INSTRUMENTAL = 3;
		private var showReady:Boolean;
		private var showInstrumental:Boolean;
		private var upcomingThreshold:int;
		private var readyThreshold:int;
		private var antiFlickerThreshold:Number;
		public var _engine:*;
		private var _displayEngine:SimpleKaraokeDisplayEngine;
		private var _numLines:*;
		private var _displays:Array;
		private var _index:int;
		private var _relativeLastKaraokeLine:int;
		private var _hasReadyLine:Boolean;
		private var _hasInstrumentalLine:Boolean;
		
		
		function RiceKaraokeShow(engine, displayEngine, numLines) {
			this.showReady = true;
			this.showInstrumental = true;
			
			this.upcomingThreshold = 5; // Number of seconds before a line to show its
			// upcoming line
			this.readyThreshold = 2; // How long ago the previous line had to be in
			// order to show that "Ready..." countdown. Be
			// aware that the "Ready..." message shows with the
			// upcoming message, and so the readyThreshold
			// cannot be higher than upcomingThreshold.
			this.antiFlickerThreshold = .5;
			
			// == No user-editable settings below ==
			
			this._engine = engine;
			this._displayEngine = displayEngine;
			this._numLines = numLines;
			
			this._displays = [];
			this._index = 0;
			this._relativeLastKaraokeLine = 0;
			this._hasReadyLine = false;
			this._hasInstrumentalLine = false;
			
			this.reset();
		}
		
		/**
		 * Attempts to reset most of the progress of the show. During the progress
		 * of the show, some numbers are cached in order to reduce the number of
		 * iterations performed. While moving ahead in the music track is fine, you
		 * cannot move backwards unless you call this method.
		 * 
		 * If you allow a scrubber for the music/video, then you need to make frequent
		 * calls of this method whenever the user changes the media's position. Once
		 * this is called, a "rewind" is basically made on the timings. This should not
		 * be too large of a performance hit.
		 * 
		 */
		private function reset():void
		{
			this._displays = [];
			for (var i = 0; i < this._numLines; i++) {
				this._displays[this._displays.length] = null;
				this._displayEngine.getDisplay(i).clear();
			}
			this._index = 0;
			this._relativeLastKaraokeLine = 0;
			this._hasReadyLine = false;
			this._hasInstrumentalLine = false;
			
		}		
		
		/**
		 * Takes in a timing and renders it. This should be called multiple times
		 * within the same second.
		 * 
		 * "Accurate" mode means that a millisecond back will be rendered for the number
		 * of available displays. This is for use with a scrubber, but it should not
		 * be used during normal play.
		 * 
		 * @param {Number} elapsed
		 * @param {Boolean} accurate
		 */
		public function render(elapsed, accurate) {
			if (accurate) {
				var numDisplays = this._displays.length;
				for (var i = numDisplays; i > 0; i--) {
					this.render(elapsed - i / 1000, false);
				}
				
				// Now we need to find an accurate value for _relativeLastKaraokeLine
				this._relativeLastKaraokeLine = 0;
				for (var i = 0; i < this._engine.timings.length; i++) {
					if (this._engine.timings[i].start < elapsed &&
						this._engine.timings[i].end > this._relativeLastKaraokeLine) {
						this._relativeLastKaraokeLine = this._engine.timings[i].end;
						break;
					}
				}
			}
			
			var freeDisplays = [];
			var displaysToClear = [];
			var unfreedDisplays = {}; 
			var displaysToUpdate = [];
			
			// Look for empty displays and displays that need to be updated
			for (var i in this._displays) {
				// Display has been empty for a while
				if (this._displays[i] == null) {
					freeDisplays[freeDisplays.length] = i;
					// Line needs to expire
				} else if (this._displays[i].end <= elapsed) {
					if (this._displays[i] instanceof RiceKaraokeReadyLine) {
						this._hasReadyLine = false;
					}
					if (this._displays[i] instanceof RiceKaraokeInstrumentalLine) {
						this._hasInstrumentalLine = false;
					}
					// It's time for this line to expire, but it may return a
					// replacement for itself
					var replacement = this._displays[i].expire(elapsed);
					if (replacement != null) {
						this._displays[i] = replacement;
						// Otherwise we just mark the slot as free
					} else {
						freeDisplays[freeDisplays.length] = i;
						displaysToClear[displaysToClear.length] = i;
					}
					// The line exists, so we need to update it
				} else {
					displaysToUpdate[displaysToUpdate.length] = i;
				}
			}
			
			// If there are free displays, look for lines to push onto the player
			if (freeDisplays.length > 0) {
				for (var i = this._index; i < this._engine.timings.length; i++) {
					if (freeDisplays.length == 0) {
						break;
					}
					
					var timing = this._engine.timings[i];
					
					// A line needs to be shown
					if (timing.start <= elapsed && timing.end >= elapsed) {
						var freeDisplay = freeDisplays.shift();
						unfreedDisplays[freeDisplay] = true; // Kind of ugly
						this._displays[freeDisplay] = new RiceKaraokeKaraokeLine(
							this.getDisplay(freeDisplay), elapsed, timing
						);
						this._relativeLastKaraokeLine = timing.end;
						this._index = i + 1;
						// Do an upcoming line
					} else if ((timing.start - this.upcomingThreshold <= elapsed ||
						timing.start - this._relativeLastKaraokeLine < this.antiFlickerThreshold) && 
						timing.end >= elapsed) {
						var freeDisplay = freeDisplays.shift();
						unfreedDisplays[freeDisplay] = true; // Kind of ugly
						this._displays[freeDisplay] = new RiceKaraokeUpcomingLine(
							this.getDisplay(freeDisplay), elapsed, timing
						);
						this._index = i + 1;
						
						// If the last line was a while ago, we need to do that 
						// 'Ready...' stuff
						if (this.showReady &&
							elapsed - this._relativeLastKaraokeLine >= this.readyThreshold &&
							!this._hasReadyLine && freeDisplays.length >= 0) {
							var freeDisplay = freeDisplays.shift();
							unfreedDisplays[freeDisplay] = true; // Kind of ugly
							this._displays[freeDisplay] = new RiceKaraokeReadyLine(
								this.getDisplay(freeDisplay), elapsed, timing.start - elapsed
							);
							this._hasReadyLine = true;
						}
						
						// This is for the actual line later on, since we won't come
						// back to this for loop when the engine transitions from the
						// upcoming line to the karaoke line
						this._relativeLastKaraokeLine = timing.end;
						// Do an instrumental line
					} else if (this.showInstrumental && freeDisplays.length == this._displays.length &&
						!this._hasInstrumentalLine) {
						var freeDisplay = freeDisplays.shift();
						unfreedDisplays[freeDisplay] = true; // Kind of ugly);
						this._displays[freeDisplay] = new RiceKaraokeInstrumentalLine(
							this.getDisplay(freeDisplay), elapsed, timing.start - this.upcomingThreshold
						);
						this._hasInstrumentalLine = true;
						// Else we do nothing
					} else if (timing.end > elapsed) {
						break;
					}
				}
			}
			
			// We need to clear displays that are empty and were not updated with
			// a new karaoke line
			if (displaysToClear.length > 0) {
				for (var i in displaysToClear) {
					if (!(displaysToClear[i] in unfreedDisplays)) {
						this._displays[displaysToClear[i]] = null;
						this._displayEngine.getDisplay(displaysToClear[i]).clear();
					}
				}
			}
			
			// Update lines
			if (displaysToUpdate.length > 0) {
				for (var i in displaysToUpdate) {
					this._displays[displaysToUpdate[i]].update(elapsed)
				}
			}
		};
		
		/**
		 * Get a particular numbered display from the renderer.
		 * 
		 * @param {Number} displayIndex
		 * @return
		 */
		public function getDisplay(displayIndex) {
			return this._displayEngine.getDisplay(displayIndex);
		};

	}
}