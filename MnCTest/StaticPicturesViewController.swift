//
//  StaticPicturesViewController.swift
//  MnCTest
//
//  Created by Esteban Rivas on 2/27/20.
//  Copyright © 2020 Esteban Rivas. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class StaticPicturesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var mess: UILabel!
    var arrayImages : [UIImage] = NSMutableArray() as! [UIImage]
    var arrayImagesProfile : [UIImage] = NSMutableArray() as! [UIImage]
    var HUD : HUDAnimated = HUDAnimated()
    override func viewDidLoad() {
        super.viewDidLoad()
        if Singleton.instance.isSaved {
            titleLabel.text = "Saved"
        }else{
            profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
            profilePicture.image = Singleton.instance.arrayImagesProfile[Singleton.instance.globalIndex]
            titleLabel.text = (Singleton.instance.itemSelected.value(forKey: "user") as! NSDictionary).value(forKey: "username") as? String
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayImages.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 500;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Singleton.instance.itemSelectedS = Singleton.instance.imagesUS[indexPath.row];
        performSegue(withIdentifier: "SeguePicture", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.mess.isHidden = true
        Singleton.instance.imagesUS = NSMutableArray() as! [NSDictionary]
        if !Singleton.instance.isSaved {
            arrayImages = NSMutableArray() as! [UIImage]
            arrayImagesProfile = NSMutableArray() as! [UIImage]
            table.isUserInteractionEnabled = false
            let newString = ((Singleton.instance.itemSelected.value(forKey: "user") as! NSDictionary).value(forKey: "links") as! NSDictionary).value(forKey: "photos") as! String
            print(newString+"?client_id=jaux-5Do1Ko8bIHpT-5lqkJQV-f5bA8eiOCOl8AO7F0")
            HUD.showHUDFromView(view: self.view, animation: "loading")
            Alamofire.request(newString+"?client_id=jaux-5Do1Ko8bIHpT-5lqkJQV-f5bA8eiOCOl8AO7F0", encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                if response.result.value != nil {
                    let res = response.result.value as! [NSDictionary]
                    Singleton.instance.imagesUS = res
                    DispatchQueue.global(qos: .background).async {
                        for x in Singleton.instance.imagesUS{
                            let URL_IMAGE = URL(string: (x.value(forKey: "urls") as! NSDictionary).value(forKey: "small") as! String)
                            if let data = try? Data(contentsOf: URL_IMAGE!) {
                                if let image = UIImage(data: data) {
                                    self.arrayImages.append(image)
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.table.isUserInteractionEnabled = true
                            self.HUD.hideHUDFromView(view: self.view)
                            self.table.reloadData()
                        }
                    }
                }else{
                    self.HUD.hideHUDFromView(view: self.view)
                }
            }
        }else{
            HUD.showHUDFromView(view: self.view, animation: "loading")
            arrayImages = NSMutableArray() as! [UIImage]
            arrayImagesProfile = NSMutableArray() as! [UIImage]
            table.isUserInteractionEnabled = false
            retrieveData()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellPhoto", for: indexPath) as! CellPhoto
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.viewContent.layer.cornerRadius = 10
        cell.viewContent.layer.shadowColor = UIColor.black.cgColor
        cell.viewContent.layer.shadowOpacity = 0.3
        cell.viewContent.layer.shadowOffset = .zero
        cell.viewContent.layer.shadowRadius = 10
        cell.viewContent.layer.shadowPath = UIBezierPath(rect: cell.viewContent.bounds).cgPath
        cell.viewContent.layer.shouldRasterize = true
        cell.viewContent.layer.rasterizationScale = UIScreen.main.scale
        cell.imageFrom.image = arrayImages[indexPath.row]
        cell.imageUser.layer.cornerRadius = 17.5
        if Singleton.instance.isSaved {
            cell.imageUser.image = arrayImagesProfile[indexPath.row]
            cell.user.text = (Singleton.instance.imagesUS[indexPath.row].value(forKey: "user") as! NSDictionary).value(forKey: "username") as? String
        }else{
            cell.imageUser.image = Singleton.instance.arrayImagesProfile[Singleton.instance.globalIndex]
            cell.user.text = (Singleton.instance.itemSelected.value(forKey: "user") as! NSDictionary).value(forKey: "username") as? String
        }
        cell.likes.text = "\(Singleton.instance.imagesUS[indexPath.row].value(forKey: "likes") as! Int) Likes"
        cell.alt_description.text = Singleton.instance.imagesUS[indexPath.row].value(forKey: "alt_description") as? String
        return cell
    }
    func retrieveData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "imageSaved", ascending: false)]
        do {
            let result = try managedContext.fetch(fetchRequest)
            if (result as! [NSManagedObject]).count == 0 {
                self.HUD.hideHUDFromView(view: self.view)
                self.table.reloadData()
                self.mess.isHidden = false
            }
            for _ in result as! [NSManagedObject] {
                if Singleton.instance.imagesUS.count == 0 {
                    do {
                        let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
                        if items.count == 0 {
                        }else{
                            for item in items {
                                var dictonary : NSDictionary?
                                if let data = (item.value(forKey: "imageSaved") as! String).data(using: String.Encoding.utf8) {
                                    do {
                                        dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
                                    } catch let error as NSError {
                                        print(error)
                                    }
                                }
                                let dic : NSDictionary = dictonary!
                                Singleton.instance.imagesUS.append(dic)
                                print(Singleton.instance.imagesUS.count)
                            }
                            DispatchQueue.global(qos: .background).async {
                                for x in Singleton.instance.imagesUS{
                                    let URL_IMAGE = URL(string: (x.value(forKey: "urls") as! NSDictionary).value(forKey: "small") as! String)
                                    if let data = try? Data(contentsOf: URL_IMAGE!) {
                                        if let image = UIImage(data: data) {
                                            self.arrayImages.append(image)
                                        }
                                    }
                                }
                                for x in Singleton.instance.imagesUS{
                                    let URL_IMAGE = URL(string: ((x.value(forKey: "user") as! NSDictionary).value(forKey: "profile_image")as! NSDictionary).value(forKey: "small") as! String)
                                    if let data = try? Data(contentsOf: URL_IMAGE!) {
                                        if let image = UIImage(data: data) {
                                            self.arrayImagesProfile.append(image)
                                        }
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.table.isUserInteractionEnabled = true
                                    self.HUD.hideHUDFromView(view: self.view)
                                    self.table.reloadData()
                                }
                            }
                        }
                    } catch {
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        Singleton.instance.imagesUS = NSMutableArray() as! [NSDictionary]
    }
}
