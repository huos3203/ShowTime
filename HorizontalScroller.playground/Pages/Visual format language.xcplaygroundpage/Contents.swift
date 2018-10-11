//: [Previous](@previous)

import Foundation
import PlaygroundSupport
import UIKit
PlaygroundPage.current.needsIndefiniteExecution = true



protocol hiddenGuideItem {
    //
    
    var leftItem:UIButton{get set}
    var rightItem:UIButton{get set}
    var backgroundView:UIImageView{get set}
    func hiddenGuideItem(item:UIButton)
    
}

// MARK: - 扩展UIView添加全屏遮罩

class TraitCollectionView:UIView{
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        //
        let traitCollection = self.traitCollection
        
        switch traitCollection.userInterfaceIdiom {
        case .pad:
            print("Pad....")
        case .phone:
            print("Phone....")
        case .tv:
            print("TV...")
        case .carPlay:
            print("carPlay...")
        case .unspecified:
            print("Unspecified...")
        }
        
        switch traitCollection.horizontalSizeClass {
        case .compact:
            print("compact...")
        case .regular:
            print("regular...")
        case .unspecified:
            print("unspecified...")
        }
        
        switch traitCollection.verticalSizeClass {
        case .compact:
            print("compact...")
        case .regular:
            print("regular...")
        case .unspecified:
            print("unspecified...")
        }
    }
    
}


extension UIView{
    var leftTraitHrizontalOfLeftItem:CGFloat{
        return traitCollection.userInterfaceIdiom == .pad ? 20 : 16
    }
    var rightTraitHrizontalOfRightItem:CGFloat{
        return traitCollection.userInterfaceIdiom == .pad ? 6 : 3
    }
    
    public var backgroundImageView:UIImageView{
        get{
            
            return self.backgroundImageView
        }
        set{
            self.addSubview(newValue)
            //self.bringSubviewToFront(newValue)
            //将newValue视图移动到self.subviews最底层
            self.sendSubview(toBack: newValue)
            newValue.translatesAutoresizingMaskIntoConstraints = false
            let backgroundImageViewV = NSLayoutConstraint.constraints(withVisualFormat:"V:|-0-[ImageView]-0-|",
                                                                      options: [],
                                                                      metrics: nil,
                                                                      views: ["ImageView":newValue])
            let backgroundImageViewH = NSLayoutConstraint.constraints(withVisualFormat:"H:|-0-[ImageView]-0-|",
                                                                      options: [],
                                                                      metrics: nil,
                                                                      views: ["ImageView":newValue])
            self.addConstraints(backgroundImageViewH)
            self.addConstraints(backgroundImageViewV)
        }
    }
    
    
    public var leftItem:UIButton{
        
        get{
            
            let leftButton = UIButton()
            leftButton.isHidden = true
            return leftButton
        }
        
        set{
            self.addSubview(newValue)
            newValue.translatesAutoresizingMaskIntoConstraints = false
            let leftItem_Vconstraints = NSLayoutConstraint.constraints(withVisualFormat:"V:|-27-[leftItem]",
                                                                       options: [],
                                                                       metrics: nil,
                                                                       views: ["leftItem":newValue])
            let leftItem_Hconstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leftConstant-[leftItem]", options: [], metrics: ["leftConstant":leftTraitHrizontalOfLeftItem], views: ["leftItem":newValue])
            self.addConstraints(leftItem_Hconstraints)
            self.addConstraints(leftItem_Vconstraints)
            newValue.addTarget(self, action: #selector(UIView.hiddenGuideItem(_:)), for: .touchUpInside)
        }
        
    }
    
    
    public var rightItem:UIButton{
        
        get{
            return self.rightItem
        }
        set{
            
            self.addSubview(newValue)
            
            newValue.translatesAutoresizingMaskIntoConstraints = false
            
            
            let rightItem_Vconstraints = NSLayoutConstraint.constraints(withVisualFormat:"V:|-31-[rightItem]",
                                                                        options: [],
                                                                        metrics: nil,
                                                                        views: ["rightItem":newValue])
            let rightItem_Hconstraints = NSLayoutConstraint.constraints(withVisualFormat:"H:[rightItem]-rightConstant-|",
                                                                        options: [],
                                                                        metrics: ["rightConstant":rightTraitHrizontalOfRightItem],
                                                                        views: ["rightItem":newValue])
            self.addConstraints(rightItem_Hconstraints)
            self.addConstraints(rightItem_Vconstraints)
            newValue.addTarget(self, action: #selector(UIView.hiddenGuideItem(_:)), for: .touchUpInside)
        }
        
    }
    public func addGuideShadeToFullScreen(){
        //
        UIApplication.shared.keyWindow?.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat:"V:|-0-[self]-0-|",
                                                          options: [],
                                                          metrics: nil,
                                                          views: ["self":self])
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat:"H:|-0-[self]-0-|",
                                                          options: [],
                                                          metrics: nil,
                                                          views: ["self":self])
        superview?.addConstraints(vConstraints)
        superview?.addConstraints(hConstraints)
    }
    
    //嵌套函数，隐藏操作
    @objc func hiddenGuideItem(_ item:UIButton) {
        //
        print("隐藏操作。。。。")
        item.isHidden = true
        for view in self.subviews {
            //
            if view != item && view.isHidden {
                //
                self.isHidden = true
                self.removeFromSuperview()
            }
        }
    }
    
    
    //    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator:UIViewControllerTransitionCoordinator){
    //            super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    //            coordinator.animateAlongsideTransition({ (context: UIViewControllerTransitionCoordinatorContext!) -> Void in
    //                if (newCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact) {
    //                        //To Do: modify something for compact vertical size
    //
    //                } else {
    //                    //To Do: modify something for other vertical size
    //
    //                }
    //                    self.view.setNeedsLayout()
    //                }, completion: nil)
    //    }
    
}


let leftitem = UIBarButtonItem()
let button2 = UIButton()
let white = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 50))
white.backgroundColor = UIColor.black
class viewController: UIViewController {
    //
    var hideGuideItem:(UIButton)->() = {_ in }
    
    override func viewDidLoad() {
        //
        let viewShade = UIView()
        view.addSubview(viewShade)
        viewShade.addGuideShadeToFullScreen()
        
        viewShade.backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "beijing-thumb@3x.jpg"))
        let btn1 = UIButton()
        btn1.setImage( #imageLiteral(resourceName: "barcelona-thumb@3x.jpg"), for: .normal)
        viewShade.leftItem = btn1
        //        btn1.addTarget(self, action: #selector(viewController.hiddenItem(_:)), forControlEvents: .TouchDown)
        //        btn1.sizeToFit()
        
        let btn2 = UIButton()
        btn2.setImage(#imageLiteral(resourceName: "barcelona-thumb@3x.jpg"), for: .normal)
        viewShade.rightItem = btn2
        //        btn2.addTarget(self, action: #selector(viewController.hiddenItem(_:)), forControlEvents: .TouchDown)
        //        btn2.sizeToFit()
        setNavgationItem()
    }
    
    func hiddenItem(item:UIButton) {
        //
        hideGuideItem(item)
    }
    //使用VFL语法来布局控件
    
    //设置导航条
    func setNavgationItem(){
        leftitem.title = "left"
        leftitem.tintColor = UIColor.black
        //        leftitem.setBackgroundImage([#Image(imageLiteral: "barcelona-thumb@2x.jpg")#], forState: .Normal, barMetrics: .Compact)
        
        let rightitem = UIBarButtonItem.init(customView: white)
        rightitem.title = "right"
        rightitem.tintColor = UIColor.black
        
        self.navigationItem.titleView?.backgroundColor = UIColor.black
        //        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.setLeftBarButton(leftitem, animated: true)
        self.navigationItem.setRightBarButton(rightitem, animated: false)
    }
}



let nav = UINavigationController.init(rootViewController: viewController())
PlaygroundPage.current.liveView = nav

//: [Next](@next)

