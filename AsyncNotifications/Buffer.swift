//
//  Buffer.swift
//  AsyncNotifications
//
//  Created by John Connolly on 2021-04-04.
//

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
