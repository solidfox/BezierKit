//
//  BezierPath.swift
//  BezierKit
//
//  Created by Daniel Schlaug on 7/5/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import UIKit

extension UIBezierPath {
    func addBezierElement(element: BezierElement) {
        switch element {
        case .MoveToPoint(let dest):
            self.moveToPoint(dest)
        case .LineToPoint(let dest):
            self.addLineToPoint(dest)
        case let .QuadraticBezier(control: controlPoint, toDestination: dest):
            self.addQuadCurveToPoint(dest, controlPoint: controlPoint)
        case let .CubicBezier(originControl: originControl, destinationControl: destinationControl, toDestination: dest):
            self.addCurveToPoint(dest, controlPoint1: originControl, controlPoint2: destinationControl)
        }
    }
}

//class BezierPointSequence:Sequence {
//    class BezierPointGenerator: Generator {
//        let bezierElements: BezierElement[]
//        var nextElementIndex = 0
//        var elementPoints: CGPoint[] = []
//        var nextPointIndex = 0
//        
//        init(bezierElements: BezierElement[]) {
//            self.bezierElements = bezierElements
//        }
//        
//        func _nextElement() -> Bool {
//            if nextElementIndex >= bezierElements.count {
//                return false
//            }
//            elementPoints = bezierElements[nextElementIndex].points
//            ++nextElementIndex
//            nextPointIndex = 0
//            return true
//        }
//        
//        func next() -> CGPoint? {
//            if nextPointIndex >= elementPoints.count {
//                if !_nextElement() {
//                    return nil
//                }
//            }
//            return elementPoints[nextPointIndex++]
//        }
//    }
//    
//    let bezierElements: BezierElement[]
//    
//    init(bezierElements: BezierElement[]) {
//        self.bezierElements = bezierElements
//    }
//    
//    func generate() -> BezierPointGenerator {
//        return BezierPointGenerator(bezierElements: bezierElements)
//    }
//}

class BezierPath {
    var _lastSubpathStartIndex = 0
    
    var _bezierElements: [BezierElement] = []
    var bezierElements: [BezierElement] {return _bezierElements}
    var empty: Bool = true
    
    var bezierPoints: [CGPoint] {
        var points: [CGPoint] = []
        for element in _bezierElements {
            points.appendContentsOf(element.points)
        }
        return points
    }
    
    var bounds: CGRect {return UIBezierPath.bounds}
    
    var currentElement: BezierElement {return _bezierElements[_bezierElements.count - 1]}
    var currentPoint: CGPoint {return currentElement.destination}
    var firstPoint: CGPoint {return _bezierElements[0].destination}

    let _UIBezierPath = UIKit.UIBezierPath()
    var UIBezierPath: UIKit.UIBezierPath {return _UIBezierPath}
    var CGPath: UIKit.CGPath {return UIBezierPath.CGPath}
    
    init() {
        _bezierElements.append(BezierElement.MoveToPoint(CGPoint(x: 0, y: 0)))
        UIBezierPath.moveToPoint(CGPoint(x: 0, y: 0))
    }
    
    // MARK Designated Mutating Functions
    func add(element: BezierElement) {
        empty = false
        switch element {
        case .MoveToPoint(_):
            switch self.currentElement {
            case .MoveToPoint(_):
                _bezierElements.removeLast()
                _lastSubpathStartIndex = _bezierElements.count
            default:
                break
            }
        default:
            break
        }
        _bezierElements.append(element)
        _UIBezierPath.addBezierElement(element)
        
        // Flush Cache
        _intermediatePoints = nil
        _length = nil
        _centroid = nil
    }
    
    func applyTransform(transform: CGAffineTransform) {
        _bezierElements = _bezierElements.map {$0.applyTransform(transform)}
        UIBezierPath.applyTransform(transform)
        
        // Transform Cache
        _intermediatePoints = _intermediatePoints?.map {CGPointApplyAffineTransform($0, transform)}
        _length = nil // TODO can this be done using bounds?
        _centroid = _centroid != nil ? CGPointApplyAffineTransform(_centroid!, transform) : nil
    }
    
    
    // MARK Convenience Mutating Functions
    func addRelative(relativeElement: BezierElement) {
        add(relativeElement.toAbsoluteWithReferenceElement(currentElement))
    }
    
    func addSmoothCurveWith(destinationControl destinationControl:CGPoint, destination:CGPoint) {
        let newDestinationControl = destinationControl
        let newDestination = destination
        
        
        var newOriginControl: CGPoint = currentElement.destination
        switch currentElement {
        case .MoveToPoint(_), .LineToPoint(_), .QuadraticBezier(_):
            break
        case let .CubicBezier(originControl: _, destinationControl: lastDestinationControl, toDestination: lastDestination):
            newOriginControl = lastDestinationControl.reflectInPoint(lastDestination)
        }
        
        add(BezierElement.CubicBezier(originControl: newOriginControl, destinationControl: newDestinationControl, toDestination: newDestination))
    }
    
    func addRelativeSmoothCurveWith(destinationControl destinationControl:CGPoint, destination:CGPoint) {
        addSmoothCurveWith(destinationControl: destinationControl.relativeToPoint(currentElement.destination), destination: destination.relativeToPoint(currentElement.destination))
    }
    
    func containsPoint(point: CGPoint) -> Bool {
        return UIBezierPath.containsPoint(point)
    }
    
    func closePathWithLine() {
        switch currentElement {
        case .MoveToPoint(_):
            break
        default:
            let startElement = _bezierElements[_lastSubpathStartIndex]
            add(BezierElement.LineToPoint(startElement.destination))
        }
    }
    
    func closePathWithSmoothCurve() {
        switch currentElement {
        case .MoveToPoint(_):
            break
        default:
            let startElement = _bezierElements[_lastSubpathStartIndex]
            let secondElement = _bezierElements[_lastSubpathStartIndex + 1]
            
            var originControl = currentElement.destination
            switch currentElement {
            case .MoveToPoint(_), .LineToPoint(_), .QuadraticBezier(_):
                break
            case let .CubicBezier(originControl: _, destinationControl: lastDestinationControl, toDestination: lastDestination):
                originControl = lastDestinationControl.reflectInPoint(lastDestination)
            }
            
            var destinationControl = startElement.destination
            switch secondElement {
            case .MoveToPoint(_), .LineToPoint(_), .QuadraticBezier(_):
                break
            case let .CubicBezier(originControl: firstOriginControl, destinationControl: _, toDestination: _):
                destinationControl = firstOriginControl.reflectInPoint(startElement.destination)
            }
            
            add(BezierElement.CubicBezier(
                originControl: originControl,
                destinationControl: destinationControl,
                toDestination: startElement.destination))
        }
    }
    
    // Cache variables
    var _intermediatePoints: [CGPoint]?
    var intermediatePoints: [CGPoint] {
        let nPoints = 10   //Points per
    
        // Check cache
        if _intermediatePoints == nil {
        
        // Find the number of bezierSegments
        var nCurveSegments = 0
        var nLinearSegments = 0
        for element in self.bezierElements {
            switch element {
            case .CubicBezier:
                ++nCurveSegments
            case .QuadraticBezier:
                ++nCurveSegments
            case .LineToPoint, .MoveToPoint:
                ++nLinearSegments
                break
            }
        }
        let totalNumberOfPoints = nLinearSegments + nCurveSegments * nPoints

        
        let kSteps = nPoints - 1
        var points = [CGPoint](count:totalNumberOfPoints, repeatedValue:CGPointZero)
        
        var _cubicConstants:(Array<Array<CGFloat>>)?
        var cubicConstants:[[CGFloat]] {
            if _cubicConstants == nil {
                _cubicConstants = (1...nPoints).map {
                    let t: CGFloat = CGFloat($0) / CGFloat(nPoints)
                    let s: CGFloat = (1.0-t)
                    return [
                        s * s * s,
                        3.0 * s * s * t,
                        3.0 * s * t * t,
                        t * t * t
                    ]
                }
            }
            return _cubicConstants!
        }

        var origin = CGPointZero
        var nextStep = 0
        
        for element in self.bezierElements {
            switch element {
            case let .CubicBezier(
                originControl: originControl,
                destinationControl: destinationControl,
                toDestination: dest
                ):
                for (index, step) in (nextStep...nextStep+kSteps).enumerate() {
                    let C = cubicConstants[index]
                    var point = C[0]*origin + C[1]*originControl    //\
                    point = point + C[2]*destinationControl         //| Ugly swift bug workaround
                    point = point + C[3]*dest                       ///
                    points[step] = point
                }
                nextStep = nextStep+kSteps+1
                origin = dest
           	case let .QuadraticBezier(control:_, toDestination:destination):
                // WARNING Unsupported part
                fatalError("QuadraticBezier not supported")
            case let .LineToPoint(destination):
                points[nextStep] = destination
                origin = destination
                ++nextStep
            case let .MoveToPoint(destination):
                points[nextStep] = destination
                origin = destination
                ++nextStep
            default:
                fatalError("Unsupported bezierElements for point generation")
            }
        }
        
        _intermediatePoints = points
            
        }
        return _intermediatePoints!
    }
    
    var _length: CGFloat?
    func length() -> CGFloat {
        if _length == nil {
            var length = CGFloat(0.0)
            var lastPoint = intermediatePoints[0]
            for point in intermediatePoints {
                length += distance(lastPoint, p2: point)
                lastPoint = point
            }
            _length = length
        }
        return _length!
        
        // OPTIMIZE Save length percent array for binary search
    }
    
    func pointAtPercent(percent:CGFloat) -> CGPoint {
        return pointsAtPercentages([percent])[0]
        
        // OPTIMIZE if percent > .5 go backwards
    }
    
    func pointsAtPercentages(percentages:[CGFloat]) -> [CGPoint] {
        let sortedPercentages = percentages.sort() {$0 < $1}
        assert(0 <= sortedPercentages[0] && sortedPercentages[sortedPercentages.count-1] <= 1, "Percentages must be between 0 and 1")
        
        if self.empty {
            return [CGPoint](count:percentages.count, repeatedValue:CGPointZero)
        } else if self.bezierElements.count == 1 || (self.bounds.height == 0 && self.bounds.width == 0) {
            return [CGPoint](count:percentages.count, repeatedValue:firstPoint)
        }
        
        var outPoints = [CGPoint](count:percentages.count, repeatedValue:CGPointZero)
        
        let length = self.length()
        var intermediatePointIndex = 0
        var currentDistance: CGFloat = 0
        var currentPoint: CGPoint {return intermediatePoints[intermediatePointIndex]}
        var nextPoint: CGPoint {return intermediatePoints[intermediatePointIndex + 1]}
        var deltaDistance: CGFloat = distance(currentPoint, p2: nextPoint)
        var newDistance = currentDistance + deltaDistance
        for (percentIndex, percentage) in sortedPercentages.enumerate() {
            if percentage == 1 {outPoints[percentIndex] = self.currentPoint; continue}
            if percentage == 0 {outPoints[percentIndex] = self.firstPoint; continue}
            let targetDistance = length * percentage
            while newDistance < targetDistance {
                currentDistance = newDistance
                ++intermediatePointIndex
                if intermediatePointIndex + 1 >= intermediatePoints.count {
                    NSLog("pointAtPercent could not handle percent: \(percentage)")
                    NSLog("targetDistance: \(targetDistance)")
                    NSLog("currentDistance: \(currentDistance)")
                    NSLog("currentPoint: \(currentPoint)")
                    NSLog("currentDistance == targetDistance = \(currentDistance == targetDistance)")
                    assert(false, "pointAtPercent should hit targetDistance before hitting the last intermediatePointIndex")
                    break
                }
                deltaDistance = distance(currentPoint, p2: nextPoint)
                newDistance = currentDistance + deltaDistance
            }
            let distanceLeftFromLastPoint = targetDistance - currentDistance
            outPoints[percentIndex] = currentPoint.interpolateToPoint(nextPoint, percentOfDistance: distanceLeftFromLastPoint / deltaDistance)
        }
        
        return outPoints
    }
    
    var _centroid: CGPoint?
    func centroid() -> CGPoint {
        if _centroid == nil {
            let nSamples = 129
            let percentages = (0..<nSamples).map {CGFloat($0)/CGFloat(nSamples-1)}
            let points = pointsAtPercentages(percentages)
            _centroid = centroidOfCGPoints(points)
        }
        return _centroid!
    }
    
    func compareTo(otherPath other: BezierPath, withInvariances invariances: [Invariant]) -> CGFloat {
        if self.empty && other.empty {return 1}
        if self.empty != other.empty {return 0}
        
        var transformSelf = CGAffineTransformIdentity
        var transformOther = CGAffineTransformIdentity
        
        let greatestWidth = max(self.bounds.width, other.bounds.width)
        let greatestHeight = max(self.bounds.height, other.bounds.height)
        let normalizationMetric: CGFloat = max(greatestHeight, greatestWidth)
        
        if normalizationMetric == 0 {
            // We are dealing with two points
            let positionInvarianceEnabled = invariances.indexOf(.Position)
            if (positionInvarianceEnabled != nil) {
                return 1
            } else {
                return self.firstPoint == other.firstPoint ? 1 : 0
            }
        }
        
        // Resample paths
        let resamplingDetail = 129
        let percentages = (0...resamplingDetail-1).map {CGFloat($0)/CGFloat(resamplingDetail-1)}
        let resampledSelf = self.pointsAtPercentages(percentages)
        let resampledOther = other.pointsAtPercentages(percentages)
        
        // Position invariant?
        if invariances.indexOf(.Position) != nil {
            // OPTIMIZE use centroid of resampled points instead of whole path if paths centroid is not pregenerated
            transformSelf = CGAffineTransformConcat(
                transformSelf,
                CGAffineTransformMakeTranslation(-self.centroid().x, -self.centroid().y)
            )
            transformOther = CGAffineTransformConcat(
                transformOther,
                CGAffineTransformMakeTranslation(-other.centroid().x, -other.centroid().y)
            )
        }
        
        // Scale invariant?
        if invariances.indexOf(.Scale) != nil && !(
            // Check for point-curves
            self.bounds.width  == 0 && self.bounds.height  == 0 ||
            other.bounds.width == 0 && other.bounds.height == 0
            ) {
            // OPTIMIZE store bounds?
            var scaleSelfTransform = CGAffineTransformIdentity
            var scaleOtherTransform = CGAffineTransformIdentity
            
            if greatestWidth > greatestHeight {
                if self.bounds.width > other.bounds.width {
                    let ratio = self.bounds.width / (other.bounds.width != 0 ? other.bounds.width : other.bounds.height)
                    scaleOtherTransform = CGAffineTransformMakeScale(ratio, ratio)
                } else {
                    let ratio = other.bounds.width / (self.bounds.width != 0 ? self.bounds.width : self.bounds.height)
                    scaleSelfTransform = CGAffineTransformMakeScale(ratio, ratio)
                }
            } else {
                if self.bounds.height > other.bounds.height {
                    let ratio = self.bounds.height / (other.bounds.height != 0 ? other.bounds.height : other.bounds.width)
                    scaleOtherTransform = CGAffineTransformMakeScale(ratio, ratio)
                } else {
                    let ratio = other.bounds.height / (self.bounds.height != 0 ? self.bounds.height : self.bounds.width)
                    scaleSelfTransform = CGAffineTransformMakeScale(ratio, ratio)
                }
            }
            transformSelf = CGAffineTransformConcat(transformSelf, scaleSelfTransform)
            transformOther = CGAffineTransformConcat(transformOther, scaleOtherTransform)
        }
        
        var avgDistance:CGFloat = 0
        for index in resampledSelf.indices {
//            NSLog("\(resampledSelf[index]) - \(resampledOther[index])")
            let selfPoint = CGPointApplyAffineTransform(resampledSelf[index], transformSelf)
            let otherPoint = CGPointApplyAffineTransform(resampledOther[index], transformOther)
//            if index == 0 || index == 128 {
//                NSLog("\(index) - \(selfPoint) - \(otherPoint)")
//                NSLog("\(index) - \(self.centroid()) - \(other.centroid())")
//            }
//            NSLog("\(selfPoint) - \(otherPoint)")
            avgDistance += distance(selfPoint, p2: otherPoint)
        }
        avgDistance = avgDistance / CGFloat(resamplingDetail)
        
        let normalizationFactor = sqrt(normalizationMetric*normalizationMetric*2)/2
        
        let score = CGFloat(1) - avgDistance / normalizationFactor
        
        if !score.isFinite {
//            let debugSelf = self
//            let debugOther = other
            NSLog("Invalid score: \(score)")
            assert(false, "this should not happen")
        }
        
        return score
    }

    func debugQuickLookObject() -> AnyObject {
        return self.UIBezierPath
    }
}

enum Invariant {
    case Position, Scale // TODO AspecRatioInvariant, RotationInvariant
    static var All: [Invariant] = [Invariant.Position, Invariant.Scale]
}