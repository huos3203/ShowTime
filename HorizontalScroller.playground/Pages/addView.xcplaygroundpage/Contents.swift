//: [Previous](@previous)

import UIKit
import PlaygroundSupport

/*:
 1. 设置子视图支持自动布局约束条件
 2. toItem对象指的是容器
 3. 添加自身约束时，toItem设置为nil
 */
class horizontalScrollViewController:UIViewController{
    
    let scrollView = UIScrollView()
    override func viewDidLoad() {
        //
        view.backgroundColor = UIColor.white
        scrollView.backgroundColor = UIColor.blue
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let layleft = NSLayoutConstraint.init(item: scrollView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let layright = NSLayoutConstraint.init(item: scrollView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let laytop = NSLayoutConstraint.init(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        view.addConstraints([layleft,layright,laytop])
        
        let layheight = NSLayoutConstraint.init(item: scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 100)
        scrollView.addConstraints([layheight])
    }
}
PlaygroundPage.current.liveView = horizontalScrollViewController()
//: [Next](@next)
