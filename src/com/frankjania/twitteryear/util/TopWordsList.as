package com.frankjania.twitteryear.util
{
	import com.frankjania.twitteryear.core.Trend;
	
	import flash.utils.Dictionary;
	
	public class TopWordsList
	{
		private static var wordset:Dictionary = new Dictionary();
		public static var wordarray:Array = new Array();
		
		public static function addTrend(w:Trend):void{
			if (wordset[w.getText()] == null){
				wordarray.push(w);
				wordset[w.getText()] = w;
			} else {
//				var t:Trend = wordset[w.getText()];
//				t.frequency += w.frequency;
				wordset[w.getText()].frequency += w.frequency;
			}
		}
		
		public static function getTrend(w:String):Trend{
			return wordset[w];
		}
		
		public static function contains(w:String):Boolean{
			if (wordset[w] == null) return false;
			return true;
		}
		
		public static function traceTopWords():void{
			wordarray.sort(sortOnOccurance);
			var count:Number = 0;
			for each (var w:Trend in wordarray){
				trace("<"+count+++"> " + w.getText() + " ("+w.frequency+") : " + w.getFirstOccurance());
			}
		}

		public static function sortOnOccurance(a:Trend, b:Trend):Number {
	        return a.firstOccurance.time < b.firstOccurance.time ? -1 : 1;
		}

		public static function sortOnFrequency(a:Trend, b:Trend):Number {
	        return a.frequency < b.frequency ? 1 : -1;
		}

	}
}