//
//  HomeTableViewController+UICollectionViewDelegateFlowLayout.swift
//  Sonix
//
//  Copyright © 2018 Mark Bourke.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

import Foundation

extension HomeTableViewController {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionView = collectionView as! RailCollectionView
        let collectionViewLayout = collectionViewLayout as! RailCollectionViewFlowLayout
        let rail = collectionView.tag
        
        switch rail {
        case 0:
            let width: CGFloat
            
            switch traitCollection.horizontalSizeClass {
            case .compact:
                width = min(365, view.frame.width - collectionView.safeAreaInsets.left - collectionViewLayout.minimumLineSpacing - collectionView.safeAreaInsets.right - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right)
            case .regular:
                width = 365
            default:
                width = 0
            }
            
            return CGSize(width: width, height: (width * 9)/16)
        case 1,2,4,5:
            switch traitCollection.horizontalSizeClass {
            case .compact:
                return CGSize(width: 112, height: 190)
            case .regular:
                return CGSize(width: 160, height: 272)
            default:
                return .zero
            }
        case 3:
            let width: CGFloat
            
            switch traitCollection.horizontalSizeClass {
            case .compact:
                width = min(365, view.frame.width - collectionView.safeAreaInsets.left - collectionViewLayout.minimumLineSpacing - collectionView.safeAreaInsets.right - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right)
            case .regular:
                width = 365
            default:
                width = 0
            }
            
            return CGSize(width: width, height: (width * 3)/11)
        case 6:
            let width: CGFloat
            
            switch traitCollection.horizontalSizeClass {
            case .compact:
                width = min(365, view.frame.width - collectionView.safeAreaInsets.left - collectionViewLayout.minimumLineSpacing - collectionView.safeAreaInsets.right - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right)
            case .regular:
                width = 365
            default:
                width = 0
            }
            
            return CGSize(width: width, height: (width * 6)/11)
        default:
            fatalError()
        }
    }
}
