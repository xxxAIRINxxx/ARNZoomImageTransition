//
//  MainViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, ARNImageTransitionZoomable {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var tableView : UITableView!
    
    weak var selectedImageView : UIImageView?
    
    var isModeModal : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extendedLayoutIncludesOpaqueBars = false

        self.collectionView.registerNib(UINib(nibName: "CollectionCell", bundle: nil), forCellWithReuseIdentifier: "CollectionCell")

        self.tableView.registerNib(UINib(nibName: "TableCell", bundle: nil), forCellReuseIdentifier: "TableCell")
        
        self.updateNavigationItem()
    }
    
    func updateNavigationItem() {
        if isModeModal {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Push", style: .Done, target: self, action: "modePush")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Modal", style: .Done, target: self, action: "modeModal")
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
    
    // MARK: - ARNImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        var imageView = UIImageView(image: self.selectedImageView!.image)
        imageView.contentMode = self.selectedImageView!.contentMode
        imageView.clipsToBounds = true
        imageView.userInteractionEnabled = false
        imageView.frame = self.selectedImageView!.convertRect(self.selectedImageView!.frame, toView: self.view)
        
        return imageView
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
