//
//  PhoneLayout.swift
//  FaceReader
//
//  iPhone-only layout scaling (no iPad / Mac targets).
//

import CoreGraphics
import UIKit

public enum PhoneLayout {
    /// Current portrait-leaning width used for layout (iPhone only).
    public static var width: CGFloat {
        let b = UIScreen.main.bounds
        return min(b.width, b.height)
    }

    /// Scales metrics (images, padding) between ~1.0 on mini and ~1.2 on Pro Max.
    public static var metricScale: CGFloat {
        min(max(width / 375, 1.0), 1.22)
    }

    /// Extra factor applied to custom app fonts so body text reads comfortably on phone.
    private static var fontFactor: CGFloat {
        min(max(width / 360, 1.02), 1.18)
    }

    public static func scaledFontSize(_ base: CGFloat) -> CGFloat {
        base * fontFactor
    }
}
