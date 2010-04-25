package com.frankjania.twitteryear.twitter
{
	import com.frankjania.twitteryear.core.TwitterTrendsToDate;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.core.Application;
	
	public class TwitterTrendsLoader
	{
		private var trendsToDate:TwitterTrendsToDate;
		private var loader:URLLoader = new URLLoader();
		
		public function TwitterTrendsLoader(trendsToDate:TwitterTrendsToDate, url:String):void{
			this.trendsToDate = trendsToDate;
			var req:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE, onTrendsLoaded);
			loader.addEventListener(ProgressEvent.PROGRESS, progressed)
			loader.load(req);
		}

		public function onTrendsLoaded(event:Event):void{
			var lines:Array = (loader.data).split("\n");
			var trendsArray:Array = new Array();
			for each (var line:String in lines){
				// assume the line has content if it's longer than 10 characters.
				if (line.length > 10){
					trendsArray.push(line.split(","))
				}
			}
			trendsToDate.setTrends(trendsArray);
			var tle:TrendsLoadedEvent = new TrendsLoadedEvent(TrendsLoadedEvent.LOADED, lines);
			Application.application.dispatchEvent(tle);
		}
		
		public function progressed(e:ProgressEvent):void{
			Application.application.dispatchEvent(e);
		}
	}
}