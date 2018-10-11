import Foundation
import QuartzCore
import XCPlayground

let randomArraySize = 20
let randoms = (0..<randomArraySize).map { _ in Int(arc4random()) }
randoms

// Profiling
func printTimeElapsedWhenRunningCode(title:String, operation:()->()) {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    print("Time elapsed for \(title): \(timeElapsed) s")
}

printTimeElapsedWhenRunningCode(title: "map()") {
    let resultArray1 = randoms.map { pow(sin(CGFloat($0)), 10.0) }
}

func timeElapsedInSecondsWhenRunningCode(operation:()->()) -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()
    operation()
    let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
    return Double(timeElapsed)
}

timeElapsedInSecondsWhenRunningCode {
    let resultArray1 = randoms.map { pow(sin(CGFloat($0)), 10.0) }
}

// Playground visualization

func plotArrayInPlayground<T>(arrayToPlot:Array<T>, title:String) {
    for currentValue in arrayToPlot {
        XCPCaptureValue(identifier: title, value: currentValue)
    }
}

let testArray = (0..<10).map {$0 * $0}
plotArrayInPlayground(arrayToPlot: testArray, title: "Test graph")
