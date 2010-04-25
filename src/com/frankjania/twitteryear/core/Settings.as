package com.frankjania.twitteryear.core{
	import com.frankjania.twitteryear.strategy.EllipticalSpiralPlacementStrategy;
	import com.frankjania.twitteryear.strategy.FastInlinePlacementStrategy;
	import com.frankjania.twitteryear.strategy.PlacementStrategy;
	
	public class Settings{
		public static var MINIMUM_FREQUENCY:Number = 20;
		public static var WINDOW_SIZE:Number = 24;
		public static var WINDOW_STEP:Number = 12;
		
		//public static var placementStrategy:PlacementStrategy = new FastInlinePlacementStrategy();
		public static var placementStrategy:PlacementStrategy = new EllipticalSpiralPlacementStrategy();
		
		public static var maximum_frequency:Number = 0;
		public static var minimum_frequency:Number = 1;
		
		public static var build_timer_tick:Number = 1;
		public static var layout_timer_tick:Number = 10;
		public static var display_timer_tick:Number = 500;
		
		public static var new_trend_effect_duration:Number = 800;
		public static var existing_trend_effect_duration:Number = 300;
	}
}