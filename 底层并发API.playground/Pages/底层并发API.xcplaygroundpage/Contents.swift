//1.开源的GCD
//2. 了解深层次的软件堆栈工作原理
//3. 原子操作  
//swift3d
import Foundation
//延时执行的黑魔法
import PlaygroundSupport
//XCPSetExecutionShouldContinueIndefinitely(true)
PlaygroundPage.current.needsIndefiniteExecution = true
func asy() {
    print(Thread.current)
    let queue = DispatchQueue.init(label: "nam", qos: .background)
    queue.async {
        print(Thread.current.isMainThread)
        for i in 1 ... 10 {
            print("@",i)
        }
    }
print(Thread.current.isMainThread)
    DispatchQueue.main.async {
        for i in 1 ... 10 {
            print("q",i)
        }
    }
}
asy()
//答案是死锁了
//主线程是串行的, 上个任务执行完成才会继续下个任务, `simpleQueues()`整个方法相当于mainQueue的一个任务(任务A), 现在它里面加了个sync的{任务A1}, 意味着任务A1只有等任务A完成才能开始, 但是要完成任务A的话就必须先完成任务A1, 然后A又在等A1,然后就傻逼了, 逻辑好绕吧????....

