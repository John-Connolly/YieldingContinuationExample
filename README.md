# Example code to represent NSNotifications as async sequences

#### based on https://forums.swift.org/t/concurrency-yieldingcontinuation/47126


```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      NotificationCenter.default.post(name: .didReceiveData, object: nil, userInfo: ["hello":"world"])
}
let notifications = NotificationCenter.default.notifications(of: .didReceiveData)
for await notiftication in notifications {
    print(notiftication)
}

``` 
