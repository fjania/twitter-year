package com.frankjania.twitteryear.twitter
{
	import flash.events.Event;

	public class TrendsLoadedEvent extends Event
	{
		public static const LOADED:String = "com.frankjania.twitteryear.trendsloadedevent";
		
		public var lines:Array;
		
		public function TrendsLoadedEvent(type:String, lines:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.lines = lines;
		}

		override public function clone():Event{
			var tle:TrendsLoadedEvent = new TrendsLoadedEvent(type, lines, bubbles, cancelable);
			return tle;
		}
		

	}
}