+++
title = "Swift iOS 기본 인터뷰 질문에 대한 정리글"
date = 2019-03-22T10:31:57+09:00
lastmod = 2019-03-22T10:31:57+09:00
draft = false
keywords = []
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

웹서핑을 하다가 우연히, 어떤 회사의 어떤 면접관이 올려놓은 기술 인터뷰 질문 목록을 보았다. 

음.. 아무리 기본에 대한 거라지만 기술면접질문을 공개하다니.. 실제 면접은 아무래도 여기서부터 물고 들어가는 심층 면접이려나? 

어떤식으로 하려는지 궁금하긴 하다. ㅎㅎ 

기본적이지만, 막상 대답하려면 막히는 부분들이 있을 수도 있으니, 면접 질문들 중에서  GIT, Testing 항목을 제외한 부분들에 대해서 간단히 정리해보았다. 


## ARC(Automatic Reference Counting)는 어느 시점에 작동하나요?


컴파일 시점에 동작. 코드를 빌드(컴파일) 할때 특정 객체의 레퍼런스 카운트를 추적하여 0 가 되는 시점에 자동으로 release 코드를 넣어주는것을 말한다. 


## strong, weak, unowned 키워드를 어떤 상황에서 사용하고, 차이는 무엇인가요?

	
*strong*
이 키워드로 선언된 (정확히는 weak 이나 unowned 로 선언되지 않은) 레퍼런스 객체는 할당되는 순간 해당 객체의 레퍼런스 카운트를 증가시킨다. 

레퍼런스 카운트를 증가시켜 ARC 로 인한 메모리해제를 피하고 객체를 안전하게 사용하고자 할 때 쓰인다. 

예를 들자면, 어떤 A 라는 메서드에서 a 라는 레퍼런스 객체를 생성하고, 이를 비동기 실행 클로저에  파라미터로 전달한다면, 

라는 메서드의 호출이 끝나는 순간, 해당 레퍼런스 객체의 레퍼런스 카운트는 1 감소하게 되는데, 클로저에 strong 타입으로 전달된 경우는 레퍼런스 카운트가 +2 이기 때문에 최종 +1 상태가 되어 메모리 해제되지 않는다. 
 
따라서 해당 클로저에서 안전하게 해당 객체에 엑세스하여 커뮤니케이션이 가능하게 된다.

또는 다른 Class 나 Struct 의 프로퍼티에 어떤 레퍼런스 객체가 할당 될 때, strong 타입으로 지정하게 되면, 레퍼런스 카운트가 +2 가 되며, 

따라서 본래 생성되었던 곳에서 레퍼런스 카운트가 1 감소하더라도, 전달받은 곳에서는 안전하게 사용이 가능하다.

```swift
class A : CustomStringConvertible {
	var description: String {
		return "Class A"
	}	

}

func someMethod() {
	let a = A()
	DispatchQueue.main.async {
		print(a) // <- referenced by strongly
	}
}
```


*weak*

객체가 할당될 때 레퍼런스 카운트를 증가시키지 않는다. 이 키워드는 Optional 타입에만 적용이 된다. 객체가 ARC 에 의해 메모리해제되면 nil 값이 할당된다. 

대표적으로 retain cycle 에 의해 메모리가 누수되는 문제를 막기 위해 사용되며, iOS 프레임워크에서 이의 대표적인 예로는 Delegate 패턴이 있다. 


*unowned*

마찬가지로 객체가 할당될 때 레퍼런스 카운트를 증가시키지 않는다. 

그러나 Non-Optional 타입으로 선언되어야 하며, 객체가 ARC 에 의해 메모리해제되더라도, 

해당 객체 값을 존재하는 것으로 인지하며, 해당객체에 액세스 할 경우 런타임 오류를 발생시킨다. 

객체의 라이프사이클이 명확하고 개발자에 의해 제어가 가능이 명확한 경우, weak Optional 타입 대신 사용하여 좀더 간결한 코딩이 가능하다. 	


## 객체 간 순환참조를 발견하는 방법과 해결 방법은?


* Xcode Memory Graph 이용해서 Live Object 들을 확인하고, Leak 된 Object 를 체크.
* Instrument 의 Leak 도구를 이용하여 체크.
* deinit 을 활용하여 로깅코드를 통해 체크.
	
	
## Escaping Closure의 개념이 무엇인가요?

	
메서드 파라미터로 전달받은 closure 를 메서드의 라이프사이클 내에서 실행하여 끝내지 않고, 메서드 scope 의 외부에 전달하려 할 때는 해당 closure 를 escaping 해야한다. 

해당 메서드의 호출이 끝난 이후에도 closure 는 메모리 어딘가에 저장되어야 하며, 이는 closure 안에서 사용된 outer object (`self` 와 같은) 에 weak 와 같은 레퍼런스타입을 사용해야할 수 있음을 주의하도록 한다. 

escaping 이 명시되어있지 않으면 기본적으로 non-escaping 이며, 이는 메서드의 실행이 끝나기 전에 closure 의 사용이 모두 완료됨을 보장하며, 

따라서 closure 내에서 weak 을 굳이 사용하지 않아도 안전할 수 있음을 의미하기도 한다. 


## 타입 캐스팅을 할 때 사용하는 키워드인 as, as?, as! 이 셋의 차이는 무엇인가요?

	
*as*

컴파일러가 타입 변환의 성공을 보장. 컴파일타임에 가능/불가능 여부를 알 수 있음

*as?*

타입변환에 실패하는 경우 nil 을 리턴. 컴파일타임에 가능/불가능 여부를 알 수 없음

*as!*

타입변환에 실패하는 경우 실행시간(Runtime) 오류를 발생시킴. 컴파일타임에 가능/불가능 여부를 알 수 없음

> p.s - Xcode 와 같은 IDE 에서는 코드 정적검사를 통해 as, as?, as! 모두에 대해 warning 을 준다. 


## Swift에서 Class와 Struct의 차이는 무엇인가요?

	
*Class* - Reference type

* 객체화 시 힙 메모리영역에 저장되며 ARC 로 객체의 메모리해제가 관리된다.
* 대입 연산 시 레퍼런스가 복사되어 할당됨. (공유 가능)
* 멀티스레딩 시 적절한 Lock 활용이 필요.
* 상속 가능.
		     
*Struct* - Value type

* 대입 연산 시 값 자체가 복제되어 할당됨(공유가 불가능). 
* 불변성(Immutable) 구현에 유리. 
* 멀티스레딩에 안전함. 
* 상속이 불가능. (protocol 은 사용 가능)
	

## Frame 과 Bounds 의 차이는 무엇인가요?

	
*Frame*

SuperView(상위뷰) 좌표시스템 내에서의 view 의  위치(origin) 과 크기(size)

*Bounds* 

view 자기 자신의 좌표시스템에서의 위치와 크기. 부모부와의 위치관계와는 아무런 관계가 없다. 

자기 자신의 좌표시스템을 가리키기 때문에 기본적으로 origin 은 x:0, y:0 을 가리킨다. 

bounds 의 origin 을 변경한다는 것은 곧, subview 들이 화면상에서 drawing 되는 위치가 변경됨을 의미한다 

이게 subview 들의 frame 값을 변화시키는게 아니다. 부모뷰 좌표축이 변하면서 subview 가 그려져야하는 위치가 달라졌기 떄문이다.

ScrollView/TabeView 등을 스크롤 할때, scrollView.bounds 가 변하고, 그리하여 subview 들의 그려지는 위치가 달라지는 것이 대표적인 예 이다. (subview 들의 frame 이 달라지는게 아님!)


## UIViewController클래스내 프로퍼티인TopLayoutGuide와 BottomLayoutGuide가 iOS11에서 deprecate된 이유와 이를 대체하기위해 어떤것이 생겼을까요?

	
*SafeAreaLayoutGuide*

기존 Top, Bottom 레이아웃 가이드와는 다르게, 안전한 컨텐츠 영역의 개념으로 등장했다. 

기존이 상단, 하단, 두개의 사각 영역으로 되어있는 가이드영역이었다면, 

SafeAreaLayoutGuide 의 영역은 하나의 사각 영역으로 되어있다. 


## UIStackView의 장점은 무엇이라고 생각하시나요?

	
여러 뷰를 가로방향 또는 세로방향으로 배치할 때, 복잡한 컨스트레인트 설정 없이, 또는 컨스트레인트 만으로 설정하기 어려운 뷰의 배치등을 구현할 때 쓰일 수 있는 뷰. 

aggangedSubview 로 하위뷰들이 관리되며, 이 하위뷰들에 Axis(가로 세로 방향), Alignment(세로방향 정렬), Distribution(가로방향 정렬), Spacing(하위뷰들간의 간격) 의 규칙을 적용할 수 있다. 


## Autolayout Constraint의 Priority의 개념이 무엇이고, 어떤상황에 사용하나요?


말그대로 제약들간의 우선순위를 말한다. 

다수의 뷰들에 여러제약이 걸려있을 때, 보통은 제약간의 충돌이 일어나지 않게끔 제약들을 설계하는게 일반적이지만, 

상황에 따라서는 뷰들의 크기가 유동적으로 변하는 경우가 있는데, 이럴때 어떤 제약들이 서로간에 충돌이 일어나는 경우가 있을 수 있다. 

이럴때에는 어떤 제약의 우선순위를 더 우위에 둘것이냐를 결정함으로써 이러한 충돌을 해결할 수 있다. 


## Content Hugging Priority의 개념이 무엇이고, 어떤상황에 사용하나요?


UI Framework 에서 제공되는 일부 뷰에는 컨테츠 고유의 사이즈(Contrisic content size)라는 개념이 있다. 

예를 들자면, UILabel, UIButton 들과 같이 뷰의 속성(텍스트 / 이미지) 에 따라 크기가 결정되는 (특정한 너비/높이 사이즈의 제약을 걸지 않은 한) 뷰들이 있겠다. 

이러한 뷰들은 다른 뷰들간에 걸린 제약에 의해, 본래의 컨텐츠 고유 사이즈보다 더 늘어나거나 줄어들게 될 수 있다. 

이때 더 늘어나게 되는 것에 대해 저항하는 제약을 Content Hugging 이라 하고, 

더 줄어들게 되는 것에 대해 저항하는 제약을 Content Compression Resistance 라고 한다.

이 고유 컨텐츠 사이즈의 변경에 대한 제약에도 우선순위(Priority) 가 있는데, 이는 Autolayout constraint priority 보다는 우선순위가 낮다. 

다시 말해서, 우선순위가 서로 같은 값을 가진다고 하면, 오토레이아웃 제약의 우선순위가 적용이 된다는 얘기다. 

이 중, Content Hugging 에 대해 간략히 설명해 보자면, 예를 들어, 부모뷰의 너비/높이가 100x100 이라고 하고, 

그 안에 UILabel 을 하나 두되, 이 레이블에는 너비 높이 제약을 주지 않고, 다만 leading, tailing, top, bottom 의 제약을 주어, 각각의 제약들에 10의 값을 지정한다고 하자. 

그렇다면 해당 레이블의 크기는 80x80 이 되도록 제약에 의해 결정되어진다고 볼 수 있다. 

그러나 이는 항상 맞는 얘기가 아니다. 

예를 들어,  레이블의 leading, tailing, top, bottom 제약의 우선순위를 250 으로 주고, ContentHugging priority 를 750 으로 준다면, 

우선순위에 따라 레이블의 크기는 레이블 컨텐츠 고유의 크기로 결정이 되고, 따라서 네 방향의 제약은 모두 충돌이 나게 된다. 


실제로 사용될 수 있는 예를 하나 들어보자면,

높이 제약이 설정되어있지 않은 어떤 뷰의 하위에, 세로방향으로 2개의 레이블을 배치하고, 서브뷰 끼리의 vertical spacing 제약, 각각의 뷰들과 부모뷰와의 top, bottom 제약을 걸어 chaining 형태의 제약을 걸었다고 생각해보자. 

그러면, 부모뷰의 높이는 자식뷰(두개의 레이블)의 높이(intrinsic content size) 와 뷰들 간의 간격, 부모뷰와의 간격값의 합으로 결정이 된다.(AutoLayout) 

이러한 경우, 부모뷰의 높이값을 어떤 특정한 값으로 지정해 더 커지도록 하게 되면, 자식뷰(레이블)들의 높이또한 변경되어야 하는데, (상하 간격 제약을 위반하지 않기 위해서)

이때 상단의 레이블의 크기는 고정시키고, 하단의 레이블의 높이만을 변경되게 하고 싶다면, 

해당 레이블의 ContentHugging priority 값을 다른 레이블의 priority 보다 낮게 지정함으로써 원하는 레이아웃을 이룰 수 있게 된다.

물론 이때, 모든 레이블의 ContentHugging priority 는 자식 뷰와(그리고 자식 뷰들 사이의 간격) 부모 뷰 사이에 설정된 상하 간격 제약들의 priority 보다 같거나 작아야 한다. 


## UICollectionViewLayout클래스에 prepare 메소드는 어떤 역할을 하나요?


레이아웃관련 연산이 일어날 때마다 가장 먼저 호출된다. 이 메소드에서 셀의 위치/크기 등을 계산하기 위한 사전처리를 할 수 있다.

UICollectionViewLayout 를 상속받아 Custom 한 CollectionView Layout 을 구성하고자 할때, 데이터소스를 참조하여 셀의 위치 및 크기를 미리 계산하여 캐싱해두고, 

CollectionView 로부터 셀의 위치 및 크기 요청이 들어올때, 미리 계산하여 캐싱해둔 데이터를 전달해주는 방식으로 커스텀 레이아웃을 구성하는 방식이 있겠다. 

	
## UITableView를 구성할때 셀의 컨텐츠에 따라 높이를 설정하고싶다면 어떻게 해야하나요?

		
델리게이트 메서드 rowHeight 에서는 UITableView.automaticDimension 값을 리턴하고 ,estimatedRowHeight 에서는  셀의 예측 높이값을 리턴한다.

이렇게 하면 오토레이아웃 테이블뷰 셀 구현이 가능하다. 

마찬가지로 테이블뷰 셀은, 고정 높이가 아닌, 셀 안의 서브뷰들의 제약 구성으로 셀의 크기가 결정될 수 있도록 해야한다. 
