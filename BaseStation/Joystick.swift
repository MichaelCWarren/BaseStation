//
//  Joystick.swift
//  BaseStation
//
//  Created by Michael Warren on 12/1/22.
//

import SwiftUI

public struct Joystick: View {
    private(set) public var width: CGFloat
    
    private(set) public var x: CGFloat
    private(set) public var y: CGFloat
    
    public init(width: CGFloat, x: CGFloat, y: CGFloat) {
        self.width = width
        self.x = x
        self.y = y
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.blue.opacity(0.5))
            .frame(width: self.width, height: self.width)
            .overlay(
                Circle().fill(Color.black)
                    .frame(width: self.width / 4, height: self.width / 4)
                    .position(x: self.width * self.x, y: self.width * self.y)
            )
    }
}
