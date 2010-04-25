package com.frankjania.twitteryear.timeline
{
	import flash.events.Event;

	public class TimelineEvent extends Event
	{
		public static const SCRUB:String = "com.frankjania.twitteryear.scrub";
		public static const SCRUBBING_DONE:String = "com.frankjania.twitteryear.scrubbing_done";
		
		public var date:Date;
		
		public function TimelineEvent(type:String, date:Date, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.date = date;
		}
		
	}
}