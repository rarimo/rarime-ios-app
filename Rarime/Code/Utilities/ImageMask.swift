// This import is required otherwise it will crash
import Darwin

import Foundation

import AVFoundation
import UIKit
import Vision

class ImageMasks {
    static func processFace(_ image: CGImage) throws -> UIImage? {
        let faceDetection = VNDetectFaceRectanglesRequest()
        
        try VNSequenceRequestHandler().perform([faceDetection], on: image)
        guard let result = faceDetection.results?.first else {
            return nil
        }

        let faceLandmarks = VNDetectFaceLandmarksRequest()
        faceLandmarks.inputFaceObservations = [result]
        
        return try detectLandmarks(image, faceLandmarks)
    }
    
    private static func detectLandmarks(_ image: CGImage, _ faceLandmarks: VNDetectFaceLandmarksRequest) throws -> UIImage? {
        try VNSequenceRequestHandler().perform([faceLandmarks], on: image)
        
        guard let observation = faceLandmarks.results?.first else {
            return nil
        }
        
        guard let boundingBox = faceLandmarks.inputFaceObservations?.first?.boundingBox else {
            return nil
        }
        
        let faceBoundingBox = boundingBox.scaled(to: .init(width: image.width, height: image.height))
        
        guard let allPoints = observation.landmarks?.allPoints else {
            return nil
        }
        
        return convertPointsForFace(image, allPoints, faceBoundingBox)
    }
    
    private static func convertPointsForFace(_ image: CGImage, _ landmark: VNFaceLandmarkRegion2D, _ boundingBox: CGRect) -> UIImage {
        let faceLandmarkVertices = landmark.normalizedPoints.map { (point: CGPoint) -> Vertex in
            let pointX = point.x * boundingBox.width + boundingBox.origin.x
            let pointY = point.y * boundingBox.height + boundingBox.origin.y
                
            return Vertex(x: Double(pointX), y: Double(pointY))
        }
            
        return draw(image, faceLandmarkVertices, boundingBox)
    }
    
    private static func draw(_ image: CGImage, _ vertices: [Vertex], _ boundingBox: CGRect) -> UIImage {
        var newVertices = vertices
        
        newVertices.removeLast()
        
        let triangles = Delaunay().triangulate(newVertices)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = .init(x: 0, y: 0, width: image.width, height: image.height)
        shapeLayer.lineWidth = 6.0
        
        // draw triangles
        for triangle in triangles {
            let triangleLayer = CAShapeLayer()
            triangleLayer.path = triangle.toPath()
            triangleLayer.strokeColor = UIColor.white.cgColor.copy(alpha: 0.4)
            triangleLayer.lineWidth = 3.0
            triangleLayer.fillColor = UIColor.clear.cgColor
            triangleLayer.backgroundColor = UIColor.clear.cgColor
            
            shapeLayer.addSublayer(triangleLayer)
        }
        
        // draw points
        for vertex in newVertices {
            let POINT_RADIUS: CGFloat = 8.0
            let pointLayer = CAShapeLayer()
            pointLayer.path = UIBezierPath(
                ovalIn: CGRect(x: vertex.x - POINT_RADIUS, y: vertex.y - POINT_RADIUS, width: POINT_RADIUS * 2, height: POINT_RADIUS * 2)
            ).cgPath
            pointLayer.fillColor = UIColor.white.cgColor
            pointLayer.backgroundColor = UIColor.clear.cgColor
            
            shapeLayer.addSublayer(pointLayer)
        }
        
        return convertShapeLayerToImage(shapeLayer, size: .init(width: image.width, height: image.height))
    }
    
    private static func convertShapeLayerToImage(_ shapeLayer: CAShapeLayer, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            shapeLayer.render(in: context.cgContext)
        }
        
        return image
    }
}

struct CircumCircle {
    let vertex1: Vertex
    let vertex2: Vertex
    let vertex3: Vertex
    let x: Double
    let y: Double
    let rsqr: Double
}

struct Triangle {
    let vertex1: Vertex
    let vertex2: Vertex
    let vertex3: Vertex

    func toPath() -> CGPath {
        let path = CGMutablePath()
        let point1 = vertex1.pointValue()
        let point2 = vertex2.pointValue()
        let point3 = vertex3.pointValue()

        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point1)

        path.closeSubpath()

        return path
    }
}

class Line {
    var start: CGPoint
    var end: CGPoint
    var color: UIColor
    var brushWidth: CGFloat
    init(start startPoint: CGPoint, end endPoint: CGPoint, color drawColor: UIColor, brushWidth lineWidth: CGFloat) {
        start = startPoint
        end = endPoint
        color = drawColor
        brushWidth = lineWidth
    }
}

struct Vertex {
    let x: Double
    let y: Double

    func pointValue() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
}

extension Vertex: Equatable {}
extension Vertex: Hashable {}

func ==(lhs: Vertex, rhs: Vertex) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}

class Delaunay {
    func superTriangle(_ vertices: [Vertex]) -> [Vertex] {
        var xMin = Double(Int32.max)
        var yMin = Double(Int32.max)
        var xMax = -Double(Int32.max)
        var yMax = -Double(Int32.max)
        
        for i in 0..<vertices.count {
            if vertices[i].x < xMin { xMin = vertices[i].x }
            if vertices[i].x > xMax { xMax = vertices[i].x }
            if vertices[i].y < yMin { yMin = vertices[i].y }
            if vertices[i].y > yMax { yMax = vertices[i].y }
        }
        
        let dx = xMax - xMin
        let dy = yMax - yMin
        let dmax = max(dx, dy)
        let xmid = xMin + dx * 0.5
        let ymid = yMin + dy * 0.5
        
        return [
            Vertex(x: xmid - 20 * dmax, y: ymid - dmax),
            Vertex(x: xmid, y: ymid + 20 * dmax),
            Vertex(x: xmid + 20 * dmax, y: ymid - dmax)
        ]
    }
    
    func circumCircle(_ i: Vertex, j: Vertex, k: Vertex) -> CircumCircle {
        let x1 = i.x
        let y1 = i.y
        let x2 = j.x
        let y2 = j.y
        let x3 = k.x
        let y3 = k.y
        let xc: Double
        let yc: Double
        
        let fabsy1y2 = abs(y1 - y2)
        let fabsy2y3 = abs(y2 - y3)
        
        if fabsy1y2 < .ulpOfOne {
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx2 = (x2 + x3) / 2
            let my2 = (y2 + y3) / 2
            xc = (x2 + x1) / 2
            yc = m2 * (xc - mx2) + my2
        } else if fabsy2y3 < .ulpOfOne {
            let m1 = -((x2 - x1) / (y2 - y1))
            let mx1 = (x1 + x2) / 2
            let my1 = (y1 + y2) / 2
            xc = (x3 + x2) / 2
            yc = m1 * (xc - mx1) + my1
        } else {
            let m1 = -((x2 - x1) / (y2 - y1))
            let m2 = -((x3 - x2) / (y3 - y2))
            let mx1 = (x1 + x2) / 2
            let mx2 = (x2 + x3) / 2
            let my1 = (y1 + y2) / 2
            let my2 = (y2 + y3) / 2
            xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2)
            
            if fabsy1y2 > fabsy2y3 {
                yc = m1 * (xc - mx1) + my1
            } else {
                yc = m2 * (xc - mx2) + my2
            }
        }
        
        let dx = x2 - xc
        let dy = y2 - yc
        let rsqr = dx * dx + dy * dy
        
        return CircumCircle(vertex1: i, vertex2: j, vertex3: k, x: xc, y: yc, rsqr: rsqr)
    }
    
    func dedup(_ edges: [Vertex]) -> [Vertex] {
        var e = edges
        var a: Vertex?, b: Vertex?, m: Vertex?, n: Vertex?
        
        var j = e.count
        while j > 0 {
            j -= 1
            b = j < e.count ? e[j] : nil
            j -= 1
            a = j < e.count ? e[j] : nil
            
            var i = j
            while i > 0 {
                i -= 1
                n = e[i]
                i -= 1
                m = e[i]
                
                if (a == m && b == n) || (a == n && b == m) {
                    e.removeSubrange(j...j + 1)
                    e.removeSubrange(i...i + 1)
                    break
                }
            }
        }
        
        return e
    }
    
    func triangulate(_ vertices: [Vertex]) -> [Triangle] {
        var filteredVertices = vertices.removeDuplicates()
        
        guard filteredVertices.count >= 3 else {
            return []
        }

        let size = filteredVertices.count
        var open: [CircumCircle] = []
        var completed: [CircumCircle] = []
        var edges: [Vertex] = []
        
        let indices = [Int](0..<size).sorted { filteredVertices[$0].x < filteredVertices[$1].x }
        
        filteredVertices += superTriangle(filteredVertices)
        
        open.append(circumCircle(filteredVertices[size], j: filteredVertices[size + 1], k: filteredVertices[size + 2]))
        
        for i in 0..<size {
            let c = indices[i]
            
            edges.removeAll()
            
            for j in (0..<open.count).reversed() {
                let dx = filteredVertices[c].x - open[j].x
                
                if dx > 0, dx * dx > open[j].rsqr {
                    completed.append(open.remove(at: j))
                    continue
                }
                
                let dy = filteredVertices[c].y - open[j].y
                
                if dx * dx + dy * dy - open[j].rsqr > .ulpOfOne {
                    continue
                }
                
                edges += [
                    open[j].vertex1, open[j].vertex2,
                    open[j].vertex2, open[j].vertex3,
                    open[j].vertex3, open[j].vertex1
                ]
                
                open.remove(at: j)
            }
            
            edges = dedup(edges)
            
            var j = edges.count
            while j > 0 {
                j -= 1
                let b = edges[j]
                
                j -= 1
                let a = edges[j]
                
                open.append(circumCircle(a, j: b, k: filteredVertices[c]))
            }
        }
        
        completed += open
        
        let ignored: Set<Vertex> = [filteredVertices[size], filteredVertices[size + 1], filteredVertices[size + 2]]
        
        let results = completed.compactMap { circumCircle -> Triangle? in
            let current: Set<Vertex> = [circumCircle.vertex1, circumCircle.vertex2, circumCircle.vertex3]
            let intersection = ignored.intersection(current)
            if intersection.count > 0 {
                return nil
            }
            
            return Triangle(vertex1: circumCircle.vertex1, vertex2: circumCircle.vertex2, vertex3: circumCircle.vertex3)
        }
        
        return results
    }
}

extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: origin.x * size.width,
            y: origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}
