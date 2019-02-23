//
//  GalleryCell.swift
//  ios
//
//  Created by William Sevigny on 2019-02-18.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class CanvasCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    
//    let canvas: Canvas;
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override var isSelected: Bool {
//        didSet{
//            UIView.animate(withDuration: 0.2, animations:
//                {
//                    self.contentView.transform = self.isSelected ? CGAffineTransform(scaleX: 0.95, y: 0.95) : CGAffineTransform.identity
//                    self.contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
//            }) { (true) in
//                UIView.animate(withDuration: 0.2, animations:
//                    {
//                        self.contentView.transform = self.isSelected ?  CGAffineTransform(scaleX: 1.0, y: 1.0) : CGAffineTransform.identity
//                        self.contentView.backgroundColor = UIColor.clear
//                })
//            }
//        }
//    }

}
