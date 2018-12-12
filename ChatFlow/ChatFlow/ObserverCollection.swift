// Copyright © 2017 Tellus, Inc. All rights reserved.

/// - Note: Not thread-safe, all methods must only be called from the main queue.
///   For most UI classes it's fine to call `removeAll()` from `deinit` (as almost always the last reference will be from the main queue).
final class ObserverCollection {
    private var notificationObservers: [NSObjectProtocol] = []
    private var keyValueObservations: [NSKeyValueObservation] = []
    private var blocksKitKVOObservers: [(NSObject, String)] = []
    private var keyboardObservers: [KeyboardObserver] = []

    var isEmpty: Bool {
        return notificationObservers.isEmpty && keyValueObservations.isEmpty && blocksKitKVOObservers.isEmpty && keyboardObservers.isEmpty
    }

    // MARK: Adding
    func addObserver(forName name: NSNotification.Name?, object: Any? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> Void) {
        notificationObservers += NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: handler)
    }

//    func addKVOObserver<T : NSObject>(on object: T, for properties: Set<String>, initialUpdate: Bool, handler: @escaping (T) -> Void) {
//        let identifier = object.bk_addObserver(forKeyPaths: Array(properties)) { _,_ in handler(object) }!
//        blocksKitKVOObservers += (object, identifier)
//        if initialUpdate { handler(object) }
//    }

    func add(_ observation: NSKeyValueObservation) {
        keyValueObservations += observation
    }

    @discardableResult func addKeyboardObserver(handler: @escaping KeyboardObserver.KeyboardChangeFrameType, animated: Bool = true, onChangePosition: KeyboardObserver.KeyboardChangePositionType? = nil) -> KeyboardObserver {
        var lastFrame: CGRect?
        let keyboardObserver = KeyboardObserver()
        keyboardObserver.onKeyboardWillChange = { lastFrame = $0 }
        keyboardObserver.onChangePosition = onChangePosition
        keyboardObserver.animationBlock = {
            guard let lastFrame = lastFrame else { return }
            if animated {
                handler(lastFrame)
            } else {
                UIView.performWithoutAnimation { handler(lastFrame) }
            }
        }
        keyboardObservers += keyboardObserver
        return keyboardObserver
    }

    func removeAll() {
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers = []
        keyValueObservations.forEach { $0.invalidate() }
        keyValueObservations = []
//        blocksKitKVOObservers.forEach { object, identifier in object.bk_removeObservers(withIdentifier: identifier) }
        blocksKitKVOObservers = []
        keyboardObservers = []
    }
}

func += (lhs: ObserverCollection, rhs: NSKeyValueObservation) { lhs.add(rhs) }
