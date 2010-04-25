package com.frankjania.twitteryear.util
{
	import mx.collections.ArrayCollection;
	
	public class ColorPalette
	{
		private static var colorArray:Array = new Array();
		private static var cursor:Number = 0;
		
		public static function add(... colors):void{
			for(var i:int = 0; i < colors.length;i++){
				colorArray.push(colors[i]);
			}
		}
		
		public static function getNextColor():uint{
			if (++cursor > colorArray.length-1){
				cursor = 0;
			}
			return colorArray[cursor];
		}
	}
}