package com.frankjania.twitteryear.collisiondetection
{
	import com.frankjania.twitteryear.core.Settings;
	import com.frankjania.twitteryear.core.Trend;
	import com.frankjania.twitteryear.display.TrendAnimationComponent;
	import com.frankjania.twitteryear.strategy.PlacementStrategy;
	import com.frankjania.twitteryear.util.FontScaler;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	public class CollisionDetectionSystem
	{
		private static var elements:Dictionary = new Dictionary();
		private static var stage:Dictionary = new Dictionary();
		
		private static var cdeGeneratorSprite:Sprite = new Sprite();
		private static var fmt:TextFormat = new TextFormat();
		private static var txt:TextField = new TextField();
		private static var txtAdded:Boolean = false;
		
		private static var strategy:PlacementStrategy = Settings.placementStrategy;

		public static function getElement(hash:String):CollisionDetectionElement{
			return elements[hash];
		}
		
		public static function addElementToSystem(element:CollisionDetectionElement):void{
			elements[element.getHash()] = element;
		}
		
		public static function addElementToStage(element:CollisionDetectionElement):void{
			stage[element.getHash()] = element;
		}
		
		public static function isPlaced(element:CollisionDetectionElement):Boolean{
			return stage[element.getHash()] != null;
		}
		
		public static function placeTrend(trend:Trend):void{
			strategy.placeTrend(trend);
		}
		
		public static function testCollision(element:CollisionDetectionElement):Boolean{
			var r:Rectangle = element.getBounds();
			var rt:Rectangle;
			for (var hash:String in stage){
				rt = stage[hash].getBounds();
				if (rt.intersects(r)){
					return true;
				}
			}
			return false;
		}

		public static function resetStage():void{
			for each (var ele:CollisionDetectionElement in stage){
				ele.resetPoint();
			}
			stage = new Dictionary();
			
			strategy.resetStrategy();
		}
		
		public static function generateCollisionDetectionElement(trend:Trend):CollisionDetectionElement{
			
			fmt.font = TrendAnimationComponent.font;
			txt.text = trend.text;
			txt.autoSize = TextFieldAutoSize.LEFT;
			txt.embedFonts = true;
			txt.selectable = false;
			txt.mouseEnabled = false;
			
			var div:uint = (-226*trend.frequency/23) + 265;
			fmt.color = div*0x10000 + div*0x100 + div;
			fmt.size = FontScaler.scale(trend.frequency);
  			txt.setTextFormat(fmt);
  			txt.x = -1 * txt.width/2;
  			txt.y = -1 * txt.height/2;

			if (!txtAdded){
				cdeGeneratorSprite.addChild(txt);
				txtAdded = true;
			}
			
			var cde:CollisionDetectionElement = CollisionDetectionSystem.getElement(trend.hashcode());
			if (cde == null){
				var bmp : BitmapData = new BitmapData(txt.width, txt.height, false, 0xffffff);
				bmp.draw(txt);
				
				var r:Rectangle = bmp.getColorBoundsRect(0xFFFFFFFF, fmt.color as uint);
				cde = new CollisionDetectionElement(trend.hashcode(), new Rectangle(r.x - txt.width/2, r.y - txt.height/2, r.width, r.height) );
				CollisionDetectionSystem.addElementToSystem(cde);
			}

			return cde;
		}
	}
}