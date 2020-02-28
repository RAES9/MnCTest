//
//  ViewController.swift
//  MnCTest
//
//  Created by Esteban Rivas on 2/26/20.
//  Copyright © 2020 Esteban Rivas. All rights reserved.
//

import UIKit
import Alamofire
import Lottie

class CellPhoto: UITableViewCell {
    @IBOutlet weak var imageFrom: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var alt_description: UILabel!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var HUD : HUDAnimated = HUDAnimated()
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var textSearch: UITextField!
    @IBOutlet weak var table: UITableView!
    var arrayImages : [UIImage] = NSMutableArray() as! [UIImage]
    var arrayImagesProfile : [UIImage] = NSMutableArray() as! [UIImage]
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var savedButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        savedButton.layer.cornerRadius = 10
        savedButton.layer.shadowColor = UIColor.black.cgColor
        savedButton.layer.shadowOpacity = 0.3
        savedButton.layer.shadowOffset = .zero
        savedButton.layer.shadowRadius = 10
        savedButton.layer.shadowPath = UIBezierPath(rect: savedButton.bounds).cgPath
        savedButton.layer.shouldRasterize = true
        savedButton.layer.rasterizationScale = UIScreen.main.scale
        searchView.layer.cornerRadius = searchView.frame.height / 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.instance.imagesU.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 500;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Singleton.instance.itemSelected = Singleton.instance.imagesU[indexPath.row];
        Singleton.instance.globalIndex = indexPath.row
        performSegue(withIdentifier: "SeguePicture", sender: nil)
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
        cell.imageUser.image = arrayImagesProfile[indexPath.row]
        cell.user.text = (Singleton.instance.imagesU[indexPath.row].value(forKey: "user") as! NSDictionary).value(forKey: "username") as? String
        cell.likes.text = "\(Singleton.instance.imagesU[indexPath.row].value(forKey: "likes") as! Int) Likes"
        cell.alt_description.text = Singleton.instance.imagesU[indexPath.row].value(forKey: "alt_description") as? String
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        Singleton.instance.isSaved = true
        Singleton.instance.imagesUS = NSMutableArray() as! [NSDictionary]
    }
    @IBAction func searchAction(_ sender: Any) {
        resultLabel.isHidden = true
        self.view.endEditing(true)
        arrayImages = NSMutableArray() as! [UIImage]
        arrayImagesProfile = NSMutableArray() as! [UIImage]
        table.isUserInteractionEnabled = false
        let newString = self.textSearch.text!.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        HUD.showHUDFromView(view: self.view, animation: "searching")
        Alamofire.request("https://api.unsplash.com/search/photos?query="+newString+"&client_id=jaux-5Do1Ko8bIHpT-5lqkJQV-f5bA8eiOCOl8AO7F0", encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            if response.result.value != nil {
                let res = response.result.value as! NSDictionary
                Singleton.instance.imagesU = res.value(forKey: "results") as! [NSDictionary]
                Singleton.instance.response = res
                DispatchQueue.global(qos: .background).async {
                    for x in Singleton.instance.imagesU{
                        let URL_IMAGE = URL(string: (x.value(forKey: "urls") as! NSDictionary).value(forKey: "small") as! String)
                        if let data = try? Data(contentsOf: URL_IMAGE!) {
                            if let image = UIImage(data: data) {
                                self.arrayImages.append(image)
                            }
                        }
                    }
                    for x in Singleton.instance.imagesU{
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
                        Singleton.instance.arrayImages = self.arrayImages
                        Singleton.instance.arrayImagesProfile = self.arrayImagesProfile
                        if self.arrayImages.count == 0{
                            self.resultLabel.isHidden = false
                        }
                    }
                }
            }else{
                self.HUD.hideHUDFromView(view: self.view)
            }
        }
    }
}

