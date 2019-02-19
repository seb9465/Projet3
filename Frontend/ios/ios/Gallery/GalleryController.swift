//
//  GalleryController.swift
//  ios
//
//  Created by William Sevigny on 2019-02-18.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

final class GalleryController: UICollectionViewController {
    private let cellIdentifier = "GalleryCell"
    private let itemsPerRow: CGFloat = 3
    private let canvas: [String] = ["aaa", "bbb", "ccc", "ddd", "eee", "fff", "ggg", "hhh"];
    private let sectionInsets = UIEdgeInsets(
        top: 50.0,
        left: 20.0,
        bottom: 50.0,
        right: 20.0
    )
    
    override func viewDidLoad() {
        print(CanvasService.getAll())
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return canvas.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GalleryCell
        cell.backgroundColor = .blue
        // Configure the cell
        return cell
    }
}

// MARK: - Collection View Flow Layout Delegate
extension GalleryController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
