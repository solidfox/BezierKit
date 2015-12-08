//
//  UIBezierPath+SVGTest.swift
//  KEX
//
//  Created by Daniel Schlaug on 6/29/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import XCTest
import UIKit
import BezierKit

class UIBezierPath_SVGTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLinearPath() {
        let absolutePath = UIBezierPath(SVGdAttribute: "M100,10 50,50 L100,100 150,50")
        XCTAssertEqual(absolutePath.bezierElements.count, 4)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 75, y: 50)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 125, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 175, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 25, y: 50)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 75, y: 10)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 100, y: 5)))
        
        let relativePath = UIBezierPath(SVGdAttribute: "m100,0 -50,50 l50,50 50,-50")
        XCTAssert(relativePath.containsPoint(CGPoint(x: 75, y: 50)))
        XCTAssert(relativePath.containsPoint(CGPoint(x: 125, y: 50)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 175, y: 50)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 25, y: 50)))
    }
    
    func testCubicBezierPath() {
        let absolutePath = UIBezierPath(SVGdAttribute: "M0,0 C20,0 50,30 50,50")
        XCTAssertEqual(absolutePath.bezierElements.count, 2)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 26, y: 24)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 49, y: 49)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 24, y: 26)))
        
        let absolutePath2 = UIBezierPath(SVGdAttribute: "M50,0 C100,0 100,100 50,100 0,100 0,100 0,50 L50,50")
        XCTAssertEqual(absolutePath2.bezierElements.count, 4)
        XCTAssert(absolutePath2.containsPoint(CGPoint(x: 75, y:75)))
        XCTAssert(absolutePath2.containsPoint(CGPoint(x: 25, y:75)))
        XCTAssertFalse(absolutePath2.containsPoint(CGPoint(x: 45, y: 45)))
        
        let relativePath = UIBezierPath(SVGdAttribute: "m50,0 c50,0 50,100 0,100 -50,0 -50,0 -50,-50 l50,0")
        XCTAssertEqual(relativePath.bezierElements.count, 4)
        XCTAssert(relativePath.containsPoint(CGPoint(x: 75, y:75)))
        XCTAssert(relativePath.containsPoint(CGPoint(x: 25, y:75)))
        XCTAssertFalse(relativePath.containsPoint(CGPoint(x: 45, y: 45)))
    }
    
    func testSmoothCurvePath() {
        let absolutePath = UIBezierPath(SVGdAttribute: "M0,0 S100,0 100,50 0,100 0,100")
        XCTAssertEqual(absolutePath.bezierElements.count, 3)
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 52, y: 23)))
        XCTAssert(absolutePath.containsPoint(CGPoint(x: 52, y: 77)))
        XCTAssertFalse(absolutePath.containsPoint(CGPoint(x: 99, y: 1)))
        
        let relativePath = UIBezierPath(SVGdAttribute: "s100,0 100,50 -100,50 -100,50")
        XCTAssertEqual(relativePath.bezierElements.count, 3)
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
