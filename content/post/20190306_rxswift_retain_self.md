+++
title = "RxSwift retain self"
date = 2019-03-06T13:35:23+09:00
lastmod = 2019-03-06T13:35:23+09:00
draft = false
keywords = ["ios", "rxswft"]
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

RxSwift 를 사용하면서 self retain 에 대해 몇가지 정리해보고자 한다.

# RxSwift

다음과 같은 코드를 살펴보자.

```swift
class TestViewController : UIViewController {
	private let disposeBag = DisposeBag()
	
	func viewDidLoad() {
		super.viewDidLoad()
		
		Observable.just(0)
			.delay(5, scheduler: MainScheduler.asyncInstance)
			.subscribe(onNext: { value in
				self.test(value)
			}, onDisposed: { 
			self.test()
		})
		.disposed(by: disposeBag)
	}

	func test(_ value: Int = -1) {
		print(value)
	}
}
```

TestViewController 화면이 로드가 되면, 5초의 딜레이 후에 0 이라는 value 를 내뱉는 Observable 을 정의하고, subscribe 해두었다. 

이 subscription 의 dispose 는 disposeBag 이 소멸될 때 자동으로 dispose 되도록 disposed(by: disposeBag) 을 지정해두었다. 

이 disposeBag 이라는 프로퍼티는 let 선언이 되어있으며, 컨트롤러 객체가 소멸될 때 함꼐 소멸되도록 되어있다. (var 로 선언해두고, 적절한 lifecycle 에 disposeBag = DisposeBag() 으로 사용할 수도 있으나, 여기서는 다루지 않도록 한다.)

그리고 subscribe 에서는 onNext 와 onDisposed 파라미터에 클로저를 선언해두었다. 
클로저는 모두 컨트롤러내의 test 라는 메서드를 호출하도록 되어있다. 

그렇다면, 이 화면에 Push ViewController 등으로 진입하자 마자, Back 키를 통해 화면을 나가버리면 어떻게 될까? 

onNext 와 onDisposed 의 클로저에서 self 를 사용하고 있는 부분에 유의하자. 
그렇다 그러므로, 이 코드에 의해서 컨트롤러 객체의 retain count 가 +2 될 것이다.

그렇다는 말인 즉, 화면을 Back 해서 빠져나갔다고 하더라도, 컨트롤러 객체는 메모리해제가 되질 않는다. (deinit 이 호출되지 않는다.) 

그러므로 disposeBag 프로퍼티 객체도 역시 메모리 해제 되지 않는다. 그러므로 Subscription 역시도 구독해제 되지 않는다. 

따라서 5초가 지난 후, onNext 클로저가 먼저 실행되고(ref count -1), 더이상 emit 되는 데이터가 없으므로, 자동으로 dispose 되어 onDisposed 클로저가 실행된다(ref count -1). 

이렇게 된 이후에야, 컨트롤러 객체에 대한 reference count 가 0 가 되므로, 이때에 이 객체가 메모리해제 될 수 있다. (deinit 실행)

이는 화면이 종료(back) 되었음에도 불구하고, Task 를 중단 시키지도 못했을 뿐 더러, 5초라는 시간동안 메모리가 누수된 상태가 되는 것이다. 

으흠? 그렇담 뭔가를 조치해줘야겠지. 클로저에서 사용되는 self 에 약한(weak) 참조 내지는 미소유(unowned) 참조를 쓰면 어떻게 될까? 

일단 둘 모두 레퍼런스 카운트를 증가시키지 않는 개념이다. weak 은 메모리해제 시 nil 을 가지게 되는 참조형태이고, unowned 는 Non nil, 그러나 메모리 보장하지 않는 참조 형태이다. 

그럼 이제 코드를 살짝 바꿔보자. 먼저 unowned 를 적용해보자.

```swift
Observable.just(0)
	.delay(5, scheduler: MainScheduler.asyncInstance)
	.subscribe(onNext: { [unowned self] value in // self 레퍼런스 카운트를 증가시키지 않음
		self.test(value)
	}, onDisposed: { [unowned self] in // self 레퍼런스 카운트를 증가시키지 않음
		self.test()
	})
	.disposed(by: disposeBag)
```



이제 화면에서 back 으로 빠져나갈때, 컨트롤러 객체가 메모리해제되며 disposeBag 이 해제되고, disposed(by: disposeBag) 에 의해 subscription 이 dispose 될 것이다. 

따라서 onNext 클로저는 실행되지 않을 것이고, onDisposed 클로저가 다음으로 실행될 것이다. 

이 onDisposed 클로저의 self 는 unowned 로 되어있다. 그럼 이때의 self 를 사용하는것은 안전할까??

아니다. 해제된 객체에 대한 접근을 하게되는거이고, 런타임 에러를 유발하여 앱이 크래시나게 될 것이다. 

그렇다면 

```swift
onDisposed: { [unowned self] in 
	guard let `self` = self else { return }
	self.test()
})
```
이런 코드는 어떨까? 답은 안된다 이다. unowned self 는 Optional 타입이 아니기 때문이다. 

그렇다. 그래서 onDisposed 의 경우에는 [weak self] 를 써야만 하는것이다. 
```swift
onDisposed: { [weak self] in 
	guard let `self` = self else { return }
	self.test() 
})
```

자, 그럼 이런 단발성 이벤트 스트림이 아닌 경우는 어떨까? RxCocoa 를 이용하여 버튼 탭 이벤트를 구독하는 Subscription 을 살펴보자. 

```swift
button.rx.tap
   .subscribe(onNext: { 
	   self.close()
   })
   .disposed(by: disposeBag)
```

처음의 예제와 마찬가지로, onNext 클로저에서 self 를 strong reference 타입으로 사용하고 있다.

이는 컨트롤러의 레퍼런스 카운트를 +1 시키며, 컨트롤러 객체의 정상적인 메모리 해제를 막는다. 

그러므로 Subscription 또한 영원히 해지 되지 않는다. 이 subscription 은 button 의 tap 이벤트를 영원히 기다리고 있기 때문에, 컨트롤러 객체는 프로세스가 종료될 때 까지 계속해서 메모리에 상주하게 된다. 

disposed(by: disposeBag) 을 통해 subscribe onNext 클로저의 실행은 컨트롤러 객체가 소멸되지 전에 실행되는것을 보장할 수 있으므로, 이런 경우 가장 적절한 retain 정책은 unowned 가 될것이다.

```swift
button.rx.tap
   .subscribe(onNext: { [unowned self] in
	   self.close()
   })
   .disposed(by: disposeBag)
```
