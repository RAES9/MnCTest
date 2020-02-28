//
//  PictureProfileViewController.swift
//  MnCTest
//
//  Created by Esteban Rivas on 2/27/20.
//  Copyright © 2020 Esteban Rivas. All rights reserved.
//

import UIKit
import Lottie
import CoreData

class PictureProfileViewController: UIViewController {
    @IBOutlet weak var picture_profile: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var view_save: UIView!
    @IBOutlet weak var saveButton: UIButton!
    var saved = false
    var animatioSave = AnimationView()
    var currentImage : UIImage = UIImage()
    var HUD : HUDAnimated = HUDAnimated()
    override func viewDidLoad() {
        super.viewDidLoad()
        view_save.layer.cornerRadius = 25
        picture.layer.cornerRadius = 10
        HUD.showHUDFromView(view: self.view, animation: "loading")
        if Singleton.instance.isSaved {
            username.text = "Saved"
        }else{
            picture_profile.layer.cornerRadius = picture_profile.frame.width / 2
            picture_profile.image = Singleton.instance.arrayImagesProfile[Singleton.instance.globalIndex]
            username.text = (Singleton.instance.itemSelected.value(forKey: "user") as! NSDictionary).value(forKey: "username") as? String
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            let URL_IMAGE = URL(string: (Singleton.instance.itemSelectedS.value(forKey: "urls") as! NSDictionary).value(forKey: "full") as! String)
            if let data = try? Data(contentsOf: URL_IMAGE!) {
                if let image = UIImage(data: data) {
                    self.currentImage = image
                }
            }
            DispatchQueue.main.async {
                self.retrieveData()
                self.textView.text = Singleton.instance.itemSelectedS.value(forKey: "alt_description") as? String
                self.picture.image = self.currentImage
                self.animatioSave = AnimationView(name: "save")
                self.animatioSave.tag = 100
                self.animatioSave.frame = self.view_save.bounds
                self.view_save.addSubview(self.animatioSave)
                self.view_save.bringSubviewToFront(self.saveButton)
                self.HUD.hideHUDFromView(view: self.view)
                if self.saved {
                    self.animatioSave.play()
                }
            }
            
        }
    }
    
    @IBAction func savePicture(_ sender: Any) {
        if !saved {
            animatioSave.play()
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let userEntity = NSEntityDescription.entity(forEntityName: "Image", in: managedContext)!
            let image = NSManagedObject(entity: userEntity, insertInto: managedContext)
            do {
                let jsonData : NSData = try JSONSerialization.data(withJSONObject: Singleton.instance.itemSelectedS, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
                let jsonString : String = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
                print(jsonString)
                image.setValue(jsonString, forKey: "imageSaved")
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            saved = true
        }else{
            for content in view_save.subviews{
                if content.tag == 100 {
                    content.removeFromSuperview()
                }
            }
            animatioSave = AnimationView(name: "save")
            animatioSave.tag = 100
            animatioSave.frame = view_save.bounds
            view_save.addSubview(animatioSave)
            view_save.bringSubviewToFront(saveButton)
            retrieveData()
            saved = false
        }
    }
    
    func retrieveData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "imageSaved", ascending: false)]
        do {
            let result = try managedContext.fetch(fetchRequest)
            print(result)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "imageSaved") as! String)
                if saved {
                            var dictonary : NSDictionary?
                            if let data = (data.value(forKey: "imageSaved") as! String).data(using: String.Encoding.utf8) {
                                do {
                                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
                                } catch let error as NSError {
                                    print(error)
                                }
                            }
                            let dic : NSDictionary = dictonary!
                            if (dic.value(forKey: "id") as! String) == (Singleton.instance.itemSelectedS.value(forKey: "id") as! String) {
                                managedContext.delete(data)
                            }
                        try managedContext.save()
                }else{
                    var dictonary : NSDictionary?
                    if let data = (data.value(forKey: "imageSaved") as! String).data(using: String.Encoding.utf8) {
                        do {
                            dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                    let dic : NSDictionary = dictonary!
                    if dic.value(forKey: "id") as! String == Singleton.instance.itemSelectedS.value(forKey: "id") as! String {
                        saved = true
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
