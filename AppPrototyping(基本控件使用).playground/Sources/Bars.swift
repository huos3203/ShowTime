//
//  Bars.swift
//
//
//  Created by Timothy Bellay on 12/6/15.
//
//

import UIKit

public extension UILabel {
	convenience init(text: String, font: UIFont, textColor: UIColor, labelColor: UIColor) {
		self.init()
		let labelAttr: NSDictionary = [
			NSAttributedStringKey.font : font,
		]
		self.attributedText = NSAttributedString(string: text, attributes:  labelAttr as? [NSAttributedStringKey : Any])
		self.textColor = textColor
		self.backgroundColor = labelColor
		self.textAlignment = .center
		self.numberOfLines = 0
		self.sizeToFit()
	}
}

public extension UIView {
	convenience init(width: CGFloat?, height: CGFloat?, color: UIColor?) {
		self.init()
		if color != nil {
			self.backgroundColor = color!
		} else {
			self.backgroundColor = .clear
		}
		self.translatesAutoresizingMaskIntoConstraints = false
		
		// Setup view anchors.
		if let wAnchor = width {
			self.widthAnchor.constraint(equalToConstant:wAnchor).isActive = true
		} else {
			self.widthAnchor.constraint(equalToConstant:44).isActive = true
			
		}
		if let hAnchor = height {
			self.heightAnchor.constraint(equalToConstant:hAnchor).isActive = true
			
		} else {
			self.heightAnchor.constraint(equalToConstant:44).isActive = true
		}
	}
}

extension UIImage {
	class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect.init(x:0.0,y:0.0,width:1.0,height:1.0)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		
		context?.setFillColor(color.cgColor)
		context?.fill(rect)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image!
	}
}

public struct StatusBar {
	public var view = UIView(frame: .zero)
	var mainSV: UIStackView?
	var carrierSV: UIStackView?
	var circleSV: UIStackView?
	var outline: Bool = false
	var appearance: Appearance
	var labels = [UILabel]()
	var carrierSignalStrength = 3 // range: 0 - 5.
	var batteryPercentage = 58 // range: 0 - 100.
	var navigationLabel = UILabel()
	public var navigation: String? {
		didSet {
			if let navString = navigation {
				if appearance.theme == .Light {
					navigationLabel = UILabel(text: navString, font: Font.SmallText.create(), textColor: appearance.textColor(), labelColor: appearance.labelColor())
				} else {
					navigationLabel = UILabel(text: navString, font: Font.SmallText.create(), textColor: appearance.textColor(), labelColor: appearance.labelColor())
				}
				carrierSV?.isHidden = true
			} else {
				carrierSV?.isHidden = false
			}
		}
	}

	public init(frame: CGRect, appearance: Appearance) {
		let width = frame.size.width
		let height = CGFloat(20)
		view.frame = CGRect.init(x:0.0,y:0.0,width:width,height:height)
		view.backgroundColor = appearance.labelColor()
		self.appearance = appearance
		let smallFont = Font.SmallText.create()

		// TODO: replace horizontal stackViews and build with UILayoutGuide.
		mainSV = makeHorizontalSV(view:view)
		carrierSV = makeHorizontalSV(view:mainSV!)
		circleSV = makeHorizontalSV(view:carrierSV!)

		// Signal strength circles.
		// Draw filled circle and get image.
        let filledCircle = UIBezierPath(arcCenter: CGPoint(x:4, y:4), radius: 3, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        UIGraphicsBeginImageContext(CGSize(width:8, height:8))
		appearance.setStrokeAndFill()
		
		filledCircle.lineWidth = 1
		filledCircle.fill()
		filledCircle.stroke()
		let filledCircleImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		// Draw empty circle and get image.
        let emptyCircle = UIBezierPath(arcCenter: CGPoint(x:4, y:4), radius: 3, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        UIGraphicsBeginImageContext(CGSize(width:8, height:8))
		appearance.setStrokeAndFill()

		emptyCircle.lineWidth = 1
		emptyCircle.stroke()
		let emptyCircleImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	
		let circleView0 = UIImageView(image: filledCircleImage)
		let circleView1 = UIImageView(image: filledCircleImage)
		let circleView2 = UIImageView(image: filledCircleImage)
		let circleView3 = UIImageView(image: emptyCircleImage)
		let circleView4 = UIImageView(image: emptyCircleImage)
		circleSV!.addArrangedSubview(circleView0)
		circleSV!.addArrangedSubview(circleView1)
		circleSV!.addArrangedSubview(circleView2)
		circleSV!.addArrangedSubview(circleView3)
		circleSV!.addArrangedSubview(circleView4)
		
		// Carrier Label
		let carrierLabel = UILabel(text: "T-Mobile LTE", font: smallFont, textColor: .clear, labelColor: .clear)
		carrierSV!.addArrangedSubview(carrierLabel)
		labels.append(carrierLabel)
		
		// Time Label
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		dateFormatter.timeStyle = .short
		let timeLabel = UILabel(text: dateFormatter.string(from:Date()), font: smallFont, textColor: .clear, labelColor: .clear)
		mainSV!.addArrangedSubview(timeLabel)
		labels.append(timeLabel)

		// Battery percentage label
		let batteryLabel = UILabel(text: "\(batteryPercentage)%", font: smallFont, textColor: .clear, labelColor: .clear)
        let batterySV = makeHorizontalSV(view:mainSV!)
		batterySV.addArrangedSubview(batteryLabel)
		labels.append(batteryLabel)
		
		// Battery percentage bar
        UIGraphicsBeginImageContext(CGSize(width:30, height:20))
		let batteryBodyWidth = 20 // pts.
		let batteryBodyPath = UIBezierPath(rect: CGRect.init(x:2.5,y:5,width:CGFloat(batteryBodyWidth),height:10))
		let batteryCapPath = UIBezierPath(rect: CGRect.init(x:CGFloat(batteryBodyWidth + 2),y:7,width:2.5,height:5))
        let batteryRemainingPath = UIBezierPath(rect: CGRect(x:3.5, y:6, width:CGFloat((batteryBodyWidth - 2) * batteryPercentage / 100), height:8))
		
		view.backgroundColor = appearance.labelColor()
		appearance.setStrokeAndFill()
		batteryBodyPath.lineWidth = 1
		batteryCapPath.lineWidth = 1
		batteryBodyPath.stroke()
		batteryCapPath.fill()
		if batteryPercentage <= 20 {
			UIColor.red.setFill()
		}
		batteryRemainingPath.fill()
		
		let batteryImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		let batteryView = UIImageView(image: batteryImage)
		batterySV.addArrangedSubview(batteryView)
		
		labels.forEach({$0.textColor = appearance.textColor()})
		
	}
}

public struct NavigationBar {
	// TODO: ability to add search bar to the navBar.
	public var containerView: ContainerView?
	var backCarrot = UIView(width: 11, height: 22, color: Color.BlueLink.create())
	var backLabel: UIView
	var titleLabel = UILabel()
	var rightNavItem: UIView
	
	public init(frame: CGRect, appearance: Appearance, title: String) {
		containerView = ContainerView(width: frame.width, height: 44, color: .orange, marginInset: 8)
		
		// Make bar elements.
		backLabel = UILabel(text: "Back", font: Font.BodyText.create(), textColor: appearance.textColor(), labelColor: appearance.labelColor())
		titleLabel = UILabel(text: title, font: Font.BodyText.create(), textColor: appearance.textColor(), labelColor: appearance.labelColor())
		rightNavItem = UILabel(text: "Action", font: Font.BodyText.create(), textColor: appearance.textColor(), labelColor: appearance.labelColor())
		containerView?.view?.backgroundColor = appearance.labelColor()
		backCarrot.backgroundColor = appearance.textColor()
		
		// Turn off autoResizingMask...
		backCarrot.translatesAutoresizingMaskIntoConstraints = false
		backLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		rightNavItem.translatesAutoresizingMaskIntoConstraints = false
		
		// Add bar elements to containerView.
		containerView?.stickSubviewToInsideMargin(margin:.Left, subview: backCarrot, byAmount: 0)
		containerView?.centerSubviewYInside(subview:backCarrot)
		containerView?.stickSubviewToSubview(subview1:backLabel, direction: .Right, subview2: backCarrot, byAmount: 4, align: .CenterY)
		
		containerView?.stickSubviewToInsideMargin(margin:.Right, subview: rightNavItem, byAmount: 0)
		containerView?.centerSubviewYInside(subview:rightNavItem)
		containerView?.centerSubviewInside(subview:titleLabel)
		
	}
}

public struct ToolBar {
	public var view = UIToolbar()
	public var buttons = [UIBarButtonItem]()
	
	public init(frame: CGRect, appearance: Appearance) {
        view.frame = CGRect(x:0, y:0, width:frame.size.width, height:44)

		let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let button0 = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
		buttons.append(button0)
		let button1 = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
		buttons.append(button1)
		let button2 = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
		buttons.append(button2)
		let button3 = UIBarButtonItem(barButtonSystemItem: .search, target: nil, action: nil)
		buttons.append(button3)

		view.barTintColor = appearance.labelColor()
//		view.setShadowImage(UIImage(), forToolbarPosition: .Any) // Clear the shadow image.
		view.isTranslucent = false // Bars are defaulted to translucent and gaussian blurred.
		buttons.forEach({$0.tintColor = appearance.textColor()})
		
		view.setItems([spacer, button0, spacer, button1, spacer, button2, spacer, button3, spacer], animated: true)
	}
}

public struct TabBar {
	public var view = UIView(frame: .zero)
	public var buttons = [UIBarButtonItem]()
	public var mainSV: UIStackView?
	
	public init(frame: CGRect, appearance: Appearance) {
        view.frame = CGRect(x:0, y:0, width:frame.size.width, height:44)
		mainSV = makeHorizontalSV(view:view)
		view.addSubview(mainSV!)
		view.backgroundColor = appearance.labelColor()
		
		let barButton0 = Button(appearance: appearance, imageName: "button", text: "Messaging", type: .Down)
		let barButton1 = Button(appearance: appearance, imageName: "button", text: "My Data", type: .Down)
		let barButton2 = Button(appearance: appearance, imageName: "button", text: "Info", type: .Down)
		let barButton3 = Button(appearance: appearance, imageName: "button", text: "Settings", type: .Down)
		mainSV?.addArrangedSubview(barButton0.view)
		mainSV?.addArrangedSubview(barButton1.view)
		mainSV?.addArrangedSubview(barButton2.view)
		mainSV?.addArrangedSubview(barButton3.view)
		
	
	}
}

public struct SearchBar {
	var view = UISearchBar()
	public init(frame: CGRect, appearance: Appearance) {
		view.barTintColor = appearance.labelColor()
		view.tintColor = appearance.textColor()
		view.backgroundImage = UIImage.imageWithColor(color:appearance.labelColor())
		view.placeholder = "search"
		view.showsCancelButton = true
		
		if appearance.theme == .Light {
            UITextField.appearance(whenContainedInInstancesOf:[UISearchBar.self]).backgroundColor = .lightGray
		} // To prevent the search bar text background to be indistinguishable from the white bar background.
	}
}
