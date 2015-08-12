//
//  ARNImageZoomTransition.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

@objc protocol ARNImageTransitionZoomable {
    
    func createTransitionImageView() -> UIImageView
    
    // Present, Push
    
    optional
    func presentationBeforeAction()
    
    optional
    func presentationAnimationAction()
    
    optional
    func presentationCompletionAction()
    
    // Dismiss, Pop
    
    optional
    func dismissalBeforeAction()
    
    optional
    func dismissalAnimationAction()
    
    optional
    func dismissalCompletionAction()
}

class ARNImageZoomTransition {
    
    class func createAnimator(operationType: ARNTransitionAnimatorOperation, fromVC: UIViewController, toVC: UIViewController) -> ARNTransitionAnimator {
        var animator = ARNTransitionAnimator(operationType: operationType, fromVC: fromVC, toVC: toVC)
        
        if let sourceTransition = fromVC as? ARNImageTransitionZoomable, let destinationTransition = toVC as? ARNImageTransitionZoomable {
            toVC.view.layoutSubviews()
            
            animator.presentationBeforeHandler = { [weak fromVC, weak toVC
                , weak sourceTransition, weak destinationTransition] (containerView: UIView) in
                containerView.addSubview(fromVC!.view)
                containerView.addSubview(toVC!.view)
                
                // Update Auto Layout
                toVC!.view.layoutIfNeeded()
                
                if operationType == .Pop || operationType == .Dismiss {
                    containerView.bringSubviewToFront(fromVC!.view)
                }
                
                let sourceImageView = sourceTransition!.createTransitionImageView()
                let destinationImageView = destinationTransition!.createTransitionImageView()
                
                containerView.addSubview(sourceImageView)
                
                sourceTransition!.presentationBeforeAction?()
                destinationTransition!.presentationBeforeAction?()
                
                toVC!.view.alpha = 0.0
                
                animator.presentationAnimationHandler = { (containerView: UIView, percentComplete: CGFloat) in
                    sourceImageView.frame = destinationImageView.frame
                    
                    toVC!.view.alpha = 1.0
                    
                    sourceTransition!.presentationAnimationAction?()
                    destinationTransition!.presentationAnimationAction?()
                }
                
                animator.presentationCompletionHandler = { (containerView: UIView, didComplete: Bool) in
                    sourceImageView.removeFromSuperview()
                    
                    sourceTransition!.presentationCompletionAction?()
                    destinationTransition!.presentationCompletionAction?()
                }
            }
            
            animator.dismissalBeforeAnimationHandler = { [weak fromVC, weak toVC
                , weak sourceTransition, weak destinationTransition] (containerView: UIView) in
                containerView.addSubview(fromVC!.view)
                containerView.addSubview(toVC!.view)
                
                if operationType == .Pop || operationType == .Dismiss {
                    containerView.bringSubviewToFront(fromVC!.view)
                }
                
                let sourceImageView = sourceTransition!.createTransitionImageView()
                let destinationImageView = destinationTransition!.createTransitionImageView()
                containerView.addSubview(sourceImageView)
                
                sourceTransition!.dismissalBeforeAction?()
                destinationTransition!.dismissalBeforeAction?()
                
                animator.dismissalAnimationHandler = { (containerView: UIView, percentComplete: CGFloat) in
                    sourceImageView.frame = destinationImageView.frame
                    fromVC!.view.alpha = 0.0
                    
                    sourceTransition!.dismissalAnimationAction?()
                    destinationTransition!.dismissalAnimationAction?()
                }
                
                animator.dismissalCompletionHandler = { (containerView: UIView, didComplete: Bool) in
                    sourceImageView.removeFromSuperview()
                    
                    sourceTransition!.dismissalCompletionAction?()
                    destinationTransition!.dismissalCompletionAction?()
                }
            }
        }
        
        return animator
    }
}
