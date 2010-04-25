package com.frankjania.twitteryear.core
{
	import com.frankjania.twitteryear.twitter.DateUtil;
	import com.frankjania.twitteryear.twitter.TwitterTrendsLoader;
	
	public class TwitterTrendsToDate
	{
		private var trends:Array;
		private var trendWindows:Array = new Array();
	
		public var trendCount:Number = 0;
		private var startIndex:Number = 0;
		
		public var startDate:Date;
		public var endDate:Date;
		
		public function TwitterTrendsToDate(url:String){
			var loader:TwitterTrendsLoader = new TwitterTrendsLoader(this, url);
		}

		public function setTrends(trends:Array):void{
			this.trends = trends;
			this.trendCount = trends.length;
			this.startDate = DateUtil.parse(trends[0][0]);
			this.endDate = DateUtil.parse(trends[trends.length-1][0]);
		}
		
		public function addNextWindow():TrendWindow{
			if (startIndex + Settings.WINDOW_SIZE >= trendCount) {
				return null
			} else {
				var window:TrendWindow = new TrendWindow(trends.slice(startIndex, startIndex + Settings.WINDOW_SIZE));
				trendWindows.push(window);
				startIndex += Settings.WINDOW_STEP;
				return window;
			}
		}
		
		public function getWindow(index:Number):TrendWindow{
			if (index < 0) return null;
			return trendWindows[index];
		}
		
		public function getTrendWindowCount():Number{
			return Math.floor( (trendCount - Settings.WINDOW_SIZE) / Settings.WINDOW_STEP);
		}
	}
}