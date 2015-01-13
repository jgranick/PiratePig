package piratepig;


import motion.easing.Quad;
import motion.Actuate;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.Assets;
import piratepig.Tile;


/**
 * @author Joshua Granick
 */
class Game extends Sprite {
	
	
	private var Score:TextField;
	private var TileContainer:MovieClip;
	
	private var cacheMouse:Point;
	private var currentScore:Int;
	private var display:PiratePig;
	private var needToCheckMatches:Bool;
	private var numColumns = 8;
	private var numRows = 8;
	private var selectedTile:Tile;
	private var tiles:Array<Array<Tile>>;
	private var tileSpacing:Point;
	private var usedTiles:Array<Tile>;
	
	
	
	public function new (display:PiratePig) {
		
		super ();
		
		this.display = display;
		
		initialize ();
		construct ();
	
	}
	
	
	private function addTile (row:Int, column:Int, animate:Bool = true):Void {
		
		var tile = null;
		var type = Type.createEnumIndex (TileType, Math.round (Math.random () * (Type.allEnums (TileType).length - 1)));
		
		for (usedTile in usedTiles) {
			
			if (usedTile.removed && usedTile.parent == null && usedTile.type == type) {
				
				tile = usedTile;
				
			}
			
		}
		
		if (tile == null) {
			
			tile = new Tile (type);
			
		}
		
		tile.initialize ();
		
		tile.type = type;
		tile.row = row;
		tile.column = column;
		tiles[row][column] = tile;
		
		var position = getPosition (row, column);
		
		if (animate) {
			
			var firstPosition = getPosition (-1, column);
			
			tile.alpha = 0;
			tile.x = firstPosition.x;
			tile.y = firstPosition.y;
			
			tile.moveTo (0.15 * (row + 1), position.x, position.y);
			Actuate.tween (tile, 0.3, { alpha: 1 } ).delay (0.15 * (row - 2)).ease (Quad.easeOut);
			
		} else {
			
			tile.x = position.x;
			tile.y = position.y;
			
		}
		
		addChild (tile);
		needToCheckMatches = true;
		
	}
	
	
	private function construct ():Void {
		
		for (row in 0...numRows) {
			
			for (column in 0...numColumns) {
				
				removeTile (row, column, false);
				
			}
			
		}
		
		for (row in 0...numRows) {
			
			for (column in 0...numColumns) {
				
				addTile (row, column, false);
				
			}
			
		}
		
		resize ();
		
		display.addEventListener (MouseEvent.MOUSE_DOWN, display_onMouseDown);
		display.addEventListener (MouseEvent.MOUSE_UP, display_onMouseUp);
		
		Assets.getSound ("soundTheme").play ();
		
		addEventListener (Event.ENTER_FRAME, this_onEnterFrame);
		
	}
	
	
	private function dropTiles ():Void {
		
		for (column in 0...numColumns) {
			
			var spaces = 0;
			
			for (row in 0...numRows) {
				
				var index = (numRows - 1) - row;
				var tile = tiles[index][column];
				
				if (tile == null) {
					
					spaces++;
					
				} else {
					
					if (spaces > 0) {
						
						var position = getPosition (index + spaces, column);
						tile.moveTo (0.15 * spaces, position.x,position.y);
						
						tile.row = index + spaces;
						tiles[index + spaces][column] = tile;
						tiles[index][column] = null;
						
						needToCheckMatches = true;
						
					}
					
				}
				
			}
			
			for (i in 0...spaces) {
				
				var row = (spaces - 1) - i;
				addTile (row, column);
				
			}
			
		}
		
	}
	
	
	public function findMatches (byRow:Bool, accumulateScore:Bool = true):Array <Tile> {
		
		var matchedTiles = new Array <Tile> ();
		
		var max:Int;
		var secondMax:Int;
		
		if (byRow) {
			
			max = numRows;
			secondMax = numColumns;
			
		} else {
			
			max = numColumns;
			secondMax = numRows;
			
		}
		
		for (index in 0...max) {
			
			var matches = 0;
			var foundTiles = new Array <Tile> ();
			var previousType = null;
			
			for (secondIndex in 0...secondMax) {
				
				var tile:Tile;
				
				if (byRow) {
					
					tile = tiles[index][secondIndex];
					
				} else {
					
					tile = tiles[secondIndex][index];
					
				}
				
				if (tile != null && !tile.moving) {
					
					if (previousType == null) {
						
						previousType = tile.type;
						foundTiles.push (tile);
						continue;
						
					} else if (tile.type == previousType) {
						
						foundTiles.push (tile);
						matches++;
						
					}
					
				}
				
				if (tile == null || tile.moving || tile.type != previousType || secondIndex == secondMax - 1) {
					
					if (matches >= 2 && previousType != null) {
						
						if (accumulateScore) {
							
							if (matches > 3) {
								
								Assets.getSound ("sound5").play ();
								
							} else if (matches > 2) {
								
								Assets.getSound ("sound4").play ();
								
							} else {
								
								Assets.getSound ("sound3").play ();
								
							}
							
							currentScore += Std.int (Math.pow (matches, 2) * 50);
							
						}
						
						matchedTiles = matchedTiles.concat (foundTiles);
						
					}
					
					matches = 0;
					foundTiles = new Array <Tile> ();
					
					if (tile == null || tile.moving) {
						
						needToCheckMatches = true;
						previousType = null;
						
					} else {
						
						previousType = tile.type;
						foundTiles.push (tile);
						
					}
					
				}
				
			}
			
		}
		
		return matchedTiles;
		
	}
	
	
	private function getPosition (row:Int, column:Int):Point {
		
		return new Point (column * tileSpacing.x, row * tileSpacing.y);
		
	}
	
	
	private function initialize ():Void {
		
		Score = display.Score;
		TileContainer = display.TileContainer;
		
		var tile = TileContainer.getChildByName ("Tile");
		var tile2 = TileContainer.getChildByName ("Tile2");
		var tile3 = TileContainer.getChildByName ("Tile3");
		
		tileSpacing = new Point (tile2.x - tile.x, tile3.y - tile.y);
		
		currentScore = 0;
		Score.text = "0";
		
		tiles = new Array<Array<Tile>> ();
		usedTiles = new Array<Tile> ();
		
		for (row in 0...numRows) {
			
			tiles[row] = new Array<Tile> ();
			
			for (column in 0...numColumns) {
				
				tiles[row][column] = null;
				
			}
			
		}
		
	}
	
	
	private function removeTile (row:Int, column:Int, animate:Bool = true):Void {
		
		var tile = tiles[row][column];
		
		if (tile != null) {
			
			tile.remove (animate);
			usedTiles.push (tile);
			
		}
		
		tiles[row][column] = null;
		
	}
	
	
	public function resize ():Void {
		
		x = TileContainer.x;
		y = TileContainer.y;
		
	}
	
	
	private function swapTile (tile:Tile, targetRow:Int, targetColumn:Int):Void {
		
		if (targetColumn >= 0 && targetColumn < numColumns && targetRow >= 0 && targetRow < numRows) {
			
			var targetTile = tiles[targetRow][targetColumn];
			
			if (targetTile != null && !targetTile.moving) {
				
				tiles[targetRow][targetColumn] = tile;
				tiles[tile.row][tile.column] = targetTile;
				
				if (findMatches (true, false).length > 0 || findMatches (false, false).length > 0) {
					
					targetTile.row = tile.row;
					targetTile.column = tile.column;
					tile.row = targetRow;
					tile.column = targetColumn;
					var targetTilePosition = getPosition (targetTile.row, targetTile.column);
					var tilePosition = getPosition (tile.row, tile.column);
					
					targetTile.moveTo (0.3, targetTilePosition.x, targetTilePosition.y);
					tile.moveTo (0.3, tilePosition.x, tilePosition.y);
					
					needToCheckMatches = true;
					
				} else {
					
					tiles[targetRow][targetColumn] = targetTile;
					tiles[tile.row][tile.column] = tile;
					
				}
				
			}
			
		}
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	private function display_onMouseDown (event:MouseEvent):Void {
		
		if (Std.is (event.target, Tile)) {
			
			selectedTile = cast event.target;
			cacheMouse = new Point (event.stageX, event.stageY);
			
		} else {
			
			cacheMouse = null;
			selectedTile = null;
			
		}
		
	}
	
	
	private function display_onMouseUp (event:MouseEvent):Void {
		
		if (cacheMouse != null && selectedTile != null && !selectedTile.moving) {
			
			var differenceX = event.stageX - cacheMouse.x;
			var differenceY = event.stageY - cacheMouse.y;
			
			if (Math.abs (differenceX) > 10 || Math.abs (differenceY) > 10) {
				
				var swapToRow = selectedTile.row;
				var swapToColumn = selectedTile.column;
				
				if (Math.abs (differenceX) > Math.abs (differenceY)) {
					
					if (differenceX < 0) {
						
						swapToColumn --;
						
					} else {
						
						swapToColumn ++;
						
					}
					
				} else {
					
					if (differenceY < 0) {
						
						swapToRow --;
						
					} else {
						
						swapToRow ++;
						
					}
					
				}
				
				swapTile (selectedTile, swapToRow, swapToColumn);
				
			}
			
		}
		
		selectedTile = null;
		cacheMouse = null;
		
	}
	
	
	private function this_onEnterFrame (event:Event):Void {
		
		if (needToCheckMatches) {
			
			var matchedTiles = new Array <Tile> ();
			
			matchedTiles = matchedTiles.concat (findMatches (true));
			matchedTiles = matchedTiles.concat (findMatches (false));
			
			for (tile in matchedTiles) {
				
				removeTile (tile.row, tile.column);
				
			}
			
			if (matchedTiles.length > 0) {
				
				Score.text = Std.string (currentScore);
				dropTiles ();
				
			}
			
		}
		
	}
	
	
}