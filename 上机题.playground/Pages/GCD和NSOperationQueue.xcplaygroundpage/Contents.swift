//start 
/*:
 - Important:
 主线程用于界面更新和用户交互，任何耗时或者耗CPU的任务必须在concurrent queue或者background queue上运行.
 */
import Foundation
//
//异步串行，任务
//创建队列
//  let queue = DispatchQueue.init(label: "my.first.swiftqueue")
//创建任务
//同步串行
func gcd2(){
    let serialQueue = DispatchQueue.init(label: "my.queue")
    serialQueue.async {
        for i in 0 ..< 10{
            print("\(Thread.current.name)---",i)
        }
    }
    for i in 100 ..< 110 {
        print("+++",i)
    }
}
gcd2()




















//end

