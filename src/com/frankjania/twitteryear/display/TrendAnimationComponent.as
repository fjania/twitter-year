package com.frankjania.twitteryear.display
{
	import com.frankjania.twitteryear.collisiondetection.CollisionDetectionSystem;
	import com.frankjania.twitteryear.core.Settings;
	import com.frankjania.twitteryear.core.Trend;
	import com.frankjania.twitteryear.core.TrendWindow;
	import com.frankjania.twitteryear.core.TwitterTrendsToDate;
	import com.frankjania.twitteryear.timeline.Timeline;
	import com.frankjania.twitteryear.timeline.TimelineEvent;
	import com.frankjania.twitteryear.twitter.TrendsLoadedEvent;
	import com.frankjania.twitteryear.util.ColorPalette;
	import com.frankjania.twitteryear.util.ColorScaler;
	import com.frankjania.twitteryear.util.FontScaler;
	import com.frankjania.twitteryear.util.TopWordsList;
	
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.controls.ProgressBar;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.effects.Effect;
	import mx.effects.Move;
	import mx.effects.Zoom;
	import mx.effects.easing.Bounce;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	
	public class TrendAnimationComponent extends UIComponent{
        private var container:UIComponent;

		private var trendSpriteCache:Dictionary = new Dictionary();

		private var downloadProgress:ProgressBar;
		
		private var timeline:Timeline;
		
		private var trendsToDate:TwitterTrendsToDate;

		private var currentLayoutWindow:TrendWindow;
		
		private var previousDisplayWindow:TrendWindow;
		private var currentDisplayWindow:TrendWindow;

		private var currentTrend:Trend;

		private var cloudTrendCounter:Number = 0;
		private var currentCloudTrend:Trend;
		
		private var windowBuildingTimer:Timer;
		private var windowLayoutTimer:Timer;
		private var cloudLayoutTimer:Timer;
		private var windowDisplayTimer:Timer;
		
		private var animationsInProgress:Number = 0;
		
		private var layoutWindowCounter:Number = 0;
		private var displayWindowCounter:Number = 0;
		
		public static var font:String = "Teen";
		
		public static var play:Boolean = true;
		
		public static var displayStep:Number = 1;
		
		public function TrendAnimationComponent():void{
			super();
			// Wait for the application to load so we know the width and height
			Application.application.addEventListener( FlexEvent.APPLICATION_COMPLETE , creationCompleteHandler )
			Application.application.addEventListener( TrendsLoadedEvent.LOADED , onTrendsLoaded );
			Application.application.addEventListener( ProgressEvent.PROGRESS, progressed );

			FontScaler.setScale(15, 40, 1, 24);
//			FontScaler.setScale(20, 40, 72, 312);
			ColorPalette.add(0x003366, 0x660033, 0x336600, 0x663300);
			ColorScaler.setScale(0x99, 0x00, 8, 24);
		}
		
		public function creationCompleteHandler(event:FlexEvent):void{
            windowBuildingTimer = new Timer(Settings.build_timer_tick);
            windowBuildingTimer.addEventListener(TimerEvent.TIMER, onWindowBuildingTimer);
            
			timeline = Application.application.timeline;
			timeline.addEventListener(TimelineEvent.SCRUB, onTimelineScrubbed);
			timeline.addEventListener(TimelineEvent.SCRUBBING_DONE, onTimelineScrubbingDone);
			graphics.drawRect(0,0,width,height);
           	trendsToDate = new TwitterTrendsToDate("http://labs.digitalanalog.net/twitteryear/ytd-short.csv");
        }
        
        private function onTimelineScrubbed(event:TimelineEvent):void{
			play = false;
			var w:Number = trendsToDate.getTrendWindowCount()  * 
				((event.date.getTime() - trendsToDate.startDate.getTime()	) / (trendsToDate.endDate.getTime() - trendsToDate.startDate.getTime()))
			displayWindowCounter = Math.round(w)
			showSpecificTrendWindow(displayWindowCounter);
     		previousDisplayWindow = currentDisplayWindow;
     		currentDisplayWindow = trendsToDate.getWindow(displayWindowCounter);
        }

        private function onTimelineScrubbingDone(event:TimelineEvent):void{
			var w:Number = trendsToDate.getTrendWindowCount()  * 
				((event.date.getTime() - trendsToDate.startDate.getTime()	) / (trendsToDate.endDate.getTime() - trendsToDate.startDate.getTime()))
			displayWindowCounter = Math.round(w)
			showSpecificTrendWindow(displayWindowCounter);
     		previousDisplayWindow = currentDisplayWindow;
     		currentDisplayWindow = trendsToDate.getWindow(displayWindowCounter);
        }

		public function onTrendsLoaded(event:TrendsLoadedEvent):void{
			windowBuildingTimer.start();
			trace("S: " + trendsToDate.startDate);
			trace("E: " + trendsToDate.endDate);
			timeline.setDateRange(trendsToDate.startDate, trendsToDate.endDate);
  		}
  
        public function onWindowBuildingTimer(event:TimerEvent):void {
        	var window:TrendWindow;
        	for (var i:int; i < 20; i++){
        		window = trendsToDate.addNextWindow();
        	}
//			if ( windowLayoutTimer == null && trendsToDate.getWindow(1) != null){
//
//				currentLayoutWindow = trendsToDate.getWindow(layoutWindowCounter++);
//
//				windowLayoutTimer = new Timer(Settings.layout_timer_tick);
//            	windowLayoutTimer.addEventListener(TimerEvent.TIMER, onWindowLayoutTimer);
//				windowLayoutTimer.start();
//			} else 
			if (window != null){
				timeline.buildProgress = window.endDate;
//	       		windowProgress.setProgress(window, trendsToDate.getTrendWindowCount());
//	      		windowProgress.label = "Creating trend windows: " + (Math.round(100*window / trendsToDate.getTrendWindowCount())) + "%";
			} else {
				TopWordsList.traceTopWords();
//				FontScaler.setScale(15, 40, 
//						TopWordsList.wordarray[TopWordsList.wordarray.length-1].frequency, TopWordsList.wordarray[0].frequency);
				ColorScaler.setScale(0x99, 0x00, 
						TopWordsList.wordarray[TopWordsList.wordarray.length-1].frequency, TopWordsList.wordarray[0].frequency);
				
				windowBuildingTimer.stop();
				cloudLayoutTimer = new Timer(Settings.layout_timer_tick);
				cloudLayoutTimer.addEventListener(TimerEvent.TIMER, onCloudLayoutTimer);
				CollisionDetectionSystem.resetStage();
				cloudLayoutTimer.start();
			}
        }
        
        public function onCloudLayoutTimer(event:TimerEvent):void {
        	//if ( Settings.placementStrategy.layoutOneByOne() ){

	        	if ( (currentCloudTrend = getNextTrendInCloudLayoutWindow()) != null){
					CollisionDetectionSystem.placeTrend(currentCloudTrend);
	        		//trace("Placed: " + currentCloudTrend);
	        		var cts:TrendSprite = new TrendSprite(currentCloudTrend);
	        		trendSpriteCache[currentCloudTrend.getText()] = cts;
					container.addChild(cts);
					cts.scaleX = FontScaler.scale(currentCloudTrend.frequency);
					cts.scaleY = FontScaler.scale(currentCloudTrend.frequency);
					cts.show();
				} else {

        	//}
					windowDisplayTimer = new Timer(Settings.display_timer_tick);
	            	windowDisplayTimer.addEventListener(TimerEvent.TIMER, onWindowDisplayTimer);
					windowDisplayTimer.start();
        	
        			cloudLayoutTimer.stop();
				}

        }
        
		public function getNextTrendInCloudLayoutWindow():Trend{
			if (cloudTrendCounter > TopWordsList.wordarray.length - 1)
				return null;
			return TopWordsList.wordarray[cloudTrendCounter++];
		}

        public function onWindowLayoutTimer(event:TimerEvent):void {
        	if ( Settings.placementStrategy.layoutOneByOne() ){

	        	if ( (currentTrend = getNextTrendInLayoutWindow()) != null){
					CollisionDetectionSystem.placeTrend(currentTrend);
				} else {
					doLayout();
				}

        	} else {

	        	for (var i:int; i < 20; i++){
		        	while ( (currentTrend = getNextTrendInLayoutWindow()) != null){
						CollisionDetectionSystem.placeTrend(currentTrend);
		        	}
		        	if (currentLayoutWindow != null)
						doLayout();
	        	}
        	}
        }
        
        private function doLayout():void{
			currentLayoutWindow.markAsLaidOut();
			timeline.layoutProgress = currentLayoutWindow.endDate;
			currentLayoutWindow = trendsToDate.getWindow(++layoutWindowCounter);
    		CollisionDetectionSystem.resetStage();
			
    		if (currentLayoutWindow == null){
    			windowLayoutTimer.stop();
    		}

			if (windowDisplayTimer == null && layoutWindowCounter > 1){
				currentDisplayWindow = trendsToDate.getWindow(0);
				displayWindowCounter += displayStep;

				windowDisplayTimer = new Timer(Settings.display_timer_tick);
            	windowDisplayTimer.addEventListener(TimerEvent.TIMER, onWindowDisplayTimer);
				windowDisplayTimer.start();
			}
        	
        }

		public function onWindowDisplayTimer(event:TimerEvent):void {
//			if (currentDisplayWindow.isLaidOut() && animationsInProgress == 0 && play){
//
//				timeline.displayProgress = currentDisplayWindow.endDate;
//    	       	showTrendWindow();
//
//	       		previousDisplayWindow = currentDisplayWindow;
//	       		displayWindowCounter += displayStep;
//        		currentDisplayWindow = trendsToDate.getWindow(displayWindowCounter);
//
//	    		if (currentDisplayWindow == null){
//	    			windowDisplayTimer.stop();
//        		}
//	 		} 
//	 		else {
//	 			trace("Waiting to display window: " + displayWindowCounter);
//	 		}

			if (animationsInProgress == 0 && play){
	       		displayWindowCounter += displayStep;
	    		currentDisplayWindow = trendsToDate.getWindow(displayWindowCounter);
	    		timeline.displayProgress = currentDisplayWindow.endDate;
				for each (var s:TrendSprite in trendSpriteCache ){
					if (currentDisplayWindow.containsTrend(s.getTrend())){
						s.updateColor(0x000000);
	//					s.scaleX = 28;
	//					s.scaleY = 28;
//						var z:Zoom = new Zoom(s);
//						z.duration = Settings.existing_trend_effect_duration;
//						z.zoomWidthTo = 28;
//						z.zoomHeightTo = 28;
//						z.startDelay = randomRange(0,200);
//						z.duration = randomRange(Settings.new_trend_effect_duration - 200, Settings.new_trend_effect_duration);
//						playEffect(z);
					} else {
						s.updateColor(0x999999);
	//					s.scaleX = 14;
	//					s.scaleY = 14;
//						var z2:Zoom = new Zoom(s);
//						z2.duration = Settings.existing_trend_effect_duration;
//						z2.zoomWidthTo = 14;
//						z2.zoomHeightTo = 14;
//						z2.startDelay = randomRange(0,200);
//						z2.duration = randomRange(Settings.new_trend_effect_duration - 200, Settings.new_trend_effect_duration);
//						playEffect(z2);
					}
				}
			}
  		}
  		
  		private function showSpecificTrendWindow(windowNumber:Number):void{
  			// hide everything
			for each (var s:TrendSprite in trendSpriteCache ){
				s.visible = false;
			}

			var window:TrendWindow = trendsToDate.getWindow(windowNumber);
			//if (window != null){
				for each (var ct:Trend in window.getTrends()){
					var cts:TrendSprite = trendSpriteCache[ct.getText()];
					if ( cts == null ){
						// never been shown before, show it and bounce it
						cts = new TrendSprite(ct);
						trendSpriteCache[ct.getText()] = cts;
						container.addChild(cts);
						cts.configure(ct);
						cts.show();
					} else {
						// it had been showing, is no longer, and should be
						// shown again.
						cts.configure(ct);
						cts.scaleX = FontScaler.scale(ct.frequency);
						cts.scaleY = FontScaler.scale(ct.frequency);
						cts.show();
					}
				}
			//}
  		}

		private function showTrendWindow():void{
			// hide any of the trends that are not in the one we're
			// about to show.
			if (previousDisplayWindow != null){
				for each (var pt:Trend in previousDisplayWindow.getTrends() ){
					if (!currentDisplayWindow.containsTrend(pt)){
						trendSpriteCache[pt.getText()].visible = false;
					}
				}
			}
			
			for each (var ct:Trend in currentDisplayWindow.getTrends() ){
				var cts:TrendSprite = trendSpriteCache[ct.getText()];
				if ( cts == null ){
					// never been shown before, show it and bounce it
					cts = new TrendSprite(ct);
					trendSpriteCache[ct.getText()] = cts;
					container.addChild(cts);
					cts.configure(ct);
					cts.show();
	
					var zin:Zoom = new Zoom(cts);
					zin.startDelay = randomRange(0,200);
					zin.duration = randomRange(Settings.new_trend_effect_duration - 200, Settings.new_trend_effect_duration);
					zin.zoomWidthTo = FontScaler.scale(ct.frequency);
					zin.zoomHeightTo = FontScaler.scale(ct.frequency);
					zin.easingFunction = Bounce.easeOut;
					playEffect(zin);
				} else 	if ( cts.visible ){
					// already showing, move and zoom if needed
					var m:Move;
					var z:Zoom;
					if (Math.floor(cts.y) != Math.floor(ct.y)){
						m = new Move(cts);
						m.duration = Settings.existing_trend_effect_duration;
						m.xTo = Math.floor(ct.x);
						m.yTo = Math.floor(ct.y);
					}
					cts.updateFrequency(ct);
					if (cts.scaleX != ct.frequency){
						z = new Zoom(cts);
						z.duration = Settings.existing_trend_effect_duration;
						z.zoomWidthTo = FontScaler.scale(ct.frequency);
						z.zoomHeightTo = FontScaler.scale(ct.frequency);
					}
					
					if ( m != null ){
						playEffect(m);
					}
					if ( z != null ){
						playEffect(z);
					}
				} else {
					// it had been showing, is no longer, and should be
					// shown again.
					cts.configure(ct);
					cts.scaleX = FontScaler.scale(ct.frequency);
					cts.scaleY = FontScaler.scale(ct.frequency);
					cts.show();
				}
			}
		}
		
		private function randomRange(a:Number, b:Number):Number{
			return (Math.floor(Math.random() * (b-a)) + a);
		}
		
		private function playEffect(e:Effect):void{
			e.addEventListener(EffectEvent.EFFECT_END, animationEnded);
			animationsInProgress++;
			e.play();
		}
		     
		override protected function createChildren():void {
		    super.createChildren();
 			container = new UIComponent()
			container.x = this.width / 2;
			container.y = this.height / 2;
			addChild(container);
			
			downloadProgress = new ProgressBar();
			downloadProgress.x = 20;
			downloadProgress.width = this.width - downloadProgress.x;
			downloadProgress.label = "Loading Twitter trends to date";
			addChild(downloadProgress);
       	}
        
        private function getNextTrendInLayoutWindow():Trend{
        	if (currentLayoutWindow != null)
        		return currentLayoutWindow.getNextTrend();
        	else
        		return null;
        }

		public function progressed(e:ProgressEvent):void{
       		downloadProgress.setProgress(e.bytesLoaded, e.bytesTotal);
      		downloadProgress.label = "Loading Twitter trends to date: " + (100*Math.round(e.bytesLoaded / e.bytesTotal)) + "%";
      		if (e.bytesLoaded == e.bytesTotal){
      			downloadProgress.visible = false;
      		}
		}

		private function animationEnded(event:EffectEvent):void{
			animationsInProgress--;
		}
	}
}