package com.util 
{
	import flash.utils.ByteArray;
	
	// ActionScript file
	public final class Utils {
		
		public static function copyArray(source:Array) : Array {
			
			var myBA:ByteArray = new ByteArray
			myBA.writeObject(source); 
			myBA.position = 0; 
			
			return(myBA.readObject()); 
		}
		
		public static function copyObject(source:Object) : * {
			
			var myBA:ByteArray = new ByteArray
			myBA.writeObject(source); 
			myBA.position = 0; 
			
			return(myBA.readObject()); 
			
		}
	}
}