+++
title = "iOS_Adhoc_아카이브와 크래시리틱스, 그리고 Bitcode"
date = 2018-06-05T16:12:15+09:00
lastmod = 2018-06-05T16:12:15+09:00
draft = false
keywords = []
description = ""
tags = ["ios", "bitcode", "adhoc", "archive", "crashlytics", "fabric", "dsym", "dsymutil"]
categories = ["Development"]
author = "Brann Park"
comment = true
toc = false
contentCopyright = false
reward = false
mathjax = false
+++

# iOS_Adhoc_아카이브와 크래시리틱스, 그리고 Bitcode
<br>

오랫만의 포스팅!

회사를 옮기고 나서 어찌어찌 하다보니 iOS 개발을 맡게 되었다. 

현 팀에서는 사내에 별도록 구축된 앱 빌드 & 배포 서비스를 이용하고 있었고, 앱 크래시 관리용으로는 Fabric crashlytics 를 사용중이었다. 

그리고 얼마전 업데이트 작업을 마치고 앱스토어에 릴리즈할때 무심코 본 옵션..  Bitcode!!

![Figure 1. Bitcode? 누구냐 넌!](http://kevindelord.io/images/itunesconnect/summary.png)

예전 회사에서는 저 옵션을 끈 채로 배포를 했던것 같은데.. 아무튼, 저게 문제가 되는 상황이 생겼다.

차근히 썰을 풀어가보겠다.

참고로.. 


> * Xcode 7부터는 Bitcode가 기본적으로 enabled 되어있다. (빌드 속성화면에서 아무리 뒤져봐야 나오지 않는다..;;) [참고](https://blog.asamaru.net/2015/10/20/ios-9-xcode-you-must-rebuild-it-with-bitcode-enabled/)

> * 강제로 Bitcode 를 비활성화하려면? (가능한가..?) [여기](http://theeye.pe.kr/archives/2501) 

<br>

## 크래시가 보이지 않아요.

테스트를 위해 사내 배포를 진행하고나면 테스터들이 설치 후 테스트를 하게 되는데, 혹여라도 사용 중 크래시가 발생한다면 Crashlytics 쪽으로 크래시들이 수집이 되어야 한다. 

그런데 나오라는 크래시는 나오지 않고 이런 화면만을 내게 보여준다!

![Figure 2. dSYM 을 찾습니다!](https://i.stack.imgur.com/noyDG.png)

dSYM 이 없어서 심볼화하지 못한 크래시가 있다는 말인데.. 

그럼 먼저 dSYM 이 뭔지 정확히 알아봐야겠다. 

<br>

## dSYM

대략 뭐하는 파일인지 검색을 해보니.. 

리버스 엔지니어링을 어렵게하고(난독화), 앱 바이너리의 사이즈를 줄이기 위한 목적으로 만들어지는 파일이라 한다.

Crashlytics 와 같은 서비스에서는 이 dSYM 이 있어야, 크래시 로그를 사람이 읽을 수 있도록 만들어줄 수 있다.

이 dSYM 은 배포를 위해 아카이브를 만들때 자동으로 만들어진다. (물론 Xcode 옵션에 따라서!) 

![Figure 3. 드워프와 dSYM](/blog/img/ios_fabric_and_bitcode/build_option.png)

<br>
> dSYM 파일은 아카이브 생성 시 함께 생성된다!!

<br>

자, 그럼 여기까지 알았으니.. dSYM 을 찾아서 Fabric 에 업로드해보자!

Fabric 대쉬보드에서, 설정화면으로 가서 App 메뉴를 선택하고, 알맞는 App 을 선택하면 다음과 같은 화면을 볼 수 있다.

![Figure 4. App setting 페이지](https://i.stack.imgur.com/hQnbI.png)

이제 이곳에 dSYM 파일을 찾아 압축을 해서 올리기만 하면 되는것처럼 보인다. 

그래서 시도해보았다. 

결과는....

![Figure 5. ___hidden](/blog/img/ios_fabric_and_bitcode/hidden.png)

hidden?!

심볼이.. 감춰져있다고 한다. 왜지? dSYM 이 심볼을 가지고 있다면서?!!

원인이 뭔지 구글링을 해봤다.. 

bitcode.. bitcode...?

아카이브를 **Export** 시 비트코드란 녀석을 활성화하는게 이 문제의 원흉임을 알 수 있었다.

내가 찾아본 대부분의 글들은, 앱스토어에 올리고 나서 어떻게 해야하는가에 대한 질답이 대부분이었는데, (필자의 경우는 Adhoc 배포!)

이런 경우에는 단순한 솔루션이 주어졌다.


>
1. 앱스토어에 릴리즈 
2. Xcode Organizer -> 아카이브 선택 -> 우측에 Download dSyms 버튼 클릭!


을 하면 아카이브 내의 dSYM 이 자동으로 갱신된단다. 
(갱신.. 응? 갱신이 필요해?)
<br>
<br>
위 방법의 대체 방법으로는, 

>
1. itunesconnect 에 접속해서
2. 앱을 선택하고
3. Activity (활동) 항목에서 업로드한 빌드를 선택
4. 화면 UI 중에 dSYM 을 다운로드 링크를 클릭


가 있다고 한다.

자.. 그렇다면 이제는 Bitcode 가 활성화된 채로 AppStore 에 업로드를 하면 무슨일이 발생하는건지 알아볼 차례다.

<br>
## Rebuild from bitcode

먼저, 릴리즈 아카이브를 앱스토어에 올리려할떄 뜨는 디어얼로그 화면이다.
![Figure 6.](/blog/img/ios_fabric_and_bitcode/appstore_upload.png)

다음은, 애드혹 아카이브를 Export 하려 할 때 뜨는 다이얼로그 화면이다.
![Figure 7.](/blog/img/ios_fabric_and_bitcode/adhoc_export.png)

묘하게 다르다. 
어쩃든 Appstore Upload 화면을 잘 보면.. Bitcode 라는 건, 

>하드웨어, 소프트웨어, 컴파일러의 변경에 따라 AppStore 가 앱을 재빌드 할 수 있도록 해주는 것

을 말한다는것을 알 수 있다.

좀 더 자세한 설명은 아래와 같다.
>iOS9 에서 LLVM Compiler에서 Bitcode를 생성을 지원한다. Bitcode를 사용하는 경우 AppStore에서 필요한 경우에 해당 코드를 사용하여 다시 최적화 된 바이너리를 생성하여 End user에게 전송해 주는 역할을 담당한다. Xcode에서 Bitcode를 포함한 iOS 앱을 AppStore로 전송하면, AppStore 내에서 사용자의 디바이스에 따라 최적화된 바이너리를 다시 빌드하는 과정을 거친다. 따라서, Bitcode가 적용된 앱을 앱스토어로 전송한 경우 개발자는 추후 새롭게 출시되는 디바이스의 특성에 따라 다시 빌드하는 수고를 덜어줄 것으로 예상된다.

<br>
이 Bitcode Adhoc 아카이브 Export 화면을 보면, 항목명이 **Rebuild from bitcode** 이다.

설명은 다음과 같다. 

> 앱스토어가 하는 방식과 같이, Bitcode 를 컴파일 하여 앱을 Export 합니다.

그렇다.. 결국 Bitcode 를 포함(맞는 표현일까..?) 하여 다시 빌드가 된다는거다. 

그리고 이 때 Pods 플젝 dSYM 들을 제외한 App.dSYM 은 여러개로 쪼개진다. 

새롭게 생성되는 dSYM 들은 UUID 포맷의 파일명을 가진다. (원본 App.dSYM 은 이떄부터 쓸모없어지게(?) 된다)

여기서 앱스토어 upload 냐, 애드혹 export 냐에 따라 이 dSYM 들에 차이점이 생긴다.

<br>
## dSYM with bitcode... AppStore Upload VS Adhoc Export 

Bitcode 로 rebuild 됨에 따라 dSYM 이 새롭게 생성이 되는데..

이때 이 dSYM 이 수상하다. dSYM 이 obfuscated 상태이다. 이 상태의 dSYM 을 그대로 Fabric 에 올려두면..

__parent#123123 와 같은 심볼을 크래시 Stacktrace 에서 보게 된다. (한번 dSYM 을 올려서 Fabric 에 기록된 크래시 로그에 dSYM 이 프로세싱 되어 적용되면.. 다시 못돌립니다.. 크래시 내용이 뭔지 소중하다면 반드시 주의하세요!)

그래서 de-obfuscate 프로세싱을 해줘야 하는데.. 앱스토어 업로드 시에는 그걸 자동으로 해주는것 같다.

따라서 업로드 후 dSYM 을 다시 다운로드 받으면 바로 Fabric 에 올려도 된다. 

그런데...

Adhoc 은 de-obfuscate 프로세싱을 자동으로 해주지 않는다. 그래서 내가 이렇게 장황하게 이 글을 쓰고 있는 것이었다..


<br>
## 해결법


필자의 회사에서 사용하고 있는 사내 빌드 & 배포 서비스의 경우 Jenkins CI 를 기반으로 만들어져 있고, 

플젝을 빌드하고 나면 빌드 아웃풋으로 plist, ipa, dSYM, xcarchive 등의 Artifacts 들이 생성된다. 

여기서 제공되는 dSYM 은 원본 App.dSYM.zip 이었기에 이를 쓸 수는 없고...

최종 빌드 산물인 xcarchive 를 내려받는 수밖에 없다. 

이를 받아서 내용물을 보면 다음과 같은 디렉토리를 찾을 수 있다.

* dSYMs
* BCSymbolMaps

dSYMs 는 dSYM 파일들이 위치하는곳이다.
BCSymbolMaps 는 dSYM 을 de-obfuscate 할 수 있는 정보를 가진 파일들이 위치한다!

위에서도 언급했듯이 Adhoc export 시에는 수동으로 난독화된 Symbol 정보를 매핑 시켜줘야 한다.

이때 쓰이는 도구가 dsymutil 이라는 녀석이다.

```
$ dsymutil -symbol-map {YourApp.xcarchive}/BCSymbolMaps  {YourApp.xcarchive}/dSYMs/*.dSYM
```
위와 같이 실행해주고 나면 dSYM 들의 난독화된 심볼이 복원이 된다. 

이제 Fabric 에는.. dSYMs 디렉토리에 있는 dSYM 파일들 중 {YourApp}.App.dSYM 파일 (원본 dSYM 파일) 을 제외한 나머지 모든 dSYM 들을 Zip 으로 압축하여 올리기만 하면 된다. 

끝이다! 야호.

부디 누군가에게 유용한 정보가 되었길!