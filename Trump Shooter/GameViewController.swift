//
//  GameViewController.swift
//  Space Shooter
//
//  Created by mwarren on 11/30/15.
//  Copyright (c) 2015 mwarren. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    @IBOutlet weak var scoreLabel: UILabel!
    var properties : Properties?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let scene = GameScene(size: CGSizeMake(self.view.frame.width, self.view.frame.height), controller: self)
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
    }
    
    func updateScore(score: Int)
    {
        scoreLabel.text = String(score)
    }

    override func shouldAutorotate() -> Bool
    {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return .Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation
    {
        return .Portrait
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
}