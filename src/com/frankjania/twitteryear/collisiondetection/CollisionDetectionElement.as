package com.frankjania.twitteryear.collisiondetection
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CollisionDetectionElement
	{
		private var bounds:Rectangle;
		private var point:Point = new Point(0,0);
		private var hash:String;
		
		public function CollisionDetectionElement(hash:String, bounds:Rectangle):void{
			this.bounds = bounds;
			this.hash = hash;
		}
		
		public function setPoint(point:Point):void{
			this.point = point;
		}
		
		public function getPoint():Point{
			return this.point;
		}
		
		public function resetPoint():void{
			this.point.x = 0;
			this.point.y = 0;
		}
		
		public function getBounds():Rectangle{
			var result:Rectangle = new Rectangle(
				bounds.x + point.x,
				bounds.y + point.y,
				bounds.width,
				bounds.height
			)
			result.inflate(3,3);
			return result;
		}

		public function getHash():String{
			return this.hash;
		}
	}
}