//
//  GalleryCell.swift
//  ios
//
//  Created by William Sevigny on 2019-03-21.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5;
        // Initialization code
    }
    
    public func setImageFromBytes(bytesString: String) -> Void {
        print("loading image")
        let dataDecoded : Data = Data(base64Encoded: bytesString, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        self.imageView.image = decodedimage
        self.imageView.setNeedsDisplay()
    }
}
