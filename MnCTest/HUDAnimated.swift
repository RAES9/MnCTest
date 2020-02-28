//
//  HUDAnimated.swift
//  MnCTest
//
//  Created by Esteban Rivas on 2/26/20.
//  Copyright © 2020 Esteban Rivas. All rights reserved.
//

import UIKit
import Lottie

class HUDAnimated{
    func showHUDFromView(view : UIView, animation : String){
        let checkMarkAnimation =  AnimationView(name: animation)
        let viewContent = UIView()
        viewContent.center = view.center
        viewContent.layer.cornerRadius = 10
        viewContent.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - ((view.frame.width / 3) / 2), y: (UIScreen.main.bounds.height / 2) - ((view.frame.width / 3) / 2), width: view.frame.width / 3, height: view.frame.width / 3)
        viewContent.backgroundColor = UIColor.white
        viewContent.contentMode = .scaleAspectFit
        viewContent.addSubview(checkMarkAnimation)
        viewContent.layer.shadowColor = UIColor.black.cgColor
        viewContent.layer.shadowOpacity = 0.3
        viewContent.layer.shadowOffset = .zero
        viewContent.layer.shadowRadius = 10
        viewContent.layer.shadowPath = UIBezierPath(rect: viewContent.bounds).cgPath
        viewContent.layer.shouldRasterize = true
        viewContent.layer.rasterizationScale = UIScreen.main.scale
        viewContent.tag = 100
        checkMarkAnimation.frame = viewContent.bounds
        checkMarkAnimation.loopMode = .loop
        checkMarkAnimation.play()
        view.addSubview(viewContent)
    }
    
    func hideHUDFromView(view : UIView){
        for content in view.subviews{
            if content.tag == 100 {
                content.removeFromSuperview()
            }
        }
    }
}
