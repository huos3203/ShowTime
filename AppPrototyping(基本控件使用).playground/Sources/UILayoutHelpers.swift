//
//  UILayoutHelpers.swift
//
//
//  Created by Timothy Bellay on 01/05/16.
//
//

import UIKit

public func horizontalStrechToParentView(arr: UIView...) {
	var viewDict = [String: UIView]()
	var layoutConstraints = [NSLayoutConstraint]()
	for (ind, view) in arr.enumerated() {
		if let _ = view.superview { // Test to see if view has a superview before trying to add constraint.
			let viewName = "view\(ind)"
			viewDict.updateValue(view, forKey: viewName)
			layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat:"|[\(viewName)]|", options: [], metrics: nil, views: viewDict)
		}
	}
	NSLayoutConstraint.activate(layoutConstraints)
}

public func setConstraints(visualLanguage: Array<String>, views: Dictionary<String, AnyObject>) {
	var layoutConstraints = [NSLayoutConstraint]()
	visualLanguage.forEach({
		layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat:$0, options: [], metrics: nil, views: views)
	})
	NSLayoutConstraint.activate(layoutConstraints)
}

public func outlineViews(views: [UIView], outlineColor: UIColor) {
	// TODO: Color horizontal and vertical stackviews differently, i.e. blue and red.
	views.forEach({
		if let sv = $0 as? UIStackView {
			let pb = sv.superview
			let outlineView = UIView(frame: sv.bounds)
			outlineView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.15)
			outlineView.layer.borderColor = UIColor.red.cgColor
			outlineView.layer.borderWidth = 2
			pb?.addSubview(outlineView)
			print("adding stackview outline: \(outlineView) to superview: \(pb)")
		} else {
			$0.layer.borderWidth = 1
			$0.layer.borderColor = outlineColor.cgColor
			print("adding view outline")
		}
		let subViews = $0.subviews
        outlineViews(views:subViews, outlineColor: outlineColor)
	})
}

public var GlobalMainQueue: DispatchQueue {
//    return dispatch_get_main_queue()
    return DispatchQueue.main
}

public func wait(seconds: Double, perform: @escaping ()->() ) {
//    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    let delayTime = DispatchTime.now() + seconds
//    dispatch_after(delayTime, GlobalMainQueue, { () -> Void in
      GlobalMainQueue.asyncAfter(deadline:delayTime){ () -> Void in
//		UIView.animateWithDuration(0.5) { () -> Void in
//			//        stackView.axis = .Vertical
//			screen.view.frame = CGRectMake(0, 0, 480, 320)
//		}
		
		perform()
	}

}


