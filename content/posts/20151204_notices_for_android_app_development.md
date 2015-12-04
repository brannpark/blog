+++
Categories = ["Development"]
Description = ""
Tags = ["android"]
date = "2015-12-04T14:46:07+09:00"
title = "안드로이드 앱 개발 시 주의사항"
+++

이 포스팅은 앞으로 쓰게 될 안드로이드 앱 개발 관련 주의사항 포스트들에 대한 게이트웨이 정도가 되겠다.
보통.. 이렇게 하면 좋다, 저렇게 하면 좋다라는 글들은 많고, 의견도 분분하고.. 하면 좋다 이지 안하면 안된다는것도 아니고.
그런데 이렇게 제발 쫌 하지 말라는 흘려버리기엔 너무 치명적이지 않을까? 왜 하지말라는지 꼭 알아봐야 한다고 생각한다. 그렇다고 누군가의 이야기를 그냥 맹신하는것은 위험! 과거엔 맞는 이야기가 현재에는 맞지 않을 수도 있으니...

간략하게 주제별로 리스팅을 하고, 원문 링크과 간략한 설명으로 작성해 나갈예정이다. 

# 안드로이드 앱 개발간 주의할 점들!

1. [Don't Store Data in the Application Object](http://www.developerphil.com/dont-store-data-in-the-application-object/) 

	Application 객체는 앱이 백그라운드에 진입해 있는 동안 시스템에 의해 recreate 될 수 있다. 그러므로 Application 객체가 상태 변수 따위를 가지도록 코드를 짜면 안된다.






