//
//  BezierPath+SVGTest.swift
//  KEX
//
//  Created by Daniel Schlaug on 7/05/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import XCTest
import UIKit
import BezierKit

class BezierPath_SVGTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLinearPath() {
        let absolutePath = BezierPath(SVGdAttribute: "M100,10 50,50 L100,100 150,50")
        XCTAssertEqual(absolutePath.bezierElements.count, 4)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 75, y: 50)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 125, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 175, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 25, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 75, y: 10)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 100, y: 5)))
        
        let relativePath = BezierPath(SVGdAttribute: "m100,0 -50,50 l50,50 50,-50")
        XCTAssert(relativePath.containsPoint(CGPoint(x: 75, y: 50)))
        XCTAssert(relativePath.containsPoint(CGPoint(x: 125, y: 50)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 175, y: 50)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 25, y: 50)))
    }
    
    func testTrickyCurve() {
        let curve = BezierPath(SVGdAttribute: "M13,50.5c1.75,0.62,3.25,0.88,5,0.25c0.97-0.35,9.75-3.5,11.25-4s2.86,1.16,2,2.75c-7.62,14.12-7.38,9.25-0.25,19c0.99,1.35,1,3.25-0.5,4.5s-6.88,6-11.25,9.25")
        let points = [
            //M
            CGPoint(x: 13, y: 50.5),
            //c
            CGPoint(x: 14.75, y: 51.12),
            CGPoint(x: 16.25, y: 51.38),
            CGPoint(x: 18, y: 50.75),
            //c
            CGPoint(x: 18.97, y: 50.40),
            CGPoint(x: 27.75, y: 47.25),
            CGPoint(x: 29.25, y: 46.75),
            //s
            CGPoint(x: 30.75, y: 46.25),
            CGPoint(x: 32.11, y: 47.91),
            CGPoint(x: 31.25, y: 49.5)
        ]
        for i in indices(points) {
            XCTAssertEqual(points[i], curve.bezierPoints[i], "Point \(i+1) was wrong")
        }
    }
    
    func testCubicBezierPath() {
        
        let absolutePath = BezierPath(SVGdAttribute: "M0,0 C20,0 50,30 50,50")
        XCTAssertEqual(absolutePath.bezierElements.count, 2)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 26, y: 24)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 49, y: 49)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 24, y: 26)))
        
        let absolutePath2 = BezierPath(SVGdAttribute: "M50,0 C100,0 100,100 50,100 0,100 0,100 0,50 L50,50")
        XCTAssertEqual(absolutePath2.bezierElements.count, 4)
        XCTAssert(absolutePath2.containsPoint(CGPoint(x: 75, y:75)))
        XCTAssert(absolutePath2.containsPoint(CGPoint(x: 25, y:75)))
        XCTAssertFalse(absolutePath2.containsPoint(CGPoint(x: 45, y: 45)))
        
        let relativePath = BezierPath(SVGdAttribute: "m50,0 c50,0 50,100 0,100 -50,0 -50,0 -50,-50 l50,0")
        XCTAssertEqual(relativePath.bezierElements.count, 4)
        XCTAssert(relativePath.containsPoint(CGPoint(x: 75, y:75)))
        XCTAssert(relativePath.containsPoint(CGPoint(x: 25, y:75)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 45, y: 45)))
    }
    
    func testSmoothCurvePath() {
        let absolutePath = BezierPath(SVGdAttribute: "M0,0 S100,0 100,50 0,100 0,100")
        XCTAssertEqual(absolutePath.bezierElements.count, 3)
        XCTAssertEqual(absolutePath.bezierPoints.count, 7)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 52, y: 23)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 52, y: 77)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 99, y: 1)))
        
        let relativePath = BezierPath(SVGdAttribute: "s100,0 100,50 -100,50 -100,50")
        XCTAssertEqual(relativePath.bezierElements.count, 3)
        XCTAssertEqual(relativePath.bezierPoints.count, 7)
        XCTAssert(relativePath.containsPoint(CGPoint(x: 52, y: 23)))
        XCTAssert(relativePath.containsPoint(CGPoint(x: 52, y: 77)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 99, y: 1)))
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measureBlock() {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
