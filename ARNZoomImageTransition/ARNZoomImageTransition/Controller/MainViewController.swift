//
//  MainViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

class MainViewController: ImageZoomAnimationVC, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var tableView : UITableView!
    
    weak var selectedImageView : UIImageView?
    
    var animator : ARNTransitionAnimator?
    
    var isModeModal : Bool = false
    var isModeInteractive : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = false

        self.collectionView.register(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: "CollectionCell")

        self.tableView.register(UINib(nibName: "TableCell", bundle: nil), forCellReuseIdentifier: "TableCell")
        
        self.updateNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MainViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("MainViewController viewWillDisappear")
    }
    
    func updateNavigationItem() {
        if isModeModal {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Modal", style: .done, target: self, action: #selector(self.modePush))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Push", style: .done, target: self, action: #selector(self.modeModal))
        }
        
        if isModeInteractive {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Interactive", style: .done, target: self, action: #selector(self.modeNormal))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Normal", style: .done, target: self, action: #selector(self.modeInteractive))
        }
    }
    
    @objc func modePush() {
        self.isModeModal = false
        self.updateNavigationItem()
    }
    
    @objc func modeModal() {
        self.isModeModal = true
        self.updateNavigationItem()
    }

    @objc func modeInteractive() {
        self.isModeInteractive = true
        self.updateNavigationItem()
    }
    
    @objc func modeNormal() {
        self.isModeInteractive = false
        self.updateNavigationItem()
    }
    
    func handleTransition() {
        if isModeInteractive {
            self.showInteractive()
        } else {
            if isModeModal {
                let storyboard = UIStoryboard(name: "ModalViewController", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
                
                let animation = ImageZoomAnimation<ImageZoomAnimationVC>(rootVC: self, modalVC: controller, rootNavigation: self.navigationController)
                let animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
                controller.transitioningDelegate = animator
                self.animator = animator
                
                self.present(controller, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                let animation = ImageZoomAnimation<ImageZoomAnimationVC>(rootVC: self, modalVC: controller)
                let animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
                self.navigationController?.delegate = animator
                self.animator = animator
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func showInteractive() {
        if isModeModal {
            let storyboard = UIStoryboard(name: "ModalViewController", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
            
            let animation = ImageZoomAnimation<ImageZoomAnimationVC>(rootVC: self, modalVC: controller, rootNavigation: self.navigationController)
            let animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
            
            let gestureHandler = TransitionGestureHandler(targetView: controller.view, direction: .bottom)
            animator.registerInteractiveTransitioning(.dismiss, gestureHandler: gestureHandler)
            
            controller.transitioningDelegate = animator
            self.animator = animator
            
            self.present(controller, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            let animation = ImageZoomAnimation<ImageZoomAnimationVC>(rootVC: self, modalVC: controller)
            let animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
            
            let gestureHandler = TransitionGestureHandler(targetView: controller.view, direction: .bottom)
            animator.registerInteractiveTransitioning(.pop, gestureHandler: gestureHandler)
            
            self.navigationController?.delegate = animator
            self.animator = animator
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    // MARK: - ImageTransitionZoomable
    
    override func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: self.selectedImageView!.image)
        imageView.contentMode = self.selectedImageView!.contentMode
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = self.selectedImageView!.convert(self.selectedImageView!.frame, to: self.view)
        
        return imageView
    }
    
    @objc override func presentationBeforeAction() {
        self.selectedImageView?.isHidden = true
    }
    
    override func presentationCompletionAction(didComplete: Bool) {
        self.selectedImageView?.isHidden = true
    }
    
    @objc override func dismissalBeforeAction() {
        self.selectedImageView?.isHidden = true
    }
    
    override func dismissalCompletionAction(didComplete: Bool) {
        self.selectedImageView?.isHidden = false
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionCell
        self.selectedImageView = cell.cellImageView
        
        self.handleTransition()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! TableCell
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! TableCell
        self.selectedImageView = cell.cellImageView
        
        self.handleTransition()
    }
}
