//
//  GameViewController.swift
//  GameEngine
//
//  Created by Jie Liang Ang on 13/2/19.
//  Copyright © 2019 nus.cs3217.a0149293w. All rights reserved.
//

import UIKit
import CoreGraphics
import PhysicsEngine

class GameViewController: UIViewController {

    @IBOutlet private var bubbleArea: UICollectionView!
    @IBOutlet private var renderArea: UIView!
    @IBOutlet private var inputArea: UIView!
    @IBOutlet private var stageArea: UIView!

    @IBOutlet private var singlePlayer: UIView!
    @IBOutlet private var cannonSinglePlayer: UIImageView!
    @IBOutlet private var bubbleToShoot: UIImageView!
    @IBOutlet private var nextBubble: UIImageView!
    @IBOutlet private var secondNextBubble: UIImageView!
    @IBOutlet private var cannonBase: UIImageView!
    @IBOutlet private var tapSingle: UITapGestureRecognizer!
    @IBOutlet private var panSingle: UIPanGestureRecognizer!
    @IBOutlet private var trajectorySingle: TrajectoryPath!
    @IBOutlet private var scoreSingle: UICountingLabel!
    @IBOutlet private var bubblesLeftSingle: CounterLabel!

    @IBOutlet private var multiplayerOne: UIView!
    @IBOutlet private var cannonPlayerOne: UIImageView!
    @IBOutlet private var bubbleToShootPlayerOne: UIImageView!
    @IBOutlet private var nextBubblePlayerOne: UIImageView!
    @IBOutlet private var secondNextBubblePlayerOne: UIImageView!
    @IBOutlet private var cannonBasePlayerOne: UIImageView!
    @IBOutlet private var tapOne: UITapGestureRecognizer!
    @IBOutlet private var panOne: UIPanGestureRecognizer!
    @IBOutlet private var trajectoryOne: TrajectoryPath!
    @IBOutlet private var scoreOne: UICountingLabel!
    @IBOutlet private var bubblesLeftOne: CounterLabel!

    @IBOutlet private var multiplayerTwo: UIView!
    @IBOutlet private var cannonPlayerTwo: UIImageView!
    @IBOutlet private var bubbleToShootPlayerTwo: UIImageView!
    @IBOutlet private var nextBubblePlayerTwo: UIImageView!
    @IBOutlet private var secondNextBubblePlayerTwo: UIImageView!
    @IBOutlet private var cannonBasePlayerTwo: UIImageView!
    @IBOutlet private var tapTwo: UITapGestureRecognizer!
    @IBOutlet private var panTwo: UIPanGestureRecognizer!
    @IBOutlet private var trajectoryTwo: TrajectoryPath!
    @IBOutlet private var scoreTwo: UICountingLabel!
    @IBOutlet private var bubblesLeftTwo: CounterLabel!

    private var bubbleSize = UIScreen.main.bounds.width / CGFloat(Constants.Game.numOfBubblesInEvenRow)
    private lazy var gameEngine: GameEngine = initializeGameEngine()
    private var resourceImageManager: [BubbleType: UIImage] = [:]

    private lazy var playerSingle = Player(mainView: singlePlayer, cannon: cannonSinglePlayer,
                                           bubbleToShoot: bubbleToShoot,
                                            nextBubble: nextBubble, secondNextBubble: secondNextBubble,
                                            cannonBase: cannonBase,
                                            tapGestureRecognizer: tapSingle, panGestureRecognizer: panSingle,
                                            trajectory: trajectorySingle, score: scoreSingle,
                                            bubblesLeft: bubblesLeftSingle)
    private lazy var playerOne = Player(mainView: multiplayerOne, cannon: cannonPlayerOne,
                                        bubbleToShoot: bubbleToShootPlayerOne,
                                        nextBubble: nextBubblePlayerOne, secondNextBubble: secondNextBubblePlayerOne,
                                        cannonBase: cannonBasePlayerOne,
                                        tapGestureRecognizer: tapOne, panGestureRecognizer: panOne,
                                        trajectory: trajectoryOne, score: scoreOne, bubblesLeft: bubblesLeftOne)
    private lazy var playerTwo = Player(mainView: multiplayerTwo, cannon: cannonPlayerTwo,
                                        bubbleToShoot: bubbleToShootPlayerTwo,
                                        nextBubble: nextBubblePlayerTwo, secondNextBubble: secondNextBubblePlayerTwo,
                                        cannonBase: cannonBasePlayerTwo,
                                        tapGestureRecognizer: tapTwo, panGestureRecognizer: panTwo,
                                        trajectory: trajectoryTwo, score: scoreTwo, bubblesLeft: bubblesLeftTwo)
    private var timer: Timer?

    var game = GameBubbleSet(numberOfRows: Constants.Game.numOfRows)
    var multiplayer = false
    var panStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up bubble grid
        bubbleArea.dataSource = self
        bubbleArea.isScrollEnabled = false
        bubbleArea.collectionViewLayout = game.isHexagonal ? AlternatingBubbleLayout()
                                                           : RectangularGridLayout()

        // Set up game
        setupPlayerMode()
        drawCannon()
        trajectorySingle.setRadius(bubbleSize / 2)

        // Set up game loop
        timer = Timer.scheduledTimer(timeInterval: Constants.Game.fps, target: self,
                                         selector: #selector(update), userInfo: nil, repeats: true)

        // Set up resource manager
        for type in BubbleType.allCases {
            resourceImageManager[type] = UIImage(named: ResourceManager.imageName(of: type))
        }

        // Set up notifications
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCellAt(_:)),
                                               name: Constants.NotificationName.reloadCell, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gameOver(_:)),
                                               name: Constants.NotificationName.gameOver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveCell(_:)),
                                               name: Constants.NotificationName.moveCell, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popCell(_:)),
                                               name: Constants.NotificationName.popCell, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(noBubblesLeft(_:)),
                                               name: Constants.NotificationName.noBubblesLeft, object: nil)
    }

    // Shoot when tap
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.renderArea)
        guard tapLocation.y < bubbleToShoot.frame.minY else {
            return
        }
        let player = getPlayerBasedOn(location: tapLocation)
        setCannonDirection(tapLocation, playerId: player)
        shootBubble(tapLocation, playerId: player)
    }

    // Shoot when release after panning
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        let currentPlayer: Player
        switch sender {
        case panOne: currentPlayer = playerOne
        case panTwo: currentPlayer = playerTwo
        case panSingle: currentPlayer = playerSingle
        default: return
        }

        let location = sender.location(in: self.renderArea)
        guard location.y < bubbleToShoot.frame.minY else {
            currentPlayer.trajectory.setEnabled(false)
            return
        }
        if ((sender == panOne) && location.x > renderArea.frame.midX) ||
            ((sender == panTwo) && location.x < renderArea.frame.midX) {
            currentPlayer.trajectory.setEnabled(false)
            return
        }
        let playerId = getPlayerBasedOn(location: location)
        switch sender.state {
        case .began:
            setCannonDirection(location, playerId: playerId)
            currentPlayer.trajectory.setColor(ResourceManager.color(of: currentPlayer.currentBubbleType))
            currentPlayer.trajectory.setStartPoint(currentPlayer.bubbleToShoot.center)
            currentPlayer.trajectory.setEndPoint(location)
            currentPlayer.trajectory.setEnabled(true)
        case .changed:
            setCannonDirection(location, playerId: playerId)
            currentPlayer.trajectory.setEndPoint(location)
            currentPlayer.trajectory.setEnabled(true)
        case .ended:
            shootBubble(location, playerId: playerId)
            currentPlayer.trajectory.setEnabled(false)
        default:
            return
        }
    }

    @IBAction func swapButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: playerSingle.swap()
        case 1: playerOne.swap()
        case 2: playerTwo.swap()
        default: break
        }
    }

    /// Update game and rendering engine
    @objc private func update() {
        gameEngine.update()
        render()
    }

    /// Render moving game objects
    private func render() {
        renderArea.subviews.forEach({ $0.removeFromSuperview() })
        for object in gameEngine.movingBubbleObjects {
            let imageView = UIImageView(image: self.resourceImageManager[object.type])
            let location = CGRect(x: object.body.position.xComponent - Double(self.bubbleSize)/2,
                                  y: object.body.position.yComponent - Double(self.bubbleSize)/2,
                                  width: Double(self.bubbleSize), height: Double(self.bubbleSize))
            imageView.frame = location
            self.renderArea.addSubview(imageView)
        }
        for object in gameEngine.droppingBubbleObjects {
            let imageView = UIImageView(image: self.resourceImageManager[object.type])
            let location = CGRect(x: object.body.position.xComponent - Double(self.bubbleSize)/2,
                                  y: object.body.position.yComponent - Double(self.bubbleSize)/2,
                                  width: Double(self.bubbleSize), height: Double(self.bubbleSize))
            imageView.frame = location
            self.renderArea.addSubview(imageView)
        }
    }

    /// Shoot bubble in game
    /// - Parameter location: point which user tapped/release
    private func shootBubble(_ location: CGPoint, playerId: PlayerType) {
        let selectedPlayer = player(playerId)
        guard selectedPlayer.canShoot else {
            return
        }
        guard selectedPlayer.numOfBubblesLeft > 0 else {
            return
        }
        let bubble = selectedPlayer.bubbleToShoot
        selectedPlayer.cannon.startAnimating()
        gameEngine.shootBubble(originLocation: CGPoint(x: bubble.frame.midX,
                                                       y: bubble.frame.midY),
                               tapLocation: location,
                               bubbleSize: bubbleSize,
                               currentPlayBubbleType: selectedPlayer.currentBubbleType,
                               player: playerId)
        selectedPlayer.loadBubble(nextType: gameEngine.randomBubbleType())
        selectedPlayer.decrementBubble()

        if selectedPlayer.numOfBubblesLeft == 0 {
            selectedPlayer.pauseLoadedBubbles()
            if multiplayer && playerOne.numOfBubblesLeft == 0 && playerTwo.numOfBubblesLeft == 0 {
                gameOverMultiPlayer(determineWinner())
            } else if !multiplayer && noColoredBubblesLeft(){
                gameOverSinglePlayer(win: true)
            } else if !multiplayer && !noColoredBubblesLeft() {
                gameOverSinglePlayer(win: false)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "endScreen" {
            guard let childVC = segue.destination as? EndScreenViewController else {
                fatalError("Error while setting EndScreenViewController")
            }
            guard let result = sender as? (Bool, PlayerType) else {
                return
            }
            childVC.result = result
        }
    }

    func gameOverSinglePlayer(win: Bool) {
        performSegue(withIdentifier: "endScreen", sender: (win, PlayerType.single))
    }

    func gameOverMultiPlayer(_ winner: PlayerType) {
        performSegue(withIdentifier: "endScreen", sender: (true, winner))
        print("done")
    }

    func noColoredBubblesLeft() -> Bool {
        return gameEngine.bubblesLeft.isEmpty
    }

    private func setCannonDirection(_ location: CGPoint, playerId: PlayerType) {
        let xDistance: CGFloat = location.x - player(playerId).bubbleToShoot.frame.midX
        let yDistance: CGFloat = location.y - player(playerId).bubbleToShoot.frame.midY
        let cannon = player(playerId).cannon

        var angle = atan(-yDistance/xDistance)
        if angle > 0 {
            angle = CGFloat.pi/2 - angle
        } else {
            angle = -CGFloat.pi/2 - angle
        }
        let offsetY = cannon.bounds.height * (0.8 - 0.5)
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: offsetY)
        transform = transform.rotated(by: angle)
        transform = transform.translatedBy(x: 0, y: -offsetY)
        cannon.transform = transform
    }

    private func setupPlayerMode() {
        if multiplayer {
            playerSingle.disable()
            playerOne.resetLoadedBubbles(set: game.bubblesLeft)
            playerTwo.resetLoadedBubbles(set: game.bubblesLeft)
        } else {
            playerOne.disable()
            playerTwo.disable()
            playerSingle.resetLoadedBubbles(set: game.bubblesLeft)
        }
    }

    private func player(_ playerId: PlayerType) -> Player {
        switch playerId {
        case .one: return playerOne
        case .two: return playerTwo
        default: return playerSingle
        }
    }

    private func updateLoadedBubbles() {
        let set = gameEngine.bubblesLeft
        if multiplayer {
            playerOne.updateLoadedBubbles(set: set)
            playerTwo.updateLoadedBubbles(set: set)
        } else {
            playerSingle.updateLoadedBubbles(set: set)
        }
    }

    private func getPlayerBasedOn(location: CGPoint) -> PlayerType {
        if multiplayer {
            if location.x < inputArea.frame.midX {
                return .one
            } else {
                return .two
            }
        } else {
            return .single
        }
    }

    private func drawCannon() {
        guard let overallImage = UIImage(named: "cannon.png") else {
            return
        }
        let overallImageHeight = overallImage.size.height
        let overallImageWidth = overallImage.size.width

        let cannonHeight = overallImageHeight / 2 * 2
        let cannonWidth = overallImageWidth / 6 * 2

        var cannonArray = [UIImage]()

        guard let cgImage = overallImage.cgImage else {
            return
        }
        for index in 0..<12 {
            let rect = CGRect(x: cannonWidth * CGFloat(index % 6),
                              y: cannonHeight * CGFloat(index / 6),
                              width: cannonWidth,
                              height: cannonHeight)

            guard let croppedCannon = cgImage.cropping(to: rect) else {
                continue
            }
            cannonArray.append(UIImage(cgImage: croppedCannon))
        }

        if multiplayer {
            cannonPlayerOne.image = cannonArray[0]
            cannonPlayerOne.animationImages = cannonArray
            cannonPlayerOne.animationDuration = 1/4
            cannonPlayerOne.animationRepeatCount = 1

            cannonPlayerTwo.image = cannonArray[0]
            cannonPlayerTwo.animationImages = cannonArray
            cannonPlayerTwo.animationDuration = 1/4
            cannonPlayerTwo.animationRepeatCount = 1
        } else {
            cannonSinglePlayer.image = cannonArray[0]
            cannonSinglePlayer.animationImages = cannonArray
            cannonSinglePlayer.animationDuration = 1/4
            cannonSinglePlayer.animationRepeatCount = 1
        }
    }

    @objc
    private func reloadCellAt(_ notification: NSNotification) {
        bubbleArea.reloadData()
        //bubbleArea.reloadItems(at: [IndexPath(item: index, section: 0)])
        updateLoadedBubbles()
    }

    @objc
    private func popCell(_ notification: NSNotification) {
        guard let dict = notification.userInfo as NSDictionary? else {
            return
        }
        guard let type = dict["type"] as? BubbleType,
            let playerId = dict["playerId"] as? PlayerType else {
                return
        }
        let playerWhoPopped = player(playerId)
        playerWhoPopped.score.increment(value: score(type))

        bubbleArea.reloadData()
    }

    @objc
    private func moveCell(_ notification: NSNotification) {
        guard let dict = notification.userInfo as NSDictionary? else {
            return
        }
        guard let center = dict["center"] as? CGPoint,
            let type = dict["type"] as? BubbleType,
            let final = dict["final"] as? CGPoint else {
                return
        }
        let imageView = UIImageView(image: resourceImageManager[type])
        imageView.frame.size = CGSize(width: bubbleSize, height: bubbleSize)
        imageView.center = center
        inputArea.addSubview(imageView)

        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
            imageView.center = final
        }, completion: { _ in
            imageView.removeFromSuperview()
            self.bubbleArea.reloadData()
        })
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        goBack()
    }

    func determineWinner() -> PlayerType {
        if playerOne.score.endNumber > playerTwo.score.endNumber {
            return .one
        } else if playerOne.score.endNumber < playerTwo.score.endNumber {
            return .two
        } else {
            return .bot
        }
    }

    @objc
    private func gameOver(_ notification: NSNotification) {
        guard let dict = notification.userInfo as NSDictionary? else {
            return
        }
        guard let loser = dict["loser"] as? PlayerType else {
            return
        }
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationName.gameOver, object: nil)
        if !multiplayer {
            gameOverSinglePlayer(win: false)
        } else {
            gameOverMultiPlayer(loser.otherPlayer())
        }

    }
    
    @objc private func noBubblesLeft(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationName.gameOver, object: nil)
        print(playerOne.score.endNumber)
        print(playerTwo.score.endNumber)
        multiplayer ? gameOverMultiPlayer(determineWinner()) : gameOverSinglePlayer(win: true)
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationName.noBubblesLeft, object: nil)
    }

    private func goBack() {
        timer?.invalidate()
        self.dismiss(animated: true, completion: {
            print("game dismissed")
        })
    }

    private func initializeGameEngine() -> GameEngine {
        let maxNumOfBubbles = game.isHexagonal ? Constants.Game.maxNumOfBubblesInHex
                                                      : Constants.Game.maxNumOfBubblesInRect

        var gridPositions = [Vector2]()
        for item in 0..<maxNumOfBubbles {
            guard let attribute = bubbleArea.layoutAttributesForItem(at: IndexPath(item: item, section: 0)) else {
                break
            }
            gridPositions.append(Vector2(point: attribute.center))
        }

        let gameEngine = GameEngine(minX: Double(0), maxX: Double(UIScreen.main.bounds.width),
                                    minY: Double(0), maxY: Double(UIScreen.main.bounds.height),
                                    gridPositions: gridPositions,
                                    game: game, maxNumOfBubbles: maxNumOfBubbles)
        return gameEngine
    }

    private func score(_ type: BubbleType) -> Float {
        switch type {
        case .colorRed, .colorYellow, .colorBlue, .colorGreen:
            return 20
        case .indestructible:
            return 10
        default:
            return 0
        }
    }
}

extension GameViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if game.isHexagonal {
            return Constants.Game.maxNumOfBubblesInHex
        } else {
            return Constants.Game.maxNumOfBubblesInRect
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bubbleCell", for: indexPath)
            as? BubbleCell else {
                return BubbleCell()
        }
        if let bubble = gameEngine.stationaryBubbleObjects[indexPath.item] {
            cell.setImage(resourceImageManager[bubble.type])
        } else {
            cell.setImage(nil)
        }
        return cell
    }
}

extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == tapOne && touch.location(in: renderArea).x < renderArea.frame.midX {
            return true
        } else if gestureRecognizer == tapTwo && touch.location(in: renderArea).x > renderArea.frame.midX {
            return true
        } else if gestureRecognizer == panOne && touch.location(in: renderArea).x < renderArea.frame.midX {
            return true
        } else if gestureRecognizer == panTwo && touch.location(in: renderArea).x > renderArea.frame.midX {
            return true
        } else {
            return false
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == tapOne && otherGestureRecognizer == panOne) ||
            (gestureRecognizer == panOne && otherGestureRecognizer == tapOne) ||
            (gestureRecognizer == tapTwo && otherGestureRecognizer == panTwo) ||
            (gestureRecognizer == panTwo && otherGestureRecognizer == tapTwo) {
            return false
        } else {
            return true
        }
    }
}
