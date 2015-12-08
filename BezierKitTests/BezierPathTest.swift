//
//  BezierPathTest.swift
//  BezierKit
//
//  Created by Daniel Schlaug on 7/5/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import XCTest
import UIKit

class BezierPathTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConvenienceAccessors() {
        let path = BezierPath(SVGdAttribute: "M368,781 L65,78")
        XCTAssertEqual(path.firstPoint, CGPoint(x: 368, y: 781))
        switch path.currentElement {
        case let BezierElement.LineToPoint(point):
            XCTAssertEqual(point, CGPoint(x: 65, y: 78))
        default:
            XCTFail("currentElement was not a LineToPoint")
        }
        XCTAssertEqual(path.currentElement.destination, CGPoint(x: 65, y: 78))
    }
    
    func testLinearPath() {
        let absolutePath = BezierPath(SVGdAttribute: "M100,10 50,50 L100,100 150,50")
        XCTAssertEqual(absolutePath.bezierElements.count, 4)
        let points: [CGPoint] = [
            CGPoint(x: 100, y: 10),
            CGPoint(x: 50, y: 50),
            CGPoint(x: 100, y: 100),
            CGPoint(x: 150, y: 50)
        ]
        var i = 0
        for point in absolutePath.bezierPoints {
            XCTAssertEqual(point, points[i])
            ++i
        }
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 75, y: 50)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 125, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 175, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 25, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 75, y: 10)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 100, y: 5)))
        
        let relativeUIPath = BezierPath(SVGdAttribute: "m100,0 -50,50 l50,50 50,-50").UIBezierPath
        XCTAssert(relativeUIPath.containsPoint(CGPoint(x: 75, y: 50)))
        XCTAssert(relativeUIPath.containsPoint(CGPoint(x: 125, y: 50)))
        XCTAssertFalse(relativeUIPath.containsPoint(CGPoint(x: 175, y: 50)))
        XCTAssertFalse(relativeUIPath.containsPoint(CGPoint(x: 25, y: 50)))
    }
    
    func testCubicBezierPath() {
        let absolutePath = BezierPath()
        absolutePath.add(BezierElement.CubicBezier(
            originControl: CGPoint(x: 20, y: 0),
            destinationControl: CGPoint(x: 50, y: 30),
            toDestination: CGPoint(x: 50, y: 50)))
        
        var pointsShouldBe: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 20, y: 0),
            CGPoint(x: 50, y: 30),
            CGPoint(x: 50, y: 50)
        ]
        var i = 0
        for point in absolutePath.bezierPoints {
            XCTAssertEqual(point, pointsShouldBe[i])
            ++i
        }
        
        XCTAssertEqual(absolutePath.bezierElements.count, 2)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 26, y: 24)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 49, y: 49)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 24, y: 26)))
        
        let absolutePath2 = BezierPath(SVGdAttribute: "M50,0 C100,0 100,100 50,100 0,100 0,100 0,50 L50,50")
        pointsShouldBe = [
            CGPoint(x: 50, y: 0),
            CGPoint(x: 100, y: 0),
            CGPoint(x: 100, y: 100),
            CGPoint(x: 50, y: 100),
            CGPoint(x: 0, y: 100),
            CGPoint(x: 0, y: 100),
            CGPoint(x: 0, y: 50),
            CGPoint(x: 50, y: 50)
        ]
        i = 0
        for point in absolutePath2.bezierPoints {
            XCTAssertEqual(point, pointsShouldBe[i])
            ++i
        }
        XCTAssertEqual(absolutePath2.bezierElements.count, 4)
        XCTAssert(absolutePath2.containsPoint(CGPoint(x: 75, y:75)))
        XCTAssert(absolutePath2.containsPoint(CGPoint(x: 25, y:75)))
        XCTAssertFalse(absolutePath2.containsPoint(CGPoint(x: 45, y: 45)))
        
        let relativePath = BezierPath()
        relativePath.add(BezierElement.MoveToPoint(CGPoint(x: 50, y: 0)))
        relativePath.addRelative(BezierElement.CubicBezier(
            originControl: CGPoint(x: 50, y: 0),
            destinationControl: CGPoint(x: 50, y: 100),
            toDestination: CGPoint(x: 0, y: 100)))
        relativePath.addRelative(BezierElement.CubicBezier(
            originControl: CGPoint(x: -50, y: 0),
            destinationControl: CGPoint(x: -50, y: 0),
            toDestination: CGPoint(x: -50, y: -50)))
        relativePath.addRelative(BezierElement.LineToPoint(CGPoint(x: 50, y: 0)))
        
        let relativeUIPath = relativePath.UIBezierPath
        XCTAssertEqual(relativePath.bezierElements.count, 4)
        XCTAssert(relativeUIPath.containsPoint(CGPoint(x: 75, y:75)))
        XCTAssert(relativeUIPath.containsPoint(CGPoint(x: 25, y:75)))
        XCTAssertFalse(relativeUIPath.containsPoint(CGPoint(x: 45, y: 45)))
    }
    
    func testSmoothCurveUIPath() {
        let absolutePath = BezierPath(SVGdAttribute: "M0,0 S100,0 100,50 0,100 0,100")
        XCTAssertEqual(absolutePath.bezierElements.count, 3)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 52, y: 23)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 52, y: 77)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 99, y: 1)))
        
        let relativePath = BezierPath(SVGdAttribute: "s100,0 100,50 -100,50 -100,50")
        XCTAssertEqual(relativePath.bezierElements.count, 3)
        XCTAssert(relativePath.containsPoint(CGPoint(x: 52, y: 23)))
        XCTAssert(relativePath.containsPoint(CGPoint(x: 52, y: 77)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 99, y: 1)))
    }

    func testCGPointExtensions() {
        XCTAssertEqual(CGPoint(x: 1, y: 2) * 5, CGPoint(x: 5, y: 10))
        XCTAssertEqual(CGPoint(x: -1, y:-2) * 5 + CGPoint(x: -4, y: -8), CGPoint(x: -9, y: -18))
        XCTAssertEqual(CGPoint(x: 0, y: 1).interpolateToPoint(CGPoint(x: 2, y: 3), percentOfDistance: 0.5), CGPoint(x: 1, y: 2))
    }
    
    func testIntermediatePoints() {
        let approxCircle = BezierPath(SVGdAttribute: "M 16 128 C 16 66 66 16 128 16 S 240 66 240 128 190 240 128 240 16 190 16 128")
        XCTAssertEqual(approxCircle.bezierElements.count, 5)
        let nSegments = 4
        let points = approxCircle.intermediatePoints
        XCTAssertEqual(points.count, 1+10*nSegments)
        var failed: [Int] = []
        for (index, point) in enumerate(points) {
            if point == CGPointZero {
                NSLog("Point \(index) should not be zero")
                failed += index
            }
        }
        XCTAssertEqual(failed.count, 0, "Points should not be zero: \(failed)")
        let path = UIBezierPath()
        for point in points {
            path.addArcWithCenter(point, radius: 10, startAngle: 0, endAngle: 7, clockwise: true)
        }
        let debugPath = path
        XCTAssertEqual(points[0], points[points.count - 1], "First and last point should be equal.")
    }
    
    func testLength() {
        // Circle with radius 112
        let approxCircle = BezierPath(SVGdAttribute: "M 16 128 C 16 66 66 16 128 16 S 240 66 240 128 190 240 128 240 16 190 16 128")
        let length = approxCircle.length()
        NSLog("\(length)")
        let circumfence = CGFloat(112.0*2.0*M_PI)
        XCTAssertEqualWithAccuracy(length, circumfence, circumfence * 0.01)
    }
    
    func testPointAtPercent() {
        // Circle with radius 112
        let approxCircle = BezierPath(SVGdAttribute: "M 16 128 C 16 66 66 16 128 16 S 240 66 240 128 190 240 128 240 16 190 16 128")
        let path = UIBezierPath()
        for point in approxCircle.pointsAtPercentages((0...20).map {CGFloat($0)/20.0}) {
            path.addArcWithCenter(point, radius: 5, startAngle: 0, endAngle: 7, clockwise: true)
        }
        let debugPath = path
        let quarterPoint = approxCircle.pointAtPercent(0.25)
        XCTAssertEqualWithAccuracy(quarterPoint.x, 128.0, 1)
        XCTAssertEqualWithAccuracy(quarterPoint.y, 16.0, 1)
        XCTAssertEqual(approxCircle.pointAtPercent(1), CGPoint(x: 16, y: 128))
        XCTAssertEqual(approxCircle.pointAtPercent(0), CGPoint(x: 16, y: 128))
        let emptyPath = BezierPath()
        XCTAssertEqual(emptyPath.pointAtPercent(0.54), CGPointZero)
        XCTAssertEqual(emptyPath.pointAtPercent(0), CGPointZero)
        XCTAssertEqual(emptyPath.pointAtPercent(1), CGPointZero)
        var onePointPath = BezierPath(SVGdAttribute: "M 12, 12")
        XCTAssertEqual(onePointPath.pointAtPercent(0.3), CGPoint(x: 12, y: 12))
        XCTAssertEqual(onePointPath.pointAtPercent(0), CGPoint(x: 12, y: 12))
        XCTAssertEqual(onePointPath.pointAtPercent(1), CGPoint(x: 12, y: 12))
        onePointPath = BezierPath(SVGdAttribute: "M 12,12 12,12 12,12")
        XCTAssertEqual(onePointPath.centroid(), CGPoint(x: 12, y: 12))
    }
    
    func testCentroid() {
        // Circle with radius 112 and center 128 128
        let approxCircle = BezierPath(SVGdAttribute: "M 16 128 C 16 66 66 16 128 16 S 240 66 240 128 190 240 128 240 16 190 16 128")
        let centroid = approxCircle.centroid()
        XCTAssertEqualWithAccuracy(centroid.x, 128, 1)
        XCTAssertEqualWithAccuracy(centroid.y, 128, 1)
        let horizontalLine = BezierPath(SVGdAttribute: "M 10 10 20 10")
        XCTAssertEqual(horizontalLine.centroid(), CGPoint(x:15, y:10))
        let emptyPath = BezierPath()
        XCTAssertEqual(emptyPath.centroid(), CGPointZero)
        var onePointPath = BezierPath(SVGdAttribute: "M 12, 12")
        XCTAssertEqual(onePointPath.centroid(), CGPoint(x: 12, y: 12))
        onePointPath = BezierPath(SVGdAttribute: "M 12,12 12,12 12,12")
        XCTAssertEqual(onePointPath.centroid(), CGPoint(x: 12, y: 12))
    }
    
    func testCompareTo() {
        // Lines
        let horizontalLine = BezierPath(SVGdAttribute: "M 10 10 20 10")
        let longerHorizontalLine = BezierPath(SVGdAttribute: "M 10 10 40 10")
        let verticalLine = BezierPath(SVGdAttribute: "M 10 10 10 20")
        XCTAssertEqual(horizontalLine.compareTo(otherPath: horizontalLine, withInvariances: []), 1)
        XCTAssertEqual(horizontalLine.compareTo(otherPath: horizontalLine, withInvariances: [Invariant.Position, Invariant.Scale]), 1)
        XCTAssertEqual(horizontalLine.compareTo(otherPath: longerHorizontalLine, withInvariances: [Invariant.Position, Invariant.Scale]), 1)
        XCTAssertLessThan(horizontalLine.compareTo(otherPath: longerHorizontalLine, withInvariances: []), 0.8)
        XCTAssertLessThan(horizontalLine.compareTo(otherPath: verticalLine, withInvariances: [Invariant.Position, Invariant.Scale]), 0.5)
        
        // Circles
        // Circle with radius 112 and center 128 128
        let largeCircle = BezierPath(SVGdAttribute: "M 16 128 C 16 66 66 16 128 16 S 240 66 240 128 190 240 128 240 16 190 16 128")
        var smallCircle = BezierPath(SVGdAttribute: "M 16 128 C 16 66 66 16 128 16 S 240 66 240 128 190 240 128 240 16 190 16 128")
        smallCircle.applyTransform(CGAffineTransformMakeScale(0.001, 0.001))
        XCTAssertLessThan(largeCircle.compareTo(otherPath: smallCircle, withInvariances: [Invariant.Position]), 0.3)
        
        // Small Paths
        let emptyPath = BezierPath()
        XCTAssertEqual(emptyPath.compareTo(otherPath: horizontalLine, withInvariances: Invariant.All), 0.0)
        var onePointPath = BezierPath(SVGdAttribute: "M 12, 12")
        let veryDifferentPointPath = BezierPath(SVGdAttribute: "M 200, 200")
        XCTAssertLessThanOrEqual(onePointPath.compareTo(otherPath: veryDifferentPointPath, withInvariances: []), 0.0)
        XCTAssertLessThanOrEqual(onePointPath.compareTo(otherPath: veryDifferentPointPath, withInvariances: Invariant.All), 1.0)
        XCTAssertEqual(onePointPath.compareTo(otherPath: onePointPath, withInvariances: []), 1)
        XCTAssertLessThan(onePointPath.compareTo(otherPath: longerHorizontalLine, withInvariances: Invariant.All), 0.65)
        XCTAssertLessThan(onePointPath.compareTo(otherPath: longerHorizontalLine, withInvariances: []), 0.5)
        
        onePointPath = BezierPath(SVGdAttribute: "M 12,12 12,12 12,12")
        XCTAssertLessThanOrEqual(onePointPath.compareTo(otherPath: veryDifferentPointPath, withInvariances: []), 0.0)
        XCTAssertLessThanOrEqual(onePointPath.compareTo(otherPath: veryDifferentPointPath, withInvariances: Invariant.All), 1.0)
        XCTAssertEqual(onePointPath.compareTo(otherPath: onePointPath, withInvariances: []), 1)
        XCTAssertLessThan(onePointPath.compareTo(otherPath: longerHorizontalLine, withInvariances: Invariant.All), 0.65)
        XCTAssertLessThan(onePointPath.compareTo(otherPath: longerHorizontalLine, withInvariances: []), 0.5)
    }
    
    func testApplyTransform() {
        let line = BezierPath(SVGdAttribute: "M -10 0 10 0")
        line.applyTransform(CGAffineTransformMakeScale(0.5, 0.5))
        XCTAssertEqual(line.firstPoint, CGPoint(x: -5, y: 0))
        XCTAssertEqual(line.currentPoint, CGPoint(x: 5, y: 0))
    }
}


