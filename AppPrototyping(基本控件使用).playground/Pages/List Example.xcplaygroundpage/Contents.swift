//: [Previous](@previous)

//: AppPrototyping - a place to prototype the look and feel of your app.
//:  Created by Tim Bellay on 12/6/15.
//:  Copyright © 2015 Tim Bellay. All rights reserved.

import UIKit
import PlaygroundSupport

let device = Device.iPhone5s
let appearance = Appearance(theme: .Custom, textColor: .yellow, labelColor: .purple)
let screen = Screen(device: device, type: .list, appearance: appearance)
PlaygroundPage.current.liveView = screen.view
//XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//outlineViews(screen.views, outlineColor: .blueColor())


//: [Next](@next)

