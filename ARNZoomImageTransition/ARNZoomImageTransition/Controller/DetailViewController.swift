//
//  DetailViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, ARNImageTransitionZoomable {
    
    @IBOutlet weak var imageView : UIImageView!
    
    deinit {
        print("deinit DetailViewController")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("DetailViewController viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("DetailViewController viewWillDisappear")
    }
    
    // MARK: - ARNImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: self.imageView.image)
        imageView.contentMode = self.imageView.contentMode
        imageView.clipsToBounds = true
        imageView.userInteractionEnabled = false
        imageView.frame = self.imageView!.frame
        return imageView
    }
    
    func presentationBeforeAction() {
        self.imageView.hidden = true
    }
    
    func presentationCompletionAction(completeTransition: Bool) {
        self.imageView.hidden = false
    }
    
    func dismissalBeforeAction() {
        self.imageView.hidden = true
    }
    
    func dismissalCompletionAction(completeTransition: Bool) {
        if !completeTransition {
            self.imageView.hidden = false
        }
    }
}
