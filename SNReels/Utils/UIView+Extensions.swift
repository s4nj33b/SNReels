//
//  UIView+Extensions.swift
//  SNReels
//
//  Created by Sanjeeb on 05/04/21.
//

import UIKit
public extension UIView {
    func addFitting(subView: UIView) -> (left: NSLayoutConstraint, right: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        return UIView.stickViewEdges(view1: self, view2: subView)
    }
    
    static func stickViewEdges(view1: UIView, view2: UIView) -> (left: NSLayoutConstraint, right: NSLayoutConstraint, top: NSLayoutConstraint, bottom: NSLayoutConstraint) {
        
        let left = NSLayoutConstraint(item: view2, attribute: .left, relatedBy: .equal, toItem: view1, attribute: .left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: view2, attribute: .right, relatedBy: .equal, toItem: view1, attribute: .right, multiplier: 1.0, constant: 0.0)
        let top = NSLayoutConstraint(item: view2, attribute: .top, relatedBy: .equal, toItem: view1, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: view2, attribute: .bottom, relatedBy: .equal, toItem: view1, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([left, right, top, bottom])
        return (left: left, right: right, top: top, bottom: bottom)
    }
    
}
