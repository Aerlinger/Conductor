package com.lyrics
{
	public class SimpleKaraokeDisplayEngine
	{
		// $Id$
		/*
		* RiceKaraoke JavaScript karaoke engine 
		* <http://code.google.com/p/ricekaraoke/>
		* Licensed under the GNU General Public License version 3
		* Copyright (c) 2005-2009 sk89q <http://sk89q.therisenrealm.com>
		*/
		private var _rightToLeft:Boolean;
		private var _container:Object;
		// Array of SimpleKaraokeDisplay elements
		private var _displays:Array;
		
		
		
		/**
		 * Creates an instance of the SimpleKaraokeDisplayEngine. This is a simple
		 * karaoke display renderer for RiceKaraoke that supports granular per-syllable
		 * highlighting. However, this renderer does not handle wrapping of the lines
		 * at all. To render highlighting, this render places an overlay element over
		 * the text and changes its width so that only the highlighted content shows.
		 * 
		 * To use this renderer, just create a new instance of this class with the ID
		 * of the element that you want the karaoke lines in. You do not need to
		 * populate this element with any children. You will need to add some CSS
		 * styling to make the highlighting show.
		 * 
		 * @param {String} containerID
		 * @param {Number} numLines
		 * @param {Boolean} rightToLeft Right to left rendering (cannot be changed later)
		 */
		function SimpleKaraokeDisplayEngine(containerID, numLines) {
			// == No user-editable settings below ==
			
			this._rightToLeft = true;
			
			
//			var elm = document.getElementById(containerID);
//			if (!elm) {
//				throw new Error("Can't find element #" + containerID)
//			}
			
			this._container = [];//Conductor.getInstance();//jQuery(elm);
			this._displays = [];
			
			// We create a "display" element for each line of karaoke. In terms of
			// HTML, this is one DIV element per display. We create an instance of
			// SimpleKaraokeDisplay here and we do not ever need to re-create it.
			
			// EDIT: Create a text element rather than a div element.
			for (var i = 0; i < numLines; i++) {
				this._displays[i] = new SimpleKaraokeDisplay(this, this._container, i);
			}
			
			
		}
		
		/**
		 * Gets a display for a particular numbered karaoke line. This is called by
		 * the RiceKaraoke object primarily.
		 * 
		 * @param {Number} displayIndex
		 * @return {SimpleKaraokeDisplay}
		 */
		public function getDisplay(displayIndex) {
			return this._displays[displayIndex];
		};
	}
}