+++
title = "iOS10+ 노티피케이션 정리"
date = 2018-06-15T15:10:28+09:00
lastmod = 2018-06-15T15:10:28+09:00
draft = false
keywords = ["ios", "notification", "swift4"]
description = ""
tags = []
categories = ["Development"]
author = "Brann Park"
comment = true
toc = false
contentCopyright = false
reward = false
mathjax = false
+++


# UserNotifications Framework

iOS10 부터는 UserNotifications 라는 새로운 사용자 노티피케이션 프레임워크가 제공된다.

사용자 노티피케이션.. 그렇다면 우리가 컴포넌트간 메시지를 보낼 때 쓰는 NotificationCenter 는 시스템 노티피케이션이(사용자에게 보여지는 UI가 없는 알림이니?)라고 하면 될까..? 아무튼.. 

UNUserNotificationCenterDelegate 프로토콜에는 다음과 같은 메서드들이 제공된다.

```swift
optional func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)

optional func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
```

`UNUserNotificationCenter.current()` 객체의 `delegate` 프로퍼티를 사용하여 위 프로토콜의 구현체를 지정할 수 있다.

노티피케이션을 받기 위해서는 당연히 우선적으로 노티피케이션을 받을 수 있는 권한을 사용자로부터 받아야 한다.

`UNUserNotificationCenter.requestAuthorization(options:completionHandler:)` 메서드를 사용하여 사용자에게 권한을 요청 하고, `UIApplication.shared.registerForRemoteNotifications()` 를 통해 APNS 등록을 진행하면 된다.

등록하고 토큰 받아내는 거야 뭐.. 자료가 많이 있으니 그다지 어려울 것은 없다.

# UserNotification did received!

자, 그럼 이제 이 글을 작성한 이유인, 앱이 푸시 알림을 받는 상황들에 대해서 알아보자. 

APN 페이로드의 내용에 따라 여러 시나리오 생긴다. 다음과 같은 네가지의 경우가 있다.

* A. alert, badge 및 sound 만 포함(B, C 의 옵션을 포함하지 않음을 의미)
* B. `content-available: 1` 포함.
* C. `mutable-content: 1` 포함.

## A.

### 1) 앱이 포그라운드 상태에 있다면,

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
```
메서드가 호출된다. completionHandler 를 호출하여 노티피케이션이 보이거나 보이지 않게 컨트롤 가능하다.

### 2) 앱이 백그라운드(프로세스가 생성되어 있지만 백그라운드 상태, 또는 프로세스가 종료된 상태)에 있다면,

아무런 메서드도 호출되지 않는다. 

### 3) 사용자에 의해 앱이 강제종료(Force-quit) 되었다면,

아무런 메서드도 호출되지 않는다.

1,2,3 모두의 경우에 대해, 사용자가 알림센터에서 노티피케이션을 탭하게 되면, 

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
```

메서드가 호출된다. 

## B. content-available == 1 

Slient Push Notification 의 동작이다. 이때 앱 프로세스는 **사용자에 의한 강제종료 상태**가 아니어야만 하며, 백그라운드 모드에서의 코드 실행시간은 30초 정도로 제한된다. 이 기능이 동작되게 하기 위해선 간단한 작업이 필요하다.

1. XCode iOS 프로젝트 타겟에서 Capabilities 항목내의 BackgroundModes 를 ON 으로 활성화. Remote Notifications 항목을 체크.
2. APNS 로 푸시 패킷을 만들어 보낼 때 apn 항목 안에 content-available 이라는 키를 1 이라는 값으로 추가해준다.

```json
{
                "aps": {
                                "content-available":1,
                                ...
                },
                ...

}
```

[자세한 설정 참고](https://medium.com/@m.imadali10/ios-silent-push-notifications-84009d57794c)


### 1) 앱이 포그라운드 상태에 있다면,

```swift
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
```
 
위 메서드가 호출된다. completionHandler 를 호출하여 노티피케이션이 보이거나 보이지 않게 컨트롤 가능하다.

### 2) 앱이 백그라운드(프로세스가 생성되어 있지만 백그라운드 상태, 또는 프로세스가 자동 종료된 상태)에 있다면,

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
```

위의 메서드가 실행된다. 메서드 구현 시 무언가 처리를 하고 마지막에 completionHandler 를 적절한 값(UIBackgroundFetchResult)을 인자로 하여 호출해주면 된다.



## C. mutable-content == 1

이 속성은 말 그대로, 푸시알림을 기기가 수신할 때(화면에 보이기 이전에) 푸시노티의 내용을 변경하고, 변경된 내용에 따라 노티피케이션이 화면에 보이도록 하는데에 쓰인다. content-available 과 마찬가지로, APNS 로 보내는 푸시 패킷 내의 "aps" 항목에 추가하면 되는데

```json
{
                "aps": {
                                "mutable-content":1,
                                "alert": {
                                                "title": "Title",
                                                "body": "Body..."
                                },
                                "sound": "default",
                },
                ...

}
```
alert 항목이 필수로 있어야 한다. 이 항목이 없다면 시스템이 mutable 하지 않은 알림으로 처리해버린다. 

단순히 이렇게 패킷을 구성하기만 해서는 바로 뭐가 되는건 아니다. 프로젝트에 UNNotificationServiceExtension 타겟을 추가하여야 하는데, 이 과정이 꽤나 번거롭다. 

단계를 정리하자면..

1. 프로젝트에 Notification Service Extension 타겟을 추가.
2. [Apple Developer console](https://developer.apple.com/account/ios/identifier/bundle) 에서 타겟 생성시 지정한 번들ID 를 가지는 App ID 를 신규 생성.
3. 기존의 앱과 묶어주기 위해 AppGroup 을 신규 생성.
4. 기존의 App 과, Notification Service Extension App 의 설정에서 AppGroup 기능을 활성화 시키고 신규 생성한 AppGroup 에 두개의 App 이 속하도록 지정.
5. Notification Service Extension App 의 프로비저닝 프로파일을 신규 생성하고 Xcode 의 Notification Service Extension App 타겟에 적용.
6. 기존 App 의 프로비저닝 프로파일을 다시 생성해서(기존것은 invalid 상태가 됨) Xcode 에 업데이트.


왜 이렇게 번거로운 짓을 하느냐...
두가지 목적이 있을거라고 생각하는데... 

**하나** 는 iOS10 부터 지원되는 Rich Notification 때문이다. 
이게 뭐냐면.. 알림에 이미지나 동영상을 첨부할 수 있게 하는건데, 푸시를 통해서 이미지나 동영상의 URL 을 보내면
푸시를 수신했을때(아직 화면에 보인게 아님) 백그라운드에서 이미지와 동영상을 파일로 다운로드하고, 이 다운로드된 파일의 URL을 Notification 에 첨부한 후에, 노티피케이션이 사용자에게 보이도록 하는거다. 노티피케이션의 내용이 변경이 되므로 (첨부파일이 생겨서..) 그래서 mutant-content 라 하는거였다. 이 값이 패킷에 포함되어있다면, 일반 노티가 아닌 NotificationServiceExtension 에서 처리되도록 하라(있다면)는 얘기고, 이는 기존 앱 프로세스가 아닌 이 NotificationServiceExtension 프로세스에서 처리되는 것이다. 그래서 별도 타겟에 별도 AppId 에 별도 프로비져닝 프로파일까지  복잡하게 구성하는 것이었다.

**두번쨰** 는 content-available 의 한계점 때문이다. 
푸시 수신 시 Background Mode 로 무언갈 할 수 있는건 좋은데... 앱이 **사용자에 의한 강제종료 상태**가 아니어야만 한다는 골때리는 제약사항이 있다. 그러나 앱이 강종되었더라도 NotificationServiceExtension 은 실행이 된다. 우와!! 하긴 이르지.. 그러나 이 경우에도 단점은 있다. 사용자에게 푸시 노티를 안보이게 할 수는 없다는것... 따라서, 알림을 사용자에게 보이면서 무언가를 백그라운드에서 처리하고자 할 때 유용하다고 할 수 있겠다.


# Notification Service Extension? Notification Content Extension?

위에서 잠깐 설명했지만, Notification Service Extension 은 mutable-content 를 가진 노티피케이션을 사용자에게 보이기 이전에 무언가 코드를 실행하고 이후에 변경된 노티피케이션을 보여주기 위하여 사용된다.

그렇다면 Notification Content Extension 은? 이는, 알림의 UI 를 커스터마이징하기 위해 쓰인다. 
이 내용에 대해선 다음의 링크를 참고하자.

[여기](http://rhammer.tistory.com/tag/%ED%91%B8%EC%89%AC)
