//
//  GalleryController.swift
//  ios
//
//  Created by William Sevigny on 2019-02-18.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

final class GalleryController: UICollectionViewController {
    // MARK: - Properties
    private let reuseIdentifier = "GalleryCell"
    private let sectionInsets = UIEdgeInsets(
        top: 50.0,
        left: 20.0,
        bottom: 50.0,
        right: 20.0
    )
    
    private let itemsPerRow: CGFloat = 3
    private let canvas: [String] = ["aaa", "bbb", "ccc", "ddd", "eee", "fff", "ggg", "hhh"];
}

// MARK: - UICollectionViewDataSource
extension GalleryController {
    //1
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return canvas.count
//    }
    
    //2
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canvas.count
    }
    
    //3
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GalleryCell
        cell.backgroundColor = .blue
        // Configure the cell
        return cell
    }
}

// MARK: - Collection View Flow Layout Delegate
extension GalleryController : UICollectionViewDelegateFlowLayout {
    //1
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
