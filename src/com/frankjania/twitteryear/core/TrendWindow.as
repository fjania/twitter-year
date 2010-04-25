package com.frankjania.twitteryear.core
{
	import com.frankjania.twitteryear.twitter.DateUtil;
	import com.frankjania.twitteryear.util.TopWordsList;
	
	import flash.utils.Dictionary;
	
	public class TrendWindow
	{
		private var map:Dictionary = new Dictionary();
		private var trends:Array = new Array();
		
		public var currentTrendIndex:Number = 0;
		
		public var startDate:Date;
		public var endDate:Date;

		private var laidOut:Boolean = false;
	
		public function TrendWindow(trendsList:Array){
			startDate = DateUtil.parse(trendsList[0][0]);
			endDate = DateUtil.parse(trendsList[trendsList.length-1][0]);
			for each (var trendSet:Array in trendsList){
				for each (var trendText:String in trendSet.slice(1)){
					if (map[trendText] == null){
						map[trendText] = 1;
					} else {
						map[trendText]++;
					}
				}
			}
			
			for (var key:String in map){
				if (map[key] >= Settings.MINIMUM_FREQUENCY){
					TopWordsList.addTrend(new Trend(key, map[key], startDate));
				}
			}
			
			for (var text:String in map){
				if (TopWordsList.contains(text)){
					trends.push(new Trend(text, map[text], startDate));
				}
			}
			
			trends.sort(sortOnCount);
		}
		
		public function isLaidOut():Boolean{
			return laidOut;
		}
		
		public function markAsLaidOut():void{
			laidOut = true;
		}
		
		public function getNextTrend():Trend{
			if (currentTrendIndex < trends.length){
				return trends[currentTrendIndex++];
			} else {
				return null;
			}
		}
		
		public function getTrendCount():Number{
			return trends.length;
		}
		
		private function sortOnCount(a:Trend, b:Trend):Number {
		    if(a.frequency > b.frequency) {
		        return -1;
		    } else if(a.frequency < b.frequency) {
		        return 1;
		    } else  {
		        //same frequency, so return alphabetical
		        return a.firstOccurance.time < b.firstOccurance.time ? 1 : -1;
		    }
		}
		
		public function toString():String{
			var out:String = "";
			for each (var i:Trend in trends){
				out += i + ", ";
			}
			return startDate + "->" + endDate + " " + out;
		}

		public function getTrends():Array{
			return trends;
		}

		public function containsTrend(trend:Trend):Boolean{
			return map[trend.text] != null;
		}
	}
}