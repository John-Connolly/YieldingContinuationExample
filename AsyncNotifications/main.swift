//
//  main.swift
//  AsyncNotifications
//
//  Created by John Connolly on 2021-04-01.

import Foundation
import _Concurrency
import Swift

final actor Buffered<Element> {
  let continuation = YieldingContinuation(yielding: Element.self)
  var buffer = [Element]()

  func push(_ element: Element) {
    if !continuation.yield(element) {
      buffer.append(element)
    }
  }

  func pop() async -> Element {
    if buffer.count > 0 {
      return buffer.removeFirst()
    }
    return await continuation.next()
  }
}


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

@asyncHandler
func main() {

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        NotificationCenter.default.post(name: .didReceiveData, object: nil, userInfo: ["hello":"world"])
    }
    let notifications = NotificationCenter.default.notifications(of: .didReceiveData)
    for await notiftication in notifications {
        print(notiftication)
    }
}

main()
RunLoop.main.run()

