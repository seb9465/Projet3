//
//  TutorialController.swift
//  ios
//
//  Created by Sebastien Cadorette on 2019-04-07.
//  Copyright © 2019 LOG3000 equipe 12. All rights reserved.
//

import UIKit

class TutorialController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Attributes
    
    private var _slides: [Slide]!;
    
    // MARK: - Outlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    // MARK: - Timing functions
    
    override func viewDidLoad() {
        self.initSlides();
        
        self.scrollView.delegate = self;
        
        super.viewDidLoad();
    }
    
    // MARK: - Public functions
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupSlideScrollView(slides: self._slides)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width);
        self.pageControl.currentPage = Int(pageIndex);
    }
    
    // MARK: - Private functions
    
    private func initSlides() -> Void {
        self._slides = self.createSlides();
        self.initSlidesView();
        setupSlideScrollView(slides: self._slides);
        self._slides.last?.getStartedButon.isHidden = false;
        
        self.initPageControl();
        
        self.view.bringSubviewToFront(self.pageControl);
    }
    
    private func initSlidesView() -> Void {
        for slide in self._slides {
            slide.initSlide();
        }
        
        self._slides.last?.getStartedBtnAction = {
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    private func createSlides() -> [Slide] {
        var images: [String] = [];
        var titles: [String] = [];
        var descriptions: [String] = [];
//        var test: [String, String, String] = []
        
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide1.imageView.image = UIImage(named: "tutorial-1");
        slide1.labelTitle.text = "Dashboard";
        slide1.labelDesc.text = "You are now in your personal profile that contains a gallery of public and private images.";
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide2.imageView.image = UIImage(named: "tutorial-2");
        slide2.labelTitle.text = "Chat";
        slide2.labelDesc.text = "You can access the chat via the right side menu.";
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide3.imageView.image = UIImage(named: "tutorial-3");
        slide3.labelTitle.text = "Chatroom";
        slide3.labelDesc.text = "Here are your channels. You can access a channel by clicking on it.";
        
        let slide4:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide4.imageView.image = UIImage(named: "tutorial-4");
        slide4.labelTitle.text = "Register to another chatroom";
        slide4.labelDesc.text = "You can register to a new chatroom by clicking the plus sign.";
        
        return [slide1, slide2, slide3];
    }
    
    private func initPageControl() -> Void {
        self.pageControl.numberOfPages = _slides.count;
        self.pageControl.currentPage = 0;
        self.pageControl.currentPageIndicatorTintColor = Constants.Colors.RED_COLOR;
        self.pageControl.tintColor = UIColor.black;
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
