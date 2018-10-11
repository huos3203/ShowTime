//: [Previous](@previous)

import Foundation

import UIKit
import PlaygroundSupport

class CoreAnimationViewController: UIViewController {
    
    //
    var animationLayer:CALayer!
    
    //UIView封装动画对象
    var animationImageView:UIImageView!
    
    override func viewDidLoad() {
        //
        view.backgroundColor = UIColor.white
        
        
        //UIViewAnimateWithDuration()
        //绘制图层动画的图层
        DrawAnimationLayer()
        
        //添加图片控件，演示UIView封装的关键帧动画
        addImageView()
    }
    
    //绘制图层动画的图层
    func DrawAnimationLayer() {
        
        //设置根layer背景图片 废弃：colorWithPatternImage
        view.layer.contents = UIImage.init(named: "background.jpg")?.cgImage
        
        //动画图层
        animationLayer = CALayer()
        animationLayer.position = CGPoint(x: 100,y: 100)
        animationLayer.bounds = CGRect.init(x: 0, y: 0, width: 10, height: 20)
        //        animationLayer.borderWidth = 1
        animationLayer.contents = UIImage.init(named: "petal")?.cgImage
        
        //添加到根Layer
        view.layer.addSublayer(animationLayer)
    }

    
    //添加图片控件，演示UIView封装动画
    func addImageView() {
        //设置根layer背景图片 废弃：colorWithPatternImage
        view.layer.contents = UIImage.init(named: "background.jpg")?.cgImage
        //
        animationImageView = UIImageView.init(image: UIImage(named:"petal"))
        animationImageView.center = CGPoint.init(x: 50, y: 150)
        view.addSubview(animationImageView)
    }
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //基础动画
        let touch = touches.first
        let location = touch?.location(in: view)
        
        //判断是否已经常见过动画，如果已经创建则不再创建动画
        let animation = animationLayer.animation(forKey: "KCBasicAnimation_Translation")
        if (animation != nil) {
            //
            if animationLayer.speed == 0 {
                //恢复
                animationResume()
            }else
            {
                //暂停
                animationPause()
            }
        }else{
            print("启动动画......")
            //启动基础动画
//            BasicAnimation(location!)
            
            //启动关键帧动画
//            translationAnimation()
            //旋转动画
//            rotationAnimation()
            
            //启动UIView封装的关键帧动画
            UIViewtranslationAnimation()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("....点击事件....")
        //UIView动画
        //        touchEventUIViewAnimation(touches.first!)
    }
}
PlaygroundPage.current.liveView = CoreAnimationViewController()


//UIView控件块代码动画：优点：实现简单，缺点：如何控制动画的暂停？如何进行动画的组合？
extension CoreAnimationViewController{

    func UIViewAnimateWithDuration() {
        //
        let imageView = UIImageView(image: UIImage(named: "photo.jpg"))
        imageView.frame = CGRect.init(x: 20, y: 20, width: 100, height: 100)
        
        view.addSubview(imageView)
    }
    
    func touchEventUIViewAnimation(touch:UITouch) {
        
        let location = touch.location(in:view)
        
        let imageView = view.subviews[0]
        
        //方法1：block方式 延迟2s开始动画，动画持续1s
        /*开始动画，UIView的动画方法执行完后动画会停留在重点位置，而不需要进行任何特殊处理
         duration:执行时间
         delay:延迟时间
         options:动画设置，例如自动恢复、匀速运动等
         completion:动画完成回调方法        
         */
        UIView.animate(withDuration:1, delay: 2, options: .beginFromCurrentState, animations: {
            imageView.center = location
            }, completion: nil)
        
        
        //嵌套函数,未使用
        func staticMethod() {
            //方法2：静态方法
            //开始动画
            UIView.beginAnimations("KCBasicAnimation", context: nil)
            UIView.setAnimationDuration(5.0)
            //[UIView setAnimationDelay:1.0];//设置延迟
            //[UIView setAnimationRepeatAutoreverses:NO];//是否回复
            //[UIView setAnimationRepeatCount:10];//重复次数
            //[UIView setAnimationStartDate:(NSDate *)];//设置动画开始运行的时间
            //[UIView setAnimationDelegate:self];//设置代理
            //[UIView setAnimationWillStartSelector:(SEL)];//设置动画开始运动的执行方法
            //[UIView setAnimationDidStopSelector:(SEL)];//设置动画运行结束后的执行方法
            
            imageView.center = location
            
            //开始动画
            UIView.commitAnimations()
        }
        
    }
}

//CABasicAnimation：基础动画，通过属性修改进行动画参数控制，只有初始状态和结束状态。
extension CoreAnimationViewController{
    
    /**
     *  @author shuguang, 16-05-07 12:05:02
     *
     *  动画创建一般分为以下几步：
         1.初始化动画并设置动画属性
         2.设置动画属性初始值（可以省略）、结束值以及其他动画属性
         3.给图层添加动画
     */
    func BasicAnimation(location:CGPoint) {
        print("点击的位置：\(location)")
        //
        let animation = CABasicAnimation.init(keyPath: "position")
    
        //设置初始值、结束值
//        animation.fromValue = NSNumber.init(integer: 50)
        animation.toValue = NSValue.init(cgPoint: location)
        
        //动画时长
        animation.duration = 2
//        animation.repeatCount = HUGE  //设置重复次数,HUGE_VALF可看做无穷大，起到循环动画的效果
        animation.isRemovedOnCompletion = false  //运行一次是否移除动画
        
        //解决：动画结束后动画图层回到了原来的位置，当然是用UIView封装的方法是没有这个问题的。
        //必须放在layer.addAnimation()方法之前添加delegate委托
        animation.delegate = self
        //存储当前位置在动画结束后使用
        animation.setValue(NSValue.init(cgPoint: location), forKey: "KCBasicAnimationLocation")
        
        //添加动画到图层,注意key相当于给动画进行命名，以后获得该动画时可以使用此名称获取
        let layer = view.layer.sublayers![0]
        layer.add(animation, forKey: "KCBasicAnimation_Translation")
    }
    
    //上面实现了一个基本动画效果，但是这个动画存在一个问题：动画结束后动画图层回到了原来的位置，当然是用UIView封装的方法是没有这个问题的。如何解决这个问题呢？
    
    //前面说过图层动画的本质就是将图层内部的内容转化为位图经硬件操作形成一种动画效果，其实图层本身并没有任何的变化。上面的动画中图层并没有因为动画效果而改变它的位置（对于缩放动画其大小也是不会改变的），所以动画完成之后图层还是在原来的显示位置没有任何变化，如果这个图层在一个UIView中你会发现在UIView移动过程中你要触发UIView的点击事件也只能点击原来的位置（即使它已经运动到了别的位置），因为它的位置从来没有变过。当然解决这个问题方法比较多，这里不妨在动画完成之后重新设置它的位置。
    
//    上面通过在animationDidStop中重新设置动画的位置主要为了说明隐式动画关闭和动画事件之间传参的内容，有朋友发现这种方式有可能在动画运行完之后出现从原点瞬间回到终点的过程，最早在调试的时候没有发现这个问题，这里感谢这位朋友。其实解决这个问题并不难，首先必须设置fromValue，其次在动画开始前设置动画position为终点位置（当然也必须关闭隐式动画）。但是这里主要还是出于学习的目的，真正开发的时候做平移动画直接使用隐式动画即可，没有必要那么麻烦。
  func animationDidStart(_ anim: CAAnimation) {
        //获取动画
        let layer = view.layer.sublayers![0]
        //通过前面的设置的key获得动画
        let animation = layer.animation(forKey:"KCBasicAnimation_Translation")
        print("animation:\(anim) | \(animation) start.\r layer.frame = \(NSStringFromCGRect(layer.frame))")
    }
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //
        let location = anim.valueForKey("KCBasicAnimationLocation")?.CGPointValue()
        let layer = view.layer.sublayers![0]
//        layer.position = location!
        
        print("animation:\(anim) Stop.\r layer.frame = \(NSStringFromCGRect(layer.frame))")
        
//如果运行上面的代码大家可能会发现另外一个问题，那就是动画运行完成后会重新从起始点运动到终点。这个问题产生的原因就是前面提到的，对于非根图层，设置图层的可动画属性（在动画结束后重新设置了position，而position是可动画属性）会产生动画效果。

//解决这个问题有两种办法：1关闭图层隐式动画、2设置动画图层为根图层。显然这里不能采取后者，因为根图层当前已经作为动画的背景。
//要关闭隐式动画需要用到动画事务CATransaction，在事务内将隐式动画关闭，例如上面的代码可以改为：
        //开启事务
        CATransaction.begin()
        //禁用隐式动画
        CATransaction.setDisableActions(true)
        
        layer.position = location!
        //提交事务
        CATransaction.commit()
        
        //暂停动画
        animationPause()
    }
}


//CAKeyframeAnimation关键帧动画

//关键帧动画开发分为两种形式：一种是通过设置不同的属性值进行关键帧控制，另一种是通过绘制路径进行关键帧控制。后者优先级高于前者，如果设置了路径则属性值就不再起作用。
extension CoreAnimationViewController{

    //关键帧动画
    func translationAnimation(){
        //1.创建关键帧动画并设置动画属性
        let keyframeAnimation = CAKeyframeAnimation.init(keyPath: "position")

//------通过设置不同的属性值进行关键帧控制--------
        //2.设置关键帧,这里有四个关键帧
//        let key1 = NSValue.init(CGPoint:CGPointMake(80, 220))
//        let key2 = NSValue.init(CGPoint:CGPointMake(45, 300))
//        let key3 = NSValue.init(CGPoint:CGPointMake(55, 400))
//        keyframeAnimation.values = [key1,key2,key3]
//--------------end
        
//------通过绘制路径进行关键帧控制--------
         /// UIBezierPath对象是CGPathRef数据类型的封装。path如果是基于矢量形状的，都用直线和曲线段去创建。使用此类可以定义简单的形状，如椭圆或者矩形，或者有多个直线和曲线段组成的形状。
        //let keyBezierPath = UIBezierPath()
        
        let keyPath = CGMutablePath()
        //移动到起始点
        CGPathMoveToPoint(keyPath, nil, animationLayer.position.x, animationLayer.position.y)
        //绘制二次贝塞尔曲线
        CGPathAddCurveToPoint(keyPath, nil, 160, 280, -30, 300, 55, 400)
        ///设置path属性
        keyframeAnimation.path = keyPath
//--------------end
        
        //设置其他属性
        keyframeAnimation.duration = 8
        keyframeAnimation.beginTime = CACurrentMediaTime() + 2 ////设置延迟2秒执行
        
        //添加到图层
        animationLayer.add(keyframeAnimation, forKey: "KCKeyframeAnimation_Position")
    }
    
    
    //旋转动画
    func rotationAnimation() {
        //
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        //        animation.fromValue = NSNumber.init(double: M_PI_2)
        animation.toValue = NSNumber.init(value: M_PI_2 * 3)
        
        //
        animation.duration = 2
        animation.autoreverses = true //旋转后再旋转到原来的位置
        
        animationLayer.add(animation, forKey: "KCBasicAnimation_Rotation")
    }
    
    //旋转动画暂停，恢复
    func animationPause() {
        //取得指定图层动画的媒体时间，后面参数用于指定子图层，这里不需要
        let interval = animationLayer.convertTime(CACurrentMediaTime(), to: nil)
        //设置时间偏移量，保证暂停时停留在旋转的位置
        animationLayer.timeOffset = interval
        //速度设置为0，暂停动画
        animationLayer.speed = 0
    }
    
    //恢复动画
    func animationResume(){
        //获得暂停的时间
        let beginTime = CACurrentMediaTime() - animationLayer.timeOffset
        //设置开始时间
        animationLayer.beginTime = beginTime
        //设置偏移量
        animationLayer.timeOffset = 0
        //设置动画速度，开始运动
        animationLayer.speed = 1
    }
}


//UIView封装的关键帧动画：从iOS7开始UIView动画中封装了关键帧动画，这里实现前面关键帧动画部分对于落花的控制。
extension CoreAnimationViewController{
    
    func UIViewtranslationAnimation() {
        
        print(" UIView封装的关键帧动画 .....")
        //UIViewAnimationOptionCurveLinear
        UIView.animateKeyframes(withDuration:5, delay: 0, options: UIViewKeyframeAnimationOptions(), animations: {
            ////第二个关键帧（准确的说第一个关键帧是开始位置）:从0秒开始持续50%的时间，也就是5.0*0.5=2.5秒
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                self.animationImageView.center = CGPoint.init(x: 80, y: 220)
            })
            //第三个关键帧，从0.5*5.0秒开始，持续5.0*0.25=1.25秒
            UIView.addKeyframe(withRelativeStartTime:0.5, relativeDuration: 0.25, animations: {
                //
                self.animationImageView.center = CGPoint.init(x: 45, y: 300)
            })
            //第四个关键帧：从0.75*5.0秒开始，持所需5.0*0.25=1.25秒
            UIView.addKeyframe(withRelativeStartTime:0.75, relativeDuration: 0.25, animations: {
                //
                self.animationImageView.center = CGPoint.init(x: 55, y: 400)
            })
            
            }, completion: nil)
        
    }

}

//动画组:是一系列动画的组合，凡是添加到动画组中的动画都受控于动画组，这样一来各类动画公共的行为就可以统一进行控制而不必单独设置，而且放到动画组中的各个动画可以并发执行，共同构建出复杂的动画效果。
//首先单独创建单个动画（可以是基础动画也可以是关键帧动画），然后将基础动画添加到动画组，最后将动画组添加到图层即可。
extension CoreAnimationViewController{
    
    func groupAnimation()  {
        //
        let animationGroup = CAAnimationGroup()
        let basicAnimation = rotationAnimation()
        let keyPathAnimation = translationAnimation()
//        animationGroup.animations = [basicAnimation,keyPathAnimation]
        //添加动画组
        animationLayer.add(animationGroup, forKey: nil)
        
    }
}



//: [Next](@next)
