//
//  DetailViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class DetailViewController: ImageZoomAnimationVC {
    
    @IBOutlet weak var imageView : UIImageView!
    
    deinit {
        print("deinit DetailViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DetailViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DetailViewController viewWillDisappear")
    }
    
    // MARK: - ImageTransitionZoomable
    
    override func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: self.imageView.image)
        imageView.contentMode = self.imageView.contentMode
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = self.imageView!.frame
        return imageView
    }
    
    @objc override func presentationBeforeAction() {
        self.imageView.isHidden = true
    }
    
    @objc override func presentationCompletionAction(didComplete: Bool) {
        if didComplete {
            self.imageView.isHidden = false
        }
    }
    
    @objc override func dismissalBeforeAction() {
        self.imageView.isHidden = true
    }
    
    @objc override func dismissalCompletionAction(didComplete: Bool) {
        if !didComplete {
            self.imageView.isHidden = false
        }
    }
}
