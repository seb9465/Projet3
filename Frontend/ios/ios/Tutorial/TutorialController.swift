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
    
    @IBOutlet weak var skipButton: UIButton!
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
    
    @IBAction func skipPressed(_ sender: Any) {
        AuthentificationAPI.setIsTutorialShown()
        self.dismiss(animated: true, completion: nil)
    }
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
        slides.append(SlideInfo(imageName: "tutorial-5", title: "Add a chatroom", description: "You can create a new room by writing the name of the room you desire. You can also register to an existing chatroom by clicking on it."));
        slides.append(SlideInfo(imageName: "tutorial-7", title: "Open an existing canvas", description: "In the gallery, you can open an existing canvas by clicking on it."));
        slides.append(SlideInfo(imageName: "tutorial-6", title: "Create a new canvas", description: "In the gallery, you can create a new canvas by clicking on the New Canvas button."));
        slides.append(SlideInfo(imageName: "tutorial-8", title: "Creating a new canvas", description: "When creating a new canvas, you will be asked to select a visibility and a protection. A public canvas can be seen by every user in the gallery. A protected canvas can only be seen by yourself."));
        slides.append(SlideInfo(imageName: "tutorial-9", title: "Password protection", description: "Once you have selected the visibility of your canvas, you will be asked a password. Password is optionnal."));
        slides.append(SlideInfo(imageName: "tutorial-10", title: "Editor", description: "Here is the canvas editor."));
        slides.append(SlideInfo(imageName: "tutorial-11", title: "Insert figure", description: "You can insert element to the canvas by selecting it in the menu."));
        slides.append(SlideInfo(imageName: "tutorial-12", title: "Insert connection", description: "You can insert a connection figure to the canvas by selecting it in the menu."));
        slides.append(SlideInfo(imageName: "tutorial-13", title: "Styling", description: "You can change the style of an element via the left side menu."));
        slides.append(SlideInfo(imageName: "tutorial-14", title: "Tools", description: "There are plently of tools available in the top bar. From left to right, there is the quit button, the save button, the clear button, the undo button, the redo button, the cut button, the duplicate button and the selection button."));
        slides.append(SlideInfo(imageName: "tutorial-15", title: "Chat in the Editor View", description: "From the Editor view, you can access the chat by clicking the top right button."));
        slides.append(SlideInfo(imageName: "", title: "You are ready to go!", description: ""));
        
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
