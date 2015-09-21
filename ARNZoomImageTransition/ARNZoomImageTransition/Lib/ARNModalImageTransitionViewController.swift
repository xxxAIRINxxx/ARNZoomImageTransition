//
//  ARNModalImageTransitionViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

class ARNModalImageTransitionViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    weak var fromVC : UIViewController?

    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ARNImageZoomTransition.createAnimator(.Present, fromVC: source, toVC: presented)
        self.fromVC = source
        
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = ARNImageZoomTransition.createAnimator(.Dismiss, fromVC: self, toVC: self.fromVC!)
        
        return animator
    }
}
