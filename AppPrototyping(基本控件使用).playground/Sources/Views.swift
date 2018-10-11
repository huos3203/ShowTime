import UIKit

public func makeHorizontalSV(view: UIView) -> UIStackView {
	return makeSV(view, axis: .horizontal)
}

public func makeVerticalSV(view: UIView) -> UIStackView {
	return makeSV(view, axis: .vertical)
}

/**
Adds a UIStackView as a subview to a view and its layout constraints to fill the view.
*/
public func makeSV(_ view: UIView, axis: UILayoutConstraintAxis) -> UIStackView {
	let stackView = UIStackView(frame: .zero)
	stackView.translatesAutoresizingMaskIntoConstraints = false
	stackView.axis = axis
	stackView.alignment = .center
	stackView.distribution = .equalCentering
	stackView.isLayoutMarginsRelativeArrangement = true
	
	var layoutConstraints = [NSLayoutConstraint]()
	let views = ["stackView" : stackView]
	
	if let v = view as? UIStackView {
		v.addArrangedSubview(stackView)
	} else {
		// if the parent view is not a stackview then we can set
		view.addSubview(stackView)
		layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat:"|[stackView]|", options: [], metrics: nil, views: views)
	}
	layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat:"V:|[stackView]|", options: [], metrics: nil, views: views)
	NSLayoutConstraint.activate(layoutConstraints)
	
	return stackView
}

public enum Margin {
	case Left, Right, Top, Bottom
}

public enum Align {
	case Left, Right, Top, Bottom, CenterX, CenterY
}

public class ContainerView {
	public var view: UIView?
	var viewWidthAnchor: CGFloat?
	var viewHeightAnchor: CGFloat?
	
	public var superStackview: UIStackView?
	public var subStackview: UIStackView?

	var subviews: [UIView]?
	let marginLayout = UILayoutGuide()
	let marginInset: CGFloat = 8
	
	public init(width: CGFloat, height: CGFloat, color: UIColor?, marginInset: CGFloat) {
		
		if color != nil {
			view = UIView(width: width, height: height, color: color)
		} else {
			view = UIView(width: width, height: height, color: nil)
		}
		viewWidthAnchor = width
		viewHeightAnchor = height
		
		view?.translatesAutoresizingMaskIntoConstraints = false

		view?.addLayoutGuide(marginLayout)
		view?.layoutMargins = UIEdgeInsets(top: marginInset, left: marginInset,
			bottom: marginInset, right: marginInset)
		// Set marginLayout guide to match view's margins.
		var constraints = [NSLayoutConstraint]()
		constraints.append(marginLayout.centerXAnchor.constraint(equalTo:(view?.centerXAnchor)!))
		constraints.append(marginLayout.centerYAnchor.constraint(equalTo:(view?.centerYAnchor)!))
		constraints.append(marginLayout.widthAnchor.constraint(equalTo:(view?.widthAnchor)!, constant: -2 * marginInset))
		constraints.append(marginLayout.heightAnchor.constraint(equalTo:(view?.heightAnchor)!, constant: -2 * marginInset))
		NSLayoutConstraint.activate(constraints)
	}
		
	public func stickSubviewToInsideMargin(margin: Margin, subview: UIView, byAmount: CGFloat) {
		view?.addSubview(subview)
		switch margin {
		case .Left:
			NSLayoutConstraint(item: subview, attribute: .left, relatedBy: .equal, toItem: marginLayout, attribute: .left, multiplier: 1, constant: byAmount).isActive = true
		case .Right:
			NSLayoutConstraint(item: subview, attribute: .right, relatedBy: .equal, toItem: marginLayout, attribute: .right, multiplier: 1, constant: byAmount).isActive = true
		case .Top:
			NSLayoutConstraint(item: subview, attribute: .top, relatedBy: .equal, toItem: marginLayout, attribute: .top, multiplier: 1, constant: byAmount).isActive = true
		case .Bottom:
			NSLayoutConstraint(item: subview, attribute: .bottom, relatedBy: .equal, toItem: marginLayout, attribute: .bottom, multiplier: 1, constant: byAmount).isActive = true
		break
		}
	}

	public func centerSubviewXInside(subview: UIView) {
		NSLayoutConstraint(item: subview, attribute: .centerX, relatedBy: .equal, toItem: view!, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
	}
	
	public func centerSubviewYInside(subview: UIView) {
		NSLayoutConstraint(item: subview, attribute: .centerY, relatedBy: .equal, toItem: view!, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
	}

	
	public func centerSubviewInside(subview: UIView) {
		view?.addSubview(subview)
		centerSubviewXInside(subview:subview)
		centerSubviewYInside(subview:subview)
	}
	
	public func stickSubviewToSubview(subview1: UIView, direction: Direction, subview2: UIView, byAmount: CGFloat, align: Align) {
		view?.addSubview(subview1)
		switch direction {
		case .Up:
			NSLayoutConstraint(item: subview1, attribute: .bottom, relatedBy: .equal, toItem: subview2, attribute: .top, multiplier: 1, constant: byAmount).isActive = true
		case .Down:
			NSLayoutConstraint(item: subview1, attribute: .top, relatedBy: .equal, toItem: subview2, attribute: .bottom, multiplier: 1, constant: byAmount).isActive = true
		case .Left:
			NSLayoutConstraint(item: subview1, attribute: .right, relatedBy: .equal, toItem: subview2, attribute: .left, multiplier: 1, constant: byAmount).isActive = true
		case .Right:
			NSLayoutConstraint(item: subview1, attribute: .left, relatedBy: .equal, toItem: subview2, attribute: .right, multiplier: 1, constant: byAmount).isActive = true
		}
		
		switch align {
		case .CenterX:
			NSLayoutConstraint(item: subview1, attribute: .centerX, relatedBy: .equal, toItem: subview2, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
		case .CenterY:
			NSLayoutConstraint(item: subview1, attribute: .centerY, relatedBy: .equal, toItem: subview2, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
		case .Left:
			NSLayoutConstraint(item: subview1, attribute: .left, relatedBy: .equal, toItem: subview2, attribute: .left, multiplier: 1, constant: 0).isActive = true
		case .Right:
			NSLayoutConstraint(item: subview1, attribute: .right, relatedBy: .equal, toItem: subview2, attribute: .right, multiplier: 1, constant: 0).isActive = true
		case .Top:
			NSLayoutConstraint(item: subview1, attribute: .top, relatedBy: .equal, toItem: subview2, attribute: .top, multiplier: 1, constant: 0).isActive = true
		case .Bottom:
			NSLayoutConstraint(item: subview1, attribute: .bottom, relatedBy: .equal, toItem: subview2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
		}
	}
	
	// TODO: Rethink and refactor stackview code below. TB.
	
//	func setupSuperStackView(direction: Direction) {
//		if superStackview == nil {
//			superStackview = UIStackView(frame: .zero)
//			superStackview?.translatesAutoresizingMaskIntoConstraints = false
//			superStackview?.alignment = .Center
//			superStackview?.distribution = .EqualCentering
//			superStackview?.layoutMarginsRelativeArrangement = true
//			switch direction {
//			case .Left, .Right:
//				superStackview?.axis = .Horizontal
//			case .Up, .Down:
//				superStackview?.axis = .Vertical
//			}
//			superStackview?.addArrangedSubview(view!)
//		}
//	}
//	
//	func setupSubStackView() {
//		if subStackview == nil {
//			subStackview = makeSV(view!, axis: .Vertical)
//		}
//	}
//	
//	func findViewInStackView(view: UIView, stackview: UIStackView?) -> Int? {
//		var ind: Int? = nil
//		if let subviews = stackview?.arrangedSubviews {
//			for (i, arrangedView) in subviews.enumerate() {
//				if arrangedView == view {
//					ind = i
//				}
//			}
//		}
//		return ind
//	}
//	
//	func removeFromStackView(subview: UIView) {
//		unstick(subview, stackview: superStackview)
//		unstick(subview, stackview: subStackview)
//	}
//	
//	func unstick(subview: UIView, stackview: UIStackView?) {
//		stackview?.removeArrangedSubview(subview)
//	}
//	
//	public func stack(subview: UIView, direction: Direction) {
//		removeFromStackView(subview)
//		setupSuperStackView(direction)
//		if let ind = findViewInStackView(view!, stackview: superStackview) {
//			switch direction {
//			case .Left, .Up:
//				superStackview?.insertArrangedSubview(subview, atIndex: ind) // Except that expected arg type is UInt.
//			case .Right, .Down:
//				superStackview?.insertArrangedSubview(subview, atIndex: ind + 1)  // Except that expected arg type is UInt.
//			}
//		} else {
//			print("Warning View.self was not found in stackview.")
//		}
//	}

	
}

