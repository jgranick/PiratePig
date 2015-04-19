package piratepig;


import layout.Layout;
import layout.LayoutItem;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.text.TextField;


/**
 * @author Joshua Granick
 */
class PiratePig extends PiratePig_Display {
	
	
	private var currentGame:Game;
	private var layout:Layout;
	
	
	public function new () {
		
		super ();
		
		initialize ();
		construct ();
		
		startGame ();
		
	}
	
	
	private function construct ():Void {
		
		layout.minWidth = 600;
		layout.minHeight = 800;
		
		layout.addItem (new LayoutItem (Background, STRETCH, STRETCH, false, false));
		layout.addItem (new LayoutItem (Footer, BOTTOM, CENTER, true, false));
		layout.addItem (new LayoutItem (Logo, TOP, CENTER));
		layout.addItem (new LayoutItem (Score, TOP, CENTER));
		layout.addItem (new LayoutItem (TileBackground, TOP, CENTER));
		layout.addItem (new LayoutItem (TileContainer, TOP, CENTER));
		
		TileContainer.visible = false;
		
		resize (stage.stageWidth, stage.stageHeight);
		stage.addEventListener (Event.RESIZE, stage_onResize);
		
	}
	
	
	private function initialize ():Void {
		
		layout = new Layout ();
		
	}
	
	
	public function resize (newWidth:Int, newHeight:Int):Void {
		
		layout.resize (newWidth, newHeight);
		
		Background.width = newWidth;
		
		if (currentGame != null) {
			
			currentGame.resize ();
			
		}
		
	}
	
	
	public function startGame ():Void {
		
		currentGame = new Game (this);
		addChild (currentGame);
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function stage_onResize (event:Event):Void {
		
		resize (stage.stageWidth, stage.stageHeight);
		
	}
	
	
}