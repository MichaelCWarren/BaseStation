//
//  ArtificialHorizon.swift
//  BaseStation
//
//  Created by Michael Warren on 12/21/22.
//

import Foundation
import SwiftUI

public struct BackgroundHorizon : View {
    var width: Double
    var height: Double
    
    public var body : some View {
        SkyGround().frame(width: width, height: height)
            .overlay {
                Group {
                    Tick()
                        .stroke(lineWidth: height * 0.0225)
                        .rotationEffect(Angle(degrees: -90))
                    
                    Tick()
                        .stroke(lineWidth: height * 0.0175)
                        .rotationEffect(Angle(degrees: -60))
                    
                    Triangle(push: (height * 0.1 / 2), width: width * 0.035)
                        .rotationEffect(Angle(degrees: -45))
                    
                    Tick()
                        .stroke(lineWidth: height * 0.0175)
                        .rotationEffect(Angle(degrees: -30))
                    
                    Tick()
                        .stroke(lineWidth: height / 100.0)
                        .rotationEffect(Angle(degrees: -20))
                    
                    Tick()
                        .stroke(lineWidth: height / 100.0)
                        .rotationEffect(Angle(degrees: -10))
                }
                
                
                Triangle(width: width * 0.0625, height: height * 0.145)
                Line()
                    .stroke(lineWidth: height * 0.0075)
                Group {
                    Tick()
                        .stroke(lineWidth: height / 100.0)
                        .rotationEffect(Angle(degrees: 10))
                    Tick()
                        .stroke(lineWidth: height / 100.0)
                        .rotationEffect(Angle(degrees: 20))
                    Tick()
                        .stroke(lineWidth: height * 0.0175)
                        .rotationEffect(Angle(degrees: 30))
                    
                    Triangle(push: (height * 0.1 / 2), width: width * 0.035)
                        .rotationEffect(Angle(degrees: 45))
                    
                    Tick()
                        .stroke(lineWidth: height * 0.0175)
                        .rotationEffect(Angle(degrees: 60))
                    
                    Tick()
                        .stroke(lineWidth: height * 0.0225)
                        .rotationEffect(Angle(degrees: 90))
                }
            }
    }
}

public struct InsideHorizon : View {
    var width: Double
    var height: Double
    var pitch: Double
    
    var verticalAngle = 70.0
    
    public var body : some View {
        SkyGround()
            .overlay {
                if pitch > (verticalAngle / 4) {
                    Color(hex: "00adef")
                } else {
                    Color(hex: "6c5735")
                }
                
            }
            .overlay {
                SkyGround()
                    .overlay{
                        Group {
                            Line(width: width * 0.25)
                                .stroke(lineWidth: height / 200.0)
                                .offset(y: (height / 2) * (20 / verticalAngle))
                            
                            Line(width: width * 0.1)
                                .stroke(lineWidth: height / 100.0)
                                .offset(y: (height / 2) * (15 / verticalAngle))
                            
                            Line(width: width * 0.175)
                                .stroke(lineWidth: height / 200.0)
                                .offset(y: (height / 2) * (10 / verticalAngle))
                            
                            Line(width: width * 0.0875)
                                .stroke(lineWidth: height / 100.0)
                                .offset(y: (height / 2) * (5 / verticalAngle))
                            
                            Line()
                                .stroke(lineWidth: 3)

                        }
                        Group {
                            Line(width: width * 0.25)
                                .stroke(lineWidth: height / 200.0)
                                .offset(y: -1 * (height / 2) * (20 / verticalAngle))
                            
                            Line(width: width * 0.1)
                                .stroke(lineWidth: height / 100.0)
                                .offset(y: -1 * (height / 2) * (15 / verticalAngle))
                            
                            Line(width: width * 0.175)
                                .stroke(lineWidth: height / 200.0)
                                .offset(y: -1 * (height / 2) * (10 / verticalAngle))
                            
                            Line(width: width * 0.0875)
                                .stroke(lineWidth: height / 100.0)
                                .offset(y: -1 * (height / 2) * (5 / verticalAngle))
                        }
                        
                    }
                    .frame(width: width, height: height)
                    .offset(y: (height / 2) * (pitch / verticalAngle))
            }
            
            .frame(width: width * 0.75, height: height * 0.75)
            .clipShape(Circle())
    }
}

public struct ArtificialHorizon : View {
    var width = 400.0
    var height = 400.0
    var roll = 0.0
    var pitch = 0.0
    
    public var body : some View {
        ZStack {
            BackgroundHorizon(width: width, height: height)
                .rotationEffect(Angle(degrees: -roll))
            
            InsideHorizon(width: width, height: height, pitch: pitch)
                .rotationEffect(Angle(degrees: -roll))
                .overlay {
                    UpsideDownTriangle(width: width * 0.05, height:  height * 0.075)
                        .stroke(lineWidth: height / 200)
                        .foregroundColor(.orange)
                }
            
            BrokenLine(width: width / 2)
                .stroke(lineWidth: height * 0.0175)
                .foregroundColor(.orange)
                .shadow(radius: 1, x: 5, y: 5)
        }
    }
}

struct BrokenLine : Shape {
    var width = 200.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX - (width / 2.0), y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX - (width / 4.0), y: rect.midY))
        path.move(to: CGPoint(x: rect.midX - (width / 32.0), y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX + (width / 32.0), y: rect.midY))
        path.move(to: CGPoint(x: rect.midX + (width / 4.0), y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX + (width / 2.0), y: rect.midY))
        return path
    }
}

struct Line : Shape {
    var width = 0.0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if width > 0 {
            path.move(to: CGPoint(x: rect.midX - (width / 2.0), y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX + (width / 2.0), y: rect.midY))
        } else {
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
        
        
        return path
    }
}

struct UpsideDownTriangle: Shape {
    var width = 25.0
    var height = 40.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX - (width / 2), y: height))
        path.addLine(to: CGPoint(x: rect.midX, y: 0))
        path.addLine(to: CGPoint(x: rect.midX + (width / 2), y: height))
        path.addLine(to: CGPoint(x: rect.midX - (width / 2), y: height))
        
        return path
    }
}

struct Triangle: Shape {
    var push = 0.0
    var width = 25.0
    var height = 40.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX - (width / 2), y: push))
        path.addLine(to: CGPoint(x: rect.midX, y: height - push))
        path.addLine(to: CGPoint(x: rect.midX + (width / 2), y: push))
        path.closeSubpath()
        
        return path
    }
}


struct Tick: Shape {
    var height = 40
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x:rect.midX, y: rect.minY))
        path.addLine (to: CGPoint(x:rect.midX, y: rect.minY + CGFloat(height)))
        return path
    }
}

public struct SkyGround : View {
    var roll: Double = 0
    
    public var body : some View {
        ZStack {
            Circle()
                .trim(from: 0.5, to: 1)
                .fill(Color(hex: "00adef"))
                .overlay {
                    
                }
            Circle()
                .trim(from: 0, to: 0.5)
                .fill(Color(hex: "6c5735"))
        }.rotationEffect(Angle(degrees: roll))
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


struct ArtificialHorizon_Previews: PreviewProvider {
    static var previews: some View {
        ArtificialHorizon()
    }
}
