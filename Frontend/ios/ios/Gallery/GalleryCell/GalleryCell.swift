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
    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    public var image: String = ""
    public var visibility: String = ""
    public var password: String = ""
    public var canvasId: String = ""
    public var author: String = ""
    public var drawViewModels: String = ""
    public var width: Float = 100
    public var height: Float = 100

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 5;
        // Initialization code
    }
    
    public func setImageFromBytes(bytesString: String) -> Void {
        let dataDecoded : Data = Data(base64Encoded: bytesString, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        self.imageView.image = decodedimage
        if(!self.password.isEmpty) {
            self.lockImage.isHidden = false
        } else {
            self.lockImage.isHidden = true
        }
        self.lockImage.setNeedsDisplay()
        self.imageView.setNeedsDisplay()
    }
}
