package com.frankjania.twitteryear.util
{
	public class FontScaler
	{
		private static var slope:Number;
		private static var intercept:Number;
		
		public static function setScale(minFont:Number, maxFont:Number, minFreq:Number, maxFreq:Number):void{
			slope = (maxFont - minFont) / (maxFreq - minFreq);
			intercept = minFont - (minFreq * slope);
		}
		
		public static function scale(freq:Number):Number{
			//return slope * freq + intercept;
			return 22;
		}

	}
}