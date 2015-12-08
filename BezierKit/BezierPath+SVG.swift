//
//  BezierPath+SVG.swift
//  BezierKit
//
//  Created by Daniel Schlaug on 7/5/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import UIKit

extension BezierPath {
    convenience init(SVGdAttribute:String) {
        self.init()
        
        enum SVGCommand: Character {
            case MoveToAbsolute = "M"
            case MoveToRelative = "m"
            //        TODO Add remaining commands
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
            
            func performOnUIBezierPath(path: BezierPath, withArguments arguments: [CGFloat]) {
                
                var pointArguments: Slice<CGPoint> = []
                for var i = 1; i < arguments.count; i += 2 {
                    let point:CGPoint = CGPoint(x: arguments[i-1], y: arguments[i])
                    pointArguments.append(point)
                }
                
                var cubicBezierPoints: [BezierElement] {
                var cubicBezierPoints: [BezierElement] = []
                    for var i = 2; i < pointArguments.count; i += 3 {
                        cubicBezierPoints.append(BezierElement.CubicBezier(originControl: pointArguments[i-2],
                            destinationControl: pointArguments[i-1],
                            toDestination: pointArguments[i]))
                    }
                    return cubicBezierPoints
                }
                
                var currentControlPoint: CGPoint? = nil
                
                switch self {
                case .MoveToAbsolute:
                    path.add(.MoveToPoint(pointArguments[0]))
                    SVGCommand.addAbsoluteLineToUIBezierPath(path, withPoints: pointArguments[1..<pointArguments.count])
                case .MoveToRelative:
                    let firstPoint = path.currentPoint.relativeToPoint(dx: arguments[0], dy: arguments[1])
                    path.addRelative(.MoveToPoint(firstPoint))
                    SVGCommand.addRelativeLineToUIBezierPath(path, withPoints: pointArguments[1..<pointArguments.count])
                case .LineToAbsolute:
                    SVGCommand.addAbsoluteLineToUIBezierPath(path, withPoints: pointArguments)
                case .LineToRelative:
                    SVGCommand.addRelativeLineToUIBezierPath(path, withPoints: pointArguments)
                case .CubicBezierCurveToAbsolute:
                    SVGCommand.addAbsoluteCubicBezierCurveToUIBezierPath(path, withPoints: cubicBezierPoints)
                case .CubicBezierCurveToRelative:
                    SVGCommand.addRelativeCubicBezierCurveToUIBezierPath(path, withPoints: cubicBezierPoints)
                case .SmoothCurveToAbsolute:
                    for var i = 1; i < pointArguments.count; i += 2 {
                        let destinationControl = pointArguments[i-1]
                        let destination = pointArguments[i]
                        path.addSmoothCurveWith(destinationControl: destinationControl, destination: destination)
                    }
                case .SmoothCurveToRelative:
                    for var i = 1; i < pointArguments.count; i += 2 {
                        let destinationControl = pointArguments[i-1]
                        let destination = pointArguments[i]
                        path.addRelativeSmoothCurveWith(destinationControl: destinationControl, destination: destination)
                    }
                case .ClosePathLower, .ClosePathUpper:
                    path.closePathWithLine()
                }
            }
            
            static func addAbsoluteLineToUIBezierPath(path:BezierPath, withPoints points: Slice<CGPoint>) {
                for point in points {
                    path.add(.LineToPoint(point))
                }
            }
            
            static func addRelativeLineToUIBezierPath(path:BezierPath, withPoints points: Slice<CGPoint>) {
                for relativePoint in points {
                    path.addRelative(.LineToPoint(relativePoint))
                }
            }
            
            static func addAbsoluteCubicBezierCurveToUIBezierPath(path:BezierPath, withPoints elements: [BezierElement]) {
                for element in elements {
                    path.add(element)
                }
            }
            
            static func addRelativeCubicBezierCurveToUIBezierPath(path:BezierPath, withPoints elements: [BezierElement]) {
                for element in elements {
                    path.addRelative(element)
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
                argumentRanges.append(NSRange(range.endIndex..<nextRange.startIndex))
            }
            argumentRanges.append(NSRange(commandRanges[commandRanges.endIndex - 1].endIndex..<countElements(cleanedCommandString)))
            
            let argumentArrays: [[CGFloat]] = argumentRanges.map { (range: NSRange) -> [CGFloat] in
                let matches = argumentRegEx.matchesInString(cleanedCommandString, options: nil, range: range)
                let doubles: [CGFloat] = matches.map {
                    CGFloat(cleanedCommandString[$0.range.startIndex..<$0.range.endIndex].doubleValue)
                }
                return doubles
            }
            
            var i = 0
            for arguments in argumentArrays {
                let commandChar: Character = cleanedCommandString[commandRanges[i].startIndex]
                let command = SVGCommand(rawValue: commandChar)!
                command.performOnUIBezierPath(self, withArguments: arguments)
                ++i
            }
        }
    }
}