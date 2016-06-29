//
//  ViewController.swift
//  ClipView
//
//  Created by skyline on 16/6/14.
//  Copyright © 2016年 skyline. All rights reserved.
//

import UIKit

class ClippingViewDemo: UIViewController {
    
    var img = UIImage(named: "IMG_2527")!
    var imgView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        view.addSubview(imgView)
        imgView.image = img
        imgView.contentMode = .ScaleAspectFill
        imgView.snp_makeConstraints { (make) in
            make.center.equalTo(0)
            make.width.equalTo(view.bounds.width)
            make.height.equalTo(view.bounds.width/img.size.width*img.size.height)
        }
        imgView.userInteractionEnabled = true
        
        let clipView = SKClipView()
        imgView.addSubview(clipView)
        clipView.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        let frameLabel = UILabel()
        view.addSubview(frameLabel)
        frameLabel.snp_makeConstraints { (make) in
            make.left.equalTo(30)
            make.bottom.equalTo(-60)
        }
        clipView.boxFrameDidChange = {
            boxFrame in
            frameLabel.text = "\(boxFrame)"
        }
        
    }
    
    
}

