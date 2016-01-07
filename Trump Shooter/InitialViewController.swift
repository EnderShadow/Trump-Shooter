//
//  SettingsViewController.swift
//  Space Shooter
//
//  Created by mwarren on 12/10/15.
//  Copyright © 2015 mwarren. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController
{
    @IBOutlet weak var highScoreLabel: UILabel!
    let properties = Properties()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        properties.highScore = NSUserDefaults.standardUserDefaults().integerForKey("HighScore")
    }
    
    @IBAction func clearData(sender: UIButton)
    {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "HighScore")
        highScoreLabel.text = "0"
        properties.highScore = 0
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        highScoreLabel.text = String(properties.highScore)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "gameSegue"
        {
            if let dest = segue.destinationViewController as? GameViewController {
                dest.properties = self.properties
            }
        }
    }
}