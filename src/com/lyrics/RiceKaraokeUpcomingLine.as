package com.lyrics
{
	public class RiceKaraokeUpcomingLine
	{
		public var _display:*;
		public var _timing:*;
		public var _elapsed:*;
		public var end:Object;
		/**
		 * Used to represent preparation lines. This will replace itself with an
		 * instance of RiceKaraokeKaraokeLine.
		 * 
		 * @param display
		 * @param {Number} elapsed
		 * @param {Object} timing The line/timing that this ready line is for
		 */
		function RiceKaraokeUpcomingLine(display, elapsed, timing) {
			this._display = display;
			this._timing = timing;
			this._elapsed = elapsed;
			this.end = timing.start; // Used by RiceKaraokeShow to know when to let this
			// object "expire" (and leave it to the GC)
			
			var text = '';
			for (var i in timing.line) {
				text += timing.line[i].text;
			}
			
			this._display.type = RiceKaraokeShow.TYPE_UPCOMING;
			this._display.renderText(text);
		}
		
		/**
		 * This is called everytime render() of RiceKaraokeShow is called, but only if
		 * this object hasn't expired.
		 * 
		 * @param {Number} elapsed
		 * @param {Boolean} Whether this object should be kept (and not expire)
		 */
		RiceKaraokeUpcomingLine.prototype.update = function(elapsed) {
			return true;
		};
		
		/**
		 * Called when this object is expiring. We want to replace this with the
		 * actual karaoke line.
		 * 
		 * @param {Number} elapsed
		 * @return
		 */
		RiceKaraokeUpcomingLine.prototype.expire = function(elapsed) {
			return new RiceKaraokeKaraokeLine(this._display, elapsed, this._timing);
		};

	}
}