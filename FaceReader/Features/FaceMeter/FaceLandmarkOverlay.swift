//
//  FaceLandmarkOverlay.swift
//  FaceReader
//

import FaceReaderCore
import FaceReaderUI
import SwiftUI

/// Draws Vision landmark points in preview-layer coordinates (same space as `PreviewLayerHost`).
struct FaceLandmarkOverlay: View {
    @ObservedObject var engine: FaceCaptureEngine

    private var session: FaceMeasureSession { engine.measureSession }

    private var dotRadius: CGFloat { 3.8 * PhoneLayout.metricScale }
    private var lineWidth: CGFloat { 1.2 * PhoneLayout.metricScale }

    var body: some View {
        Canvas { context, size in
            // Face contour (outline)
            strokePolyline(session.faceContour, in: &context, color: .white.opacity(0.85), lineWidth: lineWidth * 1.1)
            // Eyes & brows
            strokePolyline(session.leftEyebrow, in: &context, color: .cyan.opacity(0.9), lineWidth: lineWidth)
            strokePolyline(session.rightEyebrow, in: &context, color: .cyan.opacity(0.9), lineWidth: lineWidth)
            strokePolyline(session.leftEye, in: &context, color: .yellow.opacity(0.95), lineWidth: lineWidth)
            strokePolyline(session.rightEye, in: &context, color: .yellow.opacity(0.95), lineWidth: lineWidth)
            // Nose
            strokePolyline(session.nose, in: &context, color: .orange.opacity(0.9), lineWidth: lineWidth)
            // Lips
            strokePolyline(session.outerLips, in: &context, color: .pink.opacity(0.9), lineWidth: lineWidth)
            strokePolyline(session.innerLips, in: &context, color: .mint.opacity(0.85), lineWidth: lineWidth * 0.9)

            // Dots on top for every landmark
            fillDots(session.faceContour, in: &context, color: .white)
            fillDots(session.leftEyebrow, in: &context, color: .cyan)
            fillDots(session.rightEyebrow, in: &context, color: .cyan)
            fillDots(session.leftEye, in: &context, color: .yellow)
            fillDots(session.rightEye, in: &context, color: .yellow)
            fillDots(session.nose, in: &context, color: .orange)
            fillDots(session.outerLips, in: &context, color: .pink)
            fillDots(session.innerLips, in: &context, color: .mint)
        }
        .allowsHitTesting(false)
    }

    private func strokePolyline(_ points: [CGPoint]?, in context: inout GraphicsContext, color: Color, lineWidth: CGFloat) {
        guard let points, points.count >= 2 else { return }
        var path = Path()
        path.move(to: points[0])
        for i in 1 ..< points.count {
            path.addLine(to: points[i])
        }
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
    }

    private func fillDots(_ points: [CGPoint]?, in context: inout GraphicsContext, color: Color) {
        guard let points else { return }
        let r = dotRadius
        for p in points {
            let rect = CGRect(x: p.x - r, y: p.y - r, width: r * 2, height: r * 2)
            context.fill(Path(ellipseIn: rect), with: .color(color))
            context.stroke(Path(ellipseIn: rect), with: .color(.black.opacity(0.55)), lineWidth: 1)
        }
    }
}
