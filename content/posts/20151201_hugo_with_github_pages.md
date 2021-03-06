+++
Categories = ["Development"]
Description = "Hugo와 GitHub Pages 를 이용한 블로그 구축 가이드"
Tags = ["hugo", "redlounge", "static-website-engine", "github-pages"]
date = "2015-12-01T15:36:31+09:00"
title = "Made by HUGO and GitHub Pages"
+++


일반적인 웹사이트의 경우, 여러 웹 컨텐츠들을 동적으로 생성하여 이용자에게 전달한다.

다시 말해서, 웹어플리케이션은 동적 컨텐츠를 정적 컨텐츠로 변환하는 과정을 수행한다.

그러다 보니, 이렇게 생성된 동적 컨텐츠는 일반적으로 브라우저 레벨에서의 캐싱을 이용할 수 없다. 따라서 매 페이지 요청시 마다 웹어플리케이션이 반복적인 일을 해야한다.

그런데 정적 컨텐츠가 컨텐츠의 대부분을 차지하는 사이트의 경우에 따라서는 정적 웹사이트를 만들어서 운영해 볼 수 있다. 예전에는 정말 단순하고 반복적이지 않은 소수의 페이지들을 제공하는 목적으로 사용되었는데, 요즈음에는 관련 도구들이 매우 뛰어나졌다. 그 적용 방법이 나름 재미있다.

<br>
# Hugo
[Hugo](https://gohugo.io) 는 Static Website Engine 이다. 이녀석은 사용자가 만든 컨텐츠를 이용, 이를 정적 웹사이트 컨텐츠로 만들어낸다.

또한 특정 테마를 지정하여 빠르고 쉽게 사이트의 레이아웃과 스타일을 만들어 낼 수 있다.

이 모든 과정은 사용자의 로컬 호스트에서 이뤄진다. 그러나 내 로컬에 결과물을 만들어낸 것만으로는 사이트를 인터넷에 띄울 수 없다.

이 결과물을 GitHub, Amazon S3, 기타 클라우드 스토리지(public url access 가능한) 등에 업로드 하여 내 사이트를 인터넷에 띄우게 된다.

본 블로그는 보다시피 Github Pages 를 이용하여 호스팅되고 있으며, Hugo 가이드를 마치고 호스팅에 대한 이야기를 이어 가겠다.

## Installation
설치과정은 다음과 같다.

본인은 Mac 을 쓰기에 Homebrew 를 이용한 설치 방법을 따랐지만, 그 외의 [다양한 플랫폼에 설치하는 방법](https://github.com/spf13/hugo/releases)을 제공한다.

```bash
$ brew install hugo
```

단순하다. hugo는 사이트 URL(gohugo.io) 에서도 알 수 있듯이 golang으로 작성되어있다. 따라서 의존 패키지 설치와 같은 귀찮은 과정 없이 심플하게 설치된다.

## Create Hugo Project
/usr/local/bin 에 hugo 바이너리가 위치하며 이를 이용해 새 스켈레톤 프로젝트를 생성할 수 있다.

```bash
$ cd /path/to/workspace
$ hugo new site <sitename>
```

생성된 파일 및 디렉토리 구조는 다음과 같다.

```bash
  ▸ archetypes/
  ▸ content/
  ▸ data/
  ▸ layouts/
  ▸ static/
    config.toml
```

자동 생성된 각 디렉토리에 대한 간단한 셜명을 하자면,

### archetypes
hugo new 명령어로 컨텐츠를 생성 시, 자동으로 생성되는 header 템플릿을 생성하고자 하는 컨텐츠의 타입에 맞게 커스터마이징 가능하다.

예를 들어, /content/musician 의 서브디렉토리 구조가 존재하는 경우,

/archetypes/musician.md 라는 파일을 생성하여 내용을 다음과 같이 작성한다.

만약 이름이 매칭되는 archetypes가 없고, /archetypes/default.md 가 존재하는 경우는 해당 파일의 내용을 header에 추가하게 된다.

```bash
+++
name = ""
bio = ""
genre = ""
+++
```

그리고 `hugo new musician/mozart.md` 의 명령어를 수행하면
위에 지정된 name, bio, genre 구문이 header 에 추가로 자동 생성되는 것을 확인 할 수 있다.


### content

`hugo new <path/to/>filename.md` 명령어 수행 시 생성된 마크다운 문서가 저장되는 곳


### data
사이트 생성 시 필요한 추가적인 데이터를 저장할 수 있는 곳이다.
toml 의 형식으로 variable 을 선언하고 특정 데이터를 assign 가능하다.
또한 data 디렉토리의 하위 디렉토리 구조를 이용하여 데이터의 계층구조를 만들어 낼 수 있으며 같은 디렉토리내의 여러 toml 파일들은 Array 로 처리되어진다.
좀 복잡하게 다음과 같이 data 디렉토리가 구성되어있고

`/data/human/info/a.toml`, `/data/human/info/b.toml`

각각의 a.toml, b.toml 의 내용이 다음과 같다면

**[ a.toml ]**
```toml
name = "Steve"
age = 30
```

**[ b.toml ]**
```toml
name = "Peter"
age = 20
```


이를 html 템플릿에서 다음과 같이 사용할 수 있다.

```html
{{ range $.Site.Data.human.info }}
<div>
  <p>Name : {{ .name }}</p>
  <p>Age  : {{ .age }}</p>
</div>
{{ end }}
```

### layouts
테마에서 사용되는 HTML 템플릿 파일들을 overwrite 할 수 있는 곳

### static
테마에서 사용되는 asset 을 overwrite 하거나, 추가 asset 들을 제공할 수 있는 곳 


## Select Theme

Hugo 에는 다양한 오픈소스 테마들이 존재한다.
[이곳](http://themes.gohugo.io)에서 Hugo 의 다양한 테마들을 살펴볼 수 있다.

본 블로그에 적용된 테마는 [RedLounge](http://themes.gohugo.io/redlounge/) 라는 테마이다.

먼저, 적용하고자 하는 테마의 git 저장소 URL을 확인한다. 그리고, 사이트 프로젝트 root 에서 다음과 같은 명령어들을 수행한다. 

```bash
$ mkdir themes
$ cd themes
$ git clone <repository_url_of_theme>
```

다운받은 테마를 살펴보면, 기본 구조가 `hugo new site` 를 통해 만들어진 구조와 거의 흡사하다는것을 알 수 있다.

RedLounge 테마를 기준으로 분석해보니...

content 와 data 디렉토리가 없는 대신 images 디렉토리가 존재한다.

또한, config.toml 대신 theme.toml 설정파일이 존재한다.

images 디렉토리는 Hugo의 ThemeShowcase 를 위한 이미지파일을 제공하며, theme.toml 또한 테마에 대한 설명, 버젼, 작성자 등에 대한 정보를 제공하는데에 쓰인다.

hugo 는 프로젝트를 빌드 시, 테마의 파일시스템을 임시 파일시스템위에 카피하고, 다시 이곳에 사용자 프로젝트의 파일시스템을 덮어씌운 결과물을 빌드하는 것으로 보인다. 그러므로 theme 의 레이아웃 파일을 overwrite 하고 싶다면 동일한 stucture 내의 동일한 이름의 컨텐츠 파일을 생성하여 overwrite 가능하다. 



## Configuration

`config.[toml|yaml|json]`

Hugo 프로젝트의 설정파일. toml, yaml, json 모두 사용 가능하다.
기본적인 빌드관련 설정과 테마별 추가 파라미터 변수들의 설정또한 이곳에서 처리한다.

**[ config.toml]**
```
contentdir = "content"
layoutdir = "layouts"
staticdir = "static"
publishdir = "dist"
baseurl = "http://brannpark.github.io/blog"
title = "개발지식저장소"
theme = "redlounge"
...
```

위의 내용은 본 블로그 hugo 프로젝트의 configuration 중 일부로써 여기서 중요한 부분은 publishdir, baseurl, theme 정도가 되겠다.

publishdir 의 경우 기본값은 publish 인데, 여기서는 dist 라고 지정되어있다. 이는 GitHub Pages 에 배포하기 위해 사용할 배포 스크립트가 기본적으로 소스 디렉토리 이름을 dist로 사용하기 때문이다. 관련 내용은 젤 마지막 Deploying To GitHub Pages 섹션에서 확인 할 수 있다.

baseurl 은 위와같이 본인의 블로그 사이트 베이스 url 을 입력하면 되고, theme 는 themes 디렉토리 하위의 사용할 테마 디렉토리 이름을 입력하면 된다. 참고로 RedLounge 의 경우 저장소를 그대로 clone 할 경우 디렉토리 이름이 hugo-redlounge 인데 redlounge 로 리네임하였기에 위와같이 적용하하였다.

추가 Hugo Configuration 에 대한 도큐먼트는 [이곳](https://gohugo.io/overview/configuration/)을 참조하여 확인하자.

또한 각각의 테마에서 커스텀하게 사용하는 파라미터 설정들은 guide document 에 명시되어있다. [예시(RedLounge)](https://github.com/tmaiaroto/hugo-redlounge)

## Create Page
새 페이지를 만들기 위해서는 다음과 같은 명령어를 이용한다.

```bash
$ hugo new content/newpost.md
```

혹은 서브 URL 형태로 컨텐츠를 제공 하고자 한다면,

```bash
$ hugo new content/<subdir>/newpost.md
```

와 같이 명령어를 수행하여 새 컨텐츠를 생성한다.

이렇게 생성된 md 파일은 다음과 같은 특수한 header 부분을 가진다.

```
+++
Categories = ["Development"]
Description = "Hugo와 GitHub Pages 를 이용한 블로그 구축 가이드"
Tags = ["hugo", "redlounge", "static-website-engine", "github-pages"]
date = "2015-12-01T15:36:31+09:00"
title = "Made by HUGO and GitHub Pages"
+++

<Markdown Content>
```

이는, 본 게시글에 적용된 header 로 각각은 테마와 연동되어 사이트의 UI에 표시된다.

<br>
# Deploying Site on Local

이제 사이트를 로컬환경에서 띄워 볼 준비가 되었다고 볼 수 있다.
프로젝트의 루트에서 다음과 같은 명령어를 쳐보자

```
$ hugo server -D --watch
```

그러면 config 에 설정된 baseurl 의 Host 부분이 `127.0.0.1:1313` 로 변경되어 웹서버가 띄워진다.

브라우저로 `http://localhost:1313/blog` 로 접속하여 확인 가능하다. (위에 예시로 작성된 설정파일의 baseurl 의 base path 가 **blog** 이다.)

`-D` 옵션은 웹서버를 띄우기 전 프로젝트를 빌드하는 옵션이며,

`--watch` 옵션은 특정 파일시스템에 변화가 생기면 자동으로 rebuild 해주는 옵션이다. 프로젝트 설정 변경이나, 컨텐츠를 수정하고 미리보기 시 요긴하게 쓰인다.


<br>
# GitHub Pages

[Pages](https://pages.github.com) 는 github repository 를 기반으로 웹사이트를 호스팅해주는 기능이다.

github의 username 을 이용하여, 다음과 같이 내 github.io 에 접근할 수 있다.

`http://<username>.github.io`

그러나 위와 같은 식으로 접근하여 사이트를 호스팅 하려면 다음과 같은 특수한 이름의 저장소를 만들어야 한다.

`<username>.github.io`

이 저장소의 master 브랜치에 index.html 을 만들어 remote 에 푸쉬해 두면, 위 링크 접속 시 해당 페이지를 브라우저에서 볼 수 있다.

이를 Pages 에서는 User/Organization Site 라 한다.


이와 별개로, 각각의 저장소들은 각각의 Pages 를 가질 수 있는데, 이를 Project site 라 한다.

`http://<username>.github.io/<repository_name>`

예를 들어 blog 라는 저장소를 가지고 있다면, blog 저장소에 gh-pages 라는 브랜치를 orphan 모드로 생성(기존의 브랜치, 커밋들에서 완전히 독립적인 새 브랜치)하여 index.html 만들어 remote 에 푸쉬 해 두면 

`http://<username>.github.io/blog` 에 접속 시 해당 페이지를 브라우저에서 볼 수 있다.


<br>
# Deploying to GitHub Pages

Project site 형식으로 GitHub Pages 에 블로그 사이트를 호스팅하는 예를 들겠다.

GitHub 저장소 이름이 blog 라고 한다면,

Pages 에서 호스팅되는 내 블로그 사이트의 base URL 은 다음과 같다.

`http://<username>.github.io/blog`

이 주소로 GET request 하게 되면 Pages 는 blog 라는 저장소의 gh-pages 브랜치의 index.html 을 serving 한다.
먼저, blog 저장소의 master 브랜치에는 Hugo 프로젝트가 생성되어 있다고 가정한다.

이제 gh-pages 브랜치를 생성하자. 위에 설명한 대로 orphan 모드로 생성한다.

그리고 브랜치를 git rm 명령어를 이용해 모두 삭제, add, commit 하고 origin 에 푸쉬 후, master 브랜치로 체크아웃한다. 

```
$ git clone https://github.com/<username>/blog.git
$ cd blog
$ git checkout -b --orphan gh-pages
$ git rm -rf .
$ git add .
$ git commit -am "initial commit"
$ git push origin gh-pages
$ git checkout master
```

그리고 다음과 같이 deployment script 를 내려받아 excutable 퍼미션을 할당한다.

```bash
$ wget https://github.com/X1011/git-directory-deploy/raw/master/deploy.sh && chmod +x deploy.sh
```

본인의 경우 해당 스크립트의 설정값 변경없이 바로 사용하였어도 문제없이 배포가 되었지만,

혹여나 문제가 발생하였다면 해당 스크립트에 대한 [가이드](https://github.com/X1011/git-directory-deploy)를 꼭 확인해보자.

스크립트를 다운 받았으면 hugo 를 이용해 프로젝트를 빌드하고 결과물을 deploy 스크립트를 이용해 블로그를 배포할 준비가 모두 되었다. 

```bash
$ hugo -d dist
$ ./deploy.sh
```

`hugo -d dist` 명령어를 통해 프로젝트를 빌드하여 dist에 빌드 결과물을 저장하고, `./deploy.sh` 를 이용해 gh-pages 브랜치에 배포하게 된다.

여기서 중요한것은 dist 라는 디렉토리인데, deploy 스크립트는 기본값으로 dist 라는 디렉토리를 배포 소스 디렉토리로 설정되어있다는 점이다.

어찌되었든 성공적으로 수행되었다면, 잠시 후 `http://<username>.github.io/blog` 로 접속 시 내 블로그 사이트를 볼 수 있다.

