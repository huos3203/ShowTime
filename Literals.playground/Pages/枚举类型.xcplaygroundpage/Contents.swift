//: [Previous](@previous)

import Foundation

/*
    枚举值：即枚举中的成员实例
 枚举对象的两种定义方式：
    通过原始值：类似C，OC的枚举，通过原始值可以为每个枚举实例指定一个简单类型：(Int,Double,Float,Character,String)的值。
            1. 相关方法有init?(rawValue:)：获取枚举实例  2. rawValue：枚举原始值
    通过关联值：类似于枚举对象的属性值：例如一组行星的枚举组中的每个行星的重量，密度，自转周率等作为关联值，更好的描述枚举对象的属性。
             注意：即使枚举实例化时保存了关联值，为关联值指明了名称，但是也依然无法像访问元组成员一样访问枚举实例的关联值，
            必须先声明额外的变量或常量和枚举实例的关联值绑定后，才能访问。
 */

//enum枚举不仅能可以定义一组枚举成员，还可以为每个枚举成员定义一组关联值，swift并不要求各枚举成员具有相同的关联值。
//关联值类似于枚举对象的属性值：例如一组行星枚举，每个行星的重量，密度，自转周率等作为关联值，更好的描述枚举对象的属性。
//: 1. 枚举不能随意地创建实例，只能使用定义枚举时定义好的实例。
//: 2. 声明枚举变量：var day: weekday    初始化变量：day = weekday.sunday
//: 3. 原始值类型是Int时：swift可以根据已经指定的原始值的枚举来推断它前，后所有枚举的枚举值。
//:    原始值类型是String等其他类型：将无法推断，必须为每个枚举都指定原始值。
//: 枚举提供构造器和属性： 枚举值：即枚举实例，原始值：类似C，OC的枚举，
//    1. init?(rawValue:) 可失败构造器：作用传入原始值实例化对象的枚举对象，该构造器返回的是包含枚举值的可选类型。需要使用!进行强制解析
//        var mySeason = Season.(rawValue:"s")
//        if mySeason != nil
//            {
//                switch( mySeason!) //需要使用!进行强制解析
//                {
//                }
//            }
//    2. rawValue 属性: 枚举实例获取自身的原始值。

//: 枚举声明
enum CompassPoint:String{
    case East = "北方"
    case North
    case South
    case West
}
let zhixiang = CompassPoint.East

//: 枚举原始值
switch zhixiang
{
case .East:
    print("原始值：\(CompassPoint.East.rawValue)")
case .North:
    print("YES")
default:
    print("NO")
}

//: 关联值
enum Barcode
{
    case UPCA(Int,Int,Int,Int)
    case QRCode(String)
}

//: 枚举关联值的使用  
//即使枚举实例保存关联值时，已经为关联值指明了名称，但是也依然无法像访问元组成员一样访问枚举实例的关联值，
//必须先声明额外的变量或常量和枚举实例的关联值绑定后，才能访问。
let productBarcode = Barcode.UPCA(1, 2, 3, 4)
switch productBarcode
{
case .UPCA(let first, let second, let three,let four):
    print("\(first), \(second),\(three),\(four)")
case .QRCode(let qr):
    print("QRCode:\(qr)")
}

let productQRCode = Barcode.QRCode("dhikden")
switch productQRCode
{
case .QRCode(let qr):
    print("QRCode:\(qr)")
default:
    print("NO")
}

//: 递归枚举
//: 算术表达式的一个重要特性是，表达式可以嵌套使用。例如，表达式(5 + 4) * 2，乘号右边是一个数字，左边则是另一个表达式。因为数据是嵌套的，因而用来存储数据的枚举类型也需要支持这种嵌套——这意味着枚举类型需要支持递归

enum ArithmeticExpression
{
    case Number(Int)
    indirect case Addition(ArithmeticExpression,ArithmeticExpression)
    indirect case multiplication(ArithmeticExpression,ArithmeticExpression)
}

//:上面定义的枚举类型可以存储三种算术表达式：纯数字、两个表达式相加、两个表达式相乘。枚举成员Addition和Multiplication的关联值也是算术表达式——这些关联值使得嵌套表达式成为可能

func evaluate(expression:ArithmeticExpression)->Int
{
    switch expression
    {
    case .Number(let expression):
        return expression
    case .Addition(let left, let right):
        return evaluate(expression: left)  + evaluate(expression: right)
    case .multiplication(let left , let right):
        return evaluate(expression: left) * evaluate(expression: right)
    }
}
//该函数如果遇到纯数字，就直接返回该数字的值。如果遇到的是加法或乘法运算，则分别计算左边表达式和右边表达式的值，然后相加或相乘。

//5
let five = ArithmeticExpression.Number(5)
//4
let four = ArithmeticExpression.Number(4)
//5+4
let addition = ArithmeticExpression.Addition(five, four)
//(5+4)*2
let multiplication = ArithmeticExpression.multiplication(addition, ArithmeticExpression.Number(2))

evaluate(expression: multiplication)

































//: [Next](@next)
