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

    @IBOutlet var bubbleArea: UICollectionView!
    @IBOutlet var renderArea: UIView!
    @IBOutlet var inputArea: UIView!
    @IBOutlet var bubbleToShoot: UIImageView!
    @IBOutlet var stageArea: UIView!
    @IBOutlet var cannonBase: UIImageView!
    @IBOutlet var cannon: UIImageView!
    @IBOutlet var nextBubble: UIImageView!
    @IBOutlet var gameArea: UIView!

    private var gameViewFrame: CGRect {
        return renderArea.frame
    }
    private var bubbleSize: CGFloat {
        return renderArea.frame.width / CGFloat(Constants.Game.numOfBubblesInEvenRow)
    }
    private var playButtonLocation: CGRect {
        return setInitialBubbleLocation()
    }

    lazy var gameEngine: GameEngine = initializeGameEngine()
    private var resourceImageManager: [BubbleType: UIImage] = [:]

    private var currentPlayBubbleType: BubbleType = BubbleType.randomType() {
        didSet {
            bubbleToShoot.image = UIImage(named: imageName(of: currentPlayBubbleType))
        }
    }

    private var nextPlayBubbleType: BubbleType = BubbleType.randomType() {
        didSet {
            nextBubble.image = UIImage(named: imageName(of: nextPlayBubbleType))
        }
    }

    private lazy var nextBubbleOriginalPosition = nextBubble.layer.position
    private lazy var cannonOriginalPosition = cannon.layer.position

    private var canShoot = true

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let offsetX = cannon.bounds.width * (0.5 - 0.5)
        let offsetY = cannon.bounds.height * (0.8 - 0.5)
        cannon.center = CGPoint(x: cannonOriginalPosition.x + offsetX, y: cannonOriginalPosition.y + offsetY)
        cannon.translatesAutoresizingMaskIntoConstraints = true
        cannon.layer.anchorPoint = CGPoint(x: 0.5, y: 0.8)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up bubble grid
        bubbleArea.dataSource = self
        bubbleArea.isScrollEnabled = false
        bubbleArea.collectionViewLayout = AlternatingBubbleLayout()

        // Set up shooting bubble
        bubbleToShoot.image = UIImage(named: imageName(of: currentPlayBubbleType))
        nextBubble.image = UIImage(named: imageName(of: nextPlayBubbleType))

        // Set up cannon
        drawCannon()

        // Set up gestures
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        inputArea.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        inputArea.addGestureRecognizer(panGesture)

        // Set up game loop
        Timer.scheduledTimer(timeInterval: Constants.Game.fps, target: self,
                                         selector: #selector(update), userInfo: nil, repeats: true)

        // Set up resource manager
        for type in BubbleType.allCases {
            resourceImageManager[type] = UIImage(named: imageName(of: type))
        }

        // Set up notifications
        let reloadCellNotification = Notification.Name("reloadCell")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCellAt(_:)),
                                               name: reloadCellNotification, object: nil)
        let gameOverNotification = Notification.Name("gameOver")
        NotificationCenter.default.addObserver(self, selector: #selector(gameOver(_:)),
                                               name: gameOverNotification, object: nil)
    }

    /// Update game and rendering engine
    @objc private func update() {
        gameEngine.update()
        render()
    }

    /// Render moving game objects
    private func render() {
        renderArea.subviews.forEach({ $0.removeFromSuperview() })
        for object in gameEngine.movingBubbleObjects.union(gameEngine.droppingBubbleObjects) {
            let imageView = UIImageView(image: self.resourceImageManager[object.type])
            let location = CGRect(x: object.body.position.xComponent - Double(self.bubbleSize)/2,
                                  y: object.body.position.yComponent - Double(self.bubbleSize)/2,
                                  width: Double(self.bubbleSize), height: Double(self.bubbleSize))
            imageView.frame = location
            self.renderArea.addSubview(imageView)
        }
    }

    @objc
    private func tap(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.renderArea)
        setCannonDirection(tapLocation)
        shootBubble(tapLocation)
    }

    @objc
    private func pan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            setCannonDirection(sender.location(in: self.renderArea))
        // Only shoot once user releases after aiming
        case .ended:
            let releaseLocation = sender.location(in: self.renderArea)
            shootBubble(releaseLocation)
        default:
            return
        }
    }

    /// Shoot bubble in game
    /// - Parameter location: point which user tapped/release
    private func shootBubble(_ location: CGPoint) {
        // Only shoot when user tap above the top of the bubble(cannon)
        guard location.y < playButtonLocation.minY else {
            return
        }

        guard canShoot else {
            return
        }

        cannon.startAnimating()
        loadBubble()
        gameEngine.shootBubble(originLocation: CGPoint(x: playButtonLocation.midX,
                                                       y: playButtonLocation.midY),
                               tapLocation: location,
                               bubbleSize: bubbleSize,
                               currentPlayBubbleType: currentPlayBubbleType)
    }

    private func setCannonDirection(_ location: CGPoint) {
        let xDistance = location.x - playButtonLocation.midX
        let yDistance = location.y - playButtonLocation.midY
        var angle = atan(-yDistance/xDistance)
        if angle > 0 {
            angle = CGFloat.pi/2 - angle
        } else {
            angle = -CGFloat.pi/2 - angle
        }
        cannon.transform = CGAffineTransform(rotationAngle: angle)
    }

    private func loadBubble() {
        canShoot = false
        bubbleToShoot.image = nil
        nextBubble.translatesAutoresizingMaskIntoConstraints = true
        nextBubble.layer.position = nextBubbleOriginalPosition
        gameArea.sendSubviewToBack(nextBubble)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.nextBubble.layer.position = self.bubbleToShoot.layer.position
                        },
                       completion: { _ in
                        self.currentPlayBubbleType = self.nextPlayBubbleType
                        self.nextBubble.layer.position = self.nextBubbleOriginalPosition
                        self.nextPlayBubbleType = BubbleType.randomType()
                        self.canShoot = true
                        })
    }

    @objc
    private func reloadCellAt(_ notification: NSNotification) {
        guard let dict = notification.userInfo as NSDictionary? else {
            return
        }
        guard let index = dict["index"] as? Int else {
            return
        }
        bubbleArea.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    @objc
    private func gameOver(_ notification: NSNotification) {
        let gameOverAlertController = UIAlertController(title: "Game Over!", message: nil, preferredStyle: .alert)
        gameOverAlertController.addAction(UIAlertAction(title: "Restart", style: .cancel) { _  in
            // Clear bubbles again just in case they are still attached due to
            // moving bubbles not being dropped when alert comes up
            self.gameEngine.dropEverything()
        })
        self.present(gameOverAlertController, animated: true)
    }

    private func initializeGameEngine() -> GameEngine {
        var gridPositions = [Vector2]()
        for item in 0..<Constants.Game.maxNumOfBubbles {
            guard let attribute = bubbleArea.layoutAttributesForItem(at: IndexPath(item: item, section: 0)) else {
                break
            }
            gridPositions.append(Vector2(point: attribute.center))
        }
        let gameEngine = GameEngine(minX: Double(0), maxX: Double(gameViewFrame.maxX),
                                    minY: Double(0), maxY: Double(gameViewFrame.maxY),
                                    gridPositions: gridPositions)
        return gameEngine
    }

    private func setInitialBubbleLocation() -> CGRect {
        return CGRect(x: gameViewFrame.width/2 - bubbleSize/2,
                      y: bubbleSize * CGFloat(Constants.Game.numOfRows - 1),
                      width: bubbleSize, height: bubbleSize)
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
        cannon.image = cannonArray[0]

        cannon.animationImages = cannonArray
        cannon.animationDuration = 1/4
        cannon.animationRepeatCount = 1
    }

}

extension GameViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.Game.maxNumOfBubbles
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

    private func imageName(of type: BubbleType) -> String {
        let name: String
        switch type {
        case .colorBlue: name = "bubble-blue.png"
        case .colorYellow: name = "bubble-orange.png"
        case .colorRed: name = "bubble-red.png"
        case .colorGreen: name = "bubble-green.png"
        }
        return name
    }
}

