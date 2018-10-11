
import Foundation
import PlaygroundSupport
//时间复杂度O(n)

//冒泡排序法的原理解析
//嵌套两个for循环
/**
 冒泡排序：经过多轮相邻两两比较交换，每次都把当前数组中最小的“冒”到最头上，然后把这个数排除在外，剩下的那些数字不断重复这个过程，最后形成一个有序的数列。
 内循环:负责相邻元素的比较，位置置换，把最小的数往上冒，即冒泡过程
 外循环: 经过了一个冒的过程，可以使一个最小的元素冒出来，外循环就是负责把那个数字排除在外，如果数组里面有 n 个元素，就得经历n-1 次冒泡操作。
 */
var arr = [14, 11, 20, 1, 3, 9, 4, 15, 6, 19,
           2, 8, 7, 17, 12, 5, 10, 13, 18, 16]
//: 冒泡排序：嵌套for循环  [可视化](swifter.tips/playground-capture)
func bubbleSort<T: Comparable>( input: inout [T]) {
    for i in (1 ... input.count).reversed() {
        var didSwap = false
        for j in 0 ..< i-1 {
            if input[j] > input[j + 1] {
                didSwap = true
                input.swapAt(j, j + 1)
            }
        }
        if !didSwap {
            break
        }
        //plot(title: "第 \(input.count - (i - 1)) 次迭代", array: input)
    }
    //plot(title: "结果", array: input)
}

//  bubbleSort(input: &arr)

func bubbleSort2(input:inout [Int]) {
    //1.负责循环冒泡操作，如果有N个数，就要冒泡n-1次
    for i in  0 ..< input.count {
        var didSwap = false
        for j in 0 ..< input.count - i - 1 {
            //当碰到j下标数字大于j+1下标的数字时，置换位置
            if input[j] > input[j + 1] {
                let tmpNum = input[j]
                input[j] = input[j+1]
                input[j+1] = tmpNum
                didSwap = true
//                  input.swapAt(j, j+1)
            }
        }
        if !didSwap {
            break
        }
    }
}
bubbleSort2(input: &arr)
