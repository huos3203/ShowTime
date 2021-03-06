//: Playground - noun: a place where people can play

import UIKit

//在Swift类型（类和结构体）的构造过程中常量(let)属性是可修改的，枚举的构造器很少见（可暂时忽略）

//结构体中构造器的特征：

//: 值类型的构造器重载（在没有自定义构造器时，系统会默认提供两个构造器：一个无参构造器，一个所有存储属性形参的构造器），
//引出构造器代理:
//  对于值类型，swift允许使用self.init(实参)在自定义构造器中调用其他重载的构造器，而且只能在构造器内部调用self.init(实参)
//使用self.init(实参)执行构造器代理时，在执行self.init(实参)代码之前，程序不允许对任何实例属性赋值，不允许访问任何实例属性的值，不允许使用self.而且一个构造器中最多只能有一行self.init(实参)


//类中构造器的特征
//构造器：一个类中至少有一指定构造器和0-若干个便利构造器（convenience关键字修饰）
//作用：初始化从父类继承得到的属性，和本类定义的实例存储属性。
//便利构造器只有类才有的特性，结构体和枚举不支持。

//构造器链（两段式构造）
//构造器的重载：使用便利构造器重载指定构造器
//指定构造器必须向上代理（调用父类构造器），便利构造器必须横向代理（调用当前类的其他构造器）

//两段式构造：三次次安全检查
//安全检查1. 指定构造器必须先初始化当前类中的实例存储属性，然后才能向上调用父类的构造器。
//安全检查2. 指定构造器必须先向上抵用父类构造器，然后才能初始化继承得到的属性。
//安全检查3. 便利构造器必须先调用同一个类中其他构造器，然后才能对属性赋值。
//安全检查4. 构造器在第一阶段完成之前，不能调用实例方法，不能读取实例属性。

//第一阶段
//: 调用某个构造器，为实例分配内存，此时实例的内存还没有被初始化
//: 指定构造器，确保子类定义的实例存储属性都已被赋值。
//: 然后，指定构造器会调用父类的构造器，完成父类定义的实例存储属性的初始化。
//: 沿着构造链初始化直到最顶层，确保各个父类的指定构造器完成各自定义的实例存储属性

//第二阶段
//: 沿着继承树向下，此时构造链中的指定构造器都有机会进一步定制实例，构造器此时可以修改实例的属性，访问self,甚至可以调用实例的方法。
//: 最后，构造链中的便利构造器都有机会定制实例和使用 self.
