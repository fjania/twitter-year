package com.frankjania.twitteryear.util
{
	public class ColorScaler
	{
		private static var slope:Number;
		private static var intercept:Number;
		
		public static function setScale(minColor:Number, maxColor:Number, minFreq:Number, maxFreq:Number):void{
			slope = (maxColor - minColor) / (maxFreq - minFreq);
			intercept = minColor - (minFreq * slope);
		}
		
		public static function scale(freq:Number):uint{
			var div:uint = slope * freq + intercept;
			return div*0x10000 + div*0x100 + div;
		}

	}
}