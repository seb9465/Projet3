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
        var slides: [SlideInfo] = [];
        
        slides.append(SlideInfo(imageName: "tutorial-1", title: "Dashboard", description: "You are now in your personal profile that contains a gallery of public and private images."));
        slides.append(SlideInfo(imageName: "tutorial-2", title: "Dashboard", description: "You are now in your personal profile that contains a gallery of public and private images."));
        slides.append(SlideInfo(imageName: "tutorial-3", title: "Chatroom", description: "Here are your channels. You can access a channel by clicking on it."));
        slides.append(SlideInfo(imageName: "tutorial-4", title: "Register to another chatroom", description: "You can register to a new chatroom by clicking the plus sign."));
        slides.append(SlideInfo(imageName: "", title: "You are ready to go!", description: ""))
        
        var s: [Slide] = [];
        
        for slideInfos in slides {
            let slide: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
            slide.imageView.image = UIImage(named: slideInfos.imageName);
            slide.labelTitle.text = slideInfos.title;
            slide.labelDesc.text = slideInfos.description;
            
            s.append(slide);
        }
        
        return s;
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
