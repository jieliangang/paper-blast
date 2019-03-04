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

In PS3, I explained how I used an array of `BubbleType` to store my data as an object archive. Users can then load previous maps to edit in the level selection stage. Now, to integrate the game engine with the designed level, the same data is passed to the game engine for initialising. Additional data is also included, such as the grid layout of the game (hexagonal or rectangular), and whether the game is in multiplayer mode (this is not stored locally! user get to decide whether to play as single or multiplayer when selecting level).

Thus, when the ***Start*** button is pressed, the `GameSet` object, containing only important data mentioned earlier, is passed from the `LevelDesignerViewController`to the `GameViewController` via segue. The `GameViewController` then initialises the `gameEngine` based on the `GameSet` object, and also set up the cannons based on the single / multiplayer mode chosen.

This method is simple, as all the necessary is passed when the new view controller is presented. An alternative would be to follow the `LevelDesignerViewController` step in loading data, which is to retrieve the game information from the *Documents* directory, this reduces the amount of data required to transfer via segue. However, since information such as the player mode is not stored in the *Documents* directory, this information would still have to be somehow passed to the game controller. Thus, it will be much more convenient and simpler to just pass all the information at one go through one means. 

### Problem 4.4

The general strategy for handling special bubbles is simple and straightforward, explained in two steps:
1) When inserting a new bubble, remove surrounding ***power bubbles***
2) When removing a bubble, check if it is special. If it is, trigger the special power.

The method is simple, and is also efficient and elegant logic-wise. The simple two steps ensure that the chaining of special bubble is handled properly without much change needed for the code.

An alternative could be to calculate all of the the bubbles to be removed when a new bubble is inserted, add the calculated bubbles to set, and then iterate and remove. The calculation and steps required for this alternative is rather tedious. My two step logic does the job efficiently and cleanly. 

### Problem 7: Class Diagram

Please save your diagram as `class-diagram.png` in the root directory of the repository and show it here using the correct syntax of [GitHub Flavored Markdown](https://github.github.com/gfm/).

### Problem 8: Testing

***Black-box testing***
* Test level designer
	* When the game starts up:
		* The bubble grid ***should*** be empty / only filled with empty bubbles
		* Level name ***should*** above the palette should be empty
		* All bubbles and erase button on the palette area should be unselected and translucent
	* For every bubble and erase button on the palette area
		* If the button is unselected:
			* If all buttons are unselected:
				* Tapping on it ***should*** make the button fully opaque and selected
				* Long pressing on it without moving ***should*** make the button fully opaque when released
				* Long pressing on it and pan out of the button ***should*** not do anything when released
				* Long pressing on it and pan out, then pan back to the button ***should*** make the button fully opaque when released
			* If another button is selected:
				* Tapping on it ***should*** make the button fully opaque and the other button translucent 
				* Long pressing on it without moving ***should*** make the button fully opaque when released and the other button translucent 
				* Long pressing on it and pan out of the button ***should*** not do anything when released and the other button remaining selected and opaque
				* Long pressing on it and pan out, then pan back to the button ***should*** make the button fully opaque when released and the other button translucent 
		* If the button is selected:
			* Tapping on it ***should*** make the button translucent and selected
			* Long pressing on it without moving ***should*** make the button translucent when released 
			* Long pressing on it and pan out of the button ***should*** not do anything when released 
			* Long pressing on it and pan out, then pan back to the button ***should*** make the button translucent when released 
	* For every cell in the game area:
		* Suppose that a colored bubble is selected from the palette:
			* If the cell is empty:
				* Tapping on it ***should*** display the selected bubble
				* Dragging across it ***should*** display the selected bubble
				* Dragging from it ***should*** display the selected bubble
				* Long pressing ***should*** not do anything
				* Long press then drag accross it ***should*** not do anything
				* Long press then drag from it ***should*** not do anything
			* If the cell is not empty:
				* Tapping on it ***should*** display the selected bubble
				* Dragging across it ***should*** display the selected bubble
				* Dragging from it ***should*** display the selected bubble
				* Long pressing ***should*** remove the bubble
				* Long press then drag accross it ***should*** remove the bubble
				* Long press then drag from it ***should*** remove the bubble
		* Suppose that a special button is selected from the palette:
		* If the cell is empty:
				* Tapping on it ***should*** display the selected bubble
				* Dragging across it ***should*** display the selected bubble
				* Dragging from it ***should*** display the selected bubble
				* Long pressing ***should*** not do anything
				* Long press then drag accross it ***should*** not do anything
				* Long press then drag from it ***should*** not do anything
			* If the cell is not empty:
				* Tapping on it ***should*** not do anything
				* Dragging across it ***should*** display the selected bubble
				* Dragging from it ***should*** display the selected bubble
				* Long pressing ***should*** remove the bubble
				* Long press then drag accross it ***should*** remove the bubble
				* Long press then drag from it ***should*** remove the bubble
		* Suppose that the erase button is selected from the palette:
			* If the cell is empty:
				* Tapping on it ***should*** not do anything
				* Dragging across it ***should*** not do anything
				* Dragging from it ***should*** not do anything
				* Long pressing ***should*** not do anything
				* Long press then drag accross it ***should*** not do anything
				* Long press then drag from it ***should*** not do anything
			* If the cell is not empty:
				* Tapping on it ***should*** remove the bubble
				* Dragging across it ***should*** remove the bubble
				* Dragging from it ***should*** remove the bubble
				* Long pressing ***should*** remove the bubble
				* Long press then drag accross it ***should*** remove the bubble
				* Long press then drag from it ***should*** remove the bubble
		* Suppose that nothing is selected from the palette: 
			Definition of *Rotation*: Yellow bubble become red, red become blue, blue become green, green become yellow
			* If the cell is empty:
				* Tapping on it ***should*** not do anything
				* Dragging across it ***should*** not do anything
				* Dragging from it ***should*** not do anything
				* Long pressing ***should*** not do anything
				* Long press then drag accross it ***should*** not do anything
				* Long press then drag from it ***should*** not do anything
			* If the cell is not empty:
				* Tapping on it ***should*** rotate the bubble
				* Dragging across it ***should*** not do anything
				* Dragging from it ***should*** not do anything
				* Long pressing ***should*** remove the bubble
				* Long press then drag accross it ***should*** remove the bubble
				* Long press then drag from it ***should*** remove the bubble
	* If *Hexagonal* is selected
		* The grid ***should*** be hexagonal
		* If *Rectangular* is selected from *Hexagonal*
			* The bubbles in even rows ***should*** remain the same
			* The bubbles in odd rows ***should*** be shifted to the left
	* If *Rectangular* is selected
		* The grid ***should*** be rectangular
		* If *Hexagonal* is selected from *Rectangular*
			* The bubbles in even rows ***should*** remain the same
			* The first 11 bubbles in odd rows ***should*** remain the same, last one is removed
	* If *Reset* is tapped or panned from and back
		* If the bubble grid is empty:
			* *Nothing* will happen
		* If the bubble grid is partitially or completely filled
			* All bubbles on the cell grid ***should*** be removed
		* If no bubble and erase button is selected on palette area
			* The bubble and erase button ***should*** remain unselected
		* If a bubble and erase button is selected on palette area
			* The selected bubble or erase button ***should*** remain selected
		* If the level name is present above the palette area
			* The level name ***should*** disappear
		* If the level name is absent above the palette area
			* The level name ***should*** remain absent
	* If *Back* is selected
		* ***Should*** return to homepage
	* If *Start* is selected
		* ***Should*** proceed to game with loaded bubble map
* Test implementation of file operations
	* If *Save* is tapped or panned from and back
		* An alert ***should*** pop up requesting for level name
		* Suppose no level was previously loaded
			* The text input field ***should*** remain empty
			* If empty string is entered then tap Save
				* An alert ***should*** pop up indicating "Invalid Name"
				* The level ***should*** not be saved and not listed in list when click Load
			* If name exceeding 30 characters is entered then tap Save
				* An alert ***should*** pop up indicating "Invalid Name"
				* The level ***should*** not be saved and not listed in list when click Load
			* If name entered is same with a name previously saved then tap Save
				* An alert ***should*** pop up indicating "Level with same name found."
				* If Overwrite is clicked
					* The level ***should*** be saved and listed in list when click Load
					* The level loaded ***should*** be of the latest updated and saved version
					* The level name above the palette area ***should*** be updated to the recently saved name
					* The cell grid ***should*** remain the same
				* If Cancel is clicked
					* The level ***should*** not be saved but still listed in list when click Load
					* The level loaded from the load list ***should*** be of the old version
					* The level name above the palette area ***should*** remain the same
					* The cell grid ***should*** remain the same
			* If name entered is same with a name previously saved but with appended whitespaces then tap Save
				* Result should be same with "If name entered is same with a name previously saved"
			* If name entered is unique then tap Save
				* The level ***should*** be saved and listed in list when click Load
				* The level name above the palette area ***should*** be updated to the recently saved name
				* The cell grid ***should*** remain the same
			* If tap cancel
				* The level ***should*** not be saved
				* The level name above the palette area ***should*** remain the same 
				* The cell grid ***should*** remain the same
		* Suppose a level was previously loaded
			* The text input field ***should*** contain the previously loaded level name
			* Other result ***should*** be the same with "Suppose no level was previously loaded"
	* If *Load* is tapped or panned from and back
		* A list of saved levels ***should*** appear in the list above the Load text
		* For any row in the table above load
			* If the row is empty
				* Tapping on it ***should*** not do anything
				* Swiping on it ***should*** not do anything
			* If the row has a level name
				* Tapping on it ***should*** highlight the selected row
				* Tapping on it ***should*** load the corresponding on the game level at the background
				* Tapping on it ***should*** load the corresponding grid layout
				* Tapping on it ***should*** update the level name above the palette area
				* Swiping on it fully to the right ***should*** delete the level and remove it from the list
				* Swiping on it ***should*** not do anything to the level name above the palette area
		* Scrolling the list ***should*** list the levels above or below if present
		* Tapping anywhere outside the list ***should*** dismiss the list
	* If *Back* is selected
		* ***Should*** return to homepage
	* Quit the app and reopen the app
		* If *Load* is tapped or panned from and back
			* Any saved levels should remain in the level list
			* Any deleted levels should not be in the level list

* Test launching bubbles and cannon
	* If tap on region below the top of the launch bubble
		* The bubble **should not** launch
	* If tap on region above the top of the launch bubble
		* The bubble **should** move in the direction of the tap
		* The bubble **should** move from the initial launch position
		* The bubble **should** move in constant velocity
		* The cannon ***should*** rotate to tap location
	* If pan anywhere and then release on region below the top of the launch bubble
		*  The bubble **should not** launch
		*  Aim assist ***should*** appear
		* The cannon ***should*** rotate to pan location
	* If pan anywhere and then release on region above the top of the launch bubble
		* The bubble **should** move in the direction of the tap
		* The bubble **should** move from the initial launch position
		* The bubble **should** move in constant velocity
		* Aim assist ***should*** disappear
		* The cannon ***should*** rotate to pan location
* Test collision between two bubbles
	* If launched bubble collides with a launched bubble
		* If launched by the same player
			* Both bubbles **should** resume their movements as usual
		* If launched by different player
			* Bobth bubbles ***should*** collide elastically
	* If launched bubble collides with a falling bubble
		* Both bubbles **should** resume their movements as usual
 	* If launched bubble collides with a stationary bubble on the grid
		* The launched bubble **should** stop and snap to the closest available empty cell on the bubble grid
		* The stationary bubble **should** first remain stationary
		* If the initially launched bubble is connected to two or more identically-colored bubble
			* The group of identically-colored bubble **should** fade away
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
		* If the initially launched bubble is connected to two or more identically-colored bubble
			* The group of identically-colored bubble **should** fade away
			* If there exists unconnected bubbles from the top wall after the bubbles are removed
				* The unconnected bubbles from the top wall **should** drop and fall
			* If no unconnected bubbles from the top wall after the bubbles are removed
				* The remaining bubbles **should** remain stationary and not fall
		* If no group of 3 or more identically-colored bubbles are formed from the initially launched bubble
			* All bubbles in the grid **should** remain stationary
			* **No** bubbles in the grid **should** drop and fall
	* If dropping bubble collides with the side wall
		* The bubble **should** reflect and change the moving direction
	* If dropping bubble collides with the top wall
		* The bubble **should** reflect and change the moving direction
	* If dropping bubble collides with the bottom wall
		* The bubble **should** be removed
* Test special power bubbles
	* If moving object connects and is adjacent to special power bubble(s)
		* If special power bubble is indestructible
			* The special bubble ***should*** remain stationary
		* If special power bubble is lightning
			* All bubbles in the row of the lightning bubble ***should*** be removed
		* If special power bubble is *bomb*
			* All bubbles surrounding the bomb bubble ***should*** be removed
		* If special power bubble is *star*
			* All bubbles of the same color with the added object ***should*** be removed
	* If a special bubble is removed due to chaining
		* If special power bubble is indestructible
			* The special bubble ***should*** be removed
		* If special power bubble is lightning
			* All bubbles in the row of the lightning bubble ***should*** be removed
		* If special power bubble is *bomb*
			* All bubbles surrounding the bomb bubble ***should*** be removed
		* If special power bubble is *star*
			* The special bubble ***should*** be removed with no special effect
* Test game flow
	* If *Back* is selected
		* If *Level Designer* was previously used
			* Level Designer ***should*** be returned to
		* If *Level Selection* was previously used
			* Level Designer ***should*** be returned to
* Test level selection
	* Screenshots and names of respective levels ***should*** be loaded
	* If a level is selected
		* The level ***should*** be loaded based on *Multiplayer Mode* selected


***Glass-box testing***
* GameBubbleSet
	* init(numberOfRows: Int):
		* if numberOfRows is positive integer: ***should*** expect `bubbles` array to contain number of `EmptyBubble` corresponding to numberOfRows
		* if numberOfRows is negative: `bubble` ***should*** expect `bubbles` to remain empty
	* bubble(at index: Int):
		* if index is within bounds of `bubbles`: ***should*** expect to return `GameBubble` at index 
		* if index is out of bound of `bubbles`: ***should*** expect to do nothing
	* removeBubble(at index: Int):
		* if index is within bounds of `bubbles`: ***should*** expect to `GameBubble` at index to be set as `EmptyBubble`
		* if index is out of bound of `bubbles`: ***should*** expect to return `nil`
	* updateBubble(at index: Int, to type: BubbleType):
		* if index is within bounds of `bubbles`: ***should*** expect to set `GameBubble` at index to `EmptyBubble`
		* if index is out of bound of `bubbles`: ***should*** expect to do nothing
	* cycleBubble(at index: Int):
		* if index is within bounds of `bubbles`:
			* if bubble at index is `ColorBubble`:  ***should*** expect to set bubble at index to next corresponding alternate type `ColorBubble`
			* if bubble at index is not `ColorBubble`:  ***should*** expect to set bubble at same bubble
		* if index is out of bound of `bubbles`: ***should*** expect to do nothing
	* reset():
		* ***should*** expect all elements of `bubbles` to be `EmptyBubble`
	* numberOfBubbles:
		* ***should*** expect to be zero if `bubbles` is empty
		* ***should*** expect to be size of `bubbles`

* BubbleType
	* next()
		* if `bubbleType` is of color (not empty): ***should*** expect to return next corresponding `BubbleType`
		* if `bubbleType` is `emptyBubble`: ***should*** expect to return `EmptyBubble`

* ViewController
	* currentBubble:
		* if no button is selected: ***should*** expect nil
		* if button is selected: ***should*** expect to be selected `UIButton`
	* bubblePressed:
		* if sender is `currentBubble`: ***should*** expect `currentBubble` to be nil
		* if sender is not `currentBubble`" ***should*** expect `currentBubble` to be updated as sender
	* resetButtonPressed:
		* ***should*** expect `currentLevel.text` to be empty
		* ***should*** expect `game` in `BubbleViewGridViewController` to be all `EmptyBubble`
	* saveButtonPressed:
		* if save successful: ***should*** expect `currentLevel.text` to be updated
	* onNameSelected:
		* if name is valid: 
			* ***should*** expect `game` to be updated
			* ***should*** expect `currentLevel.text` to be updated
		* if name is invalid: ***should*** expect `StorageError.cannotLoad` to be thrown

* BubbleGridViewController
	* tap:
		* ***should*** expect `location` to be of tapped CGPoint
		* ***should*** expect `bubbleType` to be updated to `currentSelectedType`
		* if `bubbleType` is nil: ***should*** expect cell at specified location to be rotated
		* if `bubbleType` is not nil: ***should*** expect cell at specificed location to be updated to corresponding `GameBubble`
	* pan: 
		* if `type` is nil: ***should*** expect nothing to happen
		* if `type` is not nil:
			* if sender.state is .began or .changed:
				* ***should*** expect `location` to be of panned CGPoint
				* ***should*** expect cell at specificed location to be updated to corresponding `GameBubble`
	* longPress: 
		* if sender.state is .began or .changed:
			* ***should*** expect `location` to be of panned CGPoint
			* ***should*** expect cell at specificed location to be updated to `EmptyBubble`
	* loadDataFrom:
		* if name is valid: ***should*** expect `game` to be updated
		* if name is invalid: ***should*** expect `StorageError.cannotLoad` to be thrown
	* save:
		* if `game` is corrupted: ***should*** expect `StorageError.cannotSave` to be thrown
	* reset:
		* ***should*** expect `game` to be all `EmptyBuble`

* `BubbleObject`
	* `init(type: BubbleType, position: Vector2, shape: Shape)`
		* `type` **should** be updated
		* `body` **should** be created with corresponding `position` and `shape`, and zero `velocity` and `acceleration`
	* 	`init(type: BubbleType, position: Vector2, velocity: Vector2, shape: Shape)`
		* `type` **should** be updated
		* `body` **should** be created with corresponding `position`, `velocity` and `shape`, and zero `acceleration`

* `GameEngine`
	* `shootBubble`
		* size of `stationaryBubbleObjects` **should** increment
		* `movingBodiesCount` of `physicsEngine` **should** increment
		* inspect new `BubbleObject` in `stationaryBubbleObject`, `body` of the new `BubbleObject` should have `position` equal to `originLocation`, and correct initial `velocity`, and type equal to `currentBubbleType`
	* `dropEverything()`
		* size of `stationaryBubbleObjects` **should** zero
		* `stationaryBodiesCount` of `physicsEngine` **should** return zero
		* size of `droppingBubbleObjects` should be equal to initial size of `stationaryBubbleObjects`
		* `droppingBodiesCount` of `physicsEngine` **should** return initial value of `stationaryBodiesCount` 

### Problem 9: The Bells & Whistles

Improvements implemented

* Added ***Paper theme*** to the game, included changes to the bubbles, backhround image, and user interface
* Bubbles drop in accordance to in-game gravity
* Cannons have limited number (50) of shots in the game
	* In single player mode, if all shots are used up and game is not cleared, player loses
	* In multiplayer mode, if all shots are used up, you will have to watch the other player play!
* Aim assist added to the game, which is activated when the cannon is panned
* Score is added to the game
	* Colored and indestructible removed ***OR*** drops to ground
	* Corresponds to different teammates
	* Score added in a nice counting manner!
* End game screen added
	* Player with highest point wins!

### Problem 10: Final Reflection

Overall
