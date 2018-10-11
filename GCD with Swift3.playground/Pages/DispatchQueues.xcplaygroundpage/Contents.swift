//:## GCD with Swift 3
import UIKit
import Foundation
//  import PlaygroundSupport
//  PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true
//:### Working with DispatchQueue


//: A simple serial Queue
//dispatchQueues：wift3版本中默认为.seral,swift4中省略了该参数
let serialQueue = DispatchQueue(label: "com.allaboutswift.gcd.serial")//, attributes: [.initiallyInactive], target: .global())

serialQueue.sync {
//      print(" serialQueue ... ")
    show("serialQueue ... ")
}

//: A concurrent Queue
let concurrentBackgroundQueue = DispatchQueue(label: "com.allaboutswift.gcd.concurrrent", attributes: [.concurrent,.init(rawValue: 8)], target: .global() )

concurrentBackgroundQueue.async {
    print(" concurrentBackgroundQueue .... ")
}


//: A delayed serialQueue
serialQueue.asyncAfter(deadline: .now() + 3.0) { 
    //
    print (" once more on serialQueue ")
}
//  serialQueue.after(when: .now() + .seconds(1)) {
//      print (" once more on serialQueue ")
//  }

//: A more elaborate delayed serialQueue with suspend and resume

serialQueue.suspend()

serialQueue.async {
    print (" a resumed serialQueue ")
}

DispatchQueue.global().asyncAfter(deadline: .now() + 2.0 ) { 
    serialQueue.resume()
}
//  after(when: .now() + .seconds(2)) {
//      serialQueue.resume()
//  }

//: Scheduling concurrent operations

DispatchQueue.concurrentPerform(iterations: 10) {
    print("\($0). concurrentPerform")
}

//:**[>> Working with DispatchGroups](DispatchGroups)**



