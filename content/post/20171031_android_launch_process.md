---
title: "20171031_android_launch_process"
date: 2017-10-13T16:25:46+09:00
lastmod: 2017-10-13T16:25:46+09:00
draft: true
keywords: []
description: ""
tags: []
categories: ["Development"]
author: "Brann Park"
comment: true
toc: false
contentCopyright: false
reward: false
mathjax: false
---


# 안드로이드앱 실행속도 최적화하기

안드로이드 앱이 실행이 될때, 세가지의 다른 실행 상태가 존재한다. 

1. Cold start (차가운 시작)
2. Warm start (따듯한 시작)
3. Lukewarm Start (미지근한 시작)

앱 실행 성능을 개선하기 위해서는 각각의 시작 실행 상태들이 의미하는게 무엇인지 이해하는게 중요하다.
그리고 항상 Cold start 상태의 성능 최적화를 고려해야만 한다! 이유는 아래 글을 읽다보면 자연스레 알게 될 것이다.

## Cold start

Cold start 는 안드로이드 시스템 프로세스가 아직 앱 프로세스를 만들지 않은 상태에서 앱을 실행하는 것을 말한다. 
기기가 부팅 된 이후 최초로 앱을 실행할 때나, 완전 종료하여 앱 프로세스를 Kill 시켰을 경우 등이 해당된다. 
이 실행 상태는 다른 실행 상태들에 비해 앱을 실행하기 위해 더더욱 많은 작업을 처리해야 하기 때문에 느릴 수 밖에 없다.
따라서 앱 실행속도의 최적화 관점에서 가장 신경써야하는 상태가 되는 것이다. 

이 상태에서의 앱 실행 시, 시스템은 다음의 세가지 Task 를 처리한다.

1. 앱을 로딩하고 실행한다.
2. 앱 실행 직후, 빈(blank) starting window 를 화면에 보인다.
3. 앱 프로세스를 생성한다.

앱 프로세스가 생성 된 이후에는, 

1. Application Object 를 생성.
2. 메인 스레드를 실행.
3. 액티비티를 생성. (android.intent.action.MAIN action 을 가지는 액티비티)
4. 뷰를 생성(inflating).
5. 화면(screen)에 뷰를 배치.
6. 초기 draw 를 수행.

## Warm start

Warm start 는 훨씬 더 단순하고 Cold start 보다 오버헤드가 더 적은 실행 상태이다. 시스템은 단순히 앱의 액티비티를 background 에서 foreground 로 가져오는 일을 할 뿐이다.
Warm start 또한 Cold start 와 마찬가지의 On-Screen 과정을 수행한다. (앱이 액태비티를 렌더링 하기 전까지 blank window 를 화면에 보인다.)

## Lukewarm start

Lukewarm start 는 Cold start 에서 처리하는 Task 를 일부 처리하는 실행 상태이다. Lukewarm start 대표적인 케이스는, 

1. 사용자가 백키를 통해 앱을 종료시킴. 그러나 앱 프로세스가 Empty Process (아직 메모리에 상주해 있으나, 우선순위가 가장 낮은 상태의 프로세스이며, 필요에 따라 시스템에 의해 결국은 종료 될 프로세스) 상태 일 때, 사용자가 앱을 다시 실행함. 이러한 경우 프로세스는 다시 생성되지는 않으나, 액티비티는 새로 생성되어야 함.
2. 앱 프로세스가 백그라운드 상태일 때, 시스템이 메모리 확보를 위해 앱 프로세스를 종료시킴. 이후 사용자가 앱을 재실행. 이러한 경우, 프로세스와 액티비티는 새로 생성되어야 한다. 그러나 다만, saved instance state 정보를 이용하여 activity 의 oncreate() 가 실행되기에 어느정도의 benefit 을 가질 수 있다고 볼 수 있다. 

위의 2번과 같은 경우는, 사실 뭐 앱이 시스템에 의해 kill 되긴 한건데, 메모리 확보용이라 Activity Stack 데이터도 함께 저장되어서 다시 실행될 경우 마지막에 보였던 화면이 복원되는 실행 상태이긴한데.. 거의 뭐 Cold start 와 차이랄 게 없다. saved instace state 에서 다룰 데이터가 실행 성능에 뭐 얼마나 도움을 준다는건지는 별로 와닿지 않는다.
따라서 Cold start 보다 오버헤드는 적지만, 당연히 Warm start 보단 오버헤드는 많을 수 밖에 없다. 근데 구글 공식 문서상에는 왜!! 

`A lukewarm start encompasses some subset of the operations that take place during a cold start; at the same time, it represents less overhead than a warm start.` 

라고 써있는 것일까.. ㅇ.ㅇ 원문은 [여기](https://developer.android.com/topic/performance/launch-time.html#lukewarm)에서 확인해보자. 아무리 봐도 warm start 는 cold start 를 잘 못 쓴것 같다. 

한국어로 번역해 놓은 블로그들이 꽤 있어서.. 그들은 어떻게 번역했나 봤는데.. 다들 그대로 번역해놨다. ㅇ.ㅇ;;;

(계속...)