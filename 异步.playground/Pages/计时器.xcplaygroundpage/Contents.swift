//: [Previous](@previous)

import Foundation

import UIKit
//import SISNotes  //Playgroud中使用个人项目中的类相关方法，需要借助于Custom Frameworks桥接
//  import OHHTTPStubs
//  import Alamofire

//延时执行的黑魔法
import PlaygroundSupport
//XCPSetExecutionShouldContinueIndefinitely(true)
PlaygroundPage.current.needsIndefiniteExecution = true


//扩展NSTimer方法，提高代码更高的可读性
/// 原文地址：http://radex.io/swift/nstimer/
let timer = Timer.every(4.second) {
    print("nihao")
}

Timer.after(8) {
    print("第六秒:\(NSDate())")
    timer.invalidate()
}






//: [Next](@next)
