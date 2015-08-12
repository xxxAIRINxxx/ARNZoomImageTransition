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

public enum ARNTransitionAnimatorOperation: Int {
    case Push
    case Pop
    case Present
    case Dismiss
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
    
    private var fromVC : UIViewController
    private var toVC : UIViewController
    private var operationType : ARNTransitionAnimatorOperation
    
    private var gesture :UIPanGestureRecognizer?
    private var transitionContext : UIViewControllerContextTransitioning?
    private var isInteractive : Bool = false
    private var panLocationStart : CGFloat = 0.0
    
    deinit {
        self.unregisterPanGesture()
    }
    
    // MARK: Constructor
    
    public init(operationType: ARNTransitionAnimatorOperation, fromVC: UIViewController, toVC: UIViewController) {
        self.operationType = operationType
        self.fromVC = fromVC
        self.toVC = toVC
        self.toVC.modalPresentationStyle = .Custom
    }
    
    // MARK: Public Methods
    
    public func registerPanGesture() {
        if self.gesture == nil {
            self.gesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
            self.gesture!.delegate = self
            if self.needPresentationInteractive == true {
                self.fromVC.view.addGestureRecognizer(self.gesture!)
            } else if self.needDismissalInteractive == true {
                self.fromVC.view.addGestureRecognizer(self.gesture!)
            }
        }
    }
    
    public func unregisterPanGesture() {
        if let _gesture = self.gesture {
            if let _view = _gesture.view {
                _view.removeGestureRecognizer(_gesture)
            }
            _gesture.delegate = nil
        }
        self.gesture = nil
    }
    
    // MARK: Private Methods
    
    private func fireBeforeHandler(containerView: UIView) {
        switch (self.operationType) {
        case .Push, .Present:
            self.presentationBeforeHandler?(containerView: containerView)
        case .Pop, .Dismiss:
            self.dismissalBeforeAnimationHandler?(containerView: containerView)
        }
    }
    
    private func fireAnimationHandler(containerView: UIView, percentComplete: CGFloat) {
        switch (self.operationType) {
        case .Push, .Present:
            self.presentationAnimationHandler?(containerView: containerView, percentComplete: percentComplete)
        case .Pop, .Dismiss:
            self.dismissalAnimationHandler?(containerView: containerView, percentComplete: percentComplete)
        }
    }
    
    private func fireCompletionHandler(containerView: UIView, didComplete: Bool) {
        switch (self.operationType) {
        case .Push, .Present:
            self.presentationCompletionHandler?(containerView: containerView, didComplete: didComplete)
        case .Pop, .Dismiss:
            self.dismissalCompletionHandler?(containerView: containerView, didComplete: didComplete)
        }
    }
    
    private func animateWithDuration(duration: NSTimeInterval, containerView: UIView, didComplete: Bool, completion: (() -> Void)?) {
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
                self.fireCompletionHandler(containerView, didComplete: didComplete)
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
        
        switch (self.operationType) {
        case .Push, .Present:
            toVC.view.hidden = true
            containerView.addSubview(toVC.view)
        case .Pop, .Dismiss:
            fromVC.view.hidden = true
            containerView.bringSubviewToFront(fromVC.view)
        }
    }
    
    public override func updateInteractiveTransition(percentComplete: CGFloat) {
        if let transitionContext = self.transitionContext {
            
            // FIXME! : deal for view is displayed only for a moment
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            
            switch (self.operationType) {
            case .Push, .Present:
                toVC.view.hidden = false
            case .Pop, .Dismiss:
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
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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
    
    private func handlePan(recognizer: UIPanGestureRecognizer) {
        var window : UIWindow? = nil
        
        switch (self.operationType) {
        case .Push, .Present:
            window = self.fromVC.view.window
        case .Pop, .Dismiss:
            window = self.toVC.view.window
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
            
            switch (self.operationType) {
            case .Push:
                self.fromVC.navigationController?.pushViewController(self.toVC, animated: true)
            case .Present:
                self.fromVC.presentViewController(self.toVC, animated: true, completion: nil)
            case .Pop:
                self.toVC.navigationController?.popViewControllerAnimated(true)
            case .Dismiss:
                self.toVC.dismissViewControllerAnimated(true, completion: nil)
            }
        } else if recognizer.state == .Changed {
            var animationRatio: CGFloat = 0.0
            
            var bounds = CGRectZero
            switch (self.operationType) {
            case .Push, .Present:
                bounds = self.fromVC.view.bounds
            case .Pop, .Dismiss:
                bounds = self.toVC.view.bounds
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
