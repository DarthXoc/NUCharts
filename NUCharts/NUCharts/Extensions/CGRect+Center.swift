//
//  CGRect+Center.swift
//  NUCharts
//
//  Created by Jason Cox on 7/11/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import UIKit

extension CGRect {
    /// Calculates the center point of a CGRect
    public func centerPoint() -> CGPoint {
        return CGPoint(x: self.origin.x + (self.width / 2),
                       y: self.origin.y + (self.height / 2));
    }
}
