//
//  ARNImageTransitionNavigationController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ARNImageTransitionNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if operation == .Push {
            return ARNImageZoomTransition.createAnimator(.Push, fromVC: fromVC, toVC: toVC)
        } else if operation == .Pop {
            return ARNImageZoomTransition.createAnimator(.Pop, fromVC: fromVC, toVC: toVC)
        }
        
        return nil
    }
}
