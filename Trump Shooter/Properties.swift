//
//  Properties.swift
//  Trump Shooter
//
//  Created by mwarren on 12/18/15.
//  Copyright © 2015 mwarren. All rights reserved.
//

class Properties
{
    var highScore : Int
    
    init(score: Int)
    {
        self.highScore = score
    }
    
    convenience init()
    {
        self.init(score: 0)
    }
}