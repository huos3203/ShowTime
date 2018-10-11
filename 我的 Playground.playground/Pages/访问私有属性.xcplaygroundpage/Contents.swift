import Foundation

//: 时执行的黑魔法

import PlaygroundSupport
//XCPSetExecutionShouldContinueIndefinitely(true)
PlaygroundPage.current.needsIndefiniteExecution = true
//用户类
class User: NSObject{
    @objc private var name:String = ""  //姓名
    @objc var nickname:String?  //昵称
    @objc var age:Int = 0  //年龄
    @objc var emails:[String]?  //邮件地址
}

//创建一个User实例对象
let user1 = User()
user1.setValue("asdf", forKey: "name")
//user1.name = "hangge"
user1.age = 1001
user1.emails = ["hangge@hangge.com","system@hangge.com"]

//使用KVC取值
let name = user1.value(forKey: "name")
let nickname = user1.value(forKey: "nickname")
let age = user1.value(forKey: "age")
let emails = user1.value(forKey: "emails")
//let tel = user1.valueForKey("tel")
print(name, nickname, age, emails)
