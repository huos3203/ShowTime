
import Foundation
import UIKit
import PlaygroundSupport

class horizontalScrollViewController:UIViewController{
    
    let scrollView = HorizontalScroller()
    var images:[UIImage]?
    override func viewDidLoad() {
        //
        view.backgroundColor = UIColor.white
        scrollView.backgroundColor = UIColor.blue
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([scrollViewAddItemConstraint(.left),
                            scrollViewAddItemConstraint(.right),
                            scrollViewAddItemConstraint(.top,constant:65.0)])
        scrollView.addConstraint(scrollViewAddItemConstraint(.height,constant:300.0))
        images = [#imageLiteral(resourceName: "barcelona-thumb@3x.jpg"),#imageLiteral(resourceName: "beijing-thumb@3x.jpg"),#imageLiteral(resourceName: "london-thumb@3x.jpg"),#imageLiteral(resourceName: "walt-disney-world-thumb@3x.jpg"),#imageLiteral(resourceName: "sydney-thumb@3x.jpg"),#imageLiteral(resourceName: "walt-disney-world-thumb@3x.jpg")]
        scrollView.delegate = self
        scrollView.reload()
    }
}
//: 辅助方法
extension horizontalScrollViewController{
    //添加scrollView的自动布局约束条件
    func scrollViewAddItemConstraint(_ attr:NSLayoutAttribute,constant:CGFloat=0.0)->NSLayoutConstraint{
        let item = attr == .height ? nil : view
        return NSLayoutConstraint(item: scrollView, attribute: attr, relatedBy: .equal, toItem: item, attribute: attr, multiplier: 1.0, constant: constant)
    }
    
}
/*: 
 ### 实现轮播控件的四个代理方法
 1. 代理返回图片的个数
 2. 代理返回指定位置的图片对象
 4. 代理返回用于初始化的图片索引
 3. 代理点击图片的事件
 */
extension horizontalScrollViewController:HorizontalScrollerDelegate{
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int {
        return (images?.count)!
    }
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> UIView {
        let imageView = UIImageView(image: images![index])
        let view = UIView()
        view.addSubview(imageView)
        return view
    }
    
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
        print("点击图片....")
    }
    
    
    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return 1
    }
}

/**
 当有导航控制器时，由于scrollview默认偏移量是导航条的高度，此时make.centerY.equalTo(scrollView)会导致轮初始化轮播图默认位置偏下方，可以添加.offset(-65)
 更好的解决办法是：轮播图与scrollView父视图垂直居中对齐： make.centerY.equalTo(self)
 */
//XCPlaygroundPage.currentPage.liveView = horizontalScrollViewController()
let nav = UINavigationController.init(rootViewController: horizontalScrollViewController())
PlaygroundPage.current.liveView = nav

