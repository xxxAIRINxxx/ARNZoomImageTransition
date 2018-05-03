//
//  ModalViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ModalViewController: ImageZoomAnimationVC {

    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var closeButton : UIButton!
    
    @IBAction func tapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit ModalViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ModalViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ModalViewController viewWillDisappear")
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
    
    override func presentationBeforeAction() {
        self.imageView.isHidden = true
    }
    
    override func presentationCompletionAction(didComplete: Bool) {
        self.imageView.isHidden = false
    }
    
    override func dismissalBeforeAction() {
        self.imageView.isHidden = true
    }
    
    override func dismissalCompletionAction(didComplete: Bool) {
        if !didComplete {
            self.imageView.isHidden = false
        }
    }
}
