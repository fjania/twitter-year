package com.frankjania.twitteryear.strategy
{
	import com.frankjania.twitteryear.collisiondetection.CollisionDetectionSystem;
	import com.frankjania.twitteryear.core.Trend;
	
	import flash.geom.Point;
	
	public class InlinePlacementStrategy extends PlacementStrategy
	{
		private var yaxis:Number = -275;
		private var yaxisStep:Number = 10;
		private static var xaxis:Number = 0;
		private static var xaxisStep:Number = 1;

		override public function resetStrategy():void{
			yaxis = -275;
		}		

		override public function placeTrendWithStrategy(trend:Trend):void{
			do {
				trend.cde.setPoint( pointOnLine() );
			} while (CollisionDetectionSystem.testCollision(trend.cde))
		}
		
		public function pointOnLine():Point{
			var x:Number = xaxis;
			var y:Number = yaxis;
			yaxis += yaxisStep;
			
			return new Point(x,y);
		}

	}
}