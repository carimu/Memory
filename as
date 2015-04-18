package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.utils.Timer;
	import flash.media.Sound;
    import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class MemoryGame extends Sprite {
		static const numLights:uint = 5;
		
		private var lights:Array; // list of light objects
		private var playOrder:Array; // growing sequence
		private var repeatOrder:Array;
		
		// text message
		private var textMessage:TextField;
		private var textScore:TextField;
		
		// timers
		private var lightTimer:Timer;
		private var offTimer:Timer;
		
		var gameMode:String; // play or replay
		var currentSelection:MovieClip = null;
		var soundList:Array = new Array(); // hold sounds
		
		public function MemoryGame() {
			// text formating
			var textFormat = new TextFormat();
			textFormat.font = "Arial";
			textFormat.size = 24;
			textFormat.align = "center";
			
			// create the upper text field
			textMessage = new TextField();
			textMessage.width = 550;
			textMessage.y = 110;
			textMessage.selectable = false;
			textMessage.defaultTextFormat = textFormat;
			addChild(textMessage);
			
			// create the lower text field
			textScore = new TextField();
			textScore.width = 550;
			textScore.y = 250;
			textMessage.selectable = false;
			textScore.defaultTextFormat = textFormat;
			addChild(textScore);
			
			// load the sounds
			soundList = new Array();
			for(var i:uint=1;i<=5;i++) {
				var thisSound:Sound = new Sound();
				var req:URLRequest = new URLRequest("note"+i+".mp3");
				thisSound.load(req);
				soundList.push(thisSound);
			}

			// make lights
			lights = new Array();
			for(i=0;i<numLights;i++) {
				var thisLight:Light = new Light();
				thisLight.lightColors.gotoAndStop(i+1); // show proper frame
				thisLight.x = i*75+100; // position
				thisLight.y = 175;
				thisLight.lightNum = i; // remember light number
				lights.push(thisLight); // add to array of lights
				addChild(thisLight); // add to screen
				thisLight.addEventListener(MouseEvent.CLICK,clickLight); // listen for clicks
				thisLight.buttonMode = true;
			}
			
			// reset sequence, do first turn
			playOrder = new Array();
			gameMode = "play";
			nextTurn();
		}
		
		// add one to the sequence and start
		public function nextTurn() {
			// add new light to sequence
			var r:uint = Math.floor(Math.random()*numLights);
			playOrder.push(r);
			
			// show text
			textMessage.text = "Watch and Listen.";
			textScore.text = "Sequence Length: "+playOrder.length;
			
			// set up timers to show sequence
			lightTimer = new Timer(1000,playOrder.length+1);
			lightTimer.addEventListener(TimerEvent.TIMER,lightSequence);
			
			// start timer
			lightTimer.start();
		}
		
		// play next in sequence
		public function lightSequence(event:TimerEvent) {
			// where are we in the sequence
			var playStep:uint = event.currentTarget.currentCount-1;
			
			if (playStep < playOrder.length) { // not last time
				lightOn(playOrder[playStep]);
			} else { // sequence over
				startPlayerRepeat();
			}
		}
		
		// start player repetion
		public function startPlayerRepeat() {
			currentSelection = null;
			textMessage.text = "Repeat.";
			gameMode = "replay";
			repeatOrder = playOrder.concat();
		}
		
		// turn on light and set timer to turn it off
		public function lightOn(newLight) {
			soundList[newLight].play(); // play sound
			currentSelection = lights[newLight];
			currentSelection.gotoAndStop(2); // turn on light
			offTimer = new Timer(500,1); // remember to turn it off
			offTimer.addEventListener(TimerEvent.TIMER_COMPLETE,lightOff);
			offTimer.start();
		}
		
		// turn off light if it is still on
		public function lightOff(event:TimerEvent) {
			if (currentSelection != null) {
				currentSelection.gotoAndStop(1);
				currentSelection = null;
				offTimer.stop();
			}
		}
		
		// receive mouse clicks on lights
		public function clickLight(event:MouseEvent) {
			// prevent mouse clicks while showing sequence
			if (gameMode != "replay") return;
			
			// turn off light if it hasn't gone off by itself
			lightOff(null);
			
			// correct match
			if (event.currentTarget.lightNum == repeatOrder.shift()) {
				lightOn(event.currentTarget.lightNum);
				
				// check to see if sequence is over
				if (repeatOrder.length == 0) {
					nextTurn();
				}
				
			// got it wrong
			} else {
				textMessage.text = "Game Over!";
				gameMode = "gameover";
			}
		}
	}
}
