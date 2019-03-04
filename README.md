CS3217 Problem Set 5
==

**Name:** Ang Jie Liang

**Matric No:** A0149293W

**Tutor:** Ang Jie Liang

## Tips

1. CS3217's Gitbook is at https://www.gitbook.com/book/cs3217/problem-sets/details. Do visit the Gitbook often, as it contains all things relevant to CS3217. You can also ask questions related to CS3217 there.
2. Take a look at `.gitignore`. It contains rules that ignores the changes in certain files when committing an Xcode project to revision control. (This is taken from https://github.com/github/gitignore/blob/master/Swift.gitignore).
3. A Swiftlint configuration file is provided for you. It is recommended for you to use Swiftlint and follow this configuration. Keep in mind that, ultimately, this tool is only a guideline; some exceptions may be made as long as code quality is not compromised.
4. Do not burn out. Have fun!

### Rules of Your Game

Clear all the ***coloured bubbles*** and win the game!

After the launched bubble has found a resting position, if it is connected to other identically-colored bubbles and they form a group of 3 or more, that connected group of bubbles is removed from the arena.

After identically-colored bubbles are removed, if there are bubbles that are not connected to the bubbles on the top wall, they will be dropped too.

***!!Special bubbles!!***
* **Indestructible Bubble** - Cannot be removed through connecting with adjacent bubbles of the same color. They have to be removed by falling out of the screen.
* **Lightning Bubble** - Removes all bubbles in the same row as it. All hanging bubbles thereafter should also be removed.
* **Bomb Bubble** - Removes all bubbles adjacent to it.
* **Star Bubble** - When a colored bubble comes into contact with the star bubble, all bubbles of that color in the arena will be removed.

***Score system***
Obtained when popped or dropped.
* Colored bubbles - 30 points
* Indestructible bubbles - 20 points
* Special bubbles (excluding indestructible) - 10 points

***Limited number of shots***
50 bubbles to shoot per round. 
You lose if you run out of bubbles to shoot and had yet to clear the game!.

***Game Over***
If you reach the 14th row, you lose automatically! :(

***Two Player Mode***
If you run out of bubbles to shoot, the game ends when the other player clears the game or also run out of bubbles!
Player with the highest score wins!
You can interfer as the bubbles you shoot will collide with the opposite players' bubble!


### Problem 1: Cannon Direction

**Single Player**
Tap to shoot bubble.
Pan to aim, and release to shoot bubble.

**Multiplayer**
**Player 1**
Tap at left side of screen to shoot bubble.
Pan at left side of screen to aim, and release at left side of screen to shoot bubble. Panning to area beyond left screen cancels aim.
**Player 2**
Tap at right side of screen to shoot bubble.
Pan at right side of screen to aim, and release at right side of screen to shoot bubble. Panning to area beyond right screen cancels aim.

### Problem 2: Upcoming Bubbles

Upcoming bubbles will be a random colored bubble of **ONLY** the **present stationary colored bubbles** in the game. If any loaded upcoming bubbles happened to be of a color which is removed midway through the game, the bubble will be updated to a suitable color, which is a color present in the game. This ensures that the user will not "add" new color to the game if he/she have already cleared the color, to save the number of bubbles he/she have.

### Problem 3: Integration

In PS3, I explained how I used an array of `BubbleType` to store my data via object archive. Users can then load previous maps to edit in the level selection stage. Now, to integrate the game engine with the designed level, the same data is passed to the game engine for initialising. For PS5, additional data is also included, such as the grid layout of the game (hexagonal or rectangular), and whether the game is in multiplayer mode (this is not stored locally! user get to decide whether to play as single or multiplayer when selecting level).

Thus, when the ***Start*** button is pressed, the `GameSet` object, containing only important data mentioned earlier (array of `BubbleType` and grid layout), is passed from the `LevelDesignerViewController`to the `GameViewController` via segue. The `GameViewController` then initialises the `gameEngine` based on the `GameSet` object, and also set up the cannons based on the single / multiplayer mode chosen.

This method is simple, as all the necessary data is passed when the new view controller is presented. An alternative would be to follow the `LevelDesignerViewController` steps in loading data, which is to retrieve the game information from the *Documents* directory, this reduces the amount of data required to transfer via segue. However, since information such as the player mode is not stored in the *Documents* directory, this information would still have to be somehow passed to the game controller. Thus, it will be much more convenient and simpler to just pass all the information at one go through one means (segue). 

With the same data format used for storing the bubbles maps locally, and initialising the game engine, this simplifies the integration of the game engine and level designer, and also further facilitates the integration of level selection with game engine. As the level selection view controller can simply retrieve the data from the documents directory, and pass it on just like the level designer view controller!

### Problem 4.4

The general strategy for handling special bubbles is simple and straightforward, explained in two steps:
1) When inserting a new bubble, remove surrounding ***power bubbles***
2) When removing a bubble, check if it is special. If it is, trigger the special power.

The method is simple, and is also efficient and elegant logic-wise. The simple two steps ensure that the chaining of special bubble is handled properly without much change needed for the code.

An alternative could be to calculate all of the the bubbles to be removed when a new bubble is inserted, add the calculated bubbles to set, and then iterate and remove. The calculation and steps required for this alternative is slightly more tedious. My two step logic does the job efficiently and cleanly.

### Problem 7: Class Diagram

![alt text](https://github.com/cs3217-1819/problem-set-5-jieliangang/blob/master/class-diagram.png "Class Diagram")

***Start Screen***

***StartViewController***

Initial view controller of the game. Leads to `LevelDesignerViewController` or `LevelSelectionViewController` via segue based on user choice.

***Level Designer***

***LevelDesignerViewController***

The main controller of Level Designer. Handles all actions in the Palette Area at the bottom of the view, including selecting of bubble type and saving, loading and resetting buttons, and selection of grid and single/multiplayer mode. Sends instruction to `BubbleGridViewController` to handle model related actions. Conforms to `LoadDelegate` in order to receive data from `PopOverViewController`. Conforms to `SegmentedControlDelegate` to update the highlighting of the grid segmented control after loading data. Passes game information including player mode to `GameViewController` via segue to start game.

***BubbleGridViewController***

Child controller of `LevelDesignerViewController`. Handles all actions related to `UICollectionView`, the bubble grid, including gesture recognizers and updating the model. Also in charge of persistence data abd storing and loading of model data.

***PopOverViewController***

Handles the `UITableView` during selection of levels to be loaded. Passes data (level name and grid layout) to `LevelDesignerViewController` via delegation (`LoadDelegate`).

***GameBubbleSet***

The main model of Level Designer, containing an array of all `GameBubbles` in the grid in order from left to right, top to bottom. All `GameBubbles` are indexed and contained in an array.

***StorageManager***

A utility class containing static methods related to storing and retrieving the model data. 

***Level Selection***

* ***LevelSelectionViewController***
Handles displaying the existing levels with grid picture and level names. Passes game information including player mode to `GameViewController` via segue to start game.

***Game***

***BubbleObject***

`BubbleObject` represents the game bubbles in the game. It contains a `RigidBody`, its physical representation in the `PhysicsEngine`, and a `BubbleType` which describes the type of the bubble.

***GameEngine***

`GameEngine` handles the game logic, including collision resolution.

 For efficient handling and rendering of game objects state and animation, internal representations of the game objects are categorized to three sections:
 
 - StationaryBubbleObjects: Represents the bubble on the isometric grid. 
 - MovingBubbleObjects: Represents bubble which are being shot
 - DroppingBubbleObjects: Represents disconnected bubble which are dropping from the grid for animation purposes.

 It contains a method `shootBubble()`, which addeds a moving bubble to the game. 

 It then handles all the gameplay logic, including snapping bubbles to the grid cells, removing connected bubbles of the same color, and removal of unattached and disconnected bubbles. It also handles collision resolution for the different `BubbleObject`, as the different objects (stationary, moving and dropping) reacts differently when colliding with each other or with the wall.

 The animation for falling bubbles are handled by the game engine, as its position mid dropping is controlled by the `PhysicsEngine`, which allows gravity to act on falling bubbles.

 To inform the `GameViewController` to reload the collection view cells or indicate game over, `GameEngine` pass data to the `GameViewController` via the `NotificationCenter`.

 `GameEngine` also contains the ***Model*** of the game, as it contains all of the different `BubbleObject` in the game, the renderer can display the game objects based on the `BubbleObject`s contained in `GameEngine`.

 ***GameViewController***

`GameViewController` is mainly in charge of handling user inputs and rendering the game objects. 

It handles tap gestures and pan gestures from the user, which provides the inputs required to launch the bubble.

It also sets up the game loop, which tells the game engine to use the physics engine to update the game objects' physical property (position and velocity) then handle the resulting interaction, and then call the `render()` method to redraw the objects on the screen. The resulting interactions would also invoke `reloadCellAt` which updates the bubble grid of the game.



### Problem 8: Testing

***Black-box testing***
* Test Home Page
	* If **Design** is clicked
		* **Should** proceed to Level Designer
	* If **Play** is clicked
		* **Should** proceed to Level Selection

* Test level designer
	* When the game starts up:
		* The bubble grid **should** be empty / only filled with empty bubbles and in default hexagonal grid
		* Level name **should** above the palette should be empty
		* All bubbles and erase button on the palette area should be unselected and translucent
	* For every bubble and erase button on the palette area
		* If the button is unselected:
			* If all buttons are unselected:
				* Tapping on it **should** make the button fully opaque and selected
				* Long pressing on it without moving **should** make the button fully opaque when released
				* Long pressing on it and pan out of the button **should** not do anything when released
				* Long pressing on it and pan out, then pan back to the button **should** make the button fully opaque when released
			* If another button is selected:
				* Tapping on it **should** make the button fully opaque and the other button translucent 
				* Long pressing on it without moving **should** make the button fully opaque when released and the other button translucent 
				* Long pressing on it and pan out of the button **should** not do anything when released and the other button remaining selected and opaque
				* Long pressing on it and pan out, then pan back to the button **should** make the button fully opaque when released and the other button translucent 
		* If the button is selected:
			* Tapping on it **should** make the button translucent and selected
			* Long pressing on it without moving **should** make the button translucent when released 
			* Long pressing on it and pan out of the button **should** not do anything when released 
			* Long pressing on it and pan out, then pan back to the button **should** make the button translucent when released 
	* For every cell in the game area:
		* Suppose that a colored bubble is selected from the palette:
			* If the cell is empty:
				* Tapping on it **should** display the selected bubble
				* Dragging across it **should** display the selected bubble
				* Dragging from it **should** display the selected bubble
				* Long pressing **should** not do anything
				* Long press then drag accross it **should** not do anything
				* Long press then drag from it **should** not do anything
			* If the cell is not empty:
				* Tapping on it **should** display the selected bubble
				* Dragging across it **should** display the selected bubble
				* Dragging from it **should** display the selected bubble
				* Long pressing **should** remove the bubble
				* Long press then drag accross it **should** remove the bubble
				* Long press then drag from it **should** remove the bubble
		* Suppose that a special button is selected from the palette:
		* If the cell is empty:
				* Tapping on it **should** display the selected bubble
				* Dragging across it **should** display the selected bubble
				* Dragging from it **should** display the selected bubble
				* Long pressing **should** not do anything
				* Long press then drag accross it **should** not do anything
				* Long press then drag from it **should** not do anything
			* If the cell is not empty:
				* Tapping on it **should** not do anything
				* Dragging across it **should** display the selected bubble
				* Dragging from it **should** display the selected bubble
				* Long pressing **should** remove the bubble
				* Long press then drag accross it **should** remove the bubble
				* Long press then drag from it **should** remove the bubble
		* Suppose that the erase button is selected from the palette:
			* If the cell is empty:
				* Tapping on it **should** not do anything
				* Dragging across it **should** not do anything
				* Dragging from it **should** not do anything
				* Long pressing **should** not do anything
				* Long press then drag accross it **should** not do anything
				* Long press then drag from it **should** not do anything
			* If the cell is not empty:
				* Tapping on it **should** remove the bubble
				* Dragging across it **should** remove the bubble
				* Dragging from it **should** remove the bubble
				* Long pressing **should** remove the bubble
				* Long press then drag accross it **should** remove the bubble
				* Long press then drag from it **should** remove the bubble
		* Suppose that nothing is selected from the palette: 
			Definition of *Rotation*: Yellow bubble become red, red become blue, blue become green, green become yellow
			* If the cell is not colored:
				* Tapping on it **should** not do anything
				* Dragging across it **should** not do anything
				* Dragging from it **should** not do anything
				* Long pressing **should** not do anything
				* Long press then drag accross it **should** not do anything
				* Long press then drag from it **should** not do anything
			* If the cell is colored:
				* Tapping on it **should** rotate the bubble
				* Dragging across it **should** not do anything
				* Dragging from it **should** not do anything
				* Long pressing **should** remove the bubble
				* Long press then drag accross it **should** remove the bubble
				* Long press then drag from it **should** remove the bubble
	* If *Hexagonal* is selected
		* The grid **should** be hexagonal
		* If *Rectangular* is selected after *Hexagonal*
			* The bubbles in even rows **should** remain the same
			* The bubbles in odd rows **should** be shifted to the left
	* If *Rectangular* is selected
		* The grid **should** be rectangular
		* If *Hexagonal* is selected after *Rectangular*
			* The bubbles in even rows **should** remain the same
			* The first 11 bubbles in odd rows **should** remain the same, the last one is removed
	* If *Single Player* is selected
		* Single Player should be highlighted
	* If *Multi Player* is selected
		* Multi player should be highlighted
	* If *Reset* is tapped or panned from and back
		* If the bubble grid is empty:
			* **Nothing** will happen
		* If the bubble grid is partitially or completely filled
			* All bubbles on the cell grid **should** be removed
		* If no bubble and erase button is selected on palette area
			* The bubble and erase button **should** remain unselected
		* If a bubble and erase button is selected on palette area
			* The selected bubble or erase button **should** remain selected
		* If the level name is present above the palette area
			* The level name **should** disappear
		* If the level name is absent above the palette area
			* The level name **should** remain absent
	* If *Back* is selected
		* **should** return to homepage
	* If *Start* is selected
		* **should** proceed to game with loaded bubble map and grid
* Test implementation of file operations
	* If *Save* is tapped or panned from and back
		* An alert **should** pop up requesting for level name
		* Suppose no level was previously loaded
			* The text input field **should** remain empty
			* If empty string is entered then tap Save
				* An alert **should** pop up indicating "Invalid Name"
				* The level **should** not be saved and not listed in list when click Load
			* If name exceeding 30 characters is entered then tap Save
				* An alert **should** pop up indicating "Invalid Name"
				* The level **should** not be saved and not listed in list when click Load
			* If name entered is same with a name previously saved then tap Save
				* An alert **should** pop up indicating "Level with same name found."
				* If Overwrite is clicked
					* The level **should** be saved and listed in list when click Load
					* The level loaded **should** be of the latest updated and saved version
					* The level name above the palette area **should** be updated to the recently saved name
					* The cell grid **should** remain the same
				* If Cancel is clicked
					* The level **should** not be saved but still listed in list when click Load
					* The level loaded from the load list **should** be of the old version
					* The level name above the palette area **should** remain the same
					* The cell grid **should** remain the same
			* If name entered is same with a name previously saved but with appended whitespaces then tap Save
				* Result should be same with "If name entered is same with a name previously saved"
			* If name entered is unique then tap Save
				* The level **should** be saved and listed in list when click Load
				* The level name above the palette area **should** be updated to the recently saved name
				* The cell grid **should** remain the same
			* If tap cancel
				* The level **should** not be saved
				* The level name above the palette area **should** remain the same 
				* The cell grid **should** remain the same
		* Suppose a level was previously loaded
			* The text input field **should** contain the previously loaded level name
			* Other result **should** be the same with "Suppose no level was previously loaded"
	* If *Load* is tapped or panned from and back
		* A list of saved levels **should** appear in the list above the Load text
		* For any row in the table above load
			* If the row is empty
				* Tapping on it **should** not do anything
				* Swiping on it **should** not do anything
			* If the row has a level name
				* Tapping on it **should** highlight the selected row
				* Tapping on it **should** load the corresponding on the game level at the background
				* Tapping on it **should** load the corresponding grid layout
				* Tapping on it **should** update the level name above the palette area
				* Swiping on it fully to the right **should** delete the level and remove it from the list
				* Swiping on it **should** not do anything to the level name above the palette area
		* Scrolling the list **should** list the levels above or below if present
		* Tapping anywhere outside the list **should** dismiss the list
	* Quit the app and reopen the app
		* If *Load* is tapped or panned from and back
			* Any saved levels should remain in the level list
			* Any deleted levels should not be in the level list

* Test launching bubbles and cannon
	* Designed region for different players:
		* **Single Player**: Entire screen above top of bubble to launch
		* **Multi Player - Player One**: Similar to Single Player but limited to left half of screen
		* **Multi Player - Player Two**: Similar to Single Player but limited to right half of screen
	* If tap on region below the top of the launch bubble
		* The bubble **should not** launch
	* If tap on region above the top of the launch bubble
		* The bubble **should** move in the direction of the tap
		* The bubble **should** move from the initial launch position
		* The bubble **should** move in constant velocity
		* The cannon **should** rotate to tap location
	* If pan anywhere and then release on region below the top of the launch bubble
		* The bubble **should not** launch
		* The cannon **should** rotate to last pan location
		* Aim assist **should** initially  appear then disappear when region below is reached
	* If pan anywhere and then release on region above the top of the launch bubble
		* The bubble **should** move in the direction of the tap
		* The bubble **should** move from the initial launch position
		* The bubble **should** move in constant velocity
		* Aim assist **should** appear initially then disappear when released
		* The cannon **should** rotate to pan location
* Test collision between two bubbles
	* If launched bubble collides with a launched bubble
		* If launched by the same player
			* Both bubbles **should** resume their movements as usual
		* If launched by different player
			* Bobth bubbles **should** collide elastically
	* If launched bubble collides with a falling bubble
		* Both bubbles **should** resume their movements as usual
 	* If launched bubble collides with a stationary bubble on the grid
		* The launched bubble **should** stop and snap to the closest available empty cell on the bubble grid
		* The stationary bubble **should** first remain stationary
		* If no surrounding bubbles are special
			* If the initially launched bubble is connected to two or more identically-colored bubble
				* The group of identically-colored bubble **should** disappear
				* If there exists unconnected bubbles from the top wall after the bubbles are removed
					* The unconnected bubbles from the top wall **should** drop and fall
				* If no unconnected bubbles from the top wall after the bubbles are removed
					* The remaining bubbles **should** remain stationary and not fall
			* If no group of 3 or more identically-colored bubbles are formed from the initially launched bubble
				* All bubbles in the grid **should** remain stationary
				* **No** bubbles in the grid **should** drop and fall
	* If dropping bubble collides with launched bubble
		* Both bubbles **should** resume their movements as usual
	* If dropping bubble collides with falling bubble	
		* Both bubbles **should** resume their movements as usual
	* If dropping bubble collides with stationary bubble on the grid
		* Both bubbles **should** resume their movements as usual
* Test collisions between a bubble and a screen edge
	* If launched bubble collides with the side wall
		* The bubble **should** reflect and change the moving direction
	* If launched bubble collides with the top wall
		* The launched bubble **should** stop and snap to the closest available empty cell on the bubble grid
		* The stationary bubble **should** first remain stationary
		* If no surrounding bubbles are specia
			* If the initially launched bubble is connected to two or more identically-colored bubble
				* The group of identically-colored bubble **should** disappear
				* If there exists unconnected bubbles from the top wall after the bubbles are removed
					* The unconnected bubbles from the top wall **should** drop and fall
				* If no unconnected bubbles from the top wall after the bubbles are removed
					* The remaining bubbles **should** remain stationary and not fall
			* If no group of 3 or more identically-colored bubbles are formed from the initially launched bubble
				* All bubbles in the grid **should** remain stationary
				* **No** bubbles in the grid **should** drop and fall
	* If moving bubble collides with the bottom wall in multiplayer mode
		* The bubble **should** be removed
	* If dropping bubble collides with the side wall
		* The bubble **should** reflect and change the moving direction
	* If dropping bubble collides with the top wall
		* The bubble **should** reflect and change the moving direction
	* If dropping bubble collides with the bottom wall
		* The bubble **should** be removed
* Test special power bubbles
	* If moving object connects and is adjacent to special power bubble(s)
		* If special power bubble is indestructible
			* The special bubble **should** remain stationary 
		* If special power bubble is lightning
			* All bubbles in the row of the lightning bubble **should** be removed
		* If special power bubble is *bomb*
			* All bubbles surrounding the bomb bubble **should** be removed
		* If special power bubble is *star*
			* All bubbles of the same color with the added object **should** be removed
	* If a special bubble is removed due to chaining
		* If special power bubble is indestructible
			* The special bubble **should** be removed
		* If special power bubble is lightning
			* All bubbles in the row of the lightning bubble **should** be removed
		* If special power bubble is *bomb*
			* All bubbles surrounding the bomb bubble **should** be removed
		* If special power bubble is *star*
			* The special bubble **should** be removed with no special other effect
* Test game flow in game level
	* If *Back* is selected
		* If *Level Designer* was previously used
			* Level Designer **should** be returned to
		* If *Level Selection* was previously used
			* Level Designer **should** be returned to
* Test level selection
	* Screenshots and names of respective levels **should** be loaded
	* If a level is selected
		* The level **should** be loaded and based on *Multiplayer Mode* selected


***Glass-box testing***
* GameBubbleSet
	* `init(numberOfRows: Int)`:
		* if numberOfRows is positive integer: **should** expect `bubbles` array to contain number of `EmptyBubble` corresponding to numberOfRows
		* if numberOfRows is negative: `bubble` **should** expect `bubbles` to remain empty
	* `bubble(at index: Int)`:
		* if index is within bounds of `bubbles`: **should** expect to return `GameBubble` at index 
		* if index is out of bound of `bubbles`: **should** expect to do nothing
	* `removeBubble(at index: Int)`:
		* if index is within bounds of `bubbles`: **should** expect to `GameBubble` at index to be set as `EmptyBubble`
		* if index is out of bound of `bubbles`: **should** expect to return `nil`
	* `updateBubble(at index: Int, to type: BubbleType):`
		* if index is within bounds of `bubbles`: **should** expect to set `GameBubble` at index to `EmptyBubble`
		* if index is out of bound of `bubbles`: **should** expect to do nothing
	* `cycleBubble(at index: Int)`:
		* if index is within bounds of `bubbles`:
			* if bubble at index is `ColorBubble`:  **should** expect to set bubble at index to next corresponding alternate type `ColorBubble`
			* if bubble at index is not `ColorBubble`:  **should** expect to set bubble at same bubble
		* if index is out of bound of `bubbles`: **should** expect to do nothing
	* `reset()`:
		* **should** expect all elements of `bubbles` to be `EmptyBubble`
	* `numberOfBubbles`:
		* **should** expect to be zero if `bubbles` is empty
		* **should** expect to be size of `bubbles`
	* `typesLeft`:
		* **should** return unique colored types of elements in `bubbles`
	* `updateGridLayout`:
		* if `isHexagonal` is same with input parameter
			* **should** do nothing if existing `isHexagonal` is the same
		* else
			* if `toHex` is true
				* **should** add padding to the array at the end of odd rows to fit rectangular grid
			* if `toHex` is false
				* **should** remove padding from arrays which are elements at end of odd rows to fit hexagonal grid

* `BubbleType`
	* `next()`
		* if `bubbleType` is of color: **should** expect to return next corresponding `BubbleType`
		* if `bubbleType` is `emptyBubble`: **should** expect to return `EmptyBubble`
	* `hasPower()`
		* if `bubbleType` is special with power: **should** expect to return true
		* else: **should** expect to return false
	* `isColor()`
		* if `bubbleType` is of color **should** expect to return true
		* else: **should** expect to return false


* `LevelDesignerViewController`
	* `currentBubble`:
		* if no button is selected: **should** expect nil
		* if button is selected: **should** expect to be selected `UIButton`
	* `bubblePressed`:
		* if sender is `currentBubble`: **should** expect `currentBubble` to be nil
		* if sender is not `currentBubble`" **should** expect `currentBubble` to be updated as sender
	* `resetButtonPressed`:
		* **should** expect `currentLevel.text` to be empty
		* **should** expect `game` in `BubbleViewGridViewController` to be all `EmptyBubble`
	* `saveButtonPressed`:
		* if save successful: **should** expect `currentLevel.text` to be updated
	* `onNameSelected`:
		* if name is valid: 
			* **should** expect `game` to be updated
			* **should** expect `currentLevel.text` to be updated
		* if name is invalid: **should** expect `StorageError.cannotLoad` to be thrown
	* `playersOptionSelected`
		* if Single Player is selected: **should** expect `multiplayerMode` to be false
		* if Multi Player is selected: **should** expect `multiplayerMode` to be true

* `BubbleGridViewController`
	* `tap`:
		* **should** expect `location` to be of tapped CGPoint
		* **should** expect `bubbleType` to be updated to `currentSelectedType`
		* if `bubbleType` is nil: **should** expect cell at specified location to be rotated
		* if `bubbleType` is not nil: **should** expect cell at specificed location to be updated to corresponding `GameBubble`
	* `pan`: 
		* if `type` is nil: **should** expect nothing to happen
		* if `type` is not nil:
			* if sender.state is .began or .changed:
				* **should** expect `location` to be of panned CGPoint
				* **should** expect cell at specificed location to be updated to corresponding `GameBubble`
	* `longPress`: 
		* if sender.state is .began or .changed:
			* **should** expect `location` to be of panned CGPoint
			* **should** expect cell at specificed location to be updated to `EmptyBubble`
	* `loadDataFrom`:
		* if name is valid: **should** expect `game` to be updated
		* if name is invalid: **should** expect `StorageError.cannotLoad` to be thrown
	* `save`:
		* if `game` is corrupted: **should** expect `StorageError.cannotSave` to be thrown
	* `reset`:
		* **should** expect `game` to be all `EmptyBuble`
	* `updateGridLayout`
		* if `isHex` is true: **should** expect `bubbleArea.collectionViewLayout` to be `AlternatingBubbleLayout`
		* if `isHex` is false: **should** expect `bubbleArea.collectionViewLayout` to be `RectangularGridLayout`

* `BubbleObject`
	* `init(type: BubbleType, position: Vector2, shape: Shape)`
		* `type` **should** be updated
		* `body` **should** be created with corresponding `position` and `shape`, and zero `velocity` and `acceleration`
	* 	`init(type: BubbleType, position: Vector2, velocity: Vector2, shape: Shape)`
		* `type` **should** be updated
		* `body` **should** be created with corresponding `position`, `velocity` and `shape`, and zero `acceleration`

* `LevelSelectionViewController`
	* `levelData`: **should** expect to be list of exisiting file names in sorted order
	* `playerSelection`:
		* if Single Player is selected: **should** expect `multiplayer` to be false
		* if Multi Player is selected: **should** expect `multiplayer` to be true
* `LevelCell`
	* `configure`:
		* **should** expect `screenshot.image` and `levelName.text` to be updated


* `GameEngine`
	* `init`
		* `stationaryBubbleObjects` **should** only contain objects that are connected in game
		* `movingBubbleObjects` **should** be empty
		* `droppingBubbleObjects` **should** be empty
	* `bubblesLeft`
		* **should** return remaining `BubbleType` of stationary bubbles left in `stationaryBubbleObjects`
	* `randomBubbleType()`:
		* `should` return a random `BubbleType` of elements in `bubblesLeft`
	* `shootBubble`
		* size of `movingBubbleObjects` **should** increment
		* inspect new `BubbleObject` in `stationaryBubbleObject`, `body` of the new `BubbleObject` should have `position` equal to `originLocation`, and correct initial `velocity`, and type equal to `currentBubbleType`
* `PlayerType`
	* `otherPlayer()`
		* if is `.one` or `.two`: **should** return `.two.` or `.one` respectively
		* else: **should** return self
* `GameViewController`
	* `game`
		* **should** be object passed from previous VC via segue
	* `backButtonPressed`
		* **should** invalidate `timer` and dismiss view controller
* `Player`
	* `enable`
		* **should** expect `tapGestureRecognizer` to be enabled
		* **should** expect `panGestureRecognizer` to be enabled
		* **should** expect `radius` of `trajectory` to be enabled
	* `disable`
		* **should** expect `mainView` to be hidden
		* **should** expect `tapGestureRecognizer` to be disabled
		* **should** expect `panGestureRecognizer` to be disabled
	* `decrement()`
		* **should** expect `bubblesLeft` of `bubblesLeft` to decrement
	* `loadBubble`
		* **should** expect `currentBubbleType` to be updated to value of `nextBubbleType`
		* **should** expect `nextBubbleType` to be updated to value of `secondNextBubbleType`
		* **should** expect `secondNextBubbleType` to be updated to value of `nextType`
	* `updateLoadedBubbles` 
		* if `set` does not contain `currentBubbleType`, `nextBubbleType` or `secondNextBubbleType`
			* **should** expect to update respective types to a random type within `set`
	* `resetLoadedBubbles`
		* **should** expect `currentBubbleType`, `nextBubbleType` and `secondNextBubbleType` to be updated to a random value wthin `set`
	* `pauseLoadedBubbles`
		* **should** expect `currentBubbleType`, `nextBubbleType` and `secondNextBubbleType` to be `BubbleType.indestructible`



### Problem 9: The Bells & Whistles

Features implemented

* Added ***Paper theme*** to the game, included changes to the bubbles, background image, and user interface
* Bubbles drop in accordance to in-game gravity
* Cannons have limited number (50) of shots in the game
	* In single player mode, if all shots are used up and game is not cleared, player loses
	* In multiplayer mode, if all shots are used up, you will have to watch the other player play!
* Aim assist / cannon trajectory added to the game, which is activated when the cannon is panned
* Score is added to the game
	* Colored and indestructible removed ***OR*** drops to ground
	* Corresponds to different teammates
	* Score added in a nice counting manner!
* End game screen added
	* Player with highest point wins!
	* Score of winner displayed on screen

### Problem 10: Final Reflection

Overall
