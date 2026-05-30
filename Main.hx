package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import openfl.display.StageScaleMode;

#if cpp
import cpp.vm.Gc;
#end

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Standard HD Internal Resolution
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = TitleState;
	var zoom:Float = -1;
	var framerate:Int = 60; // Locked 60 FPS for Cool Battery & Low CPU Overhead
	var skipSplash:Bool = true;
	var startFullscreen:Bool = false;

	public static var fpsVar:FPS;

	public static function main():void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, init);
		setupGame();
	}

	private function setupGame():void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
	
		#if cpp
		Gc.enable(true);
		#end

		// ======================================================================
		// GLOBAL ANTI-CRASH SYSTEM (Blocks fatal crashes during heavy modding)
		// ======================================================================
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent) {
			#if cpp 
			Gc.run(true); 
			Gc.compact();
			#end
			e.preventDefault();
			trace("PLATFORM GUARD: Critical error intercepted successfully -> " + e.error);
		});

		// Dynamic asset cleanup handler during state transitions (e.g. Song changes / Recharts)
		FlxG.signals.preStateCreate.add(function(state:FlxState) {
			#if cpp Gc.run(true); Gc.compact(); #end
		});
		// ======================================================================

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
}
