import Foundation

extension FrFl {

    // variation function - that is converter point to point
    typealias V = (CGPoint) -> CGPoint
}

// variation factory
protocol FrFlVariationFactory: CustomStringConvertible {
    func create(transform: CGAffineTransform) -> FrFl.V
    var continuous: Bool { get }
}

extension FrFlVariationFactory {
    var continuous: Bool { return true }
    var description: String { return String(describing: type(of: self)) }
}

extension FrFl {
    typealias VF = FrFlVariationFactory
}

// utilities to implementats variation function
extension CGPoint {
    var r²: CGFloat { return x*x + y*y }
    var r: CGFloat { return hypot(x, y) }
    var θ: CGFloat { return atan2(x, y) }
    var φ: CGFloat { return atan2(y, x) }
}

fileprivate let π = CGFloat.pi

// alternative namespace
extension FrFl {

    /// Linear (Variation 0)
    struct Linear: VF {
        func create(transform: CGAffineTransform) -> V {
            return { return $0 }
        }
    }

    /// Sinusoidal (Variation 1)
    struct Sinusoidal: VF {
        func create(transform: CGAffineTransform) -> V {
            return { return CGPoint(x: sin($0.x), y: sin($0.y)) }
        }
    }

    /// Spherical (Variation 2)
    struct Spherical: VF {
        func create(transform: CGAffineTransform) -> V {
            return { return $0 / $0.r² }
        }
    }

    /// Swirl (Variation 3)
    struct Swirl: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let r² = $0.r²
                let (s, c) = (sin(r²), cos(r²))
                let (x, y) = ($0.x, $0.y)
                return CGPoint(x: x * s - y * c, y: x * c + y * s)
            }
        }
    }

    /// Horseshoe (Variation 4)
    struct Horseshoe: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (x,y) = ($0.x,$0.y); return CGPoint(x:(x-y)*(x+y), y:2*x*y) / $0.r }
        }
    }

    /// Polar (Variation 5)
    struct Polar: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let (r, θ) = ($0.r, $0.θ)
                return CGPoint(x:θ/π, y:r-1)
            }
        }
    }

    /// Handkerchief (Variation 6)
    struct Handkerchief: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (r,θ) = ($0.r,$0.θ); return CGPoint(x:sin(θ + r), y:cos(θ - r)) * r }
        }
    }

    /// Heart (Variation 7)
    struct Heart: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (r,θ) = ($0.r,$0.θ); return CGPoint(x:sin(θ * r), y: -cos(θ * r)) * r }
        }
    }

    /// Disc (Variation 8)
    struct Disc: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (r,θ) = ($0.r,$0.θ); return CGPoint(x:sin(π*r), y:cos(π*r)) * (θ/π) }
        }
    }

    /// Spiral (Variation 9)
    struct Spiral: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (r,θ) = ($0.r,$0.θ); return CGPoint(x:cos(θ)+sin(r),y:sin(θ)-cos(r)) / r }
        }
    }

    /// Hyperbolic (Variation 10)
    struct Hyperbolic: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (r,θ) = ($0.r,$0.θ); return CGPoint(x:sin(θ)/r, y:cos(θ)*r) }
        }
    }

    /// Diamond (Variation 11)
    struct Diamond: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (r,θ) = ($0.r,$0.θ); return CGPoint(x:sin(θ)*cos(r),y:cos(θ)*sin(r)) }
        }
    }

    /// Ex (Variation 12)
    struct Ex: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let (r,θ) = ($0.r,$0.θ)
                let (p₀, p₁) = (sin(θ+r), cos(θ-r))
                let (p₀³, p₁³) = (p₀ * p₀ * p₀, p₁ * p₁ * p₁)
                return CGPoint(x:p₀³+p₁³,y:p₀³-p₁³) * r
            }
        }
    }

    /// Julia (Variation 13)
    struct Julia: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let Ω = π * CGFloat(Int.random(in: 0..<2)) // Ω is a random variable that is either 0 or π.
                let (r,θ) = ($0.r,$0.θ)
                return CGPoint(x: cos(θ/2 + Ω), y: sin(θ/2 + Ω)) * sqrt(r)
            }
        }
        var continuous: Bool { return false }
    }

    /// Bent (Variation 14)
    struct Bent: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let (x, y) = ($0.x, $0.y)
                if x < 0 {
                    if y < 0 {
                        return CGPoint(x:2*x, y:y/2)
                    } else {
                        return CGPoint(x:2*x, y:y)
                    }
                } else {
                    if y < 0 {
                        return CGPoint(x:x, y:y/2)
                    } else {
                        return $0
                    }
                }
            }

        }
    }

    /// Waves (Variation 15) - dependent
    struct Waves: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let b: CGFloat = transform.c
                let c: CGFloat = transform.tx
                let e: CGFloat = transform.d
                let f: CGFloat = transform.ty
                //
                let c² = c * c
                let f² = f * f
                let (x, y) = ($0.x, $0.y)
                return CGPoint(x: x + b * sin(y/c²), y: y + e * sin(x/f²))
            }
        }
    }

    /// Fisheye (Variation 16)
    struct Fisheye: VF {
        func create(transform: CGAffineTransform) -> V {
            return { return CGPoint(x:$0.y, y:$0.x) * (2 / ($0.r + 1)) }
        }
    }

    /// Popcorn (Variation 17) - dependent
    struct Popcorn: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let c: CGFloat = transform.tx
                let f: CGFloat = transform.ty
                //
                let (x, y) = ($0.x, $0.y)
                return CGPoint(x: x + c * sin(tan(3*y)), y: y + f * sin(tan(3*x)))
            }
        }
    }

    /// Exponential (Variation 18)
    struct Exponential: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (x, y) = ($0.x, $0.y); return CGPoint(x: cos(π*y), y: sin(π*y)) * exp(x-1) }
        }
    }

    /// Power (Variation 19)
    struct Power: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (r,θ) = ($0.r,$0.θ); return CGPoint(x: cos(θ), y: sin(θ)) * pow(r, sin(θ)) }
        }
    }

    /// Cosine (Variation 20)
    struct Cosine: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let (x, y) = ($0.x, $0.y); return CGPoint(x: cos(π*x) * cosh(y), y: -sin(π*x) * sinh(y)) }
        }
    }

    /// Rings (Variation 21) - dependent
    struct Rings: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let c: CGFloat = transform.tx
                let c² = c * c
                let (r,θ) = ($0.r,$0.θ)
                let s = (r + c²).remainder(dividingBy: 2 * c²)
                let t = c² + r * (1 - c²)
                return CGPoint(x: cos(θ), y: sin(θ)) * (s - t)
            }
        }
    }

    /// Fan (Variation 22) - dependent
    struct Fan: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let c: CGFloat = transform.tx
                let f: CGFloat = transform.ty
                //
                let c² = c * c
                let t = π * c²
                let θ = $0.θ
                if (θ + f).truncatingRemainder(dividingBy: t) > (t/2) {
                    return CGPoint(x: cos(θ - t/2) , y: sin(θ - t/2)) * $0.r
                } else {
                    return CGPoint(x: cos(θ + t/2) , y: sin(θ + t/2)) * $0.r
                }
            }
        }
    }

    /// Blob (Variation 23) - parametric
    struct Blob: VF {
        let high: CGFloat
        let low: CGFloat
        let waves: CGFloat
        func create(transform: CGAffineTransform) -> V { return f }
        func f(p: CGPoint) -> CGPoint {
            let (p₁, p₂, p₃) = (high, low, waves)
            let (r, θ) = (p.r, p.θ)
            let q = r * (p₂ + ((p₁ - p₂)/2) * (sin(p₃ * θ) + 1))
            return CGPoint(x: cos(θ), y: sin(θ)) * q
        }
        var description: String {
            let sh = String(format: "%.2f", high)
            let sl = String(format: "%.2f", low)
            let sw = String(format: "%.2f", waves)
            return "Blob(high:\(sh), low:\(sl), waves:\(sw))"
        }
    }

    /// PDJ (Variation 24) - parametric
    struct PDJ: VF {
        let a:CGFloat
        let b:CGFloat
        let c:CGFloat
        let d:CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let (p₁, p₂, p₃, p₄) = (a, b, c, d)
                let (x, y) = ($0.x, $0.y)
                return CGPoint(x: sin(p₁*y) - cos(p₂*x), y: sin(p₃*x) - cos(p₄*y))
            }
        }
        var description: String {
            let sa = String(format: "%.2f", a)
            let sb = String(format: "%.2f", b)
            let sc = String(format: "%.2f", c)
            let sd = String(format: "%.2f", d)
            return "PDJ(a:\(sa), b:\(sb), c:\(sc), d:\(sd))"
        }
    }

    /// Fan2 (Variation 25) - parametric
    /// Fan2 was created as a parametric alternative to Fan.
    struct Fan2: VF {
        let x: CGFloat
        let y: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let p₁ = π * x * x
                let p₂ = y
                let (r,θ) = ($0.r,$0.θ)
                let t = θ + p₂ - p₁ * trunc(2*θ*p₂ / p₁)
                if t > p₁/2 {
                    return CGPoint(x:sin(θ-p₁/2), y:cos(θ-p₁/2)) * r
                } else {
                    return CGPoint(x:sin(θ+p₁/2), y:cos(θ+p₁/2)) * r
                }
            }
        }
        var description: String {
            let sx = String(format: "%.2f", x)
            let sy = String(format: "%.2f", y)
            return "Fan2(x:\(sx), y:\(sy))"
        }
    }

    /// Rings2 (Variation 26) - parametric
    /// Rings2 was created as a parametric alternative to Rings.
    struct Rings2: VF {
        let rings2: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let p = rings2 * rings2
                let (r,θ) = ($0.r,$0.θ)
                let t = r - 2*p*trunc((r+p)/(2*p)) + r*(1-p)
                return CGPoint(x: sin(θ), y: cos(θ)) * t
            }
        }
        var description: String {
            let srings2 = String(format: "%.2f", rings2)
            return "Rings2(rings2:\(srings2))"
        }
    }

    /// Eyefish (Variation 27)
    /// Eyefish was created to correct the order of x and y in Fisheye.
    struct Eyefish: VF {
        func create(transform: CGAffineTransform) -> V {
            return { return $0 * (2 / ($0.r + 1)) }
        }
    }

    /// Bubble (Variation 28)
    struct Bubble: VF {
        func create(transform: CGAffineTransform) -> V {
            return { return $0 * (4 / ($0.r² + 4)) }
        }
    }

    /// Cylinder (Variation 29)
    struct Cylinder: VF {
        func create(transform: CGAffineTransform) -> V {
            return { return CGPoint(x: sin($0.x), y: $0.y) }
        }
    }

    /// Perspective (Variation 30) - parametric
    struct Perspective: VF {
        let angle: CGFloat
        let dist: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let (p₁, p₂) = (angle, dist)
                let (x, y) = ($0.x, $0.y)
                return CGPoint(x: x, y: y * cos(p₁)) * (p₂ / (p₂ - y * sin(p₁)))
            }
        }
        var description: String {
            let sangle = String(format: "%.2f", angle)
            let sdist = String(format: "%.2f", dist)
            return "Perspective(angle:\(sangle), dist:\(sdist))"
        }
    }

    /// Noise (Variation 31)
    struct Noise: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                // Ψ is a random variable uniformaly distributed on the interval [0, 1].
                let Ψ₁ = CGFloat.random(in: 0...1)
                let Ψ₂ = CGFloat.random(in: 0...1)
                return CGPoint(x: $0.x * cos(2*π*Ψ₂), y: $0.y * sin(2*π*Ψ₂)) * Ψ₁
            }
        }
        var continuous: Bool { return false }
    }

    /// JuliaN (Variation 32) - parametric
    struct JuliaN: VF {
        let power: CGFloat
        let dist: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let (p₁, p₂) = (power, dist)
                let Ψ = CGFloat.random(in: 0...1)
                let p₃ = trunc(abs(p₁) * Ψ)
                let t = ($0.φ + 2 * π * p₃) / p₁
                return CGPoint(x: cos(t), y: sin(t)) * pow($0.r, p₂/p₁)
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let spower = String(format: "%.2f", power)
            let sdist = String(format: "%.2f", dist)
            return "JuliaN(power:\(spower), dist:\(sdist))"
        }
    }

    /// JuliaScope (Variation 33) - parametric
    struct JuliaScope: VF {
        let power: CGFloat
        let dist: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let (p₁, p₂) = (power, dist)
                let Λ = CGFloat(Int.random(in: 0...1) * 2 - 1) // Λ is a random variable that is either -1 or 1.
                let Ψ = CGFloat.random(in: 0...1) // Ψ is a random variable uniformally distributed on the interval [0, 1].
                let p₃ = trunc(abs(p₁) * Ψ)
                let t = (Λ * $0.φ + 2 * π * p₃) / p₁
                return CGPoint(x: cos(t), y: sin(t)) * pow($0.r, p₂/p₁)
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let spower = String(format: "%.2f", power)
            let sdist = String(format: "%.2f", dist)
            return "JuliaScope(power:\(spower), dist:\(sdist))"
        }
    }

    /// Blur (Variation 34)
    struct Blur: VF {
        func create(transform: CGAffineTransform) -> V {
            return { _ in
                let Ψ₁ = CGFloat.random(in: 0...1)
                let Ψ₂ = CGFloat.random(in: 0...1)
                return CGPoint(x: cos(2*π*Ψ₂), y: sin(2*π*Ψ₂)) * Ψ₁
            }
        }
        var continuous: Bool { return false }
    }

    /// Gaussian (Variation 35)
    /// Summing 4 random numbers and subtracting 2 is an attempt at approximating a Gaussian distribution.
    struct Gaussian: VF {
        func create(transform: CGAffineTransform) -> V {
            return { _ in
                let Σ = (1...4).reduce(CGFloat(0), { (s, _) in return s + CGFloat.random(in: 0...1) })
                let Ψ₅ = CGFloat.random(in: 0...1)
                return CGPoint(x: cos(2*π*Ψ₅), y: sin(2*π*Ψ₅)) * (Σ - 2)
            }
        }
        var continuous: Bool { return false }
    }

    /// RadialBlur (Variation 36) - parametric
    struct RadialBlur: VF {
        let angle: CGFloat
        let dist: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let p₁ = angle * (π/2)
                let v₃₆ = dist
                let Σ = (1...4).reduce(CGFloat(0), { (s, _) in return s + CGFloat.random(in: 0...1) - 2 })
                let t₁ = v₃₆ * Σ
                let t₂ = $0.φ + t₁ * sin(p₁)
                let t₃ = t₁ * cos(p₁) - 1
                let r = $0.r
                return CGPoint(x: r*cos(t₂) + t₃ * $0.x, y: r*sin(t₂) + t₃ * $0.y) / v₃₆
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let sangle = String(format: "%.2f", angle)
            let sdist = String(format: "%.2f", dist)
            return "RadialBlur(angle:\(sangle), dist:\(sdist))"
        }
    }

    /// Pie (Variation 37) - parametric
    struct Pie: VF {
        let slices: CGFloat
        let rotation: CGFloat
        let thickness: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {_ in
                let (p₁, p₂, p₃) = (slices, rotation, thickness)
                let Ψ₁ = CGFloat.random(in: 0...1)
                let Ψ₂ = CGFloat.random(in: 0...1)
                let Ψ₃ = CGFloat.random(in: 0...1)
                let t₁ = trunc(Ψ₁*p₁ + 0.5)
                let t₂ = p₂ + (2*π / p₁) * (t₁ + Ψ₂*p₃)
                return CGPoint(x: cos(t₂), y: sin(t₂)) * Ψ₃
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let sslices = String(format: "%.2f", slices)
            let srotation = String(format: "%.2f", rotation)
            let sthickness = String(format: "%.2f", thickness)
            return "Pie(slices:\(sslices), rotation:\(srotation), thickness:\(sthickness))"
        }
    }

    /// Ngon (Variation 38) - parametric
    struct Ngon: VF {
        let power: CGFloat
        let sides: CGFloat
        let corners: CGFloat
        let circle: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let p1 = power
                let p2 = 2*π/sides
                let p3 = corners
                let p4 = circle
                let φ = $0.φ
                let t3 = φ - p2 * floor(φ/p2)
                let t4 = (t3 > p2/2) ? t3 : t3 - p2
                let k = (p3 * (1 / cos(t4) - 1) + p4) / pow($0.r, p1)
                return $0 * k
            }
        }
        var description: String {
            let spower = String(format: "%.2f", power)
            let ssides = String(format: "%.2f", sides)
            let scorners = String(format: "%.2f", corners)
            let scircle = String(format: "%.2f", circle)
            return "Ngon(power:\(spower), sides:\(ssides), corners:\(scorners), circle:\(scircle))"
        }
    }

    /// Curl (Variation 39) - parametric
    struct Curl: VF {
        let c1: CGFloat
        let c2: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let (p₁, p₂) = (c1, c2)
                let (x, y) = ($0.x, $0.y)
                let x² = x * x
                let y² = y * y
                let t₁ = 1 + p₁ * x + p₂ * (x² - y²)
                let t₂ = p₁ * y + 2 * p₂ * x * y
                let t₁² = t₁ * t₁
                let t₂² = t₂ * t₂
                return CGPoint(x: x*t₁ + y*t₂, y: y*t₁ - x*t₂) / (t₁² + t₂²)
            }
        }
        var description: String {
            let sc1 = String(format: "%.2f", c1)
            let sc2 = String(format: "%.2f", c2)
            return "Curl(c1:\(sc1), c2:\(sc2))"
        }
    }

    /// Rectangles (Variation 40) - parametric
    struct Rectangles: VF {
        let x: CGFloat
        let y: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let (p1, p2) = (x, y)
                let (x,y) = ($0.x,$0.y)
                return CGPoint(x: (2 * floor(x/p1) + 1)*p1 - x, y: (2 * floor(y/p2) + 1)*p2 - y)
            }
        }
        var description: String {
            let sx = String(format: "%.2f", x)
            let sy = String(format: "%.2f", y)
            return "Rectangles(x:\(sx), y:\(sy))"
        }
    }

    /// Arch (Variation 41)
    struct Arch: VF {
        let v41: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return { _ in
                let Ψ = CGFloat.random(in: 0...1)
                let s = sin(Ψ * π * v41)
                let sin² = s * s
                return CGPoint(x: sin(Ψ * π * v41), y: sin² / cos(Ψ * π * v41))
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let sv41 = String(format: "%.2f", v41)
            return "Arch(v41:\(sv41))"
        }
    }

    /// Tangent (Variation 42)
    struct Tangent: VF {
        func create(transform: CGAffineTransform) -> V {
            return { let(x,y)=($0.x,$0.y); return CGPoint(x: sin(x)/cos(y), y: tan(y)) }
        }
    }

    /// Square (Variation 43)
    struct Square: VF {
        func create(transform: CGAffineTransform) -> V {
            return { _ in
                let Ψ₁ = CGFloat.random(in: 0...1)
                let Ψ₂ = CGFloat.random(in: 0...1)
                return CGPoint(x: Ψ₁ - 0.5, y: Ψ₂ - 0.5)
            }
        }
        var continuous: Bool { return false }
    }

    /// Rays (Variation 44)
    struct Rays: VF {
        let v44: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let Ψ = CGFloat.random(in: 0...1)
                return CGPoint(x: cos($0.x), y: sin($0.y)) * (v44 * tan(Ψ * π * v44) / $0.r²)
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let sv44 = String(format: "%.2f", v44)
            return "Rays(v44:\(sv44))"
        }
    }

    /// Blade (Variation 45)
    struct Blade: VF {
        let v45: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let Ψ = CGFloat.random(in: 0...1)
                let r = $0.r
                return CGPoint(x:cos(Ψ*r*v45) + sin(Ψ*r*v45), y:cos(Ψ*r*v45) - sin(Ψ*r*v45)) * $0.x
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let sv45 = String(format: "%.2f", v45)
            return "Blade(v45:\(sv45))"
        }
    }

    /// Secant (Variation 46)
    struct Secant: VF {
        let v46: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                return CGPoint(x:$0.x, y:1/(v46 * cos(v46 * $0.r)))
            }
        }
        var description: String {
            let sv46 = String(format: "%.2f", v46)
            return "Secant(v46:\(sv46))"
        }
    }

    /// Twintrian (Variation 47)
    struct Twintrian: VF {
        let v47: CGFloat
        func create(transform: CGAffineTransform) -> V {
            return {
                let Ψ = CGFloat.random(in: 0...1)
                let w = Ψ * $0.r * v47
                let s = sin(w)
                let c = cos(w)
                let s² = s * s
                let t = log10(s²) + c
                return CGPoint(x:t, y:t - π * s) * $0.x
            }
        }
        var continuous: Bool { return false }
        var description: String {
            let sv47 = String(format: "%.2f", v47)
            return "Twintrian(v47:\(sv47))"
        }
    }

    /// Cross (Variation 48)
    struct Cross: VF {
        func create(transform: CGAffineTransform) -> V {
            return {
                let (x,y) = ($0.x, $0.y)
                let (x²,y²) = (x*x, y*y)
                let s = (x² - y²)
                let s² = s * s
                return $0 * sqrt(1/s²)
            }
        }
    }
}

// MARK: - Factory for JSON

extension FrFl {

    typealias VFF = (Arg) -> VF

    struct Arg {
        let primary: [String: Float]
        let defval: Float
        subscript(key: String) -> CGFloat {
            if let val = primary[key] {
                return CGFloat(val)
            }
            return CGFloat(defval)
        }
    }
}

extension FrFl {

    static let map: [String: VF] = [
      "Linear": Linear(),
      "Sinusoidal": Sinusoidal(),
      "Spherical": Spherical(),
      "Swirl": Swirl(),
      "Horseshoe": Horseshoe(),
      "Polar": Polar(),
      "Handkerchief": Handkerchief(),
      "Heart": Heart(),
      "Disc": Disc(),
      "Spiral": Spiral(),
      "Hyperbolic": Hyperbolic(),
      "Diamond": Diamond(),
      "Ex": Ex(),
      "Julia": Julia(),
      "Bent": Bent(),
      "Waves": Waves(),
      "Fisheye": Fisheye(),
      "Popcorn": Popcorn(),
      "Exponential": Exponential(),
      "Power": Power(),
      "Cosine": Cosine(),
      "Rings": Rings(),
      "Fan": Fan(),
      "Eyefish": Eyefish(),
      "Bubble": Bubble(),
      "Cylinder": Cylinder(),
      "Noise": Noise(),
      "Blur": Blur(),
      "Gaussian": Gaussian(),
      "Tangent": Tangent(),
      "Square": Square(),
      "Cross": Cross(),
    ]

    static let pool: [String: VFF] = [
      "Blob": { (o:Arg) -> VF in return Blob(high: o["high"], low:o["low"], waves:o["waves"]) },
      "PDJ": { (o:Arg) -> VF in return PDJ(a: o["a"], b:o["b"], c:o["c"], d:o["d"]) },
      "Fan2": { (o:Arg) -> VF in return Fan2(x:o["x"], y:o["y"]) },
      "Rings2": { (o:Arg) -> VF in return Rings2(rings2: o["rings2"]) },
      "Perspective": { (o:Arg) -> VF in return Perspective(angle: o["angle"], dist:o["dist"]) },
      "JuliaN": { (o:Arg) -> VF in return JuliaN(power:o["power"], dist:o["dist"]) },
      "JuliaScope": { (o:Arg) -> VF in return JuliaScope(power:o["power"], dist: o["dist"]) },
      "RadialBlur": { (o:Arg) -> VF in return RadialBlur(angle:o["angle"], dist: o["dist"]) },
      "Pie": { (o:Arg) -> VF in return Pie(slices: o["slices"], rotation: o["rotation"], thickness: o["thickness"]) },
      "Ngon": { (o:Arg) -> VF in return Ngon(power: o["power"], sides: o["sides"], corners: o["corners"], circle: o["circle"]) },
      "Curl": { (o:Arg) -> VF in return Curl(c1: o["c1"], c2: o["c2"]) },
      "Rectangles": { (o:Arg) -> VF in return Rectangles(x: o["x"], y: o["y"]) },
      "Arch": { (o:Arg) -> VF in return Arch(v41: o["v41"]) },
      "Rays": { (o:Arg) -> VF in return Rays(v44: o["v44"]) },
      "Blade": { (o:Arg) -> VF in return Blade(v45: o["v45"]) },
      "Secant": { (o:Arg) -> VF in return Secant(v46: o["v46"]) },
      "Twintrian": { (o:Arg) -> VF in return Twintrian(v47: o["v47"]) },
    ]

    static func obtain(name: String, param: [String: Float]) -> VF? {
        if param.isEmpty {
            return map[name]
        } else {
            guard let vff: VFF = pool[name] else { return nil }
            return vff(Arg(primary: param, defval: 1))
        }
    }
}
