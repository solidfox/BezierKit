//
//  UIBezierPath+SVG.swift
//  KEX
//
//  Created by Daniel Schlaug on 6/27/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import UIKit



extension UIBezierPath {
    
    convenience init(SVGdAttribute:String) {
        self.init()
        
        self.moveToPoint(CGPoint(x: 0, y: 0))
        
        enum SVGCommand: Character {
            case MoveToAbsolute = "M"
            case MoveToRelative = "m"
            //        TODO
            case LineToAbsolute = "L"
            case LineToRelative = "l"
            //        case HorizontalLineToAbsolute = "H"
            //        case HorizontalLineToRelative = "h"
            //        case VerticalLineToAbsolute = "V"
            //        case VerticalLineToRelative = "v"
            case CubicBezierCurveToAbsolute = "C"
            case CubicBezierCurveToRelative = "c"
            case SmoothCurveToAbsolute = "S"
            case SmoothCurveToRelative = "s"
            case ClosePathUpper = "Z"
            case ClosePathLower = "z"
            
            static let pattern = ~/"[MmLlCcSsZz]"
            
            struct CubicBezierPoint {
                let originControlPoint: CGPoint
                let destinationControlPoint: CGPoint
                let destination: CGPoint
            }
            
            func performOnUIBezierPath(path: UIBezierPath, withArguments arguments: [CGFloat], lastControlPoint optionalLastControlPoint: CGPoint? = nil) -> CGPoint? {
                
                var pointArguments: Slice<CGPoint> = []
                for var i = 1; i < arguments.count; i += 2 {
                    let point:CGPoint = CGPoint(x: arguments[i-1], y: arguments[i])
                    pointArguments += point
                }
                
                var cubicBezierPoints: [CubicBezierPoint] {
                    var cubicBezierPoints: [CubicBezierPoint] = []
                    for var i = 2; i < pointArguments.count; i += 3 {
                        cubicBezierPoints += CubicBezierPoint(originControlPoint: pointArguments[i-2],
                                                              destinationControlPoint: pointArguments[i-1],
                                                              destination: pointArguments[i])
                    }
                    return cubicBezierPoints
                }
                
                func cubicBezierPointsFromSmoothCurveArguments(relativeArguments:Bool = false) -> [CubicBezierPoint] {
                    func reflectControlPoint(cp:CGPoint, inPoint point:CGPoint) -> CGPoint {
                        let dx = (cp.x - point.x)
                        let dy = (cp.y - point.y)
                        return CGPoint(x: point.x - dx, y: point.y - dy)
                    }
                    if relativeArguments {
                        var refPoint = path.currentPoint
                        for i in 0..<pointArguments.count {
                            pointArguments[i] = pointArguments[i].relativeToPoint(refPoint)
                            if i % 2 == 1 {
                                refPoint = pointArguments[i]
                            }
                        }
                    }
                    
                    
                    var cubicBezierPoints: [CubicBezierPoint] = []
                    
                    var lastControlPoint = optionalLastControlPoint ? optionalLastControlPoint! : path.currentPoint
                    var lastDestinationPoint = path.currentPoint
                    
                    for var i = 1; i < pointArguments.count; i += 2 {
                        let originControlPoint = reflectControlPoint(lastControlPoint, inPoint: lastDestinationPoint)
                        cubicBezierPoints += CubicBezierPoint(
                            originControlPoint: originControlPoint,
                            destinationControlPoint: pointArguments[i-1],
                            destination: pointArguments[i])
                        lastControlPoint = pointArguments[i-1]
                        lastDestinationPoint = pointArguments[i]
                    }
                    
                    
                    return cubicBezierPoints
                }
                
                var currentControlPoint: CGPoint? = nil
                
                switch self {
                case .MoveToAbsolute:
                    path.moveToPoint(pointArguments[0])
                    SVGCommand.addAbsoluteLineToUIBezierPath(path, withPoints: pointArguments[1..<pointArguments.count])
                case .MoveToRelative:
                    let firstPoint = path.currentPoint.relativeToPoint(dx: arguments[0], dy: arguments[1])
                    path.moveToPoint(firstPoint)
                    SVGCommand.addRelativeLineToUIBezierPath(path, withPoints: pointArguments[1..<pointArguments.count])
                case .LineToAbsolute:
                    SVGCommand.addAbsoluteLineToUIBezierPath(path, withPoints: pointArguments)
                case .LineToRelative:
                    SVGCommand.addRelativeLineToUIBezierPath(path, withPoints: pointArguments)
                case .CubicBezierCurveToAbsolute:
                    currentControlPoint = SVGCommand.addAbsoluteCubicBezierCurveToUIBezierPath(path, withPoints: cubicBezierPoints)
                case .CubicBezierCurveToRelative:
                    currentControlPoint = SVGCommand.addRelativeCubicBezierCurveToUIBezierPath(path, withPoints: cubicBezierPoints)
                case .SmoothCurveToAbsolute:
                    currentControlPoint = SVGCommand.addAbsoluteCubicBezierCurveToUIBezierPath(path, withPoints: cubicBezierPointsFromSmoothCurveArguments())
                case .SmoothCurveToRelative:
                    currentControlPoint = SVGCommand.addAbsoluteCubicBezierCurveToUIBezierPath(path, withPoints: cubicBezierPointsFromSmoothCurveArguments(relativeArguments: true))
                case .ClosePathLower, .ClosePathUpper:
                    path.closePath()
                default:
                    break
                }
                return currentControlPoint
            }
            
            static func addAbsoluteLineToUIBezierPath(path:UIBezierPath, withPoints points: Slice<CGPoint>) {
                for point in points {
                    path.addLineToPoint(point)
                }
            }
            
            static func addRelativeLineToUIBezierPath(path:UIBezierPath, withPoints points: Slice<CGPoint>) {
                for relativePoint in points {
                    let absolutePoint = relativePoint.relativeToPoint(path.currentPoint)
                    path.addLineToPoint(absolutePoint)
                }
            }
            
            static func addAbsoluteCubicBezierCurveToUIBezierPath(path:UIBezierPath, withPoints points: [CubicBezierPoint]) -> CGPoint {
                for bezPoint in points {
                    path.addCurveToPoint(bezPoint.destination,
                        controlPoint1: bezPoint.originControlPoint,
                        controlPoint2: bezPoint.destinationControlPoint)
                }
                return points[points.endIndex - 1].destinationControlPoint
            }
            
            static func addRelativeCubicBezierCurveToUIBezierPath(path:UIBezierPath, withPoints points: [CubicBezierPoint]) -> CGPoint {
                for bezPoint in points {
                    let relPoint = path.currentPoint
                    
                    path.addCurveToPoint(bezPoint.destination.relativeToPoint(relPoint),
                        controlPoint1: bezPoint.originControlPoint.relativeToPoint(relPoint),
                        controlPoint2: bezPoint.destinationControlPoint.relativeToPoint(relPoint))
                }
                return points[points.endIndex - 1].destinationControlPoint
            }
        }
        
        class SVGToken {
            let command: SVGCommand
            let arguments: [CGFloat] = []
            init(command:SVGCommand, arguments: [CGFloat]) {
                self.command = command
                self.arguments = arguments
            }
            class func performTokenSequence(tokens: [SVGToken], onUIBezierPath path: UIBezierPath) {
                var currentControlPoint: CGPoint? = nil
                for token in tokens {
                    currentControlPoint = token.command.performOnUIBezierPath(path, withArguments: token.arguments, lastControlPoint: currentControlPoint)
                }
            }
        }
        
        let argumentRegEx = ~/"(-?\\d+(\\.\\d+)?|-?\\.\\d+)([eE][\\+\\-]?\\d+)?"
        
        var cleanedCommandString = SVGdAttribute.stringByReplacingMatchesOfRegularExpression(~/"\\s+", withTemplate: " ")
        
        let commandMatches = SVGCommand.pattern.matchesInString(cleanedCommandString,
            options: nil, range: cleanedCommandString.fullRange) as [NSTextCheckingResult]
        let commandRanges = commandMatches.map {$0.range}
        let nCommands: Int = commandRanges.count
        
        if !commandRanges.isEmpty {
            var argumentRanges: [NSRange] = []
            for i in 0..<nCommands-1 {
                let range = commandRanges[i]
                let nextRange = commandRanges[i+1]
                argumentRanges += NSRange(range.endIndex..<nextRange.startIndex)
            }
            argumentRanges += NSRange(commandRanges[commandRanges.endIndex - 1].endIndex..<countElements(cleanedCommandString))
            let argumentArrays: [[CGFloat]] = argumentRanges.map { (range: NSRange) -> [CGFloat] in
                let matches = argumentRegEx.matchesInString(cleanedCommandString, options: nil, range: range)
                let doubles: [CGFloat] = matches.map {
                    CGFloat(cleanedCommandString[$0.range.startIndex..<$0.range.endIndex].doubleValue)
                }
                return doubles
            }
            var tokens: [SVGToken] = []
            var i = 0
            for arguments in argumentArrays {
                let commandChar: Character = cleanedCommandString[commandRanges[i].startIndex]
                let token = SVGToken(command: SVGCommand.fromRaw(commandChar)!, arguments: arguments)
                tokens += token
                ++i
            }
            SVGToken.performTokenSequence(tokens, onUIBezierPath: self)
        }
    }
}