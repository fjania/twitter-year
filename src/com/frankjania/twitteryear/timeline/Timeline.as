package com.frankjania.twitteryear.timeline{
	import com.frankjania.twitteryear.display.TrendAnimationComponent;
	import com.frankjania.twitteryear.twitter.DateUtil;
	
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	public class Timeline extends UIComponent{
		private var slider:Slider;
		private var playButton:PlayButton;
		private var speedButton:SpeedButton;
		
		private var fmt:TextFormat = new TextFormat();
		
		public static const shortMonthNames:Array =
			['Jan', 'Feb', 'Mar','Apr', 'May', 'Jun','Jul', 'Aug', 'Sep','Oct', 'Nov', 'Dec',];
		public static const longMonthNames:Array =
			['January', 'February', 'March','April', 'May', 'June',
			'July', 'August', 'September','October', 'November', 'December',];
		private var months:Array = [];
		
		private var lineWidthThick:Number = 3;
		private var lineWidthThin:Number = 1;
		
		//private var monthFields:Array = new Array();
		private var monthTicks:Array = new Array();
		
		private var _startDate:Date = new Date();
		private var _endDate:Date = new Date();
		
		private var _buildProgress:Date = new Date();
		private var _layoutProgress:Date = new Date();
		private var _displayProgress:Date = new Date();
		
		private var _trackStartTime:Number;
		private var _trackEndTime:Number;
		private var _trackTotalTime:Number;

		public static var stw:Number = 82;
		public static var sth:Number = 60;
		public static var str:Number = 10;
		public static var sti:Number = 10;
		public static var sto:Number = 5;

		public static var tth:Number = 24;
		public static var tty:Number = sth + sti - sto;
		public static var ttr:Number = 10;
			
		public static var sby:Number = tty + tth + 4;
		public static var sbw:Number = stw/2;
		public static var sbr:Number = str;
		public static var sbh:Number = 20;
		public static var sbi:Number = 8;
		public static var sbo:Number = 5;
	
		public static var sbgp:Number = 7;
		public static var sbhs:Number = 5;
		public static var sbhc:Number = 2;

		public static var tickh:Number = tth/3;
		
		public static var controlGap:Number = 5;

	    public static var sliderWidth:Number = Math.max(stw,sbw);

		public function Timeline(){
			super();
			fmt.font = "Verdana";
			fmt.size = 10;
			fmt.color = 0xf0f0f0;
			Application.application.addEventListener( FlexEvent.APPLICATION_COMPLETE , creationCompleteHandler )
		}
		
		private var dragging:Boolean = false;
		private var clickDelta:Number = 0;

		public function creationCompleteHandler(event:FlexEvent):void{
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
		}

		private function mouseDown(event:MouseEvent):void {
			if (slider.handle.hitTestPoint(event.stageX, event.stageY)){
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, drag);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
				dragging = true;
				//playButton.setPlay(false);
				clickDelta = event.stageX - slider.x;
			}
		}
	
		private function mouseUp(event:MouseEvent):void {
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, drag);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
		    dragging = false;
		    var indicatorx:Number = event.stageX - clickDelta + sliderWidth/2;
		    dispatchEvent(new TimelineEvent(TimelineEvent.SCRUBBING_DONE, pixelToDate(indicatorx)));
		}
	
		private function drag(event:MouseEvent):void {
			if (dragging){
				playButton.setPlay(false);
			    var indicatorx:Number = event.stageX - clickDelta + sliderWidth/2;
			    var indicatorDate:Date = pixelToDate(indicatorx);
			    if (indicatorDate >= _startDate && indicatorDate <= _endDate){
				    slider.x = event.stageX - clickDelta;
				    slider.setDate(indicatorDate);
				    dispatchEvent(new TimelineEvent(TimelineEvent.SCRUB, indicatorDate));
			    }
			}
		}

		public function setDateRange(start:Date, end:Date):void{
			_startDate.setTime(start.getTime());
			_buildProgress = new Date(_startDate.getTime());
			_layoutProgress = new Date(_startDate.getTime());
			_displayProgress = new Date(_startDate.getTime());

			var s:Date = new Date();
			s.setTime(_startDate.getTime());
			s.setDate(1);
			_trackStartTime = s.getTime();

			_endDate.setTime(end.getTime());
			var e:Date = new Date();
			e.setTime(_endDate.getTime());
			//advance the month one
			e.setMonth(_endDate.getMonth()+1);
			//roll back to the last day of the last month
			e.setDate(0);
			_trackEndTime = e.getTime();
			_trackTotalTime = _trackEndTime - _trackStartTime;
			
			slider.x = dateToPixel(_startDate) - sliderWidth/2;
			slider.visible = true;
			slider.setDateRange(start, end);
			buildMonthList();
		}

		public function set buildProgress(d:Date):void{
			_buildProgress.setTime(d.getTime());
			invalidateDisplayList();
		}

		public function set layoutProgress(d:Date):void{
			_layoutProgress.setTime(d.getTime());
			invalidateDisplayList();
		}

		public function set displayProgress(d:Date):void{
			_displayProgress.setTime(d.getTime());
			invalidateDisplayList();
			slider.x = dateToPixel(d) - sliderWidth/2;
			slider.setDate(d);
		}

		override protected function createChildren():void{
			slider = new Slider();
			slider.visible = false;
			slider.y = 0;
			addChild(slider);
			
			playButton = new PlayButton();
			playButton.width = tth;
			playButton.height = tth;
			playButton.x = unscaledWidth - sliderWidth/2 + controlGap;
			playButton.y = tty;
			playButton.visible = false;
			addChild(playButton);
			
			speedButton = new SpeedButton();
			speedButton.width = tth + 5;
			speedButton.height = tth;
			speedButton.x = sliderWidth/2 - tth - controlGap - 5;
			speedButton.y = tty;
			addChild(speedButton);
		}

		private function dateToPixel(d:Date):Number{
			return timeToPixel(d.getTime()); 
		}
		
		private function timeToPixel(t:Number):Number{
			return ((t - _trackStartTime) / _trackTotalTime) * (unscaledWidth - sliderWidth) + sliderWidth/2; 
		}
		
		private function pixelToTime(x:Number):Number{
			return _trackStartTime + ((_trackTotalTime/(unscaledWidth-sliderWidth)) * (x-sliderWidth/2)); 
		}
		
		private function pixelToDate(x:Number):Date{
			return new Date(pixelToTime(x)); 
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		    super.updateDisplayList(unscaledWidth, unscaledHeight);
		    
		    var buildStartPixel:Number = dateToPixel(_startDate);
		    var buildEndPixel:Number = dateToPixel(_buildProgress);
		    var buildWidth:Number = buildEndPixel - buildStartPixel;
		    
		    var layoutStartPixel:Number = dateToPixel(_startDate);
		    var layoutEndPixel:Number = dateToPixel(_layoutProgress);
		    var layoutWidth:Number = layoutEndPixel - layoutStartPixel;
		    
		    if (!buildEndPixel || !buildStartPixel) return;
		    if (!playButton.visible) playButton.visible = true;
		    
		    // make the component as wide and high as it's set to
			graphics.clear();		    
		    graphics.lineStyle();
		    graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);

			// draw the track
			graphics.lineStyle(3, 0x000000, 0.8, true);
			graphics.beginFill(0xffffff);

		    graphics.drawRect(sliderWidth/2, tty, unscaledWidth - lineWidthThin - sliderWidth, tth - lineWidthThin);
	
			graphics.lineStyle(1, 0xffffff, 1, true);
			graphics.beginFill(0x333333, 1);
	
		    graphics.drawRect(sliderWidth/2, tty, unscaledWidth - lineWidthThin - sliderWidth, tth - lineWidthThin);

			// draw the track
//		    graphics.lineStyle(lineWidthThin, 0xaaaaaa, 1.0);
//		    graphics.drawRect(sliderWidth/2, tty - lineWidthThin, unscaledWidth - lineWidthThin - sliderWidth, tth - lineWidthThin);
//		    graphics.lineStyle();

			// draw the build progress
		    graphics.beginFill(0xf0f0f0);
		    graphics.drawRect(buildStartPixel, tty + 2*lineWidthThick, buildWidth, tth - 4*lineWidthThick);
		    graphics.endFill();

			// draw the layout progress		
		    graphics.lineStyle();
		    var matr:Matrix = new Matrix();
			matr.createGradientBox(unscaledWidth, tth+10, Math.PI/2, 0, tty);
			var spreadMethod:String = SpreadMethod.PAD;

			graphics.endFill();
		    graphics.beginGradientFill(GradientType.LINEAR, [0x3052ae, 0xb3d7ff], [1.0, 1.0], [0,255], matr, spreadMethod);
		    graphics.drawRoundRect(layoutStartPixel, tty + lineWidthThick, layoutWidth, tth - 2*lineWidthThick, tth/3, tth/3);
		    graphics.endFill();

			// draw the build progress
//		    graphics.lineStyle(lineWidthThick, 0x9abbd4, 1.0);
//		    graphics.drawRect(buildStartPixel, tty, buildWidth, tth - lineWidthThick);
//		    graphics.lineStyle();

			// draw the display progress
//		    graphics.lineStyle(lineWidthThick, 0xff0000, 1.0);
//		    graphics.drawRect(dateToPixel(_displayProgress)-5, tty + (tth / 2) - 5, 10, 10);
//		    graphics.lineStyle();

			for each (var tickx:Number in monthTicks){
			    graphics.lineStyle(lineWidthThin, 0xf0f0f0, 1.0);
				graphics.moveTo(tickx, tty + tth - lineWidthThin);
				graphics.lineTo(tickx, tty + tth - lineWidthThin - tickh);
			}
		}

		private function buildMonthList():void{
			var monthidx:Number = 0;

			var displayDate:Date = new Date();
			displayDate.setFullYear(_startDate.getFullYear());
			displayDate.setMonth(_startDate.getMonth());
			displayDate.setDate(1);
			displayDate.setHours(0,0,1,0);

			do{
				months[monthidx] = longMonthNames[displayDate.getMonth()];

				var x:Number = dateToPixel(displayDate);
				if (monthidx > 0){
					monthTicks.push(x);
				}

				var field:TextField = new TextField();
				field.text = months[monthidx];
				field.embedFonts = true;
				field.autoSize = TextFieldAutoSize.LEFT;
				field.selectable = false;
				field.mouseEnabled = false;
				field.setTextFormat(fmt);
				field.antiAliasType = AntiAliasType.ADVANCED;
				field.visible = true;
				field.x = x + 5;
				field.y = tty + tth - field.height - lineWidthThick;
				addChildAt(field, 0);

				displayDate.setMonth( displayDate.getMonth() + 1);
				monthidx++;
				
			}while ( displayDate.getTime() < _endDate.getTime() )
			
		}

	}
}

import mx.core.UIComponent;
import flash.text.TextFormat;
import flash.text.TextField;
import com.frankjania.twitteryear.timeline.Timeline;
import flash.text.TextFormatAlign;
import flash.text.TextFieldType;
import flash.events.MouseEvent;
import mx.events.FlexEvent;
import flash.display.Sprite;
import mx.core.Application;
import com.frankjania.twitteryear.twitter.DateUtil;
import flash.text.AntiAliasType;
import flash.events.Event;
import mx.controls.Tree;
import com.frankjania.twitteryear.display.TrendAnimationComponent;
import flash.external.ExternalInterface;

class DayPage extends UIComponent{
	private var fmt:TextFormat = new TextFormat();
	private var pageDate:Date;
	
	private static const dayWidth:Number = 30;
	private static const dayHeight:Number = 30;
	private static const monthHeight:Number = 15;
	private static const padding:Number = 3;
	public static const pageWidth:Number = dayWidth + 2*padding;
	public static const pageHeight:Number = monthHeight + dayHeight;
	
	private var dayFontSize:Number = 20;
	private var monthFontSize:Number = 10;

	public function DayPage(pageDate:Date):void{
		this.pageDate = pageDate;
		fmt.font = "Verdana";
		fmt.color = 0x000000;
		width = pageWidth;
	}
	
	override protected function createChildren():void{
		var day:TextField = new TextField();
		day.antiAliasType = AntiAliasType.ADVANCED;
		day.embedFonts = true;
		fmt.size = dayFontSize;
		fmt.align = TextFormatAlign.CENTER;
		day.selectable = false;
		day.mouseEnabled = false;
		day.text = "" + pageDate.getDate();
		day.setTextFormat(fmt);
		//day.border = true;
		day.background = true;
		day.backgroundColor = 0xffffff;
		day.width = dayWidth;
		day.height = dayHeight;
		addChild(day);
		//day.x = padding;
		day.y = 0;

		var month:TextField = new TextField();
		month.antiAliasType = AntiAliasType.ADVANCED;
		fmt.align = TextFormatAlign.CENTER;
		fmt.size = monthFontSize;
		//fmt.bold = true;
		month.selectable = false;
		month.mouseEnabled = false;
		month.text = Timeline.shortMonthNames[pageDate.getMonth()];
		month.setTextFormat(fmt);
		//month.border = true;
		month.width = dayWidth;
		month.height = monthHeight;
		month.background = true;
		month.backgroundColor = 0xdd3300;
		addChild(month)
		//month.x = padding;
		month.y = day.height;
	}

//	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
//	    super.updateDisplayList(unscaledWidth, unscaledHeight);
//	    
//	    graphics.lineStyle(1, 0x0000bb);
//	    graphics.drawRect(0, 0, pageWidth-2*padding, dayHeight+monthHeight-2*padding);
//	    graphics.endFill();
//	}

}

class Slider extends UIComponent{
	private var fmt:TextFormat = new TextFormat();
	private var pb:PlayButton;
	
	private var dayStrip:UIComponent = new UIComponent();
	private var maskSprite:Sprite;
	private var frameSprite:Sprite;
	public var handle:UIComponent;
	
	private var _startDate:Date = new Date();
	private var _endDate:Date = new Date();		

	public function Silder():void{
		fmt.font = "Verdana";
		fmt.color = 0x000000;
	}
	
	public function setDateRange(start:Date, end:Date):void{
		_startDate = start;
		_endDate = end;
		var dayidx:Number = 0;
		var displayDate:Date = new Date();
		displayDate.setTime(start.getTime());
		do{
			var dayPage:DayPage = new DayPage(displayDate);
			dayPage.x = Timeline.stw/2 - DayPage.pageWidth/2 + dayidx * dayPage.width;
			dayidx++;
			dayStrip.addChild(dayPage);
			displayDate.setTime(displayDate.getTime() + DateUtil.millisecondsPerDay);
		}while ( displayDate.getTime() < end.getTime() )
	}
	
	public function setDate(d:Date):void{
		var x:Number = DayPage.pageWidth * ((d.getTime() - _startDate.getTime())/DateUtil.millisecondsPerDay);
		dayStrip.x = -x + Timeline.stw/2 - DayPage.pageWidth/2;
	}
	
	override protected function createChildren():void{

		dayStrip.y = 7.5;
		addChild(dayStrip);
		maskSprite = new Sprite();
		maskSprite.graphics.beginFill(0xFF0000);
		maskSprite.graphics.drawRect(1, 0, 79, 60);
		maskSprite.x = 0;
		maskSprite.y = 0;
		addChild(maskSprite);

		dayStrip.mask = maskSprite;

		handle = new UIComponent();
		handle.x = Timeline.sliderWidth/2 - Timeline.sbw/2;
		handle.y = Timeline.sby;
		handle.graphics.drawRect(0, 0, Timeline.sbw, Timeline.sbh);
		addChild(handle);
		doubleClickEnabled = true;
		
//		var pbEdge:Number = 15;
//		var pbPadding:Number = 3;
//		pb = new PlayButton();
//		pb.width = pbEdge;
//		pb.height = pbEdge;
//		pb.x = Timeline.sbw - pbEdge - pbPadding;
//		pb.y = Timeline.sbh - pbEdge - pbPadding;
//		handle.addChild(pb);
//
//		pb.addEventListener(MouseEvent.CLICK, handlePlayButtonClicked);
	}
	
	private function handlePlayButtonClicked(event:MouseEvent):void{
		trace("Clicked");
//		if (!TrendAnimationComponent.pause){
//			trace("> Pausing <");
//		} else {
//			trace("< Playing >");
//		}
//		TrendAnimationComponent.pause = !TrendAnimationComponent.pause;
		pb.play = !pb.play;
		pb.invalidateDisplayList();
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
	    super.updateDisplayList(unscaledWidth, unscaledHeight);

		// calendar view
		graphics.lineStyle(3, 0x000000, 0.8, true);
		graphics.beginFill(0xffffff);

		graphics.moveTo(0, Timeline.sth-Timeline.str);
		graphics.curveTo(0, Timeline.sth, Timeline.str, Timeline.sth);
		graphics.lineTo(Timeline.stw/2-2*Timeline.str, Timeline.sth);
		graphics.curveTo(Timeline.stw/2, Timeline.sth, Timeline.stw/2, Timeline.sth+Timeline.sti);
		graphics.curveTo(Timeline.stw/2, Timeline.sth, Timeline.stw/2+2*Timeline.str, Timeline.sth);
		graphics.lineTo(Timeline.stw-Timeline.str, Timeline.sth);
		graphics.curveTo(Timeline.stw, Timeline.sth, Timeline.stw, Timeline.sth-Timeline.str);
		graphics.lineTo(Timeline.stw, Timeline.str);
		graphics.curveTo(Timeline.stw, 0, Timeline.stw-Timeline.str, 0);
		graphics.lineTo(Timeline.str,0);
		graphics.curveTo(0, 0, 0, Timeline.str);
		graphics.lineTo(0,Timeline.sth-Timeline.str);

		graphics.lineStyle(1, 0xffffff, 1, true);
		graphics.beginFill(0x333333, 1);

		graphics.moveTo(0, Timeline.sth-Timeline.str);
		graphics.curveTo(0, Timeline.sth, Timeline.str, Timeline.sth);
		graphics.lineTo(Timeline.stw/2-2*Timeline.str, Timeline.sth);
		graphics.curveTo(Timeline.stw/2, Timeline.sth, Timeline.stw/2, Timeline.sth+Timeline.sti);
		graphics.curveTo(Timeline.stw/2, Timeline.sth, Timeline.stw/2+2*Timeline.str, Timeline.sth);
		graphics.lineTo(Timeline.stw-Timeline.str, Timeline.sth);
		graphics.curveTo(Timeline.stw, Timeline.sth, Timeline.stw, Timeline.sth-Timeline.str);
		graphics.lineTo(Timeline.stw, Timeline.str);
		graphics.curveTo(Timeline.stw, 0, Timeline.stw-Timeline.str, 0);
		graphics.lineTo(Timeline.str,0);
		graphics.curveTo(0, 0, 0, Timeline.str);
		graphics.lineTo(0,Timeline.sth-Timeline.str);
		
		// handle
		graphics.lineStyle(3, 0x000000, 0.8, true);
		graphics.beginFill(0xffffff);

		graphics.moveTo(Timeline.sliderWidth/2, Timeline.sby - Timeline.sbi);
		graphics.curveTo(Timeline.sliderWidth/2, Timeline.sby, Timeline.sliderWidth/2 + Timeline.sbr, Timeline.sby);
		graphics.lineTo(Timeline.sliderWidth/2 + Timeline.sbw/2 - Timeline.sbr, Timeline.sby);
		graphics.curveTo(Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby, Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby + Timeline.sbr);
		graphics.lineTo(Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby + Timeline.sbh - Timeline.sbr);
		graphics.curveTo(Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby + Timeline.sbh, Timeline.sliderWidth/2 + Timeline.sbw/2 - Timeline.sbr, Timeline.sby + Timeline.sbh);
		graphics.lineTo(Timeline.sliderWidth/2 - Timeline.sbw/2 + Timeline.sbr, Timeline.sby + Timeline.sbh);
		graphics.curveTo(Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby + Timeline.sbh, Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby + Timeline.sbh - Timeline.sbr);
		graphics.lineTo(Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby + Timeline.sbr);
		graphics.curveTo(Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby, Timeline.sliderWidth/2 - Timeline.sbw/2 + Timeline.sbr, Timeline.sby);
		graphics.lineTo(Timeline.sliderWidth/2 - Timeline.sbr, Timeline.sby);
		graphics.curveTo(Timeline.sliderWidth/2, Timeline.sby, Timeline.sliderWidth/2, Timeline.sby - Timeline.sbi);

		graphics.lineStyle(1, 0xffffff, 1, true);
		graphics.beginFill(0x333333, 1.0);

		graphics.moveTo(Timeline.sliderWidth/2, Timeline.sby - Timeline.sbi);
		graphics.curveTo(Timeline.sliderWidth/2, Timeline.sby, Timeline.sliderWidth/2 + Timeline.sbr, Timeline.sby);
		graphics.lineTo(Timeline.sliderWidth/2 + Timeline.sbw/2 - Timeline.sbr, Timeline.sby);
		graphics.curveTo(Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby, Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby + Timeline.sbr);
		graphics.lineTo(Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby + Timeline.sbh - Timeline.sbr);
		graphics.curveTo(Timeline.sliderWidth/2 + Timeline.sbw/2, Timeline.sby + Timeline.sbh, Timeline.sliderWidth/2 + Timeline.sbw/2 - Timeline.sbr, Timeline.sby + Timeline.sbh);
		graphics.lineTo(Timeline.sliderWidth/2 - Timeline.sbw/2 + Timeline.sbr, Timeline.sby + Timeline.sbh);
		graphics.curveTo(Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby + Timeline.sbh, Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby + Timeline.sbh - Timeline.sbr);
		graphics.lineTo(Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby + Timeline.sbr);
		graphics.curveTo(Timeline.sliderWidth/2 - Timeline.sbw/2, Timeline.sby, Timeline.sliderWidth/2 - Timeline.sbw/2 + Timeline.sbr, Timeline.sby);
		graphics.lineTo(Timeline.sliderWidth/2 - Timeline.sbr, Timeline.sby);
		graphics.curveTo(Timeline.sliderWidth/2, Timeline.sby, Timeline.sliderWidth/2, Timeline.sby - Timeline.sbi);

		// grippers
		graphics.lineStyle(2, 0xffffff, 0.8, true);
		graphics.moveTo(Timeline.sliderWidth/2, Timeline.sby+Timeline.sbgp);
		graphics.lineTo(Timeline.sliderWidth/2, Timeline.sby+Timeline.sbh-Timeline.sbgp);
		for (var i:int = 1; i <= Timeline.sbhc; i++){
			graphics.moveTo(Timeline.sliderWidth/2 - i*Timeline.sbhs, Timeline.sby+Timeline.sbgp);
			graphics.lineTo(Timeline.sliderWidth/2 - i*Timeline.sbhs, Timeline.sby+Timeline.sbh-Timeline.sbgp);
			graphics.moveTo(Timeline.sliderWidth/2 + i*Timeline.sbhs, Timeline.sby+Timeline.sbgp);
			graphics.lineTo(Timeline.sliderWidth/2 + i*Timeline.sbhs, Timeline.sby+Timeline.sbh-Timeline.sbgp);
		} 
	}
}

class PlayButton extends UIComponent{
	
	public var play:Boolean = true;
	private var padding:Number = 8;
	
	public function PlayButton():void{
		addEventListener(MouseEvent.CLICK, handleClick);
	}
	
	private function handleClick(e:MouseEvent):void{
		setPlay(!this.play);
	}
	
	public function setPlay(play:Boolean):void{
		this.play = play;
		TrendAnimationComponent.play = this.play;
		invalidateDisplayList();
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
	    super.updateDisplayList(unscaledWidth, unscaledHeight);
		graphics.clear();
		graphics.lineStyle(3, 0x000000, 0.8, true);
		graphics.beginFill(0xffffff);

	    graphics.drawRoundRect(0, 0, unscaledWidth - 1, unscaledHeight - 1, 10, 10);

		graphics.lineStyle(1, 0xffffff, 1, true);
		graphics.beginFill(0x333333, 1);

	    graphics.drawRoundRect(0, 0, unscaledWidth - 1, unscaledHeight - 1, 10, 10);

		if (play){
			graphics.lineStyle(2, 0xf0f0f0, 0.8, true);
			graphics.moveTo(padding, padding);
			graphics.lineTo(padding,unscaledHeight - padding);
			graphics.lineTo(unscaledWidth - padding, unscaledHeight/2);
			graphics.lineTo(padding, padding);
		} else {
			graphics.lineStyle(1, 0xf0f0f0, 0.8, true);
			graphics.drawRect(unscaledWidth/3, padding, 2, unscaledHeight - 2*padding);
			graphics.drawRect(2*unscaledWidth/3-2, padding, 2, unscaledHeight - 2*padding);
//			graphics.moveTo(2*unscaledWidth/3,padding);
//			graphics.lineTo(2*unscaledWidth/3,unscaledHeight - padding);
		}
	}	
}
class SpeedButton extends UIComponent{
	
	private var speeds:Array = [1, 2, 5, 10];
	private var speedPointer:Number = 0;
	private var padding:Number = 8;
	
	private var txt:TextField = new TextField();
	private var fmt:TextFormat = new TextFormat();
	
	public function SpeedButton():void{
		addEventListener(MouseEvent.CLICK, handleClick);
		txt.text = "x" + new String(TrendAnimationComponent.displayStep);
	}
	
	private function handleClick(e:MouseEvent):void{
		cycleSpeed();
	}

	public function cycleSpeed():void{
		speedPointer++;
		if (speedPointer >= speeds.length){
			speedPointer = 0;
		}
		TrendAnimationComponent.displayStep = speeds[speedPointer];
		txt.text = "x" + new String(TrendAnimationComponent.displayStep);
		txt.setTextFormat(fmt);
		trace("Cycle Speed: " + speeds[speedPointer]);
		
	}

	override protected function createChildren():void{
		fmt.font = "Verdana";
		fmt.color = 0xffffff;
		txt.antiAliasType = AntiAliasType.ADVANCED;
		txt.embedFonts = true;
		fmt.size = 12;
		fmt.align = TextFormatAlign.CENTER;
		txt.selectable = false;
		txt.mouseEnabled = true;
		txt.setTextFormat(fmt);
		txt.width = this.width;
		txt.height = this.height;
		txt.y = 2;
		addChild(txt);
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
	    super.updateDisplayList(unscaledWidth, unscaledHeight);
		graphics.clear();
		graphics.lineStyle(3, 0x000000, 0.8, true);
		graphics.beginFill(0xffffff);

	    graphics.drawRoundRect(0, 0, unscaledWidth - 1, unscaledHeight - 1, 10, 10);

		graphics.lineStyle(1, 0xffffff, 1, true);
		graphics.beginFill(0x333333, 1);

	    graphics.drawRoundRect(0, 0, unscaledWidth - 1, unscaledHeight - 1, 10, 10);

	}	
}