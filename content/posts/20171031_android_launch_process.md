+++
title = "안드로이드 앱 실행 시의 세가지 상태"
date = 2017-10-13T16:25:46+09:00
lastmod = 2017-10-13T16:25:46+09:00
draft = false
keywords = []
description = ""
tags = ["android", "launchspeed"]
categories = ["Development"]
author = "Brann Park"
comment = true
toc = false
contentCopyright = false
reward = false
mathjax = false
+++


안드로이드 앱이 실행이 될때, 세가지의 다른 실행 상태가 존재한다. 

1. Cold start (차가운 시작)
2. Hot start (따듯한 시작)
3. Warm Start (미지근한 시작)

앱 실행 성능을 개선하기 위해서는 각각의 시작 실행 상태들이 의미하는게 무엇인지 이해하는게 중요하다.


## Cold start

Cold start 는 안드로이드 시스템 프로세스가 아직 앱 프로세스를 만들지 않은 상태에서 앱을 실행하는 것을 말한다. 
기기가 부팅 된 이후 최초로 앱을 실행할 때나, 앱 프로세스를 완전히 종료시켰을 경우 등이 해당된다. 
이 실행 상태는 다른 실행 상태들에 비해 앱을 실행하기 위해 더욱 많은 작업을 처리해야 하기 때문에 느릴 수 밖에 없다.
따라서 앱 실행속도의 최적화 관점에서 가장 신경써야하는 상태가 되는 것이다. 

이 상태에서의 앱 실행 시, 시스템은 다음의 세가지 Task 를 처리한다.

1. 앱을 로딩하고 실행한다.
2. 앱 실행 직후, 빈(blank) starting window 를 화면에 보인다. (System process 가 담당)
3. 앱 프로세스를 생성한다.

앱 프로세스가 생성 된 이후에는, 

1. Application Object 를 생성.
2. Main(UI) 스레드를 실행.
3. 기본 액티비티를 생성. (android.intent.action.MAIN action 을 가지는 액티비티)
4. 뷰를 생성(inflating).
5. 화면(screen)에 뷰를 배치.
6. 초기 draw 를 수행.

## Hot start

Hot start 는 Cold start 보다 훨씬 더 단순하고 오버헤드가 적은 실행 상태이다. 시스템은 단순히 앱의 액티비티를 background 에서 foreground 로 가져오는 일을 할 뿐이다. 
앱의 Activity 가 아직 메모리에 남아있는 경우, 별도의 객체 초기화, View inflating, Rendering 을 할 필요가 없다.
Warm start 또한 Cold start 와 마찬가지로 동일한 On-Screen 과정을 수행한다. 즉, 앱이 액태비티 렌더링을 완료 하기 전까지 시스템 프로세스는 blank window 를 화면에 보여준다.


## Warm start

Warm start 는 Cold start 에서 발생하는 작업들의 일부를 포함하며, Hot start 보다는 더 많은 오버헤드를 일으키는 앱 실행 상태이다. 
대표적인 예로는, 

1. 사용자가 백키를 통해 앱을 종료시킨다. 
   그러나 앱 프로세스가 Empty Process (아직 메모리에 상주해 있으나, 우선순위가 가장 낮은 상태의 프로세스이며, 필요에 따라 시스템에 의해 결국은 종료 될 프로세스) 상태 일 때, 
   사용자가 앱을 다시 실행시킨다. 
   이러한 경우 프로세스 자체는 기존의 프로세스가 그대로 사용되지만, 액티비티는 새로 생성되며, onCreate 단계부터 진행이 된다. 
2. 사용자가 앱 프로세스를 완전히 종료시키거나, 시스템이 메모리 확보를 위해 앱 프로세스를 종료시킨다. 
   이후 사용자가 앱을 재실행한다.
   이러한 경우, 프로세스와 액티비티는 모두 새롭게 생성되어야 한다. (cold start)
   다만, Cold start 에 비교하여, Warm Start 의 경우에는 savedInstanceState 를 활용할 수 있으며, 이를 통해 미리 저장된 데이터를 활용하여 액티비티를 실행 할 수 있다는 장점이 있다.




