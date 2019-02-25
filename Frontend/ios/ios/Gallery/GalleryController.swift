//
//  CollectionViewController.swift
//  ios
//
//  Created by William Sevigny on 2019-02-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

private let canvasCellIdentifier = "CanvasCell"
private let contextMenuIdentifier = "ContextMenuCell"
private let placeholderIdentifier = "PlaceHolderCell"
private let sectionHeaderIdentifier = "GalleryHeader"

class GalleryController: UICollectionViewController {
    
    private var canvas : [Canvas] = []
    
    private var isContextMenuActive = false
    private var selectedCanvasIndex: Int = 1
    private var selectedCellIndex: Int = 1
    private var contextMenuCellCount: Int = -1
    private var placeholderCellCount: Int = -1
    
    private let itemsPerRow: CGFloat = 4
    private let sectionInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 50.0, right: 10.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CanvasService.getAll().done { (retreivedCanvas) in
            self.canvas = retreivedCanvas
            self.contextMenuCellCount = Int(ceil(Double(self.canvas.count) / 4.0))
            self.placeholderCellCount = (self.canvas.count) % 4
            self.collectionView.reloadData()
        }
    }

    // UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // Return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items
        return canvas.count + contextMenuCellCount + placeholderCellCount
    }

    // Configure the cells
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let isContextMenuCell = (indexPath.row + 1) % 5 == 0
        let isPlaceholderCell = (indexPath.row + 1) >= canvas.count + contextMenuCellCount && !isContextMenuCell
        
        if (isContextMenuCell) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: contextMenuIdentifier, for: indexPath) as! ContextMenuCell
            cell.CanvasName.text = canvas[selectedCanvasIndex].name
            cell.CanvasID.text = canvas[selectedCanvasIndex].canvasId
            return cell
        }
        
        if (isPlaceholderCell){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: placeholderIdentifier, for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: canvasCellIdentifier, for: indexPath) as! CanvasCell
        cell.name.text = canvas[indexPath.row - Int(floor(Double(indexPath.row) / 5.0))].name
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isContextMenuCell = (indexPath.row + 1) % 5 == 0
        let isPlaceholderCell = (indexPath.row + 1) >= canvas.count + contextMenuCellCount && !isContextMenuCell

        // Ignore placeholder cells on click
        if (isPlaceholderCell) {
            return
        }
        
        self.collectionView.performBatchUpdates({
            if(isContextMenuCell) {
                return
            }
            
            if (indexPath.row == selectedCellIndex) {
                self.isContextMenuActive = !self.isContextMenuActive
            } else {
                self.isContextMenuActive = true
                selectedCellIndex = indexPath.row
                selectedCanvasIndex = selectedCellIndex - Int(floor(Double(selectedCellIndex) / 5.0))
            }
            
        }, completion: { (finished) in
            let temp = IndexPath(row: (self.selectedCellIndex + (5 - (self.selectedCellIndex % 5))) - 1, section: 0)
            self.collectionView.reloadItems(at: [temp])
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        // 1
        switch kind {
        // 2
        case UICollectionView.elementKindSectionHeader:
            // 3
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: sectionHeaderIdentifier,
                    for: indexPath) as? GalleryHeader
                else {
                    fatalError("Invalid view type")
            }
            
//            let searchTerm = searches[indexPath.section].searchTerm
//            headerView.label.text = searchTerm
            return headerView
        default:
            // 4
            assert(false, "Invalid element type")
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension GalleryController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        var widthPerItem = availableWidth / itemsPerRow
        
        var heightPerItem: CGFloat = widthPerItem;

        if ((indexPath.row + 1) % 5 == 0) {
            widthPerItem = view.frame.width - sectionInsets.left * 2
            heightPerItem = 0
            if(self.isContextMenuActive) {
                if(indexPath.row + 1 == (selectedCellIndex + (5 - (selectedCellIndex % 5)))) {
                    heightPerItem = 200
                }
            }
        }

        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left / 2
    }
}

