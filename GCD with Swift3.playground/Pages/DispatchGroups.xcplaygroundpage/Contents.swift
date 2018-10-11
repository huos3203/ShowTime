//: [<< Working with DispatchQueues](DispatchQueues)

//:### Working with DispatchGroups

import UIKit
import Foundation
import PlaygroundSupport
PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

//在主线程上创建一个并行队列
let queue = DispatchQueue(label: "com.allaboutswift.dispatchgroup", attributes: .concurrent, target: .main)
//新建一个队列组，用来分组队列
let group = DispatchGroup()
//添加三个并行执行的任务
    //1
queue.async (group: group) {
    print("doing stuff")
}
    //2
queue.async (group: group) {
    print("doing more stuff")
}
    //3
queue.async (group: group) {
    print("doing a lot more stuff")
}

//并行队列中的任务完成后，向主线程添加任务
group.notify(queue: DispatchQueue.main) {
    print("done doing stuff")
}

//: alternate API approach

group.enter()
queue.async (group: group) {
    print("doing stuff again")
    group.leave()
}

group.enter()
queue.async (group: group) {
    print("doing more stuff again ")
    group.leave()
}

group.enter()
queue.async (group: group) {
    print("doing a lot more stuff again")
    group.leave()
}

group.notify(queue: DispatchQueue.main) {
    print("done doing stuff again")
}


//: [>> Working with Dispatch work items](DispatchWorkItems)
