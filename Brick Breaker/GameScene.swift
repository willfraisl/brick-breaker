//
//  GameScene.swift
//  Brick Breaker
//
//  Created by Will Fraisl on 3/2/16.
//  Copyright (c) 2016 Will Fraisl. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isTouching = false;
    var score = 0
    var lives = 3
    //mode 0 is normal
    //mode 1 is flashing colors
    var mode = 0
    
    let ball = SKSpriteNode(imageNamed: "ball")
    let paddle = SKShapeNode(rectOf: CGSize(width: 65, height: 10))
    let bottom = SKShapeNode(rectOf: CGSize(width: 1000, height: 1))
    let scoreBoard = SKLabelNode(text: "Score: ")
    let lossLabel = SKLabelNode(text: "YOU LOST")
    let startLabel = SKLabelNode(text: "START")
    let livesLabel = SKLabelNode(text: "Lives: ")
    let restartLabel = SKLabelNode(text: "Restart?")
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        initGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        isTouching = true;
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = false;
        
        for touch: AnyObject in touches {
            if atPoint(touch.location(in: self)) == startLabel {
                startGame()
            }
            
            else if atPoint(touch.location(in: self)) == restartLabel {
                restartGame()
                initGame()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        paddle.position = CGPoint(x: touchLocation.x, y: paddle.position.y)
    }
   
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if(mode == 1){
            changeColors()
        }
    }
    
    func ballDidCollideWithBrick(_ ball: SKSpriteNode, brick: SKShapeNode){
        brick.removeFromParent()
        score += 1
        scoreBoard.text = "Score: " + score.description
    }
    
    func ballDidCollideWithBottom(_ ball: SKSpriteNode, bottom: SKShapeNode){
        lifeLost()
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Ball) &&
            (secondBody.categoryBitMask == PhysicsCategory.Brick)) {
                ballDidCollideWithBrick(firstBody.node as! SKSpriteNode, brick: secondBody.node as! SKShapeNode)
        }
        
        if ((firstBody.categoryBitMask == PhysicsCategory.Ball) && (secondBody.categoryBitMask == PhysicsCategory.Bottom)){
            ballDidCollideWithBottom(firstBody.node as! SKSpriteNode, bottom: secondBody.node as! SKShapeNode)
        }
    }
    
    func initGame(){
        initScene()
        initBall()
        initPaddle()
        initScoreBoard()
        initLossLabel()
        initStartLabel()
        initLivesLabel()
        initRestartLabel()
        for i in 1...20{
            for j in 1...10{
                initBrick(CGPoint(x: 35*j - 5, y: 420 + i*10))
            }
        }
    }
    
    func initScene(){
        backgroundColor = SKColor.white
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody (edgeLoopFrom: self.frame)
        
        bottom.physicsBody = SKPhysicsBody (rectangleOf: CGSize(width: 1000, height: 1))
        
        bottom.position = CGPoint(x: 0, y: 1)
        bottom.fillColor = SKColor.white
        bottom.physicsBody?.isDynamic = false
        addChild(bottom)
        
        bottom.physicsBody?.categoryBitMask = PhysicsCategory.Bottom
        bottom.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        bottom.physicsBody?.collisionBitMask = PhysicsCategory.Ball
    
        
    }
    
    func initBall(){
        
        ball.setScale(0.15)
        ball.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(ball)
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.restitution = 1.005
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Brick
        ball.physicsBody?.collisionBitMask = PhysicsCategory.Brick
        
    }
    
    func initPaddle(){
        
        paddle.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        paddle.fillColor = SKColor.randomColor()
        addChild(paddle)
        
        paddle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 65, height: 10))
        paddle.physicsBody?.isDynamic = false
    }
    
    func initBrick(_ point: CGPoint){
        let brick = SKShapeNode(rectOf: CGSize(width: 30, height: 8))
        brick.position = point
        brick.fillColor = SKColor.randomColor()
        brick.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 8))
        
        brick.physicsBody?.categoryBitMask = PhysicsCategory.Brick
        brick.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
        brick.physicsBody?.collisionBitMask = PhysicsCategory.Ball
        
        brick.physicsBody?.isDynamic = false
        addChild(brick)
    }
    
    func initScoreBoard(){
        scoreBoard.position = CGPoint(x: size.width * 0.1, y: size.height * 0.95)
        scoreBoard.fontColor = SKColor.black
        scoreBoard.fontSize = 14.0
        scoreBoard.text = "Score: " + score.description
        addChild(scoreBoard)
    }
    
    func initLossLabel(){
        lossLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        lossLabel.fontColor = SKColor.black
        lossLabel.isHidden = true
        addChild(lossLabel)
    }
    
    func initStartLabel(){
        startLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.4)
        startLabel.fontColor = SKColor.black
        addChild(startLabel)
    }
    
    func initLivesLabel(){
        livesLabel.position = CGPoint(x: size.width * 0.9, y: size.height * 0.95)
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 14.0
        livesLabel.text = "Lives: " + lives.description
        addChild(livesLabel)
    }
    
    func initRestartLabel(){
        restartLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.4)
        restartLabel.fontColor = SKColor.black
    }
    
    func startGame(){
        ball.physicsBody?.applyImpulse(CGVector(dx: 1,dy: -3))
        scoreBoard.isHidden = false
        startLabel.removeFromParent()
    }
    
    func lifeLost(){
        if(lives > 0){
            lives -= 1
            livesLabel.text = "Lives: " + lives.description
            resetGame()
        }
        else{
            gameLost()
        }
    }
    
    func gameLost(){
        ball.removeFromParent()
        lossLabel.isHidden = false
        addChild(restartLabel)
        
    }
    
    func resetGame(){
        ball.removeFromParent()
        initBall()
        initStartLabel()
    }
    
    func restartGame(){
        ball.removeFromParent()
        paddle.removeFromParent()
        bottom.removeFromParent()
        scoreBoard.removeFromParent()
        lossLabel.removeFromParent()
        startLabel.removeFromParent()
        livesLabel.removeFromParent()
        restartLabel.removeFromParent()
        
        for case let child in self.children {
            child.removeFromParent()
        }
        
        lives = 3
        score = 0
    }
    
    func changeColors(){
        backgroundColor = UIColor.randomColor()
        for case let child as SKShapeNode in self.children {
                child.fillColor = UIColor.randomColor()
        }
    }
}

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball      : UInt32 = 0b1
    static let Brick     : UInt32 = 0b10
    static let Bottom    : UInt32 = 0b11
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        let r = CGFloat.random()
        let g = CGFloat.random()
        let b = CGFloat.random()

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
