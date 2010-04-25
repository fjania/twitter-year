package com.frankjania.twitteryear.core
{
	import com.frankjania.twitteryear.collisiondetection.CollisionDetectionElement;
	import com.frankjania.twitteryear.collisiondetection.CollisionDetectionSystem;
	
	public class Trend extends Object{
		
		public var frequency:Number;
		public var text:String;
		public var firstOccurance:Date;
		public var cde:CollisionDetectionElement;
		public var x:Number;
		public var y:Number;
		
		public function Trend(text:String, frequency:Number, firstOccurance:Date){
			this.frequency = frequency;
			this.text = text;
			this.firstOccurance = firstOccurance;
			this.cde = CollisionDetectionSystem.generateCollisionDetectionElement(this);
		}
		
		public function hashcode():String{
			return this.text + ":" + this.frequency;
		}

		public function getText():String{
			return this.text;
		}
		
		public function getFirstOccurance():Date{
			return firstOccurance;
		}

		public function toString():String{
			return text + " (" + frequency + ")  @ (" + x + ", " + y + ")";
		}
	}
}