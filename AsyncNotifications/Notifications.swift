//
//  Notifications.swift
//  AsyncNotifications
//
//  Created by John Connolly on 2021-04-04.
//

import Foundation
import _Concurrency
import Swift

extension NotificationCenter {
    func notifications(of name: Notification.Name, on object: AnyObject? = nil) -> Notifications {
        return Notifications(name: name, object: object, center: self)
    }
    
    struct Notifications: AsyncSequence {
        let name: Notification.Name
        let object: AnyObject?
        let center: NotificationCenter
        
        typealias Element = Notification
        func makeAsyncIterator() -> Iterator {
            Iterator(center: center, name: name, object: object)
        }
        
        actor Iterator : AsyncIteratorProtocol {
            let name: Notification.Name
            let object: AnyObject?
            let center: NotificationCenter
            
            init(center: NotificationCenter, name: Notification.Name, object: AnyObject? = nil) {
                self.name = name
                self.object = object
                self.center = center
            }
            
            let continuation = YieldingContinuation<Notification, Never>()
            var observationToken: Any?
            func next() async -> Notification? {
                observationToken = center.addObserver(forName: name, object: object, queue: nil) { [continuation] in
                    // NotificationCenter's behavior is to drop if nothing is registered to receive, so ignore the return value. Other implementations may choose to provide a buffer.
                    let _ = continuation.yield($0)
                }
                return await continuation.next()
            }
        }
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
}
