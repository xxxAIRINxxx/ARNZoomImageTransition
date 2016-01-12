//
//  MainViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

class MainViewController: UIViewController, ARNImageTransitionZoomable {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var tableView : UITableView!
    
    weak var selectedImageView : UIImageView?
    
    var animator : ARNTransitionAnimator?
    
    var isModeModal : Bool = false
    var isModeInteractive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = false

        self.collectionView.registerNib(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: "CollectionCell")

        self.tableView.registerNib(UINib(nibName: "TableCell", bundle: nil), forCellReuseIdentifier: "TableCell")
        
        self.updateNavigationItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("MainViewController viewWillAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("MainViewController viewWillDisappear")
    }
    
    func updateNavigationItem() {
        if isModeModal {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Modal", style: .Done, target: self, action: "modePush")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Push", style: .Done, target: self, action: "modeModal")
        }
        
        if isModeInteractive {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Interactive", style: .Done, target: self, action: "modeNormal")
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Normal", style: .Done, target: self, action: "modeInteractive")
        }
    }
    
    func modePush() {
        self.isModeModal = false
        self.updateNavigationItem()
    }
    
    func modeModal() {
        self.isModeModal = true
        self.updateNavigationItem()
    }

    func modeInteractive() {
        self.isModeInteractive = true
        self.updateNavigationItem()
    }
    
    func modeNormal() {
        self.isModeInteractive = false
        self.updateNavigationItem()
    }
    
    func handleTransition() {
        if isModeInteractive {
            self.showInteractive()
        } else {
            if isModeModal {
                let storyboard = UIStoryboard(name: "ModalViewController", bundle: nil)
                let controller = storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
                controller.transitioningDelegate = controller
                self.presentViewController(controller, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil)
                let controller = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func showInteractive() {
        let storyboard = UIStoryboard(name: "ModalViewController", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        let operationType: ARNTransitionAnimatorOperation = isModeModal ? .Present : .Push
        let animator = ARNTransitionAnimator(operationType: operationType, fromVC: self, toVC: controller)
        
        animator.presentationBeforeHandler = { [weak self, weak controller] (containerView: UIView, transitionContext: UIViewControllerContextTransitioning) in
            containerView.addSubview(self!.view)
            containerView.addSubview(controller!.view)
            controller!.closeButton.hidden = true
            
            controller!.view.layoutIfNeeded()
            
            let sourceImageView = self!.createTransitionImageView()
            let destinationImageView = controller!.createTransitionImageView()
            
            containerView.addSubview(sourceImageView)
            
            controller!.presentationBeforeAction()
            
            controller!.view.alpha = 0.0
            
            animator.presentationAnimationHandler = { (containerView: UIView, percentComplete: CGFloat) in
                sourceImageView.frame = destinationImageView.frame
                
                controller!.view.alpha = 1.0
            }
            
            animator.presentationCompletionHandler = { (containerView: UIView, completeTransition: Bool) in
                sourceImageView.removeFromSuperview()
                self!.presentationCompletionAction(completeTransition)
                controller!.presentationCompletionAction(completeTransition)
            }
        }
        
        animator.dismissalBeforeHandler = { [weak self, weak controller] (containerView: UIView, transitionContext: UIViewControllerContextTransitioning) in
            containerView.addSubview(self!.view)
            containerView.bringSubviewToFront(controller!.view)
            
            let sourceImageView = controller!.createTransitionImageView()
            let destinationImageView = self!.createTransitionImageView()
            containerView.addSubview(sourceImageView)
            
            let sourceFrame = sourceImageView.frame;
            let destFrame = destinationImageView.frame;
            
            controller!.dismissalBeforeAction()
            
            animator.dismissalCancelAnimationHandler = { (containerView: UIView) in
                sourceImageView.frame = sourceFrame
                controller!.view.alpha = 1.0
            }
            
            animator.dismissalAnimationHandler = { (containerView: UIView, percentComplete: CGFloat) in
                if percentComplete < -0.05 { return }
                let frame = CGRectMake(
                    destFrame.origin.x - (destFrame.origin.x - sourceFrame.origin.x) * (1 - percentComplete),
                    destFrame.origin.y - (destFrame.origin.y - sourceFrame.origin.y) * (1 - percentComplete),
                    destFrame.size.width + (sourceFrame.size.width - destFrame.size.width) * (1 - percentComplete),
                    destFrame.size.height + (sourceFrame.size.height - destFrame.size.height) * (1 - percentComplete)
                )
                sourceImageView.frame = frame
                controller!.view.alpha = 1.0 - (1.0 * percentComplete)
            }
            
            animator.dismissalCompletionHandler = { (containerView: UIView, completeTransition: Bool) in
                self!.dismissalCompletionAction(completeTransition)
                controller!.dismissalCompletionAction(completeTransition)
                sourceImageView.removeFromSuperview()
            }
        }
        
        self.animator = animator
        
        if isModeModal {
            self.animator!.interactiveType = .Dismiss
            controller.transitioningDelegate = self.animator
            self.presentViewController(controller, animated: true, completion: nil)
        } else {
            self.animator!.interactiveType = .Pop
            if let _nav = self.navigationController as? ARNImageTransitionNavigationController {
                _nav.interactiveAnimator = self.animator!
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    // MARK: - ARNImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: self.selectedImageView!.image)
        imageView.contentMode = self.selectedImageView!.contentMode
        imageView.clipsToBounds = true
        imageView.userInteractionEnabled = false
        imageView.frame = self.selectedImageView!.convertRect(self.selectedImageView!.frame, toView: self.view)
        
        return imageView
    }
    
    func presentationCompletionAction(completeTransition: Bool) {
        self.selectedImageView?.hidden = true
    }
    
    func dismissalCompletionAction(completeTransition: Bool) {
        self.selectedImageView?.hidden = false
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as! CollectionCell
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionCell
        self.selectedImageView = cell.cellImageView
        
        self.handleTransition()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell", forIndexPath: indexPath) as! TableCell
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableCell
        self.selectedImageView = cell.cellImageView
        
        self.handleTransition()
    }
}
