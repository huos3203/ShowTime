//: [Previous](@previous)

import UIKit
import PlaygroundSupport



let device = Device.iPhone5s
let frame = device.frame()
let appearance = Appearance(theme: .Dark, textColor: nil, labelColor: nil)
let statusbar = StatusBar(frame: device.frame(), appearance: appearance)
let navbar = NavigationBar(frame: frame, appearance: appearance, title: "Simple Table")

let cell1 = Cell(device: device, cellType: .Simple, appearance: appearance)
let cell2 = Cell(device: device, cellType: .Simple, appearance: appearance)
cell1.containerView?.view?.frame
cell1.containerView?.view?.frame = CGRect(x:0, y:0, width:frame.width,height: 100)
cell1.containerView?.view?.frame

var tableView = TableView(device: device, width: nil, height: device.frame().height - 64, cells: [cell1, cell2])

var containerView = UIView(frame: device.frame())
var sv = makeVerticalSV(view: containerView)
sv.addArrangedSubview(statusbar.view)
horizontalStrechToParentView(arr: statusbar.view)
sv.addArrangedSubview(navbar.containerView!.view!)
sv.addArrangedSubview(tableView.view)
tableView.view

PlaygroundPage.current.liveView = containerView
PlaygroundPage.current.needsIndefiniteExecution = true


outlineViews(views:[containerView], outlineColor: .darkGray)


//: [Next](@next)
