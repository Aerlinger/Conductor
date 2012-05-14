package com.main
{
	import flash.geom.Point;

	public class PolarCoords
	{
		private var radius:Number;
		private var theta:Number;
		
		public function PolarCoords(radius:Number, theta:Number)
		{
			this.radius = radius;
			this.theta 	= theta;
		}
		
		/** Returns a polar representation of the coordinates given */
		public static function rectangularToPolar( x:Number, y:Number ) : PolarCoords {
			var radius:Number = x*x + y*y;
			radius = Math.sqrt(radius);
			
			var theta:Number = Math.atan2(y, x);
			
			return new PolarCoords(radius, theta);
		}
		
		/** Returns a rectangular representation of the coordinates given */
		public static function polarToRectangular( radius:Number, theta:Number ) : Point {
			var x:Number = radius * Math.cos(theta);
			var y:Number = radius * Math.sin(theta);
			
			return new Point(x, y);
		}
		
		public function getRadius : Number {
			return radius;
		}
		
		public function getTheta() : Number {
			return this.theta;
		}
	}
}