//: [Previous](@previous)

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

class senderNotification
{
    init(){
        print("发出广播...")
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BLDownloadImageNotification"), object: self)
    }
}

class getNotification {
    //
    init(){
        print("初始化接收广播....")
        NotificationCenter.default.addObserver(self, selector: "DownloadImage:", name: NSNotification.Name(rawValue: "BLDownloadImageNotification"), object: nil)
    }
    
    func DownloadImage(notification:NSNotification) {
        //
        print("成功接收广播...")
    }
}

senderNotification()
//senderNotification.setNotification()
getNotification()

//: [Next](@next)
