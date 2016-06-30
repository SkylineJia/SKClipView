//
//  ClipView.swift
//  ClipView
//
//  Created by skyline on 16/6/15.
//  Copyright © 2016年 skyline. All rights reserved.
//

import Foundation
import UIKit


// 裁剪框＋半透明背景＋手势
class SKClipView: UIView {
    
    /// 裁剪框
    let clipBox = SKClipBox()
    /// 裁剪框frame
    var boxFrame = CGRectZero {
        didSet {
            // 保留小数点一位
            let x = CGFloat(Int(boxFrame.origin.x*10))/10
            let y = CGFloat(Int(boxFrame.origin.y*10))/10
            let w = CGFloat(Int(boxFrame.size.width*10))/10
            let h = CGFloat(Int(boxFrame.size.height*10))/10
            boxFrame = CGRect(x: x, y: y, width: w, height: h)
            
            clipBox.frame = boxFrame
            // 调用drawRect
            self.setNeedsDisplay()
            boxFrameDidChange?(boxFrame)
        }
    }
    /// 背景颜色
    var screenColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// 背景透明度
    var screenAlpha: CGFloat = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// 裁剪框最小高度
    let clipMinimizeHeight: CGFloat = 60
    /// 裁剪框最小宽度
    let clipMinimizeWidth: CGFloat = 60
    
    var boxFrameDidChange: ((CGRect)->())?
    
    private var dragPosition: SKClipBox.DragPosition = .None
    private var startingPoint = CGPointZero
    private var startingFrame = CGRectZero
    private var isDraging = false
    private var firstTouch: UITouch!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(clipBox)
        clipBox.frame = boxFrame
        self.backgroundColor = UIColor.clearColor()
        // 缩放
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let ctx = UIGraphicsGetCurrentContext()!
        fillInTheRect(ctx, rect: self.bounds)
        clearRect(ctx, rect: boxFrame)
    }
    
    private func fillInTheRect(ctx: CGContextRef, rect: CGRect) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        if screenColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) == true {
            CGContextSetRGBFillColor(ctx, red, green, blue, alpha*screenAlpha)
        } else {
            CGContextSetRGBFillColor(ctx, 0.2, 0.2, 0.2, 0.7)
        }
        CGContextFillRect(ctx, rect)
    }
    
    private func clearRect(ctx: CGContextRef, rect: CGRect) {
        CGContextClearRect(ctx, rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if clipBox.frame == CGRectZero {
            let rect = CGRect(x: self.frame.width/2-50, y: self.frame.height/2-50, width: 100, height: 100)
            boxFrame = rect
        }
    }
   
    
}

// 手势
extension SKClipView: UIGestureRecognizerDelegate{
    // 缩放
    func handlePinch(pinch: UIPinchGestureRecognizer) {
        let scale = sqrt(pinch.scale)
        
        switch pinch.state {
        case .Began:
            startingFrame = boxFrame
            
        case .Changed:
            let size = CGSize(width: max(startingFrame.width*scale, clipMinimizeWidth), height: max(startingFrame.height*scale, clipMinimizeHeight ))
            var rect = CGRect(origin: CGPointZero, size: size)
            let centerPoint = CGPoint(x: CGRectGetMidX(startingFrame), y: CGRectGetMidY(startingFrame))
            rect.origin.x = centerPoint.x - rect.size.width/2
            rect.origin.y = centerPoint.y - rect.size.height/2
            
            if rect.width>bounds.width {
                rect.size.width = clipBox.frame.width
            }
            if rect.height>bounds.height {
                rect.size.height = clipBox.frame.height
            }
            if rect.minX<0 {
                rect.origin.x = 0
            }
            if rect.minY<0 {
                rect.origin.y = 0
            }
            if rect.maxX>bounds.width {
                rect.origin.x = bounds.width-rect.width
            }
            if rect.maxY>bounds.height {
                rect.origin.y = bounds.height-rect.height
            }
            boxFrame = rect
            
        case .Ended:
            startingFrame = boxFrame
            
        default:
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 防止一只手指拖动时，另一只手指触发缩放手势
        if isDraging {
            return false
        } else {
            return true
        }
    }
    
    // touch点击
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let allTouches = event!.allTouches()!
        
        switch allTouches.count {
        case 1:
            startingFrame = boxFrame
            firstTouch = allTouches.first!
            startingPoint = firstTouch.locationInView(self)
            
            if CGRectContainsPoint(clipBox.upperEdge.bounds, firstTouch.locationInView(clipBox.upperEdge)) {
                dragPosition = .UpperEdge
            }
            else if CGRectContainsPoint(clipBox.rightEdge.bounds, firstTouch.locationInView(clipBox.rightEdge)) {
                dragPosition = .RightEdge
            }
            else if CGRectContainsPoint(clipBox.lowerEdge.bounds, firstTouch.locationInView(clipBox.lowerEdge)) {
                dragPosition = .LowerEdge
            }
            else if CGRectContainsPoint(clipBox.leftEdge.bounds, firstTouch.locationInView(clipBox.leftEdge)) {
                dragPosition = .LeftEdge
            }
            else if CGRectContainsPoint(clipBox.upperLeftCorner.bounds, firstTouch.locationInView(clipBox.upperLeftCorner)) {
                dragPosition = .UpperLeftCorner
            }
            else if CGRectContainsPoint(clipBox.upperRightCorner.bounds, firstTouch.locationInView(clipBox.upperRightCorner)) {
                dragPosition = .UpperRightCorner
            }
            else if CGRectContainsPoint(clipBox.lowerLeftCorner.bounds, firstTouch.locationInView(clipBox.lowerLeftCorner)) {
                dragPosition = .LowerLeftCorner
            }
            else if CGRectContainsPoint(clipBox.lowerRightCorner.bounds, firstTouch.locationInView(clipBox.lowerRightCorner)) {
                dragPosition = .LowerRightCorner
            } else if CGRectContainsPoint(clipBox.bounds, firstTouch.locationInView(clipBox)) {
                dragPosition = .Inside
            }
            else {
                dragPosition = .None
            }
        default:
            break
        }
    }
    
    // touch移动
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard firstTouch != nil else {
            return
        }
        let allTouches = event!.allTouches()!
        switch allTouches.count {
        case 1:
            isDraging = true
            firstTouch = allTouches.first
            fallthrough
        default:
            let touch = firstTouch
            let touchPoint = touch.locationInView(self)
            let dx = touchPoint.x - startingPoint.x
            let dy = touchPoint.y - startingPoint.y
            
            var originX: CGFloat = 0
            var originY: CGFloat = 0
            var width: CGFloat = 0
            var height: CGFloat = 0
            
            switch dragPosition {
            case .UpperEdge:
                originX = startingFrame.origin.x
                originY = startingFrame.origin.y + dy
                width = startingFrame.width
                height = startingFrame.height - dy
                
                if originY < bounds.minY {
                    originY = bounds.minY
                    height = startingFrame.maxY - originY
                }
                if originY > startingFrame.maxY - clipMinimizeHeight {
                    originY = startingFrame.maxY - clipMinimizeHeight
                    height = clipMinimizeHeight
                }
                
            case .RightEdge:
                originX = startingFrame.origin.x
                originY = startingFrame.origin.y
                width = startingFrame.width + dx
                height = startingFrame.height
                
                if originX + width > bounds.maxX {
                    width = bounds.maxX - originX
                }
                width = max(width, clipMinimizeWidth)
                
            case .LowerEdge:
                originX = startingFrame.origin.x
                originY = startingFrame.origin.y
                width = startingFrame.width
                height = startingFrame.height + dy
                
                if height > bounds.maxY - startingFrame.minY {
                    height = bounds.maxY - startingFrame.minY
                }
                height = max(height, clipMinimizeHeight)
                
            case .LeftEdge:
                originX = startingFrame.origin.x + dx
                originY = startingFrame.origin.y
                width = startingFrame.width - dx
                height = startingFrame.height
                
                if originX < bounds.minX {
                    originX = bounds.minX
                    width = startingFrame.maxX - originX
                }
                if originX > startingFrame.maxX - clipMinimizeWidth {
                    originX = startingFrame.maxX - clipMinimizeWidth
                    width = clipMinimizeWidth
                }
                
            case .UpperLeftCorner:
                originX = startingFrame.origin.x + dx
                originY = startingFrame.origin.y + dy
                width = startingFrame.width - dx
                height = startingFrame.height - dy
                
                if originX < bounds.minX {
                    originX = bounds.minX
                    width = startingFrame.maxX - originX
                }
                if originX > startingFrame.maxX - clipMinimizeWidth {
                    originX = startingFrame.maxX - clipMinimizeWidth
                    width = clipMinimizeWidth
                }
                if originY < bounds.minY {
                    originY = bounds.minY
                    height = startingFrame.maxY - originY
                }
                if originY > startingFrame.maxY - clipMinimizeHeight {
                    originY = startingFrame.maxY - clipMinimizeHeight
                    height = clipMinimizeHeight
                }
                
            case .UpperRightCorner:
                originX = startingFrame.origin.x
                originY = startingFrame.origin.y + dy
                width = startingFrame.width + dx
                height = startingFrame.height - dy
                
                if originY < bounds.minY {
                    originY = bounds.minY
                    height = startingFrame.maxY - originY
                }
                if originY > startingFrame.maxY - clipMinimizeHeight {
                    originY = startingFrame.maxY - clipMinimizeHeight
                    height = clipMinimizeHeight
                }
                if originX + width > bounds.maxX {
                    width = bounds.maxX - originX
                }
                width = max(width, clipMinimizeWidth)
                
            case .LowerLeftCorner:
                originX = startingFrame.origin.x + dx
                originY = startingFrame.origin.y
                width = startingFrame.width - dx
                height = startingFrame.height + dy
                
                if height > bounds.maxY - startingFrame.minY {
                    height = bounds.maxY - startingFrame.minY
                }
                if originX < bounds.minX {
                    originX = bounds.minX
                    width = startingFrame.maxX - originX
                }
                if originX > startingFrame.maxX - clipMinimizeWidth {
                    originX = startingFrame.maxX - clipMinimizeWidth
                    width = clipMinimizeWidth
                }
                height = max(height, clipMinimizeHeight)
                
            case .LowerRightCorner:
                originX = startingFrame.origin.x
                originY = startingFrame.origin.y
                width = startingFrame.width + dx
                height = startingFrame.height + dy
                
                if height > bounds.maxY - startingFrame.minY {
                    height = bounds.maxY - startingFrame.minY
                }
                if originX + width > bounds.maxX {
                    width = bounds.maxX - originX
                }
                width = max(width, clipMinimizeWidth)
                height = max(height, clipMinimizeHeight)
                
            case .Inside:
                originX = startingFrame.origin.x + dx
                originY = startingFrame.origin.y + dy
                width = startingFrame.width
                height = startingFrame.height
                
                if originX < bounds.minX {
                    originX = bounds.minX
                }
                if originY < bounds.minY {
                    originY = bounds.minY
                }
                if originX + width > bounds.maxX {
                    originX = bounds.maxX - width
                }
                if originY + height > bounds.maxY {
                    originY = bounds.maxY - height
                }
                
            default:
                // box 区域外
                return
            }
            
            boxFrame = CGRect(x: originX, y: originY, width: width, height: height)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dragPosition = .None
        isDraging = false
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        dragPosition = .None
        isDraging = false
    }
    
    
}


