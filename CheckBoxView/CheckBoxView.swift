//
//  CheckBoxView.swift
//
//  Created by Guan Xiaopeng on 2018/7/26.
//  Copyright © 2018年 songtao. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class CheckBoxView : UIView {
    
    private let label  = UILabel()
    private let spacing = CGFloat(4)
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let fsize = CGFloat(iconSize)
        label.frame = CGRect(
            x: bounds.minX + spacing*2 + fsize,
            y: bounds.minY,
            width: bounds.width - bounds.height - spacing * 3,
            height: bounds.height
        )
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.addSubview(label)
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func onTapped() {
        if self.isEnabled {
            isChecked = !isChecked
            
            delegate?.didTapCheckBox(sender: self)
        }
    }
    
    @IBInspectable
    public var text : String? {
        set(value) {
            self.label.text = value
        }
        get {
            return self.label.text
        }
    }
    
    private var mChecked = false
    @IBInspectable
    public var isChecked : Bool {
        set (value) {
            if mChecked == value {
                return
            }
            
            mChecked = value
            self.setNeedsDisplay()
            if mChecked && isRadio {
                RaidoGroups.setCheckedView(view: self)
            }
        }
        
        get {
            return mChecked
        }
    }
    
    @IBInspectable
    public var isTextOnRight : Bool = true {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var radioGroup : String? = nil {
        didSet {
            self.setNeedsDisplay()
            if mChecked && isRadio {
                RaidoGroups.setCheckedView(view: self)
            }
        }
    }
    
    fileprivate var isRadio : Bool {
        return radioGroup == nil ? false : !radioGroup!.isEmpty
    }
    
    @IBInspectable
    public var iconColor: UIColor? = UIColor.green {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var isEnabled : Bool = true {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var iconSize : Int = 16 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        let fsize = CGFloat(iconSize)
        if self.isTextOnRight {
            label.frame = CGRect(
                x: bounds.minX + spacing*2 + fsize,
                y: bounds.minY,
                width: bounds.width - bounds.height - spacing * 3,
                height: bounds.height
            )
            label.textAlignment = .left
        } else {
            label.frame = CGRect(
                x: bounds.minX,
                y: bounds.minY,
                width: bounds.width - spacing * 3 - fsize,
                height: bounds.height
            )
            label.textAlignment = .right
        }
    }
    
    fileprivate func drawCheckBox(_ rect: CGRect, _ context: CGContext) {
        
        var color = iconColor == nil ? UIColor.green.cgColor: iconColor!.cgColor
        if !self.isEnabled {
            color = UIColor.lightGray.cgColor
        }
        
        let fsize = CGFloat(iconSize)
        
        let circleRect = self.isTextOnRight ?
            CGRect(x: rect.minX + spacing, y: rect.midY - fsize/2, width: fsize, height: fsize) :
            CGRect(x: rect.maxX - spacing * 2 - fsize , y: rect.midY - fsize/2, width: fsize, height: fsize)
        
        if self.isChecked {
            context.setFillColor(color)
            context.fillEllipse(in: circleRect)
            
            let inner = circleRect.insetBy(dx: circleRect.width/6, dy: circleRect.width/6).offsetBy(dx: 0, dy: -circleRect.width/12)
            
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(fsize/6)
            context.setLineCap(CGLineCap.round)
            context.beginPath()
            context.move(to: CGPoint(x:inner.minX, y:inner.midY + inner.width/8))
            context.addLine(to: CGPoint(x: inner.midX, y: inner.maxY))
            context.addLine(to: CGPoint(x: inner.maxX, y: inner.midY - inner.width/4))
            context.strokePath()
        } else {
            context.setStrokeColor(color)
            context.setLineWidth(2)
            context.addEllipse(in: circleRect)
            context.strokePath()
        }
    }
    
    fileprivate func drawRadioBox(_ rect: CGRect, _ context: CGContext) {
        
        var color = iconColor == nil ? UIColor.green.cgColor: iconColor!.cgColor
        if !self.isEnabled {
            color = UIColor.lightGray.cgColor
        }
        
        let fsize = CGFloat(iconSize)
        
        let circleRect = self.isTextOnRight ?
            CGRect(x: rect.minX + spacing, y: rect.midY - fsize/2, width: fsize, height: fsize) :
            CGRect(x: rect.maxX - spacing * 2 - fsize , y: rect.midY - fsize/2, width: fsize, height: fsize)
        
        context.setStrokeColor(color)
        context.setLineWidth(2)
        context.addEllipse(in: circleRect)
        context.strokePath()
        
        if self.isChecked {
            context.setFillColor(color)
            context.fillEllipse(in: circleRect.insetBy(dx: 4, dy: 4))
        }
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.saveGState()
        self.isRadio ? drawRadioBox(rect, context) : drawCheckBox(rect, context)
        context.restoreGState()
        
        super.draw(rect)
    }
    
    public var delegate: CheckBoxViewDelegate?
}

fileprivate class CheckBoxViewHolder {
    weak var handle : CheckBoxView?
    init(_ view : CheckBoxView) {
        handle = view
    }
}

fileprivate class RaidoGroups {
    static var groupDic = [String : [CheckBoxViewHolder]]()
    static func setCheckedView(view: CheckBoxView) {
        var groupItems = groupDic[view.radioGroup!] as [CheckBoxViewHolder]?
        if groupItems == nil {
            groupItems = Array<CheckBoxViewHolder>()
        }
        
        var items = groupItems!
        udpateGroup(&items)
        checkedInGroup(&items, view)
        groupDic[view.radioGroup!] = items
    }
    
    private static func udpateGroup(_ groupItems:inout [CheckBoxViewHolder]) {
        var removing = [Int]()
        for index in 0 ..< groupItems.count {
            if groupItems[index].handle == nil {
                removing.insert(index, at: 0)
            }
        }
        for i in removing {
            groupItems.remove(at: i)
        }
    }
    
    private static func checkedInGroup(_ groupItems:inout [CheckBoxViewHolder], _ view : CheckBoxView) {
        var holder = groupItems.first { vh in  vh.handle == view  }
        if holder == nil {
            holder = CheckBoxViewHolder(view)
            groupItems.append(holder!)
        }
        for h in groupItems {
            h.handle!.isChecked = h.handle == view
        }
    }
}

public protocol CheckBoxViewDelegate {
    func didTapCheckBox(sender: CheckBoxView)
}
