package com.frankjania.twitteryear.display
{
	import com.frankjania.twitteryear.core.Trend;
	import com.frankjania.twitteryear.util.ColorScaler;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.core.UIComponent;
	
	public class TrendSprite extends UIComponent
	{
		private var fmt:TextFormat = new TextFormat();
		private var txt:TextField = new TextField();
		
		private var trend:Trend;
		
		public function TrendSprite(trend:Trend):void{
			//txt.antiAliasType = AntiAliasType.ADVANCED;
			this.configure(trend);
		}
		
		override protected function createChildren():void {
		    super.createChildren();
			addChild(txt);
		}
				
		public function configure(trend:Trend):void{
  			this.visible = false;
  			this.trend = trend;
  			
			fmt.font = TrendAnimationComponent.font;
			txt.text = trend.text;
			txt.autoSize = TextFieldAutoSize.LEFT;
			
			txt.embedFonts = true;
			txt.selectable = false;
			txt.mouseEnabled = false;
			
			updateFrequency(trend);
		}

		public function updateFrequency(trend:Trend):void{
			fmt.color = ColorScaler.scale(trend.frequency);
			fmt.color = 0x999999;			
			fmt.size = 1; // gets zoomed by FontScaler.scale(trend.frequency) later on
  			txt.setTextFormat(fmt);
  			
  			txt.x = -1 * txt.width/2;
  			txt.y = -1 * txt.height/2;
		}
		
		public function updateColor(color:uint):void{
			fmt.color = color;
			txt.setTextFormat(fmt);
		}
		
		public function getTrend():Trend{
			return trend;
		}

		public function show():void{
			this.x = trend.x;
			this.y = trend.y;
			this.visible = true;
		}
	}
}

