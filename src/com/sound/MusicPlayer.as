package com.sound
{
	
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	/** Loads and plays back an .mp3 file from a URL 
	 * 
	 * @author Anthony Erlinger
	 * */
	public class MusicPlayer {
		
		private var mURL:String = "";
		private var mMusicSound:Sound;
		private var mSoundChannel:SoundChannel;
		
		private var mPlaying:Boolean = false;
		
		private var mPosition:Number = 0;
		
		private var mBuffer:ByteArray = new ByteArray();
		
		
		public function MusicPlayer(URL:String="") {
			loadMusic(URL);

			var read:uint;
			do {
				read = mMusicSound.extract(mBuffer, 4096);
			} while(read==4096);
			
			var s2:Sound = new Sound();
			s2.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData)
				
			s2.play();
		}
		
		public function onSampleData( SampleEvt:SampleDataEvent ) : void {
			
			var pos:uint=mBuffer.length;
			
			for(var i:uint;i<8000 && pos > 0;++i,pos-=8) {
				mBuffer.position=pos-8;
				SampleEvt.data.writeFloat(mBuffer.readFloat());
				SampleEvt.data.writeFloat(mBuffer.readFloat());
			}
		}
		
		public function loadMusic( URL:String ) : void {
			if(URL == null || URL.length == 0)
				return;
			
			mMusicSound = new Sound( new URLRequest(URL) );			
		}
		
		public function playFromBeginning() : void {
			
			mSoundChannel.stop();
			mSoundChannel = mMusicSound.play();
			mPlaying = true;
			
		}
		
		public function resume() : void {
			if(!mPlaying) {
				mPlaying = true;
				mSoundChannel = mMusicSound.play(mPosition);
			}
			
		}
		
		public function gotoAndPlay(time:Number) : void {
			
			mSoundChannel.stop();
			mPlaying = true;
			mSoundChannel = mMusicSound.play(time);
			
		}
		
		public function pause() : void {
			if(mSoundChannel != null ) {
				mPosition = mSoundChannel.position;
				mSoundChannel.stop();
				mPlaying = false;
			}
		}
		
		public function getSoundChannel() : SoundChannel {
			return mSoundChannel;
		}
		
		public function getSoundObject() : Sound {
			return mMusicSound;
		}
		
	}
}