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
    var boxFrame = CGRect.zero {
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
    var screenColor = UIColor.black {
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
    
    fileprivate var dragPosition: SKClipBox.DragPosition = .none
    fileprivate var startingPoint = CGPoint.zero
    fileprivate var startingFrame = CGRect.zero
    fileprivate var isDraging = false
    fileprivate var firstTouch: UITouch!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(clipBox)
        clipBox.frame = boxFrame
        self.backgroundColor = UIColor.clear
        // 缩放

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()!
        fillInTheRect(ctx, rect: self.bounds)
        clearRect(ctx, rect: boxFrame)
    }
    
    
    fileprivate func fillInTheRect(_ ctx: CGContext, rect: CGRect) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        if screenColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) == true {
            ctx.setFillColor(red: red, green: green, blue: blue, alpha: alpha*screenAlpha)
        } else {
            ctx.setFillColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
        }
        ctx.fill(rect)
    }
    
    fileprivate func clearRect(_ ctx: CGContext, rect: CGRect) {
        ctx.clear(rect)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if clipBox.frame == CGRect.zero {
            let rect = CGRect(x: self.frame.width/2-50, y: self.frame.height/2-50, width: 100, height: 100)
            boxFrame = rect
        }
    }
   
    
}

// 手势
extension SKClipView: UIGestureRecognizerDelegate{
    // 缩放
    func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        let scale = sqrt(pinch.scale)
        
        switch pinch.state {
        case .began:
            startingFrame = boxFrame
            
        case .changed:
            let size = CGSize(width: max(startingFrame.width*scale, clipMinimizeWidth), height: max(startingFrame.height*scale, clipMinimizeHeight ))
            var rect = CGRect(origin: CGPoint.zero, size: size)
            let centerPoint = CGPoint(x: startingFrame.midX, y: startingFrame.midY)
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
            
        case .ended:
            startingFrame = boxFrame
            
        default:
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 防止一只手指拖动时，另一只手指触发缩放手势
        if isDraging {
            return false
        } else {
            return true
        }
    }
    
    // touch点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let allTouches = event!.allTouches!
        
        switch allTouches.count {
        case 1:
            startingFrame = boxFrame
            firstTouch = allTouches.first!
            startingPoint = firstTouch.location(in: self)
            
            if clipBox.upperEdge.bounds.contains(firstTouch.location(in: clipBox.upperEdge)) {
                dragPosition = .upperEdge
            }
            else if clipBox.rightEdge.bounds.contains(firstTouch.location(in: clipBox.rightEdge)) {
                dragPosition = .rightEdge
            }
            else if clipBox.lowerEdge.bounds.contains(firstTouch.location(in: clipBox.lowerEdge)) {
                dragPosition = .lowerEdge
            }
            else if clipBox.leftEdge.bounds.contains(firstTouch.location(in: clipBox.leftEdge)) {
                dragPosition = .leftEdge
            }
            else if clipBox.upperLeftCorner.bounds.contains(firstTouch.location(in: clipBox.upperLeftCorner)) {
                dragPosition = .upperLeftCorner
            }
            else if clipBox.upperRightCorner.bounds.contains(firstTouch.location(in: clipBox.upperRightCorner)) {
                dragPosition = .upperRightCorner
            }
            else if clipBox.lowerLeftCorner.bounds.contains(firstTouch.location(in: clipBox.lowerLeftCorner)) {
                dragPosition = .lowerLeftCorner
            }
            else if clipBox.lowerRightCorner.bounds.contains(firstTouch.location(in: clipBox.lowerRightCorner)) {
                dragPosition = .lowerRightCorner
            } else if clipBox.bounds.contains(firstTouch.location(in: clipBox)) {
                dragPosition = .inside
            }
            else {
                dragPosition = .none
            }
        default:
            break
        }
    }
    
    // touch移动
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard firstTouch != nil else {
            return
        }
        let allTouches = event!.allTouches!
        switch allTouches.count {
        case 1:
            isDraging = true
            firstTouch = allTouches.first
            fallthrough
        default:
            let touch = firstTouch
            let touchPoint = touch?.location(in: self)
            let dx = (touchPoint?.x)! - startingPoint.x
            let dy = (touchPoint?.y)! - startingPoint.y
            
            var originX: CGFloat = 0
            var originY: CGFloat = 0
            var width: CGFloat = 0
            var height: CGFloat = 0
            
            switch dragPosition {
            case .upperEdge:
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
                
            case .rightEdge:
                originX = startingFrame.origin.x
                originY = startingFrame.origin.y
                width = startingFrame.width + dx
                height = startingFrame.height
                
                if originX + width > bounds.maxX {
                    width = bounds.maxX - originX
                }
                width = max(width, clipMinimizeWidth)
                
            case .lowerEdge:
                originX = startingFrame.origin.x
                originY = startingFrame.origin.y
                width = startingFrame.width
                height = startingFrame.height + dy
                
                if height > bounds.maxY - startingFrame.minY {
                    height = bounds.maxY - startingFrame.minY
                }
                height = max(height, clipMinimizeHeight)
                
            case .leftEdge:
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
                
            case .upperLeftCorner:
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
                
            case .upperRightCorner:
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
                
            case .lowerLeftCorner:
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
                
            case .lowerRightCorner:
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
                
            case .inside:
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragPosition = .none
        isDraging = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        dragPosition = .none
        isDraging = false
    }
    
    
}


