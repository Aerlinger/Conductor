package com.lyrics
{
	public class RiceKaraokeInstrumentalLine
	{
		private var _display:*;
		private var _start:*;
		private var end:*;
		/**
		 * Represents an instrumental line.
		 * 
		 * @param display
		 * @param {Number} elapsed
		 * @param {Number} end
		 */
		function RiceKaraokeInstrumentalLine(display, elapsed, end) {
			this._display = display;
			this._start = elapsed;
			this.end = end
			
			this._display.type = RiceKaraokeShow.TYPE_INSTRUMENTAL;
			this._display.renderInstrumental();
		}
		
		/**
		 * This is called everytime render() of RiceKaraokeShow is called, but only if
		 * this object hasn't expired.
		 * 
		 * @param {Number} elapsed
		 * @param {Boolean} Whether this object should be kept (and not expire)
		 */
		RiceKaraokeInstrumentalLine.prototype.update = function(elapsed) {
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
		RiceKaraokeInstrumentalLine.prototype.expire = function(elapsed) {
			return null;
		};
	}
}