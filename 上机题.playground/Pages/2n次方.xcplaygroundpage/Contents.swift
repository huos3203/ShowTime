var i = 1 << 17

//var value = 1<<Int(arc4random_uniform(5))  //2的0~4随机次方（包括0,4）
Int.max
Int.min
//区分nil/NSNull案例代码：
import Foundation
let mutableArray = NSMutableArray()
let null = NSNull()
mutableArray.add(null)

let mutableDictionary = NSMutableDictionary()
    //添加NSNull对象正常，因为它是一个有内存地址的对象，故添加到字典和数组都不会崩溃。
mutableDictionary.setObject(null, forKey: "null" as NSCopying)

    //数组和字典中存放的都是对象，对象都对应的地址，但是nil内存中没有地址
mutableArray.add(nil)
mutableDictionary.setObject(nil, forKey: "nil")






