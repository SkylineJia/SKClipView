//
//  ClipBox.swift
//  SkylineSwift
//
//  Created by skyline on 16/6/14.
//  Copyright © 2016年 skyline. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

// 裁剪框
class SKClipBox: UIView {
    
    enum DragPosition {
        case upperEdge
        case leftEdge
        case lowerEdge
        case rightEdge
        case upperLeftCorner
        case upperRightCorner
        case lowerLeftCorner
        case lowerRightCorner
        case inside
        case none
    }
    
    fileprivate var verticalLines = [UIView]()
    fileprivate var horizontalLines = [UIView]()
    
    // 网格线数
    var vertivalLineCount = 2
    var horizontalLineCount = 2
    
    var upperEdge: BoxEdgeView!
    var lowerEdge: BoxEdgeView!
    var leftEdge: BoxEdgeView!
    var rightEdge: BoxEdgeView!
    
    var upperLeftCorner: BoxCornerView!
    var upperRightCorner: BoxCornerView!
    var lowerLeftCorner: BoxCornerView!
    var lowerRightCorner: BoxCornerView!
    
    override init(frame: CGRect) {
        if frame == CGRect.zero {
            super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        } else {
            super.init(frame: frame)
        }
        self.backgroundColor = UIColor.clear
        // 竖线
        for _ in 0...vertivalLineCount+1 {
            let line = UIView()
            line.backgroundColor = UIColor.white
            self.addSubview(line)
            verticalLines.append(line)
        }
        // 横线
        for _ in 0...horizontalLineCount+1 {
            let line = UIView()
            line.backgroundColor = UIColor.white
            self.addSubview(line)
            horizontalLines.append(line)
        }
        
        upperEdge = BoxEdgeView()
        self.addSubview(upperEdge)
        upperEdge.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.top)
            make.centerX.equalToSuperview()
        }
        
        lowerEdge = BoxEdgeView()
        self.addSubview(lowerEdge)
        lowerEdge.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        leftEdge = BoxEdgeView()
        self.addSubview(leftEdge)
        leftEdge.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.left)
            make.centerY.equalToSuperview()
        }
        
        leftEdge.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        rightEdge = BoxEdgeView()
        self.addSubview(rightEdge)
        rightEdge.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.right)
            make.centerY.equalToSuperview()
        }
        rightEdge.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        
        upperLeftCorner = BoxCornerView()
        self.addSubview(upperLeftCorner)
        upperLeftCorner.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.left)
            make.centerY.equalTo(self.snp.top)
        }
        
        upperRightCorner = BoxCornerView()
        self.addSubview(upperRightCorner)
        upperRightCorner.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.right)
            make.centerY.equalTo(self.snp.top)
        }
        upperRightCorner.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        
        lowerLeftCorner = BoxCornerView()
        self.addSubview(lowerLeftCorner)
        lowerLeftCorner.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.left)
            make.centerY.equalTo(self.snp.bottom)
        }
        lowerLeftCorner.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/2))
        
        lowerRightCorner = BoxCornerView()
        self.addSubview(lowerRightCorner)
        lowerRightCorner.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.right)
            make.centerY.equalTo(self.snp.bottom)
        }
        lowerRightCorner.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = self.bounds
        // 竖线
        for i in 0...vertivalLineCount+1 {
            verticalLines[i].frame = CGRect(x: rect.width/3*CGFloat(i), y: 0, width: 1, height: rect.height)
        }
        // 横线
        for i in 0...horizontalLineCount+1 {
            horizontalLines[i].frame = CGRect(x: 0, y: rect.height/3*CGFloat(i), width: rect.width, height: 1)
        }
    }
    
    // 边
    class BoxEdgeView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor.clear
        
            let line = UIView()
            self.addSubview(line)
            line.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(3)
            }
            line.backgroundColor = UIColor.white
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // 固有大小
        override var intrinsicContentSize: CGSize {
            return CGSize(width: 30, height: 20)
        }
        
        
    }
    
    // 角
    class BoxCornerView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let length: CGFloat = 15
            let width: CGFloat = 3

            let vertical = UIView()
            vertical.backgroundColor = UIColor.white
            self.addSubview(vertical)
            vertical.snp.makeConstraints { (make) in
                make.height.equalTo(length)
                make.width.equalTo(width)
                make.centerY.equalToSuperview().offset((length-width+1)/2)
                make.centerX.equalToSuperview()
            }
            
            let horizontal = UIView()
            horizontal.backgroundColor = UIColor.white
            self.addSubview(horizontal)
            horizontal.snp.makeConstraints { (make) in
                make.width.equalTo(length)
                make.height.equalTo(width)
                make.centerY.equalToSuperview()
                make.centerX.equalToSuperview().offset((length-width+1)/2)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override var intrinsicContentSize: CGSize {
            return CGSize(width: 30, height: 30)
        }
        
    }
    
    
}
