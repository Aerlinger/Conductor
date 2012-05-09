package com.anim
{
	
	/** Stores all of the destination variables for an action object */
	public interface ActionTransform
	{
		
		public var xFinal:Number 	= Number.NaN;
		public var yFinal:Number 	= Number.NaN;
		public var rotation:Number 	= Number.NaN;
		public var scaleX:Number 	= Number.NaN;
		public var scaleY:Number 	= Number.NaN;
		
		public var color:uint		= Number.NaN;	// 24 bit representation of the color for this object
		public var alpha:Number		= Number.NaN;	
		
		
	}
}