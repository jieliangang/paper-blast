CS3217 Problem Set 4
==

**Name:** Ang Jie Liang

**Matric No:** A0149293W

**Tutor:** Wang Yanhao

## Instructions for Tutors

1. Make sure the skeleton code repository is squashed to a single commit.
1. Remove this section for the skeleton.
1. Check that the `.gitignore` file is updated.

## Tips

1. CS3217's Gitbook is at https://www.gitbook.com/book/cs3217/problem-sets/details. Do visit the Gitbook often, as it contains all things relevant to CS3217. You can also ask questions related to CS3217 there.
2. Take a look at `.gitignore`. It contains rules that ignores the changes in certain files when committing an Xcode project to revision control. (This is taken from https://github.com/github/gitignore/blob/master/Swift.gitignore).
3. A SwiftLint configuration file is provided for you. It is _strongly_ recommended for you to use SwiftLint and follow this configuration. Keep in mind that, ultimately, this tool is only a guideline; some exceptions may be made as long as code quality is not compromised.
    - Unlike previous problem sets, you are creating the Xcode project this time, which means you will need to copy the config into the folder created by Xcode and [configure Xcode](https://github.com/realm/SwiftLint#xcode) yourself if you want to use SwiftLint. 
4. Do not burn out. Have fun!

## Problem 1: Design

## Problem 1.1

![alt text](https://github.com/cs3217-1819/2019-ps4-jieliangang/blob/master/class-diagram.png "Class Diagram")

***Shape***

`Shape` is an enumeration, which consists of different shapes and properties which represents the shape. Currently, only case in `Shape` is `circle`, which contains property `radius` to represent a circle. In the near future (for PS5), additional shape such as `rectangle` will be added to represent rectangles, as well as the walls of the physics engine.

***RigidBody***

 `RigidBody` represents a physics object in the `PhysicsEngine`, which is a solid body with no deformation, considered as a continuous distribution of mass. It contains physical properties such as `position`, `velocity`, `acceleration`, `shape` and `mass`. It also conforms to the `Hashable` protocol and is identified per instance based on the instance's `ObjectIdentifier`. It contains a method `update()`, which updates its physical property based on the timestep provided.

***PhysicsEngine***

 `PhysicsEngine` provides an environment to simulate a physical system, such as simple object physical movement / path computation and rigid body dynamics / collision detection.
 `PhysicsEngine` consists of a system of `RigidBody` reacting to each other, and is bounded within a rectangle.
 
 The internal representation of `RigidBody` objects in `PhysicsEngine` is categorized to three sections:

 - Stationary bodies: `RigidBody` which position is fixed at all time and can never move
 - Moving bodies: `RigidBody` which are free to move and not affected by gravity, may collide with other bodies
 - Dropping bodies: `RigidBody` which are free falling and affected by gravity

 This allows different type of bodies to interactly differently within the `PhysicsEngine` environment and with each other. It is thus able to detect collision between different bodies and its boundary, and handles it accordingly based on the collision resolution provided by `GameEngine`

 It contains an `update()` method which updates the physical state of all the `RigidBody` within the system, specifically moving and dropping bodies, as stationary bodies' positions are fixed.

***BubbleObject***

`BubbleObject` represents the game bubbles in the game. It contains a `RigidBody`, its physical representation in the `PhysicsEngine`, and a `BubbleType` which describes the type of the bubble.

***GameEngine***

`GameEngine` handles the game logic, including collision resolution.

 For efficient handling and rendering of game objects state and animation, internal representations of the game objects are categorized to three sections:
 
 - StationaryBubbleObjects: Represents the bubble on the isometric grid. 
 - MovingBubbleObjects: Represents bubble which are being shot
 - DroppingBubbleObjects: Represents disconnected bubble which are dropping from the grid for animation purposes.

 It contains a method `shootBubble()`, which addeds a moving bubble to the game. 

 It then handles all the gameplay logic, including snapping bubbles to the grid cells, removing connected bubbles of the same color, and removal of unattached and disconnected bubbles. It also provided collision resolution for the different `BubbleObject`, as the different objects (stationary, moving and dropping) reacts differently when colliding with each other or with the wall. For instance, a moving object would stick to a grid cell when it collides with the top wall, while a mid-dropping object would bounce off the top wall. 

 The animation for falling bubbles are handled by the game engine, as its position mid dropping is controlled by the `PhysicsEngine`, which allows gravity to act on falling bubbles.

 To inform the `GameViewController` to reload the collection view cells or indicate game over, `GameEngine` pass data to the `GameViewController` via the `NotificationCenter`.

 `GameEngine` also contains the ***Model*** of the game, as it contains all of the different `BubbleObject` in the game, the renderer can display the game objects based on the `BubbleObject`s contained in `GameEngine`.

***GameViewController***

`GameViewController` is mainly in charge of handling user inputs and rendering the game objects. 

It handles tap gestures and pan gestures from the user, which provides the inputs required to launch the bubble.

It also sets up the game loop, which tells the game engine to use the physics engine to update the game objects' physical property (position and velocity) then handle the resulting interaction, and then call the `render()` method to redraw the objects on the screen. The resulting interactions would also invoke `reloadCellAt` which updates the bubble grid of the game.

***Views***

***UICollectionView***

Similar to PS4, the `bubbleArea` is a subclass of `UICollectionView` which displays all the stationary bubbles on the isometric grid.

***UIView***

`inputArea` contains subviews which represents all the moving objects, and is redrawn frequently at 60 frames per second.

## Problem 1.2

Implementations of more complex game logic will be done within the `GameEngine` class, which is in charge of all the game logic involved in this game.

As most special bubble type involved logic will compose of various basic game logic, based on the current design of the physics and game engine, additions of new complex logic should be relatively simple.

In fact, to showcase how simple modifications or extensions can be, I have implemented a demo of the suggested logic: removal of all bubbles of a specific color from the grid, within my PS4 submission code, marked as *PS4 - Problem 1.2*. 

The method of the logic for this feature was written in 6 lines of code in `GameEngine`.

```swift
    func removeAllBubblesOfType(_ typeToRemove: BubbleType) {
        for (index, bubble) in stationaryBubbleObjects where bubble.type == typeToRemove {
            removeStationaryObject(index)
        }
        dropObjects()
    }
```
Basically, iterate through the bubbles in the grid, and remove the `BubbleObject`s which has the same `BubbleType` type by calling `removingStationaryObject()`. `removingStationaryObject()` handles the removal of bubble from grid, including the updating of `PhysicsEngine` and the calling of render to invoke animation which removes the cell in View. The method is similarly used in other logic which involves removal of bubble. At the end, drop all unconnected bubbles.

To showcase how the function would work, a `UIButton` is added at top left of the stage area located at the bottom of the game. Clicking on *RemoveColor* would remove all bubbles of the color of the current bubble to shoot. Do try it out to test out my implementation!

Let's say for example, the popping of a certain special *type* of `BubbleObject` will invoke the special power which removes all bubbles of a specific color (for instance the bubble which collides with it). During handling of collision in `resolveCollisionWithStationaryObject(_:_:)`, if the stationary bubble which is collided is this special bubble, invoke the shown `removeAllBubblesOfType(_:)` method with the parameter to be the initially moving objects' type! This showcases an example of how I would extend my design to support more complex game logic.

## Problem 2.1

The `ViewController` handles all user input and relay the input data to the `GameEngine` for further processing in regards to the gameplay logic.

To shoot a bubble, a user can either
a) tap on the region above the top of the bubble, or
b) pan and release within the region above the top of the bubble

With GestureRecognizers, the `ViewController` will then check if the region tapped or released is above the top of the bubble. If it is, then it sends the following information to the `GameEngine` by invoking `shootBubble()`:
i) origin location of bubble to launch
ii) location in which user tap/released
iii) type of bubble to shoot

Based on the origin location and tapped/released location, the `GameEngine` calculates the angle of launch direction based on vector calculations, and sets the initial x and y velocity component of the bubble object based on the angle and then place its rigid body representation in the physics engine.

This marks the beginning of the launched bubble at constant speed in the direction of launch. 

## Problem 3: Testing

***Black-box testing***
* Test launching bubbles
	* If tap on region below the top of the launch bubble
		* The bubble **should not** launch
	* If tap on region above the top of the launch bubble
		* The bubble **should** move in the direction of the tap
		* The bubble **should** move from the initial launch position
		* The bubble **should** move in constant velocity
	* If pan anywhere and then release on region below the top of the launch bubble
		*  The bubble **should not** launch
	* If pan anywhere and then release on region above the top of the launch bubble
		* The bubble **should** move in the direction of the tap
		* The bubble **should** move from the initial launch position
		* The bubble **should** move in constant velocity
* Test collision between two bubbles
	* If launched bubble collides with a launched bubble
		* Both bubbles **should** resume their movements as usual
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

***Glass-box testing***

* `RigidBody`
	* `init(position: Vector2, shape: Shape)`
		* `position` and `shape` **should** be updated 
		* `velocity` **should** be zero vector
		* `acceleration` **should** be zero vector
	* `init(position: Vector2, velocity: Vector2, shape: Shape)`
		* `position`, `velocity` and `shape` **should** be updated 
		* `acceleration` **should** be zero vector
	* `init(position: Vector2, velocity: Vector2, acceleration: Vector2, shape: Shape, mass: Double)`
		* `position`, `velocity`, `acceleration` and `shape` **should** be updated
	* `update()`
		* `position` and `velocity` should be updated based on the `velocity` and `acceleration` respectively multipled by the `Constants.Game.timestep`

* `PhysicsEngine`
	* `init(minX: Double, maxX: Double, minY: Double, maxY: Double, gravity: Vector2)`
		* `stationaryBodiesCount` **should** return zero
		* `movingBodiesCount` **should** return zero
		* `droppingBodiesCount` **should** return zero
	* `addStationaryBody(_ body: RigidBody)`
		* if velocity of body is non-zero
			* `stationaryBodiesCount` **should** remain the same
		* if acceleration of body is non-zero
			* `stationaryBodiesCount` **should** remain the same
		* else
			* `stationaryBodiesCount` **should** increment
	* `removeStationaryBody(_ body: RigidBody)`
		* if body does not exist in `PhysicsEngine`
			* `stationaryBodiesCount` **should** remain the same
		* if body exist in `PhysicsEngine`
			* `stationaryBodiesCount` **should** decrement
	* `addMovingBody(_ body: RigidBody)`
		 * if acceleration of body is non-zero
		 	* `movingBodiesCount` **should** remain the same
		 * else
		 	* `movingBodiesCount` **should** increment
	* `removeMovingBody(_ body: RigidBody)`
		* if body does not exist in `PhysicsEngine`
			* `movingBodiesCount` **should** remain the same
		* if body exist in `PhysicsEngine`
			* `movingBodiesCount` **should** decrement	
	* `addDroppingBody(_ body: RigidBody)`
		* `droppingBodiesCount` **should** increment
		* acceleration of body should be equal to set gravity
	* `dropBody(_ body: RigidBody)`
		* if body does not exist in `PhysicsEngine`
			* nothing **should** happen
		* if body was stationary
			* `stationaryBodiesCount` **should** decrement
			* `droppingBodiesCount` **should** increment
		* if body was moving
			* `movingBodiesCount` **should** decrement
			* `droppingBodiesCount` **should** increment
	* `removeDroppingBody(_ body: RigidBody)`
		* if body does not exist in `PhysicsEngine`
			* `droppingBodiesCount` **should** remain the same
		* if body exist in `PhysicsEngine`
			* `droppingBodiesCount` **should** decrement	
	* `reset()`
		* `stationaryBodiesCount` **should** return zero
		* `movingBodiesCount` **should** return zero
		* `droppingBodiesCount` **should** return zero

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

***Note:*** Testings for the `RemoveColour` button and *Game Over* feature are not added as they are not part of the requirements for this problem set.

