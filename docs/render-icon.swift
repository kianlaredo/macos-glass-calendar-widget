import AppKit

let size = 1024
let pixelCount = size * size
let outputPath = CommandLine.arguments[1]
let squircleExponent: Float = CommandLine.arguments.count > 2 ? Float(CommandLine.arguments[2]) ?? 5 : 5

typealias Vec = SIMD3<Float>

func smoothstep(_ edge0: Float, _ edge1: Float, _ value: Float) -> Float {
    let t = min(max((value - edge0) / (edge1 - edge0), 0), 1)
    return t * t * (3 - 2 * t)
}

func gaussian(_ value: Float, _ sigma: Float) -> Float { exp(-(value * value) / (2 * sigma * sigma)) }

func normalized(_ vector: Vec) -> Vec { vector / max(simd_length(vector), 1e-6) }

func simd_length(_ vector: Vec) -> Float { (vector * vector).sum().squareRoot() }

func dot(_ a: Vec, _ b: Vec) -> Float { (a * b).sum() }

func squircleCoverage(_ x: Int, _ y: Int) -> Float {
    var inside: Float = 0
    for sy in 0..<4 {
        for sx in 0..<4 {
            let u = (Float(x) + (Float(sx) + 0.5) / 4) / Float(size) * 2 - 1
            let v = (Float(y) + (Float(sy) + 0.5) / 4) / Float(size) * 2 - 1
            if pow(abs(u), squircleExponent) + pow(abs(v), squircleExponent) <= 1 { inside += 1 }
        }
    }
    return inside / 16
}
var coverage = [Float](repeating: 0, count: pixelCount)
for y in 0..<size {
    for x in 0..<size {
        coverage[y * size + x] = squircleCoverage(x, y)
    }
}

func insetDistance(_ x: Int, _ y: Int) -> Float {
    let u = abs((Float(x) + 0.5) / Float(size) * 2 - 1)
    let v = abs((Float(y) + 0.5) / Float(size) * 2 - 1)
    let n = squircleExponent
    let gauge = pow(pow(u, n) + pow(v, n), 1 / n)
    if gauge < 1e-4 { return Float(size) }
    let gradientX = pow(u / gauge, n - 1)
    let gradientY = pow(v / gauge, n - 1)
    let gradientLength = (gradientX * gradientX + gradientY * gradientY).squareRoot()
    return max((1 - gauge) * Float(size) / 2 / gradientLength, 0)
}

func blurred(_ values: [Float], radius: Int, passes: Int) -> [Float] {
    var current = values
    for _ in 0..<passes {
        var horizontal = current
        for y in 0..<size {
            for x in 0..<size {
                var total: Float = 0
                for offset in -radius...radius { total += current[y * size + min(max(x + offset, 0), size - 1)] }
                horizontal[y * size + x] = total / Float(2 * radius + 1)
            }
        }
        var vertical = horizontal
        for y in 0..<size {
            for x in 0..<size {
                var total: Float = 0
                for offset in -radius...radius { total += horizontal[min(max(y + offset, 0), size - 1) * size + x] }
                vertical[y * size + x] = total / Float(2 * radius + 1)
            }
        }
        current = vertical
    }
    return current
}
var edgeDistance = [Float](repeating: 0, count: pixelCount)
for y in 0..<size { for x in 0..<size { edgeDistance[y * size + x] = insetDistance(x, y) } }

let bevelWidth: Float = 96
let bevelHeight: Float = 70
let seamY: Float = 270.5
let columnCenters: [Float] = [169, 283, 395, 510, 625, 738, 853]
let rowCenters: [Float] = [416, 549, 682, 816]
let dotRadius: Float = 28
let bubbleRadius: Float = 60
let dotLayout: [[Int]] = [[2, 3, 4, 5, 6], [0, 1, 2, 3, 4, 5, 6], [0, 1, 2, 3, 5, 6], [0, 1, 2, 3, 4]]
let bubbleCenter = SIMD2<Float>(columnCenters[4], rowCenters[2])
var dotCenters: [SIMD2<Float>] = []
for (rowIndex, columns) in dotLayout.enumerated() {
    for column in columns { dotCenters.append(SIMD2(columnCenters[column], rowCenters[rowIndex])) }
}

func height(_ x: Int, _ y: Int) -> Float {
    let index = min(max(y, 0), size - 1) * size + min(max(x, 0), size - 1)
    let t = min(edgeDistance[index] / bevelWidth, 1)
    var value = bevelHeight * (1 - (1 - t) * (1 - t)).squareRoot()
    let fy = Float(y)
    let u = (Float(x) / Float(size)) * 2 - 1
    let v = (fy / Float(size)) * 2 - 1
    value += 46 * max(1 - (u * u + v * v) * 0.5, 0)
    let capDome = smoothstep(seamY + 10, seamY - 60, fy) * sin(min(max(fy / seamY, 0), 1) * Float.pi)
    value += 26 * capDome
    value -= 9 * gaussian(fy - seamY, 3.2)
    value += 5 * smoothstep(seamY + 6, seamY - 14, fy)
    for center in dotCenters {
        let d = ((Float(x) - center.x) * (Float(x) - center.x) + (Float(y) - center.y) * (Float(y) - center.y)).squareRoot()
        value -= 10 * smoothstep(dotRadius + 16, dotRadius - 6, d)
    }
    return value
}

var rawHeights = [Float](repeating: 0, count: pixelCount)
for y in 0..<size { for x in 0..<size { rawHeights[y * size + x] = height(x, y) } }
let heights = blurred(rawHeights, radius: 2, passes: 2)

func surfaceNormal(_ x: Int, _ y: Int) -> Vec {
    func h(_ px: Int, _ py: Int) -> Float { heights[min(max(py, 0), size - 1) * size + min(max(px, 0), size - 1)] }
    let dx = (h(x + 1, y) - h(x - 1, y)) * 0.5
    let dy = (h(x, y + 1) - h(x, y - 1)) * 0.5
    return normalized(Vec(-dx * 1.6, dy * 1.6, 1))
}

func environment(_ reflected: Vec) -> Float {
    let a = reflected.x, b = reflected.y
    var value: Float = 0.36
    value += 0.95 * gaussian(a + 0.55, 0.42) * gaussian(b - 0.62, 0.40)
    value += 0.50 * gaussian(a - 0.85, 0.16) * gaussian(b - 0.1, 0.65)
    value += 0.38 * gaussian(a - 0.15, 0.55) * gaussian(b + 0.9, 0.22)
    value -= 0.30 * gaussian(a + 0.2, 0.9) * gaussian(b + 0.35, 0.20)
    value -= 0.22 * gaussian(a - 0.35, 0.30) * gaussian(b - 0.25, 0.30)
    return value
}

func lightDirection(_ x: Float, _ y: Float, _ z: Float) -> Vec { normalized(Vec(x, y, z)) }
let keyLight = lightDirection(-0.45, 0.62, 0.64)
let rimLight = lightDirection(0.55, -0.62, 0.56)
let viewDirection = Vec(0, 0, 1)

func glassColor(x: Int, y: Int, normal: Vec, edge: Float, channelSkew: Float) -> Vec {
    var n = normal
    n.x *= 1 + channelSkew
    n.y *= 1 + channelSkew
    n = normalized(n)
    let nz = max(n.z, 0)
    let reflected = Vec(2 * nz * n.x, 2 * nz * n.y, 2 * nz * nz - 1)
    let fresnel = 0.05 + 0.95 * pow(1 - nz, 3.5)
    let fy = Float(y) / Float(size)
    let fx = Float(x) / Float(size)
    var base = 0.872 + 0.09 * (0.5 - fy) + 0.04 * (0.5 - fx)
    base += 0.16 * max(dot(n, keyLight) - keyLight.z, 0) * 1.4
    let t = min(edge / bevelWidth, 1)
    base *= 1 - 0.26 * gaussian(t - 0.42, 0.17) * (0.55 + 0.45 * (n.x * 0.6 - n.y * 0.8 + 0.4))
    let coolTint = Vec(0.955, 0.972, 1.0)
    let lowerWeight = smoothstep(0.35, 1.0, fy)
    let tint = Vec(1, 1, 1) * (1 - lowerWeight) + coolTint * lowerWeight
    var value = base * (1 - fresnel * 0.55) + environment(reflected) * (fresnel * 0.95 + 0.04)
    value *= (tint.x + tint.y + tint.z) / 3
    let contour = smoothstep(7, 0, edge)
    value = value * (1 - contour * 0.45) + 0.66 * contour * 0.45
    let halfKey = normalized(keyLight + viewDirection)
    let halfRim = normalized(rimLight + viewDirection)
    value += 1.25 * pow(max(dot(n, halfKey), 0), 150)
    value += 0.55 * pow(max(dot(n, halfRim), 0), 100)
    let sheenBand = smoothstep(0.08, 0.0, abs((fx * 0.8 - fy * 0.6) - 0.18)) * 0.07
    value += sheenBand * smoothstep(seamY + 30, seamY - 120, Float(y))
    return Vec(repeating: value)
}

var body = [Vec](repeating: .zero, count: pixelCount)
let skew: Float = 0.12
for y in 0..<size {
    for x in 0..<size {
        let index = y * size + x
        let normal = surfaceNormal(x, y)
        let edge = edgeDistance[index]
        let red = glassColor(x: x, y: y, normal: normal, edge: edge, channelSkew: skew).x
        let green = glassColor(x: x, y: y, normal: normal, edge: edge, channelSkew: 0).x
        let blue = glassColor(x: x, y: y, normal: normal, edge: edge, channelSkew: -skew).x
        var color = Vec(red, green, blue)
        let fx = Float(x) / Float(size)
        let capWeight = smoothstep(seamY + 4, seamY - 40, Float(y)) * 0.075
        let hueRamp = Vec(0.55 + 0.45 * fx, 0.78 + 0.1 * sin(fx * 6.0), 1.0 - 0.45 * fx)
        color = color * (1 - capWeight) + hueRamp * capWeight * color
        body[index] = color
    }
}

func sampleBody(_ px: Float, _ py: Float) -> Vec {
    let x = min(max(Int(px.rounded()), 0), size - 1)
    let y = min(max(Int(py.rounded()), 0), size - 1)
    return body[y * size + x]
}

var final = body
for y in 0..<size {
    for x in 0..<size {
        let point = SIMD2<Float>(Float(x), Float(y))
        for center in dotCenters {
            let offset = point - center
            let distance = (offset.x * offset.x + offset.y * offset.y).squareRoot()
            let rho = distance / dotRadius
            if rho > 1.0 && rho < 1.18 {
                let ringFalloff = 1 - smoothstep(1.0, 1.18, rho)
                let lowerLight = max(offset.y / distance, 0)
                let upperShade = max(-offset.y / distance, 0)
                let index = y * size + x
                final[index] += Vec(repeating: 0.07 * lowerLight * ringFalloff - 0.13 * upperShade * ringFalloff)
            } else if rho <= 1.0 {
                let sphereZ = (1 - rho * rho).squareRoot()
                let n = normalized(Vec(offset.x / dotRadius, -offset.y / dotRadius, sphereZ))
                var shade: Float = 0.075 + 0.06 * max(dot(n, keyLight), 0)
                shade += 0.55 * pow(max(dot(n, normalized(keyLight + viewDirection)), 0), 38)
                shade += 0.10 * pow(1 - sphereZ, 2.2) * max(-n.y, 0)
                let edgeAlpha = smoothstep(1.0, 0.94, rho)
                let darkColor = Vec(0.075, 0.082, 0.105) + Vec(repeating: shade - 0.075)
                let index = y * size + x
                final[index] = final[index] * (1 - edgeAlpha) + darkColor * edgeAlpha
            }
        }
        let offset = point - bubbleCenter
        let distance = (offset.x * offset.x + offset.y * offset.y).squareRoot()
        let rho = distance / bubbleRadius
        if rho <= 1.04 {
            let clamped = min(rho, 1)
            let sphereZ = (1 - clamped * clamped).squareRoot()
            let n = normalized(Vec(offset.x / bubbleRadius, -offset.y / bubbleRadius, sphereZ))
            let magnify: Float = 26
            let refractedPoint = point - SIMD2<Float>(n.x, -n.y) * magnify * (1 - sphereZ * 0.35)
            var color = sampleBody(refractedPoint.x, refractedPoint.y) * 0.96
            color = color * Vec(0.955, 0.975, 1.0)
            let fresnel = pow(1 - sphereZ, 2.6)
            let reflected = Vec(2 * sphereZ * n.x, 2 * sphereZ * n.y, 2 * sphereZ * sphereZ - 1)
            color += Vec(repeating: environment(reflected) * (fresnel * 0.9 + 0.03))
            color += Vec(repeating: 0.95 * pow(max(dot(n, normalized(keyLight + viewDirection)), 0), 55))
            color += Vec(repeating: 0.25 * pow(max(dot(n, normalized(rimLight + viewDirection)), 0), 30))
            let ringPosition = clamped
            color.x += 0.05 * gaussian(ringPosition - 0.9, 0.06) * (0.5 + 0.5 * n.x)
            color.z += 0.06 * gaussian(ringPosition - 0.88, 0.06) * (0.5 - 0.5 * n.x)
            color.y += 0.03 * gaussian(ringPosition - 0.84, 0.05)
            color *= 1 - 0.10 * gaussian(ringPosition - 0.97, 0.03)
            let alpha = smoothstep(1.04, 0.98, rho)
            let index = y * size + x
            final[index] = final[index] * (1 - alpha) + color * alpha
            let shadowRing = gaussian(rho - 1.1, 0.08) * 0.10
            if rho > 1.0 { final[index] *= 1 - shadowRing * (offset.y < 0 ? 1 : 0.4) }
        }
    }
}

var bytes = [UInt8](repeating: 0, count: pixelCount * 4)
for index in 0..<pixelCount {
    let alpha = coverage[index]
    let color = final[index]
    for channel in 0..<3 {
        let value = min(max(color[channel], 0), 1)
        bytes[index * 4 + channel] = UInt8((value * alpha * 255).rounded())
    }
    bytes[index * 4 + 3] = UInt8((alpha * 255).rounded())
}
let provider = CGDataProvider(data: Data(bytes) as CFData)!
let image = CGImage(width: size, height: size, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: size * 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                    provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
let rep = NSBitmapImageRep(cgImage: image)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: outputPath))
