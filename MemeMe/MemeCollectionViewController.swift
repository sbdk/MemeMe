//
//  SentMemesViewController.swift
//  MemeMe
//
//  Created by Li Yin on 11/18/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import Foundation
import UIKit

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView!.reloadData()
        
    }
    
    //reload collectionView when screen start to rotate
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        collectionView?.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
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

    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath)
        
        let meme = memes[indexPath.item]
        collectionCell.backgroundView = UIImageView(image: meme.memedImage)
        
        return collectionCell
        
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailVC.meme = self.memes[indexPath.item]
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    //function to check screen's orientation status
    func isLandscapeOrientation() -> Bool {
        
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
}