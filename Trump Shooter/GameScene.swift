//
//  GameScene.swift
//  Space Shooter
//
//  Created by mwarren on 11/30/15.
//  Copyright (c) 2015 mwarren. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene
{
    let SPAWN_THRESHOLD = 1.0
    var controller : GameViewController?
    
    let player = SKSpriteNode(imageNamed: "trump")
    let whitehouse = SKSpriteNode(imageNamed: "whitehouse")
    
    let enemySprites = ["enemy1", "enemy2", "enemy3", "enemy4"]
    let enemyScales : [(CGFloat, CGFloat)] = [(0.08, 0.08), (0.07, 0.07), (0.05, 0.05), (0.08, 0.08)]
    var enemies : [SKSpriteNode] = []
    
    let motionManager = CMMotionManager()
    var tilt = 0.0
    var spawn = 0.0
    var numSpawns = 0
    var prevTime : CFTimeInterval?
    var score = 0
    
    init(size: CGSize, controller: GameViewController)
    {
        super.init(size: size)
        self.controller = controller
        
        if motionManager.accelerometerAvailable
        {
            motionManager.accelerometerUpdateInterval = 0.02
            motionManager.startAccelerometerUpdates()
        }
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override func didMoveToView(view: SKView)
    {
        whitehouse.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame) + CGRectGetHeight(self.frame) / 12)
        whitehouse.xScale = 0.4
        whitehouse.yScale = 0.4
        if !children.contains(whitehouse)
        {
            self.addChild(whitehouse)
        }
        
        player.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(whitehouse.frame) + CGRectGetHeight(self.frame) / 10)
        player.xScale = 0.125
        player.yScale = 0.125
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.frame.size)
        player.physicsBody!.dynamic = true
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.mass = 0.02
        if !children.contains(player)
        {
            self.addChild(player)
        }
        
        spawn = 0.0
        numSpawns = 0
        prevTime = nil
        score = 0
        
        for enemy in enemies
        {
            enemy.removeActionForKey("action")
            enemy.runAction(SKAction.removeFromParent())
        }
        enemies = []
    }
    
    override func willMoveFromView(view: SKView)
    {
        super.willMoveFromView(view)
        
        controller?.properties?.highScore = max((controller?.properties?.highScore)!, score)
        NSUserDefaults.standardUserDefaults().setInteger((controller?.properties?.highScore)!, forKey: "HighScore")
    }
    
    func reset()
    {
        player.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(whitehouse.frame) + CGRectGetHeight(self.frame) / 10)
        
        spawn = 0.0
        numSpawns = 0
        prevTime = nil
        score = 0
        
        for enemy in enemies
        {
            enemy.removeActionForKey("action")
            enemy.removeFromParent()
        }
        enemies = []
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
       /* Called when a touch begins */
        
        for _ in touches
        {
            let sprite = SKSpriteNode(imageNamed:"money")
            
            sprite.xScale = 0.05
            sprite.yScale = 0.05
            sprite.position = player.position
            sprite.position.x -= player.frame.width / 8
            sprite.position.y += player.frame.height / 2 + sprite.frame.height / 2.5
            sprite.zPosition = 1
            
            sprite.runAction(SKAction.repeatActionForever(SKAction.moveByX(0.0, y: self.frame.height / 1.5, duration: 1)), withKey: "action")
            
            self.addChild(sprite)
        }
    }
    
    func processUserMotionForUpdate()
    {
        if let data = motionManager.accelerometerData
        {
            if fabs(data.acceleration.x) > 0.1
            {
                player.physicsBody!.velocity.dx = 1200.0 * CGFloat(data.acceleration.x)
            }
            else
            {
                player.physicsBody!.velocity.dx = 0.0
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        var deltaTime = currentTime - (prevTime == nil ? currentTime : prevTime!)
        if deltaTime > 1
        {
            deltaTime = 1.0 / 60.0
        }
        prevTime = currentTime
        
        if paused
        {
            return
        }
        
        processUserMotionForUpdate()
        
        for child in self.children
        {
            if child.isKindOfClass(SKSpriteNode)
            {
                if child.description.containsString("money")
                {
                    for enemy in self.enemies
                    {
                        if child.frame.intersects(enemy.frame)
                        {
                            enemy.removeActionForKey("action")
                            enemy.runAction(SKAction.removeFromParent())
                            child.removeActionForKey("action")
                            child.runAction(SKAction.removeFromParent())
                            enemies.removeAtIndex(enemies.indexOf(enemy)!)
                            score += 1
                            break
                        }
                    }
                    if !self.frame.contains(child.frame) && !self.frame.intersects(child.frame)
                    {
                        child.runAction(SKAction.removeFromParent())
                    }
                }
                else if child.description.containsString("enemy") && child.position.y < player.position.y - player.frame.height / 2
                {
                    controller?.properties?.highScore = max((controller?.properties?.highScore)!, score)
                    NSUserDefaults.standardUserDefaults().setInteger((controller?.properties?.highScore)!, forKey: "HighScore")
                    
                    let gameOver = UIAlertController(title: "Game Over", message: "Score: \(score)", preferredStyle: .Alert)
                    
                    let playAgain = UIAlertAction(title: "Play Again?", style: .Default, handler: {action in
                        self.reset()
                        self.paused = false
                    })
                    
                    let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: {action in
                        self.controller?.performSegueWithIdentifier("mainScreenSegue", sender: self)
                    })
                    
                    gameOver.addAction(playAgain)
                    gameOver.addAction(cancel)
                    
                    controller?.presentViewController(gameOver, animated: true, completion: nil)
                    self.paused = true
                }
            }
        }
        
        spawn += deltaTime
        if spawn >= SPAWN_THRESHOLD / (Double(1 + numSpawns * numSpawns))
        {
            spawn -= SPAWN_THRESHOLD
            
            let sprite = getRandomEnemy()
            
            sprite.position = CGPointZero
            sprite.position.x = CGFloat(Float(arc4random()) / 0xFFFFFFFF) * (frame.width - sprite.frame.width - player.frame.width / 2) + sprite.frame.width / 2
            sprite.position.y = frame.height
            sprite.zPosition = 1
            
            sprite.runAction(SKAction.repeatActionForever(SKAction.moveByX(0.0, y: -self.frame.height / max(8.0 - CGFloat(numSpawns) / 50.0, 0.2), duration: 1)), withKey: "action")
            
            enemies.append(sprite)
            self.addChild(sprite)
            numSpawns++
            //print("\(SPAWN_THRESHOLD / (1 + pow(Double(numSpawns), 2))) \(max(8.0 - CGFloat(numSpawns) / 50.0, 0.2))")
        }
        controller?.updateScore(score)
    }
    
    func getRandomEnemy() -> SKSpriteNode
    {
        let index = Int(arc4random_uniform(UInt32(enemySprites.count)))
        let sprite = SKSpriteNode(imageNamed: enemySprites[index])
        sprite.xScale = enemyScales[index].0
        sprite.yScale = enemyScales[index].1
        
        return sprite
    }
}