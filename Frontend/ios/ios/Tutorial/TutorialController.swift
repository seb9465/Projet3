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
    
    private func initSlides() -> Void {
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
            slide.getStartedBtnAction = {
                self.dismiss(animated: true, completion: nil);
            }
        }
    }
    
    private func createSlides() -> [Slide] {
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide1.imageView.image = UIImage(named: "chienperdu2");
        slide1.labelTitle.text = "TITLE 1";
        slide1.labelDesc.text = "DESCRIPTION 1";
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide2.imageView.image = UIImage(named: "chienperdu1");
        slide2.labelTitle.text = "TITLE 2";
        slide2.labelDesc.text = "DESCRIPTION 2";
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide3.imageView.image = nil;
        slide3.labelTitle.text = "FIN";
        slide3.labelDesc.text = "FIN";
        
        return [slide1, slide2, slide3];
    }
    
    private func initPageControl() -> Void {
        self.pageControl.numberOfPages = _slides.count;
        self.pageControl.currentPage = 0;
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
