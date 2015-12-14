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

Application 객체는 앱이 백그라운드에 진입해 있는 동안 시스템에 의해 recreate 될 수 있다. 그러므로 Application 의 적절한 라이프사이클(onCreate 같은)이 아닌 개별 액티비티의 라이프 사이클 내에서 Application 객체의 상태를 지정하는 코드는 위험하다. 사실 Application 객체 뿐 아니라, 모든 Activity 객체들에도 해당하는 말이다.

```java
class MyApplication extends Application {
    private String mName;

    public void setName(String name) {
        this.mName = name;
    }

    public String getName() {
        return mName;
    }
}


class FirstActivity extends Activity {

    void onCreate(Bundle bundle) {
        MyApplication app = (MyApplication)getApplication;
		app.setName("AppName");
	}
}


class SecondActivity extends Activity {
    void onCreate(Bundle bundle) {
	    MyApplication app = (MyApplication)getApplication;
		Toast.makeText(this, app.getName() + " is Application Name", Toast.LENGTH_SHORT).show();  //  <-- app.getName() 은 상황에 따라서 Null 이 리턴될 수 있다. 따라서 이 코드는 NullPointerException 이 발생할 수 있는 잘못된 코드이다.
	}
}


```


static 변수들 또한 Device low memory 시점에 OS에 의해서 앱이 kill 되며 GC 될 수 있다. 따라서 singletone 패턴으로 사용되지 않는 static 객체 사용에 유의해야 한다. static 에 객체를 유지하고자 한다면 값이 assign 되는 시점이 액티비티의 적절한 라이프 사이클 내에 위치 시키거나 class load 타임 또는 객체 initialize 타임에 assign 될 수 있도록 해야한다.


```java
public class MainActivity extends AppCompatActivity {
    public static String name = "MainActivity"; // class initialize 시점에 값을 할당
    public static String name2;
    public static String name3;
	public static String name4;

    static { // class initialize 시점에 값을 할당
        name2 = "MainActivity2";
	}

    { // object initialize 시점에 값을 할당
	    name4 = "MainActivity4";
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(MainActivity.this, SecondActivity.class);
                startActivity(intent);
            }
        });

        name3 = "MainActivity3";
    }
}


public class SecondActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_second);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = (FloatingActionButton) findViewById(R.id.fab);
        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        });

        Toast.makeText(this, MainActivity.getName(), Toast.LENGTH_SHORT).show();
        Toast.makeText(this, MainActivity.getName2(), Toast.LENGTH_SHORT).show();
        Toast.makeText(this, MainActivity.getName3(), Toast.LENGTH_SHORT).show(); // LowMemory 시점에 OS에 의해 앱이 kill 된 후 recreate 되는 경우 getName3() 의 리턴값은 NULL 이다.
		Toast.makeText(this, MainActivity.getName4(), Toast.LENGTH_SHORT).show(); // getName3() 과 마찬가지로 recreate 시점에서 NULL 값을 리턴한다.
    }
    
}

```

위의 예제코드를 검증해보기 위해서는, 먼저 에뮬레이터를 띄워 앱을 실행 후 메인액티비티 화면에서 FAB 을 터치하여 SecondActivity 로 화면을 전환한 다음,
홈(HOME)버튼을 터치하여 앱을 백그라운드로 보낸다.
그리고 DDMS 를 이용하여 나의 앱 프로세스를 stop 버튼을 이용해 강제 종료시킨다.
그리고 다시 에뮬레이터에서 앱 히스토리 목록을 열고 앱으로 돌아가게 되면, 마지막 세번째 토스트의 경우 빈 문자열로 토스트 메시지가 뜨는 것을 확인 할 수 있다.


