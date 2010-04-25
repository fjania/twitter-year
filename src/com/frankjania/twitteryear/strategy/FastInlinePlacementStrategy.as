package com.frankjania.twitteryear.strategy
{
	import com.frankjania.twitteryear.core.Trend;
	
	import flash.geom.Point;
	
	public class FastInlinePlacementStrategy extends PlacementStrategy
	{
		private var yaxis:Number = -275;
		private var yaxisStep:Number = 10;
		private static var xaxis:Number = 0;
		private static var xaxisStep:Number = 1;
		private static var placementHeight:Number = -275;
		
		override public function resetStrategy():void{
			yaxis = -275;
			placementHeight = -275;
		}		

		override public function placeTrendWithStrategy(trend:Trend):void{
			trend.cde.setPoint( new Point(xaxis, placementHeight) );
			placementHeight += trend.cde.getBounds().height;
		}
		
	}
}