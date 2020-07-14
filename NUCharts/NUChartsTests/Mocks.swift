//
//  Mocks.swift
//  NUChartsTests
//
//  Created by Jason Cox on 7/12/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import UIKit

class Mocks {
    /// Creates a mock UICollectionView
    internal static func collectionView() -> UICollectionView {
        // Setup the mock UICollectionViewFlowLayout
        let collectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        
        // Setup the mock UICollectionView
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                                collectionViewLayout: collectionViewFlowLayout);
        collectionView.contentSize = CGSize(width: 100, height: 100);
        
        return collectionView;
    }
    
    /// Returns an array of the following double values: -100. -50, 0, 50 and 100
    internal static func arrayOfValues_100_50_0_50_100() -> [Double] {
        return [-100, -50, 0, 50, 100];
    }
}
