//
//  CGPoint+FaceMeter.swift
//  FaceReader
//

import CoreGraphics

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
}

extension CGSize {
    public var cgPoint: CGPoint { CGPoint(x: width, y: height) }
}

extension CGPoint {
    public var cgSize: CGSize { CGSize(width: x, height: y) }

    public func absolutePoint(in rect: CGRect) -> CGPoint {
        CGPoint(x: x * rect.size.width, y: y * rect.size.height) + rect.origin
    }
}
