//
//  ViewController.swift
//  MemeMe
//
//  Created by Li Yin on 10/29/15.
//  Copyright © 2015 Li Yin. All rights reserved.
//

import UIKit
import CoreData

class MemeEditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var NaviBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    //define a textField method for both top and bottom text field
    func prepareTextField(textField: UITextField, defaultText: String){
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName :UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.autocapitalizationType = .AllCharacters
        textField.textAlignment = .Center
        textField.layer.zPosition = 1
        
    }
    
    //hide status bar for bigger editing area
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //disable share button when no image selected
        if imagePickerView.image == nil  {
            
            shareButton.enabled = false
        }
        
        subscribeToKeyboarWillShowdNotifications()
        subscribeToKeyboarWillHidedNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        prepareTextField(topTextField, defaultText: "TOP")
        prepareTextField(bottomTextField, defaultText: "BOTTOM")
        
        //put navigation bar and toolbar on top of main editing view
        NaviBar.layer.zPosition = 2
        toolBar.layer.zPosition = 2
 
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //define all button action function below:
    
    @IBAction func pickImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func takePhoto(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
       
    }
    
    @IBAction func sharePhoto(sender: AnyObject) {
        
        let finishedImage = generateMemedImage()
        let shareViewController = UIActivityViewController(activityItems: [finishedImage], applicationActivities: nil)
        presentViewController(shareViewController, animated: true, completion: nil)
        
        shareViewController.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.saveMeme()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelMeme(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboarWillShowdNotifications()
        unsubscribeFromKeyboarWillHidedNotifications()
    }
    
    
    
    //define all custom function below:
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let tempImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imagePickerView.image = tempImage
            dismissViewControllerAnimated(true, completion: nil)
            
            //enable share button when finish picking image
            shareButton.enabled = true
        }
    }
    
    //func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //dismissViewControllerAnimated(true, completion: nil)
    //}
    
    
    //clear textfield if they contain default stings.
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        
    }
    
    //dismiss keyboard when user hit return while in textfield
    func textFieldShouldReturn(textField: UITextField) -> Bool {
         textField.resignFirstResponder()
         return true
    }
    
    
    
    
    //define view rise effect useing keyboard notification below:
    
    func keyboardWillShow(notification: NSNotification) {
        
        //make view rise or fall effect only valid for bottom textfield
        if bottomTextField.isFirstResponder(){
            self.view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notifiction: NSNotification) {
        
        //make view rise or fall effect only valid for bottom textfield
        if bottomTextField.isFirstResponder(){
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
    
    
    func subscribeToKeyboarWillShowdNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboarWillShowdNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboarWillHidedNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboarWillHidedNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    
    
    //generate final image and save object below:
    
    func generateMemedImage() -> UIImage {
        
        NaviBar.hidden = true
        toolBar.hidden = true
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0.0)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
        NaviBar.hidden = false
        toolBar.hidden = false
        
        return memedImage
    }
    
    func saveMeme() {

        let finishedMeme = Meme(topTextInput: topTextField.text!, bottomTextInput: bottomTextField.text!, pickedImageFile: imagePickerView.image!, memedImageFile: generateMemedImage(), context: sharedContext)
        sharedContext.insertObject(finishedMeme)
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
    lazy var sharedContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
}

