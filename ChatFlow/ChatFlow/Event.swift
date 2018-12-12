// Copyright © 2017 Tellus, Inc. All rights reserved.

class Event<Arguments> : Equatable, AnyEvent {
    private(set) var observers: [Observer<Arguments>] = [] { didSet { handleObserversChanged() } }

    // MARK: General
    private func add(_ observer: Observer<Arguments>) {
        precondition(observer.event == nil, "Attempting to attach an observer that is already attached to an event.")
        assert(!observers.contains(observer))
        observers.append(observer)
        observer.event = self
    }

    fileprivate func remove(_ observer: Observer<Arguments>) {
        precondition(observer.event == self)
        observers = observers.filter { $0 != observer }
    }
    
    fileprivate func handleObserversChanged() { }

    static func == <T>(lhs: Event<T>, rhs: Event<T>) -> Bool { return lhs === rhs }
}

final class OwnedEvent<Arguments> : Event<Arguments> {
    var observersChangedHandler: (([Observer<Arguments>]) -> Void)?
    
    func raise(withArguments arguments: Arguments) {
        for observer in observers {
            guard observer.event == self else { continue } // Can happen if it was remove in the handler of an earlier observer
            observer.handler(arguments)
        }
    }
    
    override fileprivate func handleObserversChanged() {
        observersChangedHandler?(observers)
    }
}

extension OwnedEvent where Arguments == Void {
    func raise() { raise(withArguments: ()) }
}

// MARK: Any Event
protocol AnyEvent {
    func any_add(_ handler: @escaping () -> Void) -> AnyObserver
}

extension Event {
    func any_add(_ handler: @escaping () -> Void) -> AnyObserver {
        return add { _ in handler() }
    }
}

// MARK: Convenience
extension Event {
    func add(_ handler: @escaping (Arguments) -> Void) -> Observer<Arguments> {
        let observer = Observer(handler)
        add(observer)
        return observer
    }

    func onNextFiring(_ handler: @escaping (Arguments) -> Void) {
        weak var weakObserver: Observer<Arguments>?
        let observer = Observer<Arguments> { [weak self] arguments in
            if let event = self, let observer = weakObserver, observer.event == event { event.remove(observer) }
            handler(arguments)
        }
        weakObserver = observer
        add(observer)
    }
}

func += <T>(event: Event<T>, handler: @escaping Observer<T>.Handler) -> Observer<T> { return event.add(handler) }



// MARK: - Observer

final class Observer<Arguments> : AnyObserver, Equatable {
    fileprivate weak var event: Event<Arguments>?
    let handler: Handler

    typealias Handler = (Arguments) -> Void

    // MARK: Initialization
    fileprivate init(_ handler: @escaping Handler) {
        self.handler = handler
    }

    // MARK: General
    func remove() {
        event?.remove(self)
    }

    static func == <T>(lhs: Observer<T>, rhs: Observer<T>) -> Bool { return lhs === rhs }
}

protocol AnyObserver {
    func remove()
}
