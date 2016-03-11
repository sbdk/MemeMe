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

class MemeCollectionViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    
    var selectedIndexes = [NSIndexPath]()
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.toolbar.hidden = true
        fetchedResultController.delegate = self
        
        do{
            try fetchedResultController.performFetch()
        } catch {print(error)}
        
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
        
        deleteSelectedCells()
        
        /*collectionView.performBatchUpdates({
            
            let seletedItemPaths = self.collectionView.indexPathsForSelectedItems()
            
            for itemPath in seletedItemPaths! where ((seletedItemPaths?.isEmpty) == false) {
                
                let memeToRemove = self.fetchedResultController.objectAtIndexPath(itemPath) as! Meme
                self.sharedContext.deleteObject(memeToRemove)
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
            }, completion: nil)
        */
    }

    lazy var sharedContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()

    
    //Collection View
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sessionInfo = fetchedResultController.sections![section]
        return sessionInfo.numberOfObjects
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
        let meme = fetchedResultController.objectAtIndexPath(indexPath) as! Meme
        configureCell(collectionCell, meme: meme)
        return collectionCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.collectionView.allowsMultipleSelection == false {
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
            detailVC.meme = fetchedResultController.objectAtIndexPath(indexPath) as! Meme
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
    
    //implemente FetchedResultController Delegate Method
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                insertedIndexPaths.append(newIndexPath!)
                break
                
            case .Delete:
                deletedIndexPaths.append(indexPath!)
                break
                
            case .Update:
                updatedIndexPaths.append(indexPath!)
                break
                
            case .Move:
                break
                
            default:
                break
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({
            
            for indexPath in self.insertedIndexPaths{
                 self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
        },completion: nil)
    }
    
    func configureCell(cell: MemeCustomCollectionViewCell, meme: Meme){
        cell.collectionCellImage.image = meme.memedImage
        cell.collectionCellImage.alpha = 1.0
        cell.checkMarkImage.hidden = true
    }
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "generateTime", ascending: true)]
        let fetchedRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedRequestController
    }()
    
    func deleteSelectedCells() {
        var memeToDelete = [Meme]()
        selectedIndexes = self.collectionView.indexPathsForSelectedItems()!
        
        for indexPath in selectedIndexes {
            memeToDelete.append(self.fetchedResultController.objectAtIndexPath(indexPath) as! Meme)
        }
        for meme in memeToDelete {
            sharedContext.deleteObject(meme)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        selectedIndexes = [NSIndexPath]()
    }
    
    //function to check screen's orientation status
    func isLandscapeOrientation() -> Bool {
        
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
}