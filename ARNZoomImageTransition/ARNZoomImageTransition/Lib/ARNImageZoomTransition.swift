//
//  ARNImageZoomTransition.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

@objc protocol ARNImageTransitionZoomable {
    
    func createTransitionImageView() -> UIImageView
    
    // Present, Push
    
    optional
    func presentationBeforeAction()
    
    optional
    func presentationAnimationAction(percentComplete: CGFloat)
    
    optional
    func presentationCancelAnimationAction()
    
    optional
    func presentationCompletionAction(completeTransition: Bool)
    
    // Dismiss, Pop
    
    optional
    func dismissalBeforeAction()
    
    optional
    func dismissalAnimationAction(percentComplete: CGFloat)
    
    optional
    func dismissalCancelAnimationAction()
    
    optional
    func dismissalCompletionAction(completeTransition: Bool)
}

class ARNImageZoomTransition {
    
    class func createAnimator(operationType: ARNTransitionAnimatorOperation, fromVC: UIViewController, toVC: UIViewController) -> ARNTransitionAnimator {
        let animator = ARNTransitionAnimator(operationType: operationType, fromVC: fromVC, toVC: toVC)
        
        if let sourceTransition = fromVC as? ARNImageTransitionZoomable, let destinationTransition = toVC as? ARNImageTransitionZoomable {
            
            animator.presentationBeforeHandler = { containerView, transitionContext in
                containerView.addSubview(toVC.view)
                
                toVC.view.setNeedsLayout()
                toVC.view.layoutIfNeeded()
                
                let sourceImageView = sourceTransition.createTransitionImageView()
                let destinationImageView = destinationTransition.createTransitionImageView()
                
                containerView.addSubview(sourceImageView)
                
                sourceTransition.presentationBeforeAction?()
                destinationTransition.presentationBeforeAction?()
                
                toVC.view.alpha = 0.0
                
                animator.presentationAnimationHandler = { containerView, percentComplete in
                    sourceImageView.frame = destinationImageView.frame
                    
                    toVC.view.alpha = 1.0
                    
                    sourceTransition.presentationAnimationAction?(percentComplete)
                    destinationTransition.presentationAnimationAction?(percentComplete)
                }
                
                animator.presentationCompletionHandler = { containerView, completeTransition in
                    if !completeTransition { return }
                    
                    sourceImageView.removeFromSuperview()
                    sourceTransition.presentationCompletionAction?(completeTransition)
                    destinationTransition.presentationCompletionAction?(completeTransition)
                }
            }
            
            animator.dismissalBeforeHandler = { containerView, transitionContext in
                if case .Dismiss = operationType {
                    containerView.addSubview(toVC.navigationController!.view)
                } else {
                    containerView.addSubview(toVC.view)
                }
                containerView.addSubview(fromVC.view)
                
                let sourceImageView = sourceTransition.createTransitionImageView()
                let destinationImageView = destinationTransition.createTransitionImageView()
                containerView.addSubview(sourceImageView)
                
                sourceTransition.dismissalBeforeAction?()
                destinationTransition.dismissalBeforeAction?()
                
                animator.dismissalAnimationHandler = { containerView, percentComplete in
                    sourceImageView.frame = destinationImageView.frame
                    fromVC.view.alpha = 0.0
                    
                    sourceTransition.dismissalAnimationAction?(percentComplete)
                    destinationTransition.dismissalAnimationAction?(percentComplete)
                }
                
                animator.dismissalCompletionHandler = { containerView, completeTransition in
                    if !completeTransition { return }
                    
                    sourceImageView.removeFromSuperview()
                    fromVC.view.removeFromSuperview()
                    
                    sourceTransition.dismissalCompletionAction?(completeTransition)
                    destinationTransition.dismissalCompletionAction?(completeTransition)
                }
            }
        }
        
        return animator
    }
}
