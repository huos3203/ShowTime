// Playground - noun: a place where people can play

import UIKit

typealias KVObserver = (_ kvo: KeyValueObserver, _ change: [NSObject : AnyObject]) -> Void

class KeyValueObserver {
    let source: NSObject
    let keyPath: String
    private let observer: KVObserver

    init(source: NSObject, keyPath: String, options: NSKeyValueObservingOptions, observer: @escaping KVObserver) {
        self.source = source
        self.keyPath = keyPath
        self.observer = observer
        source.addObserver(defaultKVODispatcher, forKeyPath: keyPath, options: options, context: self.pointer)
    }

    func __conversion() -> UnsafeMutablePointer<KeyValueObserver> {
        return pointer
    }

    private lazy var pointer: UnsafeMutablePointer<KeyValueObserver> = {
        return UnsafeMutablePointer<KeyValueObserver>(Unmanaged<KeyValueObserver>.passUnretained(self).toOpaque())
    }()

    private class func fromPointer(pointer: UnsafeMutablePointer<KeyValueObserver>) -> KeyValueObserver {
        return Unmanaged<KeyValueObserver>.fromOpaque(OpaquePointer(pointer)).takeUnretainedValue()
    }

    class func observe(pointer: UnsafeMutablePointer<KeyValueObserver>, change: [NSObject : AnyObject]) {
        let kvo = fromPointer(pointer: pointer)
        kvo.observer(kvo, change)
    }

    deinit {
        source.removeObserver(defaultKVODispatcher, forKeyPath: keyPath, context: self.pointer)
    }
}


class KVODispatcher : NSObject {
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        KeyValueObserver.observe(pointer: UnsafeMutablePointer<KeyValueObserver>(context), change: change)
    }
}

private let defaultKVODispatcher = KVODispatcher()



let button = UIButton()
KeyValueObserver(source: button, keyPath: "selected", options: .new) {
    (kvo, change) in
    NSLog("OBSERVE 1 %@ %@", kvo.keyPath, change)
}

button.isSelected = true
button.isSelected = false

var kvo: KeyValueObserver? = KeyValueObserver(source: button, keyPath: "selected", options: .new) {
    (kvo, change) in
    NSLog("OBSERVE 2 %@ %@", kvo.keyPath, change)
}

button.isSelected = true
button.isSelected = false
kvo = nil
button.isSelected = true

