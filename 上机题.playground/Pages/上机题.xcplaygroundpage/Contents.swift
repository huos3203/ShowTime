//: Playground - noun: a place where people can play

import UIKit
import Foundation
//某时刻正在运行任务的个数

///
/**
 given n tasks that start and end at time: n < 1000
 [start1,end1),[start2,end2),...,[startn,endn) of which all starting times are inclusive and all ending times are exclusive .
 write code to efficiently return the number of tasks that are running at given times m>100000
 query1,query2,...,querym

 开启n段任务区间，一个任务区间即是包含开始，不包含end。
 现在有一个query任务组，需要在以上n个任务中执行。求出在开启的任务中能完成的几个query任务，并返回。
 */

/// []]
func numberOfTasksRunning()
{
    let start = [0,5,2]
    let end = [4,7,8]
    let query = [1,9,4,3]
    var number_of_tasks_running = [0,0,0,0]
    number_of_tasks_runningq(numberOfTasksRunning: &number_of_tasks_running, start: start, end: end, n: start.count, query: query, m: query.count)
    print("[")
    for i in 0..<query.count {
        if 0 < i {
            print(",")
        }
        print(number_of_tasks_running[i])
    }
    print("]")
}

func number_of_tasks_runningq(numberOfTasksRunning:inout [Int],start:[Int] ,end:[Int],n:Int,query:[Int],m:Int)
{
    for i in 0..<query.count {
        var count = 0
        for j in 0..<start.count {
            if query[i]>start[j] && query[i] < end[j] {
                count = count + 1
                print(query[i])
            }
        }
        numberOfTasksRunning[i] = count
    }
}
numberOfTasksRunning()


