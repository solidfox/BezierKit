//
//  BezierElement.swift
//  BezierKit
//
//  Created by Daniel Schlaug on 7/9/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import UIKit

enum BezierElement {
    case MoveToPoint(CGPoint)
    case LineToPoint(CGPoint)
    case QuadraticBezier(control:CGPoint, toDestination:CGPoint)
    case CubicBezier(originControl:CGPoint, destinationControl:CGPoint, toDestination:CGPoint)
    
    var destination: CGPoint {
    switch self {
    case .MoveToPoint(let dest):
        return dest
    case .LineToPoint(let dest):
        return dest
    case .QuadraticBezier(control: _, toDestination: let dest):
        return dest
    case .CubicBezier(originControl: _, destinationControl: _, toDestination: let dest):
        return dest
        }
    }
    
    var points: [CGPoint] {
    var points:[CGPoint] = []
        switch self {
        case .MoveToPoint(let dest):
            points = [dest]
        case .LineToPoint(let dest):
            points = [dest]
        case let .QuadraticBezier(control: cp, toDestination: dest):
            points = [cp,dest]
        case let .CubicBezier(originControl: ocp, destinationControl: dcp, toDestination: dest):
            points = [ocp, dcp, dest]
        }
        return points
    }
    
    func toAbsoluteWithReferenceElement(referenceElement:BezierElement) -> BezierElement {
        var absoluteElement = self
        let referencePoint = referenceElement.destination
        switch self {
        case .MoveToPoint(let dest):
            absoluteElement = .MoveToPoint(dest.relativeToPoint(referencePoint))
        case .LineToPoint(let dest):
            absoluteElement = .LineToPoint(dest.relativeToPoint(referencePoint))
        case let .QuadraticBezier(control: cp, toDestination: dest):
            absoluteElement = .QuadraticBezier(
                control: cp.relativeToPoint(referencePoint),
                toDestination: dest.relativeToPoint(referencePoint))
        case let .CubicBezier(originControl: ocp, destinationControl: dcp, toDestination: dest):
            absoluteElement = .CubicBezier(
                originControl: ocp.relativeToPoint(referencePoint),
                destinationControl: dcp.relativeToPoint(referencePoint),
                toDestination: dest.relativeToPoint(referencePoint))
        }
        return absoluteElement
    }
    
    func applyTransform(transform: CGAffineTransform) -> BezierElement {
        switch self {
        case .MoveToPoint(let dest):
            return .MoveToPoint(CGPointApplyAffineTransform(dest, transform))
        case .LineToPoint(let dest):
            return .LineToPoint(CGPointApplyAffineTransform(dest, transform))
        case let .QuadraticBezier(control: controlPoint, toDestination: dest):
            return .QuadraticBezier(
                control: CGPointApplyAffineTransform(controlPoint, transform),
                toDestination: CGPointApplyAffineTransform(dest, transform)
            )
        case let .CubicBezier(originControl: originControl, destinationControl: destinationControl, toDestination: dest):
            return .CubicBezier(
                originControl: CGPointApplyAffineTransform(originControl, transform),
                destinationControl: CGPointApplyAffineTransform(destinationControl, transform),
                toDestination: CGPointApplyAffineTransform(dest, transform)
            )
        }
    }
}