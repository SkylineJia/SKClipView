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
        view.backgroundColor = UIColor.black
        
        view.addSubview(imgView)
        imgView.image = img
        imgView.contentMode = .scaleAspectFill
        imgView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(view.bounds.width)
            make.height.equalTo(view.bounds.width/img.size.width*img.size.height)
        }
        imgView.isUserInteractionEnabled = true
        
        let clipView = SKClipView()
        imgView.addSubview(clipView)
        clipView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        let frameLabel = UILabel()
        view.addSubview(frameLabel)
        frameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.bottom.equalTo(-60)
        }
        frameLabel.textColor = UIColor.white
        clipView.boxFrameDidChange = {
            boxFrame in
            frameLabel.text = "\(boxFrame)"
        }
    }
    
    
}

