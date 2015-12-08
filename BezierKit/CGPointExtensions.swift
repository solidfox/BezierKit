//
//  CGPointExtensions.swift
//  BezierKit
//
//  Created by Daniel Schlaug on 7/5/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func relativeToPoint(dx dx:CGFloat, dy:CGFloat) -> CGPoint {
//        NSLog("\(self.x), \(self.y), \(dx), \(dy)")
        let x = self.x + dx
        let y = self.y + dy
        return CGPoint(x: x, y: y)
    }
    
    func relativeToPoint(point: CGPoint) -> CGPoint {
        return self.relativeToPoint(dx: point.x, dy: point.y)
    }
    
    func reflectInPoint(point:CGPoint) -> CGPoint {
        let dx = (self.x - point.x)
        let dy = (self.y - point.y)
        return CGPoint(x: point.x - dx, y: point.y - dy)
    }
    
    func interpolateToPoint(destinationPoint:CGPoint, percentOfDistance:CGFloat) -> CGPoint {
        let dx = destinationPoint.x - self.x
        let dy = destinationPoint.y - self.y
        return CGPoint(
            x: self.x + percentOfDistance * dx,
            y: self.y + percentOfDistance * dy
        )
    }
    
}

func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
}

func -(lhs:CGPoint, rhs:CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
}

func *(lhs:CGFloat, rhs:CGPoint) -> CGPoint {
    return CGPoint(x: lhs*rhs.x, y: lhs*rhs.y)
}

func *(lhs:CGPoint, rhs:CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x*rhs, y: lhs.y*rhs)
}

func centroidOfCGPoints(points:[CGPoint]) -> CGPoint {
    var x:CGFloat = 0.0
    var y:CGFloat = 0.0
    for point in points {
        x += point.x
        y += point.y
    }
    let count = CGFloat(points.count)
    return CGPoint(x: x/count, y: y/count)
}