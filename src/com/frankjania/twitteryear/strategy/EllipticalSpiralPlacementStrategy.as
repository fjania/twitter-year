package com.frankjania.twitteryear.strategy
{
	import com.frankjania.twitteryear.collisiondetection.CollisionDetectionSystem;
	import com.frankjania.twitteryear.core.Trend;
	
	import flash.geom.Point;
	
	public class EllipticalSpiralPlacementStrategy extends PlacementStrategy
	{
		private var angle:Number = 0;
		private var radius:Number = 0;
		private var radiusRatio:Number = 1.2;

		private var angleStart:Number = 0;

		private var angleStep:Number = 10;
		private var radiusStep:Number = 0.2;
		
		private var xOffset:int = 0;
		
		override public function layoutOneByOne():Boolean{
			return true;
		}

		override public function resetStrategy():void{
			radius = 0;
			xOffset = 0;
			angle = Math.random() * 360;
		}		

		override public function placeTrendWithStrategy(trend:Trend):void{
			resetStrategy();
			do {
				trend.cde.setPoint( pointOnEllipse() );
			} while (CollisionDetectionSystem.testCollision(trend.cde))
		}
		
		public function pointOnEllipse():Point{
			var q:Number = angle * (Math.PI/180)
			var x:Number = ((radius) * radiusRatio) * Math.cos(q) + xOffset;
			var y:Number = ((radius) * (1/radiusRatio)) * Math.sin(q);

			radius += radiusStep;
			angle += angleStep;
			
			return new Point(x,y);
		}

	}
}