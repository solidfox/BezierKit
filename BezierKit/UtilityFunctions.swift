//
//  UIBezierPath+Points.swift
//  BezierKit
//
//  Created by Daniel Schlaug on 7/4/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import UIKit

func distance(p1: CGPoint,p2: CGPoint) -> CGFloat {
    let dx = p2.x - p1.x
    let dy = p2.y - p1.y
    
    let distance = sqrt(CGFloat(dx*dx + dy*dy))
    
    return CGFloat(distance)
}