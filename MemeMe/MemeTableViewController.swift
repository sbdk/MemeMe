//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Li Yin on 11/18/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MemeTableViewController: UITableViewController {

    //var memes = CoreDataMeme.sharedInstance().memes
    
    var memes = [Meme]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        memes = fetchAllMemes()
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    //Table View
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
    }
    
    //let row heigth auto adjust to screen orientation
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if isLandscapeOrientation(){
            return 50.0
        } else {
            return 80.0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCellWithIdentifier("MemeTableCell", forIndexPath: indexPath) as! MemeCustomTableViewCell
        
        let meme = self.memes[indexPath.row]
        
        
        tableCell.tableCellImage.backgroundColor = UIColor.blackColor()
        tableCell.tableCellImage.image = meme.memedImage
        tableCell.tableCellTopLabel.text = meme.topText
        tableCell.tableCellBottomLabel.text = meme.bottomText
        
        return tableCell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        detailVC.meme = self.memes[indexPath.row]
        self.navigationController!.pushViewController(detailVC, animated: true)
        
    }
    
    //add swipe-to-delete function to tableView
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            tableView.beginUpdates()
            
            let memeToRemove = memes[indexPath.row]
            print(indexPath.row)
            print(memes.count)
            memes.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
            
            sharedContext.deleteObject(memeToRemove)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
  

    //function to check screen's orientation status
    func isLandscapeOrientation() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    
}