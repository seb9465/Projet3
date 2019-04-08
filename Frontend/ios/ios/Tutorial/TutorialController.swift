//
//  TutorialController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-04-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class TutorialController: UIViewController {
    
    // MARK: - Attributes
    
    
    // MARK: - Outlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    // MARK: - Timing functions
    
    override func viewDidLoad() {
        let slides: [Slide] = self.createSlides();
        setupSlideScrollView(slides: slides);
        
        self.pageControl.numberOfPages = slides.count;
        self.pageControl.currentPage = 0;
        self.view.bringSubviewToFront(self.pageControl);
    }
    
    // MARK: - Public functions
    
    
    // MARK: - Private functions
    
    private func createSlides() -> [Slide] {
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide1.imageView.image = UIImage(named: "ic_onboarding_1");
        slide1.labelTitle.text = "A real-life bear";
        slide1.labelDesc.text = "Did you know that Winnie the chubby little cubby was based on a real, young bear in London";
        
        return [slide1];
    }
    
    private func setupSlideScrollView(slides: [Slide]) -> Void {
        self.scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
        self.scrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(slides.count), height: self.view.frame.height);
        self.scrollView.isPagingEnabled = true;
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: self.view.frame.width * CGFloat(i), y: 0, width: self.view.frame.width, height: self.view.frame.height);
            self.scrollView.addSubview(slides[i]);
        }
    }
}
