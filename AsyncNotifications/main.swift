//
//  main.swift
//  AsyncNotifications
//
//  Created by John Connolly on 2021-04-01.

import Foundation
import _Concurrency
import Swift

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


