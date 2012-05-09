package com.lyrics
{
	public class RiceKaraokeReadyLine
	{
		private var _display:Object;
		private var _start:*;
		private var end:*;
		/**
		 * Used to represent preparation lines.
		 * 
		 * @param display
		 * @param {Number} elapsed
		 * @param {Number} countdown Number of seconds until the karaoke line comes up
		 * @return
		 */
		function RiceKaraokeReadyLine(display, elapsed, countdown) {
			this._display = display;
			this._start = elapsed;
			this.end = elapsed + countdown;  // Expire after the countdown ends
			
			this._display.type = RiceKaraokeShow.TYPE_READY;
			this._display.renderReadyCountdown(Math.round(countdown + 1));
		}
		
		/**
		 * This is called everytime render() of RiceKaraokeShow is called, but only if
		 * this object hasn't expired. We need to re-render a different number.
		 * 
		 * @param {Number} elapsed
		 * @param {Boolean} Whether this object should be kept (and not expire)
		 */
		RiceKaraokeReadyLine.prototype.update = function(elapsed) {
			var countdown = this.end - elapsed;
			this._display.renderReadyCountdown(Math.round(countdown + 1));
			
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
		RiceKaraokeReadyLine.prototype.expire = function(elapsed) {
			return null;
		};
	}
}