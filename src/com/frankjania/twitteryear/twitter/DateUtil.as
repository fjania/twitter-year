package com.frankjania.twitteryear.twitter{
	public class DateUtil{
		
		private static const dateSeperatorPattern:RegExp = /-/g; 
		private static const dateSeperatorReplacment:String = "/"; 
		public static const millisecondsPerDay:int = 1000 * 60 * 60 * 24;

		public static function parse(dateAsTwitterFormatString:String):Date{
			return new Date(Date.parse(dateAsTwitterFormatString.replace(dateSeperatorPattern, dateSeperatorReplacment)));
		}
	}
}