//
//  Singleton.swift
//  MnCTest
//
//  Created by Esteban Rivas on 2/26/20.
//  Copyright © 2020 Esteban Rivas. All rights reserved.
//

import UIKit

class Singleton{
    private init() {}
    static let instance = Singleton()
    var imagesU : [NSDictionary] = NSMutableArray() as! [NSDictionary]
    var imagesUS : [NSDictionary] = NSMutableArray() as! [NSDictionary]
    var arrayImages : [UIImage] = NSMutableArray() as! [UIImage]
    var arrayImagesProfile : [UIImage] = NSMutableArray() as! [UIImage]
    var response : NSDictionary = NSDictionary()
    var itemSelected : NSDictionary = NSDictionary()
    var itemSelectedS : NSDictionary = NSDictionary()
    var globalIndex : NSInteger = NSInteger()
    var isSaved = Bool()
}
