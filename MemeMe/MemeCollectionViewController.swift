//
//  SentMemesViewController.swift
//  MemeMe
//
//  Created by Li Yin on 11/18/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MemeCollectionViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    var memes = [Meme]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.toolbar.hidden = true
        memes = fetchAllMemes()
        collectionView?.reloadData()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({context in

            self.flowLayout?.invalidateLayout()

            }, completion: nil)
    }
    
    //reload collectionView when screen start to rotate
    /*override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        collectionView.performBatchUpdates(nil, completion: nil)
        collectionView.reloadData()
    
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func pressEdit(sender: AnyObject) {
        
        //prevent unwanted button title slow transition
        UIView.setAnimationsEnabled(false)
        
        collectionView.allowsMultipleSelection = !collectionView.allowsMultipleSelection
        
        navigationController?.toolbar.hidden = !navigationController!.toolbar.hidden
        tabBarController?.tabBar.hidden = !tabBarController!.tabBar.hidden
        
        if navigationController?.toolbar.hidden == false {
            editButton.title = "Cancel"
            navigationItem.rightBarButtonItem?.enabled = false
            navigationController?.toolbar.frame.origin.y += (tabBarController?.tabBar.frame.height)!
            
        } else {
            
            editButton.title = "Select"
            navigationItem.rightBarButtonItem?.enabled = true
            navigationController?.toolbar.frame.origin.y -= (tabBarController?.tabBar.frame.height)!
            
        }
        
        collectionView.reloadData()
        
        UIView.setAnimationsEnabled(true)
    }
    
    @IBAction func pressDelete(sender: AnyObject) {
        
        collectionView.performBatchUpdates(
            {
        
            let itemPaths = self.collectionView.indexPathsForSelectedItems()
            
            //set an array to store all selected Cell index
            var indexArray = [Int]()
                
            for index in itemPaths! {
                    
                indexArray.append(index.item)
                print(indexArray)
                    
            }
            
            //set an array to store sotrted cell index from largest to smallest
            let sortedArray = indexArray.sort({$0 > $1})
            
            //remove item from dataSource array backward
            for index in sortedArray
            {
                
                let memeToRemove = self.memes[index]
                self.memes.removeAtIndex(index)
                
                self.sharedContext.deleteObject(memeToRemove)
                CoreDataStackManager.sharedInstance().saveContext()
            }
                
            self.collectionView.deleteItemsAtIndexPaths(itemPaths!)
            
            }
            , completion: nil)
        
    }

    lazy var sharedContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    func fetchAllMemes() -> [Meme]{
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        
        do{
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Meme]
        } catch let error as NSError {
            print("there is a error: \(error.localizedDescription)")
            return [Meme]()
        }
    }
    
    //Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return memes.count
        
    }
    
    //update collectoinViewCell Size according to Screen orientation
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let space: CGFloat = 3.0
        var dimension: CGFloat
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        if isLandscapeOrientation(){
            dimension = (view.frame.size.width - (4 * space)) / 5.0
            flowLayout.itemSize = CGSizeMake(dimension, dimension)
            return flowLayout.itemSize
            
        } else {
            dimension = (view.frame.size.width - (2 * space)) / 3.0
            flowLayout.itemSize = CGSizeMake(dimension, dimension)
            return flowLayout.itemSize
            }
    }

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCustomCollectionViewCell
        
        let meme = memes[indexPath.item]
        
        collectionCell.collectionCellImage.image = meme.memedImage
        collectionCell.collectionCellImage.alpha = 1.0
        collectionCell.checkMarkImage.hidden = true
        
        return collectionCell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if self.collectionView.allowsMultipleSelection == false {
            
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
            detailVC.meme = self.memes[indexPath.item]
            self.navigationController?.pushViewController(detailVC, animated: true)
        } else {
            
            let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCustomCollectionViewCell
            selectedCell.collectionCellImage.alpha = 0.7
            selectedCell.checkMarkImage.hidden = false
            
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! MemeCustomCollectionViewCell
        selectedCell.collectionCellImage.alpha = 1.0
        selectedCell.checkMarkImage.hidden = true
        
    }

    
    //function to check screen's orientation status
    func isLandscapeOrientation() -> Bool {
        
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
}