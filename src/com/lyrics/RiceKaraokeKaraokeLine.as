package com.lyrics
{
	public class RiceKaraokeKaraokeLine
	{
		private var _display:SimpleKaraokeDisplay;
		private var _timing:*;
		private var _elapsed:*;
		private var end:Object;
		
		/**
		 * Represents the current karaoke line (to be highlighted). Once the line is
		 * over with, this object will be left to the garbage collector.
		 * 
		 * @param display
		 * @param {Number} elapsed
		 * @param {Object} timing Current line
		 */
		function RiceKaraokeKaraokeLine(display, elapsed, timing) : void {
			this._display = display;
			this._timing = timing;
			this._elapsed = elapsed;
			this.end = timing.end; // Used by RiceKaraokeShow to know when to let this
			// object "expire" (and leave it to the GC)
			
			this._display.type = RiceKaraokeShow.TYPE_KARAOKE;
			this.update(elapsed);
		}
		
		/**
		 * This is called everytime render() of RiceKaraokeShow is called, but only if
		 * this object hasn't expired.
		 * 
		 * @param {Number} elapsed
		 * @param {Boolean} Whether this object should be kept (and not expire)
		 */
		public function update(elapsed) : Boolean {
			var passedFragments = [];
			var currentFragmentPercent = 0.0;
			var currentFragment = null;
			var upcomingFragments = [];
			
			for (var l = 0; l < this._timing.line.length; l++) {
				var fragment = this._timing.line[l];
				if (this._timing.start + fragment.start <= elapsed) {
					// The last currentFragment wasn't really a currentFragment
					if (currentFragment != null) {
						passedFragments[passedFragments.length] = currentFragment;
					}
					currentFragment = fragment;
					// Percent elapsed for the current fragment
					var fragmentEnd = this._timing.line.end ? this._timing.line.end :
						(this._timing.line.length > l + 1 ?
							this._timing.line[l + 1].start :
							this._timing.end - this._timing.start);
					currentFragmentPercent = (elapsed - (this._timing.start + fragment.start)) /
						(fragmentEnd - fragment.start) * 100;
				} else {
					upcomingFragments[upcomingFragments.length] = fragment;
				}
			}
			
			this._display.renderKaraoke(passedFragments, currentFragment,
				upcomingFragments, currentFragmentPercent);
			
			return true;
		};
		
		/**
		 * Called when this object is expiring. This should return another object to
		 * replace itself. Because we don't need to replace this with anything, we will
		 * return a null.
		 * 
		 * @param {Number} elapsed
		 * @return
		 */
		RiceKaraokeKaraokeLine.prototype.expire = function(elapsed) {
			return null;
		};
	}
}