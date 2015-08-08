//
//  ARNTransitionAnimator.swift
//  ARNTransitionAnimator
//
//  Created by xxxAIRINxxx on 2015/02/26.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public enum ARNTransitionAnimatorDirection: Int {
    case Top
    case Bottom
    case Left
    case Right
}

public class ARNTransitionAnimator: UIPercentDrivenInteractiveTransition,
    UIViewControllerAnimatedTransitioning,
    UIViewControllerTransitioningDelegate,
UIGestureRecognizerDelegate {
    
    public var direction : ARNTransitionAnimatorDirection = .Bottom
    public var panCompletionThreshold : CGFloat = 100.0
    
    public var presentationBeforeHandler : ((containerView: UIView) ->())?
    public var presentationAnimationHandler : ((containerView: UIView, percentComplete: CGFloat) ->())?
    public var presentationCompletionHandler : ((containerView: UIView, didComplete: Bool) ->())?
    
    public var dismissalBeforeAnimationHandler : ((containerView: UIView) ->())?
    public var dismissalAnimationHandler : ((containerView: UIView, percentComplete: CGFloat) ->())?
    public var dismissalCompletionHandler : ((containerView: UIView, didComplete: Bool) ->())?
    
    public var usingSpringWithDamping : CGFloat = 1.0
    public var transitionDuration : NSTimeInterval = 0.5
    public var initialSpringVelocity : CGFloat = 0.1
    
    public var needPresentationInteractive : Bool = false {
        didSet {
            if self.needPresentationInteractive == true {
                self.registerPanGesture()
            } else {
                self.unregisterPanGesture()
            }
        }
    }
    public var needDismissalInteractive : Bool = false {
        didSet {
            if self.needDismissalInteractive == true {
                self.registerPanGesture()
            } else {
                self.unregisterPanGesture()
            }
        }
    }
    
    var parentController : UIViewController
    var modalController : UIViewController
    var gesture :UIPanGestureRecognizer?
    var transitionContext : UIViewControllerContextTransitioning?
    var isDismiss : Bool = false
    var isInteractive : Bool = false
    var panLocationStart : CGFloat = 0.0
    
    deinit {
        self.unregisterPanGesture()
    }
    
    public init(parentController: UIViewController,  modalViewController: UIViewController) {
        self.parentController = parentController
        self.modalController = modalViewController
        self.modalController.modalPresentationStyle = .Custom
    }
    
    func registerPanGesture() {
        if self.gesture == nil {
            self.gesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
            self.gesture!.delegate = self
            if self.needPresentationInteractive == true {
                self.parentController.view.addGestureRecognizer(self.gesture!)
            } else if self.needDismissalInteractive == true {
                self.modalController.view.addGestureRecognizer(self.gesture!)
            }
        }
    }
    
    func unregisterPanGesture() {
        if let _gesture = self.gesture {
            if let _view = _gesture.view {
                _view.removeGestureRecognizer(_gesture)
            }
            _gesture.delegate = nil
        }
        self.gesture = nil
    }
    
    func fireBeforeHandler(containerView: UIView) {
        if self.isDismiss == false {
            self.presentationBeforeHandler?(containerView: containerView)
        } else {
            self.dismissalBeforeAnimationHandler?(containerView: containerView)
        }
    }
    
    func fireAnimationHandler(containerView: UIView, percentComplete: CGFloat) {
        if self.isDismiss == false {
            self.presentationAnimationHandler?(containerView: containerView, percentComplete: percentComplete)
        } else {
            self.dismissalAnimationHandler?(containerView: containerView, percentComplete: percentComplete)
        }
    }
    
    func animateWithDuration(duration: NSTimeInterval, containerView: UIView, didComplete: Bool, completion: (() -> Void)?) {
        UIView.animateWithDuration(
            duration,
            delay: 0,
            usingSpringWithDamping: self.usingSpringWithDamping,
            initialSpringVelocity: self.initialSpringVelocity,
            options: .CurveEaseOut,
            animations: {
                if didComplete == true {
                    self.fireAnimationHandler(containerView, percentComplete: 1.0)
                } else {
                    self.fireBeforeHandler(containerView)
                }
            }, completion: { finished in
                if self.isDismiss == false {
                    self.presentationCompletionHandler?(containerView: containerView, didComplete: didComplete)
                } else {
                    self.dismissalCompletionHandler?(containerView: containerView, didComplete: didComplete)
                }
                completion?()
        })
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    public func animationEnded(transitionCompleted: Bool) {
        self.needPresentationInteractive = false
        self.needDismissalInteractive = false
        self.transitionContext = nil
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)
        
        if self.isDismiss == true {
            containerView.bringSubviewToFront(fromVC.view)
        }
        
        self.fireBeforeHandler(containerView)
        
        self.animateWithDuration(
            self.transitionDuration(transitionContext),
            containerView: containerView,
            didComplete: true) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    // MARK: UIViewControllerInteractiveTransitioning
    
    public override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        self.fireBeforeHandler(containerView)
        self.transitionContext = transitionContext
        
        if self.isDismiss == false {
            toVC.view.hidden = true
            containerView.addSubview(toVC.view)
        } else {
            fromVC.view.hidden = true
            containerView.bringSubviewToFront(fromVC.view)
        }
    }
    
    public override func updateInteractiveTransition(percentComplete: CGFloat) {
        if let transitionContext = self.transitionContext {
            
            // FIXME! : deal for view is displayed only for a moment
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            if self.isDismiss == false {
                toVC.view.hidden = false
            } else {
                fromVC.view.hidden = false
            }
            
            let containerView = transitionContext.containerView()
            self.fireAnimationHandler(containerView, percentComplete: percentComplete)
        }
    }
    
    public override func finishInteractiveTransition() {
        if let transitionContext = self.transitionContext {
            
            let containerView = transitionContext.containerView()
            self.animateWithDuration(
                self.transitionDuration(transitionContext),
                containerView: containerView,
                didComplete: true) {
                    transitionContext.completeTransition(true)
            }
        }
    }
    
    public override func cancelInteractiveTransition() {
        if let transitionContext = self.transitionContext {
            
            let containerView = transitionContext.containerView()
            self.animateWithDuration(
                self.transitionDuration(transitionContext),
                containerView: containerView,
                didComplete: false) {
                    transitionContext.completeTransition(false)
            }
        }
    }
    
    // MARK: UIViewControllerTransitioning Delegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isDismiss = false
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isDismiss = true
        return self
    }
    
    public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.needPresentationInteractive == true {
            return self
        }
        return nil
    }
    
    public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.needDismissalInteractive == true {
            return self
        }
        return nil
    }
    
    // MARK: Gesture Delegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // MARK: Gesture
    
    public func handlePan(recognizer: UIPanGestureRecognizer) {
        var window : UIWindow? = nil
        
        if self.isDismiss == false {
            window = self.parentController.view.window
        } else {
            window = self.modalController.view.window
        }
        
        var location = recognizer.locationInView(window)
        location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view!.transform))
        var velocity = recognizer .velocityInView(window)
        velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view!.transform))
        
        if recognizer.state == .Began {
            self.isInteractive = true
            switch (self.direction) {
            case .Top, .Bottom:
                self.panLocationStart = location.y
            case .Left, .Right:
                self.panLocationStart = location.x
            }
            if self.isDismiss == false {
                self.parentController.presentViewController(self.modalController, animated: true, completion: nil)
            } else {
                self.modalController.dismissViewControllerAnimated(true, completion: nil)
            }
        } else if recognizer.state == .Changed {
            var animationRatio: CGFloat = 0.0
            
            var bounds = CGRectZero
            if self.isDismiss == false {
                bounds = self.parentController.view.bounds
            } else {
                bounds = self.modalController.view.bounds
            }
            
            switch self.direction {
            case .Top:
                animationRatio = (self.panLocationStart - location.y) / CGRectGetHeight(bounds)
            case .Bottom:
                animationRatio = (location.y - self.panLocationStart) / CGRectGetHeight(bounds)
            case .Left:
                animationRatio = (self.panLocationStart - location.x) / CGRectGetWidth(bounds)
            case .Right:
                animationRatio = (location.x - self.panLocationStart) / CGRectGetWidth(bounds)
            }
            self.updateInteractiveTransition(animationRatio)
        } else if recognizer.state == .Ended {
            var velocityForSelectedDirection: CGFloat = 0.0
            switch (self.direction) {
            case .Top, .Bottom:
                velocityForSelectedDirection = velocity.y
            case .Left, .Right:
                velocityForSelectedDirection = velocity.x
            }
            
            if velocityForSelectedDirection > self.panCompletionThreshold && (self.direction == .Right || self.direction == .Bottom) {
                self.finishInteractiveTransition()
            } else if velocityForSelectedDirection < -self.panCompletionThreshold && self.direction == .Left {
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
            
            self.isInteractive = false
        }
    }
}
