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

우리는 흔히 Application 객체는 단일 객체로 앱이 사용자에 의해 명확하게 종료되기 전 까지는 값이 해제되지 않고 유지된다고 생각하기 쉽다. 그러나 이는 잘못된 생각이다. 앱이 백그라운드에 진입해 있는 동안 시스템에 의해 언제든지 종료될 수 있다. 예를들어, 어떤 A 라는 앱을 사용 하다가 앱을 전환(종료x)해서, 유튜브를 보다가 다시 앱을 전환해서, A 앱으로 돌아왔을 때, 과연 이 앱은 그 사이에 종료가 되지 않고 메모리에 계속 남아있을까? 이는 순전히 OS 에 의해 결정될 뿐이다. 그러나 OS 는 이렇게 종료시킨 앱의 "상태" 를 저장하고, 다음번 실행될 때 저장된 상태를 "복원" 해 줌으로써, 마치 사용자가 그 앱을 계속 사용하던 것처럼 보이도록 해 준다. (물론 개발자가 이에 맞게 적절히 개발을 했다고 가정한다.)  이러한 프로세스에 대한 이해가 충분하지 않은 상황에서, Application 객체에 어떠한 상태를 저장해두고 다른곳에서 읽기를 하는 코드는 위험하다. 왜일까? 다음과 같은 예를 한번 살펴보자. 

```java
class MyApplication extends Application {
    private String mAppName; // MyApplication 객체는 AppName 이라는 값을 가지고 있다. 기본값은 별도로 지정되어있지 않으므로 Null 이다. 

    // Setter
    public void setAppName(String name) { 
        this.mAppName = name;
    }

    // Getter
    public String getAppName() {
        return mAppName;
    }
}


class FirstActivity extends Activity {

    void onCreate(Bundle bundle) {
        MyApplication app = (MyApplication)getApplication;
		app.setName("MyAppName");  // 앱이 시작될 때 가장 먼저 실행되는 액티비티에서 애플리케이션 객체에 접근하여 AppName 을 지정해주고 있다. 
	}
}


class SecondActivity extends Activity {
    void onCreate(Bundle bundle) {
	    MyApplication app = (MyApplication)getApplication;

        // 애플리케이션 객체의 AppName 값을 토스트메시지로 띄워주는 코드. 
        // 그러나 app.getName() 은 상황에 따라서 Null 이 리턴될 수 있다. 따라서 이 코드는 NullPointerException 이 발생할 수 있는 잘못된 코드이다.
		Toast.makeText(this, app.getName() + " is Application Name", Toast.LENGTH_SHORT).show();  
	}
}


```

위의 예제에서 보면, 상황에 따라서 app.getName() 이 Null 이 될 수 있다고 밝혔는데, 왜 그런지 좀 더 자세히 설명해보겠다. 
일단 앱이 시작되어, FirstActivity -> SecondActivity 를 거쳐 실행되어있는 상태로 백그라운드 상태로 진입을 했고, 오랜 시간이 지났거나, 다른 앱의 실행에 필요한 메모리를 확보하기 위한 과정 등에서 "OS 에 의해 앱 프로세스가 종료" 되었다고 해보자. 


프로세스가 종료되었다는 얘기는 즉, 프로세스에 할당된 모든 메모리가 해제가 됨을 이야기한다.(여기서 백그라운드 서비스와 같은 특수한 것들은 예외가 될 수 있겠다.)
이러한 상태에서 앱을 다시 실행한다면? 


앱은 즉시 복원프로세스로 들어간다. 먼저 MyApplication 객체를 생성한다. Application 클래스 자체에는 상태저장/복원프로세스가 없다. 따라서 그냥 새롭게 생성이 될 뿐이다. 
물론 이는 개발자가 특별히 뭔가 코드를 짜서 별도의 상태저장/복원 프로세스를 만들어 두지 않았음을 전제로 한다. 
이렇게 새롭게 생성된 MyApplication 객체의 mAppName 프로퍼티가 가지는 값은? 그렇다, Null 이다. 


다음으로 Activity 들이 복원된다. 복원이 될 때에는 당연히 마지막 Activity Stack 상태에 따라 복원이 된다. 다시말해서, 마지막 화면이었던 SecondActivity 가 먼저 생성/복원이 된다. 
자 그러면.. FirstActivity 의 onCreate() 는 언제 호출이 된다는건가? 이곳에서 MyApplication.appName 을 지정해줬는데 말이다. 
FirstActivity 는 SecondActivity 에서 Back press 등을 통해 이전화면으로 돌아가려할 때, 그떄야 비로소 생성/복원되게 된다.


그러므로 SecondActivity.onCreate() 가 먼저 실행이 되며, 이떄 실행하는 코드 중 app.getName() 의 리턴값은, 기대했던 값 "MyAppName" 이 아닌 Null 이 될 것이다. 


Application 클래스를 이용하여 단순한 예를 들어놨지만, 실제로는 Lifecycle 을 가진 모든 안드로이드 컴포너트에서 주의해야 하는 일이다. 
이는 실제 내가 다뤘던 많은 레거시 코드들에서 많이 발견된 문제이기도 했다. 심지어는 이런 상황이 왜 일어나는지 제대로 알지 못하고, 급한대로 예외처리를 하고자 
`if (xx != null) restart()` 
재시작 시켜버리는 코드가 여기저기에 있던 기억이...


여기에는 class initialize 타임에 Null 이 아닌 값으로 초기화 되지 않는 static 변수들 또한 예외가 아닌다. static 변수는 프로세스의 라이프사이클 내에서 유효할 뿐이다. 그러므로 프로세스가 종료되면 static 메모리도 모두 해제가된다. 
다만 final static 의 경우는 *상수* 이므로 이 주제에는 맞지 않음을 주의하자.
그럼 일단 예제를 보자.

```java
public class FirstActivity {
    public static String name = "FiratActivity"; // class initialize 시점에 값을 할당
    public static String name2;
    public static String name3;
	public static String name4;

    static { // class initialize 시점에 값을 할당
        name2 = "FirstActivity2";
	}

    { // object initialize 시점에 값을 할당
	    name4 = "FirstActivity4";
    }


    public static String getName() {
        return name;
    }
    public static String getName2() {
        return name2;
    }
    public static String getName3() {
        return name3;
	}
    public static String getName4() {		
	    return name4;
    }

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        name3 = "FirstActivity3"; // onCreate 시점에 값을 할당
    }
}


public class SecondActivity {

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Toast.makeText(this, FirstActivity.getName(), Toast.LENGTH_SHORT).show(); // class 초기화 시점에 할당되는 값이므로, 정상적으로 할당된 값을 가져올 수 있다. 
        Toast.makeText(this, FirstActivity.getName2(), Toast.LENGTH_SHORT).show(); // 위 케이스와 동일.

        Toast.makeText(this, FirstActivity.getName3(), Toast.LENGTH_SHORT).show(); // LowMemory 시점에 OS에 의해 앱이 kill 된 후 recreate 되는 경우 getName3() 의 리턴값은 NULL 이다.
		Toast.makeText(this, FirstActivity.getName4(), Toast.LENGTH_SHORT).show(); // getName3() 과 마찬가지로 recreate 시점에서 NULL 값을 리턴한다.
    }
    
}

```

위의 예제에서 보듯 Process 의 종료/복원 프로세스에서는 static 메모리라 하여도 일반 객체들과 다를바가 없다. 
이 뿐 아니라, 내가 static 변수의 사용을 조심하라고 강조하는데는 다음과 같은 경우를 많이 보았기 때문이다. 


안드로이드에서 컴포넌트간 데이터를 주고받을 때, 일반적으로 쓰이는 데이터 타입은 Parcelable 이며 이는 Intent 를 통해 Framework 에서 제공하는 API를 이용하여 다른 컴포넌트로 전달되어질 수 있다. 
컴포넌트끼리 데이터를 주고 받을 때는 특별한 이유가 없는 한 이러한 방식을 써야만 한다. Intent 로 제공된 정보는 자동으로 액티비티의 상태저장 시점에 저장되며, 복원시점에 복원된다. 개별 액티비티가 독립적으로 생성/저장/복원/종료 될 수 있는게 안드로이드 앱 이기 때문이다. 


그러나 기존의 개발자들에게는 안드로이드 앱 라이프사이클과 데이터 교환 매커니즘이 익숙하지가 않았던게 문제다. Activity 는 new 로 객체를 생성하는 방식이 아니다. 그러다보니 액티비티 간 데이터 교환을 쉽게 처리하려다 보니 static 변수를 이용하여 Global 액세스 가능한 변수들을 남발하는 경우가 가장 큰 문제가 되었다. 
이는 디자인패턴 관점에서도 의존성을 높이는 문제도 있지만, 그런건 아무래도 상관없이, 이런 코드가 라이프사이클과 엮이면 그 존재 자체만으로도 아주 치명적인 버그양산 코드가 되는것이다.


또한 앱 개발 과정에서 싱글톤패턴의 객체를 자주 사용하는데, 당연히 프로세스 강제종료/복원 시점에 이 싱글톤 객체도 초기화가 됨을 유의해야한다. 
만약 이 싱글톤 객체가 사용자 설정값을 저장하고 있던 객체라면? 복원되고 난 이후에는 사용자가 설정한 모든 값이 초기화가 되어버릴 것이다. (메모리에만 존재하던 거라면) 따라서 이러한 경우에는 적절한 상태저장/복원 매커니즘을 별도로 구현하여야만 할 것이다.
