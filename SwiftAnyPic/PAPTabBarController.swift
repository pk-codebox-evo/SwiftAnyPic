import UIKit
import MobileCoreServices

class PAPTabBarController: UITabBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    var navController: UINavigationController?

    // MARK:- UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        //[[self tabBar] setBackgroundImage:[UIImage imageNamed:@"BackgroundTabBar.png"]];
    //    [[self tabBar] setSelectionIndicatorImage:[UIImage imageNamed:@"BackgroundTabBarItemSelected.png"]];
       // self.tabBar.tintColor = [UIColor colorWithRed:139.0f/255.0f green:111.0f/255.0f blue:95.0f/255.0f alpha:1.0f];
        
        
        // iOS 7 style
        self.tabBar.tintColor = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        self.tabBar.barTintColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
         
        self.navController = UINavigationController()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:- UITabBarController

    override func setViewControllers(viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
        let cameraButton = UIButton(type: UIButtonType.Custom)
        cameraButton.frame = CGRectMake(94.0, 0.0, 131.0, self.tabBar.bounds.size.height)
        cameraButton.setImage(UIImage(named: "ButtonCamera.png"), forState: UIControlState.Normal)
        cameraButton.setImage(UIImage(named: "ButtonCameraSelected.png"), forState: UIControlState.Highlighted)
        cameraButton.addTarget(self, action: Selector("photoCaptureButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.tabBar.addSubview(cameraButton)
        
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("handleGesture:"))
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        swipeUpGestureRecognizer.numberOfTouchesRequired = 1
        cameraButton.addGestureRecognizer(swipeUpGestureRecognizer)
    }

    // MARK:- UIImagePickerDelegate

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.dismissViewControllerAnimated(false, completion: nil)
        
        let image: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
         
        let viewController: PAPEditPhotoViewController = PAPEditPhotoViewController(image: image)
        viewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.navController!.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.navController!.pushViewController(viewController, animated: false)
        
        self.presentViewController(self.navController!, animated: true, completion: nil)
    }

    // MARK:- UIActionSheetDelegate
    // FIXME???

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.shouldStartCameraController()
        } else if buttonIndex == 1 {
            self.shouldStartPhotoLibraryPickerController()
        }
    }

    // MARK:- PAPTabBarController

    func shouldPresentPhotoCaptureController() -> Bool {
        var presentedPhotoCaptureController: Bool = self.shouldStartCameraController()
        
        if !presentedPhotoCaptureController {
            presentedPhotoCaptureController = self.shouldStartPhotoLibraryPickerController()
        }
        
        return presentedPhotoCaptureController
    }

    // MARK:- ()

    func photoCaptureButtonAction(sender: AnyObject) {
        let cameraDeviceAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        let photoLibraryAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        
        if cameraDeviceAvailable && photoLibraryAvailable {
            // TODO: Change to use UIActionController
            let actionSheet: UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo", "Choose Photo")
            actionSheet.showFromTabBar(self.tabBar)
        } else {
            // if we don't have at least two options, we automatically show whichever is available (camera or roll)
            self.shouldPresentPhotoCaptureController()
        }
    }

    func shouldStartCameraController() -> Bool {
    
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false {
            return false
        }
        
        let cameraUI = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
            && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)!.contains(kUTTypeImage as String) {
            
            cameraUI.mediaTypes = [kUTTypeImage as String]
            cameraUI.sourceType = UIImagePickerControllerSourceType.Camera
            
            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) {
                cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) {
                cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Front
            }
        } else {
            return false
        }
        
        cameraUI.allowsEditing = true
        cameraUI.showsCameraControls = true
        cameraUI.delegate = self

        self.presentViewController(cameraUI, animated: true, completion: nil)
        
        return true
    }


    func shouldStartPhotoLibraryPickerController() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) == false
             && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) == false {
            return false
        }
        
        let cameraUI = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
            && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.PhotoLibrary)!.contains(kUTTypeImage as String) {
            
            cameraUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            cameraUI.mediaTypes = [kUTTypeImage as String]
            
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum)
                   && UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.SavedPhotosAlbum)!.contains(kUTTypeImage as String) {
            cameraUI.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            cameraUI.mediaTypes = [kUTTypeImage as String]
            
        } else {
            return false
        }
        
        cameraUI.allowsEditing = true
        cameraUI.delegate = self
        
        self.presentViewController(cameraUI, animated: true, completion: nil)
        
        return true
    }

    func handleGesture(gestureRecognizer: UIGestureRecognizer) {
        self.shouldPresentPhotoCaptureController()
    }
}


@objc protocol PAPTabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, cameraButtonTouchUpInsideAction button: UIButton)
}