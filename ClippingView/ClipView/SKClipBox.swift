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
        case UpperEdge
        case LeftEdge
        case LowerEdge
        case RightEdge
        case UpperLeftCorner
        case UpperRightCorner
        case LowerLeftCorner
        case LowerRightCorner
        case Inside
        case None
    }
    
    private var verticalLines = [UIView]()
    private var horizontalLines = [UIView]()
    
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
        if frame == CGRectZero {
            super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        } else {
            super.init(frame: frame)
        }
        self.backgroundColor = UIColor.clearColor()
        // 竖线
        for _ in 0...vertivalLineCount+1 {
            let line = UIView()
            line.backgroundColor = UIColor.whiteColor()
            self.addSubview(line)
            verticalLines.append(line)
        }
        // 横线
        for _ in 0...horizontalLineCount+1 {
            let line = UIView()
            line.backgroundColor = UIColor.whiteColor()
            self.addSubview(line)
            horizontalLines.append(line)
        }
        
        upperEdge = BoxEdgeView()
        self.addSubview(upperEdge)
        upperEdge.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.snp_top)
            make.centerX.equalTo(0)
        }
        
        lowerEdge = BoxEdgeView()
        self.addSubview(lowerEdge)
        lowerEdge.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.snp_bottom)
            make.centerX.equalTo(0)
        }
        
        leftEdge = BoxEdgeView()
        self.addSubview(leftEdge)
        leftEdge.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.snp_left)
            make.centerY.equalTo(0)
        }
        leftEdge.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        
        rightEdge = BoxEdgeView()
        self.addSubview(rightEdge)
        rightEdge.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.snp_right)
            make.centerY.equalTo(0)
        }
        rightEdge.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        
        
        upperLeftCorner = BoxCornerView()
        self.addSubview(upperLeftCorner)
        upperLeftCorner.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.snp_left)
            make.centerY.equalTo(self.snp_top)
        }
        
        upperRightCorner = BoxCornerView()
        self.addSubview(upperRightCorner)
        upperRightCorner.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.snp_right)
            make.centerY.equalTo(self.snp_top)
        }
        upperRightCorner.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        
        lowerLeftCorner = BoxCornerView()
        self.addSubview(lowerLeftCorner)
        lowerLeftCorner.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.snp_left)
            make.centerY.equalTo(self.snp_bottom)
        }
        lowerLeftCorner.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI_2))
        
        lowerRightCorner = BoxCornerView()
        self.addSubview(lowerRightCorner)
        lowerRightCorner.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.snp_right)
            make.centerY.equalTo(self.snp_bottom)
        }
        lowerRightCorner.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
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
            self.backgroundColor = UIColor.clearColor()
        
            let line = UIView()
            self.addSubview(line)
            line.snp_makeConstraints { (make) in
                make.center.equalTo(0)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.height.equalTo(3)
            }
            line.backgroundColor = UIColor.whiteColor()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // 固有大小
        override func intrinsicContentSize() -> CGSize {
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
            vertical.backgroundColor = UIColor.whiteColor()
            self.addSubview(vertical)
            vertical.snp_makeConstraints { (make) in
                make.height.equalTo(length)
                make.width.equalTo(width)
                make.centerY.equalTo((length-width+1)/2)
                make.centerX.equalTo(0)
            }
            
            let horizontal = UIView()
            horizontal.backgroundColor = UIColor.whiteColor()
            self.addSubview(horizontal)
            horizontal.snp_makeConstraints { (make) in
                make.width.equalTo(length)
                make.height.equalTo(width)
                make.centerY.equalTo(0)
                make.centerX.equalTo((length-width+1)/2)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func intrinsicContentSize() -> CGSize {
            return CGSize(width: 30, height: 30)
        }
        

    }
    
    
}