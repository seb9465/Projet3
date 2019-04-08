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
        self._slides = self.createSlides();
        setupSlideScrollView(slides: self._slides);
        
        self.pageControl.numberOfPages = _slides.count;
        self.pageControl.currentPage = 0;
        self.view.bringSubviewToFront(self.pageControl);
        
        self.scrollView.delegate = self;
        
        self.initSlidesView();
        
        super.viewDidLoad();
    }
    
    // MARK: - Public functions
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupSlideScrollView(slides: self._slides)
    }
    
    // MARK: - Private functions
    
    private func initSlidesView() -> Void {
        for slide in self._slides {
            slide.initSlide();
        }
    }
    
    private func createSlides() -> [Slide] {
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide1.imageView.image = UIImage(named: "lock");
        slide1.labelTitle.text = "TITLE 1";
        slide1.labelDesc.text = "DESCRIPTION 1";
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide2.imageView.image = UIImage(named: "lock");
        slide2.labelTitle.text = "TITLE 2";
        slide2.labelDesc.text = "DESCRIPTION 2";
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide;
        slide3.imageView.image = UIImage(named: "lock");
        slide3.labelTitle.text = "FIN";
        slide3.labelDesc.text = "FIN";
        // Ajouter bouton pour retourner au début.
        
        return [slide1, slide2, slide3];
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset);
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
            _slides[0].imageView.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
            _slides[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
        }
//        else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
//            _slides[1].imageView.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
//            _slides[2].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
//        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
//            _slides[2].imageView.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
//            _slides[3].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
//        } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
//            _slides[3].imageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
//            _slides[4].imageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
//        }
    }
}
