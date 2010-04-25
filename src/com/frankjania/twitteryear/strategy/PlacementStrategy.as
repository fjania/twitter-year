package com.frankjania.twitteryear.strategy
{
	import com.frankjania.twitteryear.collisiondetection.CollisionDetectionSystem;
	import com.frankjania.twitteryear.core.Trend;
	
	public class PlacementStrategy
	{
		
		public function placeTrend(trend:Trend):void{
			placeTrendWithStrategy(trend);

			// store the position in the trend for playback later
			trend.x = trend.cde.getPoint().x;
			trend.y = trend.cde.getPoint().y;
			
			// add AFTER it's been placed. Existing on the stage is
			// how we know it's been placed.
			CollisionDetectionSystem.addElementToStage(trend.cde);
		}
		
		public function placeTrendWithStrategy(trend:Trend):void{
			// THIS MUST BE OVERRIDDEN
			throw new Error("Must override placeTrendInStrategy in sub-class");
		}

		public function resetStrategy():void{
			// THIS MUST BE OVERRIDDEN
			throw new Error("Must override resetStrategy in sub-class");
		}
		
		public function layoutOneByOne():Boolean{
			// This must be overridden if you want to layout the
			// words one by by, i.e. one per timer tick. This is
			// important to set to true if the layou will take a
			// while to complete.
			return false;
		}


	}
}