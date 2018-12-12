// Copyright © 2018 Tellus, Inc. All rights reserved.

final class KeyPathObserver : NSObject, AnyObserver {
    let keyPath: String
    let handler: Handler
    let object: AnyObject

    typealias Handler = (String?, [NSKeyValueChangeKey : Any]?) -> Void

    // MARK: Initialization
    fileprivate init(object: AnyObject, keyPath: String, _ handler: @escaping Handler) {
        self.keyPath = keyPath
        self.handler = handler
        self.object = object
        super.init()
        self.object.addObserver(self, forKeyPath: keyPath, options: [], context: nil)
    }

    // MARK: General
    func remove() {
        object.removeObserver(self, forKeyPath: keyPath)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == self.keyPath { handler(keyPath, change) }
    }
}

final class Observers: NSObject {
    private var observers: [NSObjectProtocol] = []
    private var keyPathObservers: [KeyPathObserver] = []

    deinit { removeAll() }

    func when(_ name: NSNotification.Name, object: Any? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> Void) {
        observers.append(NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: handler))
    }

    func observe(object: AnyObject, keyPath: String, handler: @escaping KeyPathObserver.Handler) {
        keyPathObservers.append(KeyPathObserver(object: object, keyPath: keyPath, handler))
    }

    func removeAll() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers = []
        keyPathObservers.forEach { $0.remove() }
        keyPathObservers = []
    }
}
