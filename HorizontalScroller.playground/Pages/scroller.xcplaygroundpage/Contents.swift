//: [Previous](@previous)

import Foundation
import UIKit
import PlaygroundSupport
//  import SnapKit

/*:
 [dddd](ddddddd)
 
 */
//: 学习自动布局的基础语法
class scroller:UIViewController{
    //添加五张图片，点击后方法，并居中
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        //
        addSubPageView()
    }
    func addSubPageView()->UIScrollView {
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = false
        view.addSubview(scrollView)
        //上下左右对齐
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        //3
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        view.backgroundColor = UIColor.yellow
        let tap = UITapGestureRecognizer.init(target:self, action:#selector(scroller.hander(_:)))
        scrollView.addGestureRecognizer(tap)
        
        let images = [#imageLiteral(resourceName: "barcelona-thumb@3x.jpg"),#imageLiteral(resourceName: "beijing-thumb@3x.jpg"),#imageLiteral(resourceName: "london-thumb@3x.jpg"),#imageLiteral(resourceName: "walt-disney-world-thumb@3x.jpg"),#imageLiteral(resourceName: "sydney-thumb@3x.jpg"),#imageLiteral(resourceName: "walt-disney-world-thumb@3x.jpg")]
        var preView:UIImageView!
        var tag = 0
        for image in images {
            let imageview = UIImageView(image: image)
            tag += 1
            imageview.tag = tag
            scrollView.addSubview(imageview)
            imageview.isUserInteractionEnabled = true
            imageview.translatesAutoresizingMaskIntoConstraints =  false
            imageview.sizeToFit()
            if (preView != nil) {
                //高度200，垂直居中，左边紧邻上一图片的右边
                let centerY = NSLayoutConstraint.init(item: preView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0)
                let layleft = NSLayoutConstraint.init(item: preView, attribute: .right, relatedBy: .equal, toItem: imageview, attribute: .left, multiplier: 1, constant: 0)
//                preView.addConstraint(layleft)
                let layheight = NSLayoutConstraint.init(item: preView, attribute: .height, relatedBy: .equal, toItem: imageview, attribute: .height, multiplier: 1, constant: 0)
                let laywidth = NSLayoutConstraint.init(item: preView, attribute: .width, relatedBy: .equal, toItem: imageview, attribute: .width, multiplier: 1, constant: 0)
                scrollView.addConstraints([centerY,layleft,layheight,laywidth])
                
                //                  imageview.snp_makeConstraints(closure: { (make) in
                //                      make.centerY.equalTo(preView)
                //                      make.left.equalTo(preView.snp_right)
                //                      make.height.width.equalTo(200)
                //                  })
            }else{
                //第一个ImageView的约束：高度200，垂直居中，左对齐scrollView容器
                let centerY = NSLayoutConstraint.init(item: imageview, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0)
                let layleft = NSLayoutConstraint.init(item: imageview, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 0)
                scrollView.addConstraints([centerY,layleft])
                let layright = NSLayoutConstraint.init(item: imageview, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0)
                self.view.addConstraint(layright)
                
                let layheight = NSLayoutConstraint.init(item: imageview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)
                imageview.addConstraint(layheight)
                
                //                  imageview.snp_makeConstraints(closure: { (make) in
                //                      make.centerY.equalTo(scrollView)
                //                      make.left.equalTo(scrollView)
                //                      make.height.width.equalTo(200)
                //                  })
            }
            
            preView = imageview
        }
        
        //循环结束之后，为最后一个ImageView添加right约束：右对齐srollView右侧
        let layright = NSLayoutConstraint.init(item: preView, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1, constant: 0)
        scrollView.addConstraint(layright)
        
        //          preView.snp_makeConstraints { (make) in
        //              make.right.equalTo(scrollView)
        //          }
        return scrollView
    }
    
    
    @objc func hander(_ TapGesture:UITapGestureRecognizer) {
        
        //获取ImageView
        let scrollView = TapGesture.view as! UIScrollView
        let tapPoint = TapGesture.location(in: scrollView)
        
        for imageView in scrollView.subviews{
            
            if imageView.frame.contains(tapPoint) {
                //
                //scrollview偏移量 ＝ 当前位置 + (屏幕width - 图片width)
                let x = imageView.frame.origin.x - view.frame.size.width/2 + imageView.frame.size.width/2
                scrollView.setContentOffset(CGPoint.init(x: x, y: 0), animated:true)
            }
            
        }
        
    }
    
    func centerCurrentViewbyTap(localPoint:CGPoint)->CGFloat  {
        //
        //二元方程式：求第N张图片，在ScrollView中心显示
        //1. 中心坐标xFinal = 偏移量 + 图片宽度/2 + 图片间距
        //2. 第N张 ＝ 中心坐标xFinal/(图片宽度 + 2 * 图片间距)
        //3. xFinal = 第N张 *
        let CenterX = scrollView.contentOffset.x + view.frame.size.width/2
        
        print("\(view.frame.size.width/2)|||||\(CenterX)-----\(localPoint.x) ===\(CenterX - localPoint.x)")
        let offset = scrollView.contentOffset.x - (CenterX - localPoint.x)
        
        //        if localPoint.x < CenterX {
        //            //向右移动
        //            offset = scrollView.contentOffset.x - CenterX - localPoint.x
        //        }else
        //        {
        //            //向左移动
        //            offset = scrollView.contentOffset.x + localPoint.x - CenterX
        //        }
        print("偏移量：\(offset)")
        return   offset
    }
    
    //滑动居中
    func centerCurrentViewByScroll(localPoint:CGPoint)->CGFloat  {
        //
        //二元方程式：求第N张图片，在ScrollView中心显示
        //1. 中心坐标xFinal = 偏移量 + 图片宽度/2 + 图片间距
        //2. 第N张 ＝ 中心坐标xFinal/(图片宽度 + 2 * 图片间距)
        //3. xFinal = 第N张 *
        var xFinal = scrollView.contentOffset.x + 100
        let viewIndex = xFinal / 200
        xFinal = viewIndex * 200
        return xFinal
    }
    
}
//: ### ddddddd
extension scroller:UIScrollViewDelegate{
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //
        print("完成偏移动画:\(scrollView.contentOffset.x)")
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //
        print("完成偏移动画1111:\(scrollView.contentOffset.x)")
    }
    
}

PlaygroundPage.current.liveView = scroller()

//: [Next](@next)
