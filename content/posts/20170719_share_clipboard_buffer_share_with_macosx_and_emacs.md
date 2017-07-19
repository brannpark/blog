+++
Categories = ["Development"]
Description = "Mac osx 에서 Emacs 의 버퍼와 pbcopy pbpaste 가 연동되도록 설정하는 방법"
Tags = ["emacs", "mac-osx"]
date = "2017-07-19T14:45:52+09:00"
title = "Emacs, Mac osx 클립보드 공유"
+++

===

가끔 Mac 에서 Emacs 를 쓸 때, OS 의 clipboard 가 Emacs 의 clipboard(?) 가 별도의 공간이어서 불편함을 느꼈던 적이 많았다.

붙여넣기야... Cmd + V 를 이용하면 된다지만, Emacs 상의 텍스트 블록을 복사해서 다른 Mac 어플리케이션에 붙여넣기를 하려면 마우스를 이용해서 드래깅하여 영역을 지정하고 Cmd + C 키를 이용하여 복사하여야만 했고, Emacs 의 창이 분할이 되어있는 경우라면(가로분할), 먼저 해당 창을 닫지 않으면 마우스로 여러줄을 복사해야 할때, 다른창의 글자까지 복사가 되어버린다. (실제 OS 의 '창' 이 아니기 때문)

이럴때는 다음과 같은 설정을 통해 OS 와 Emacs 의 Clipboard 가 공유되게(실제로는 공유 되는 것 "처럼") 만들 수 있다.

### Guide

먼저 본인의 이맥스 설정파일을 연다. (이 파일이 없다면, 새로 생성하면 된다.)

```bash
$ emacs ~/.emacs
```

그리고는 아래와 같이 적당한 위치에 다음의 코드를 삽입한다.

![.Emacs 설정파일](/blog/img/emacs_clipboard_with_osx/emacs_pbpaste.png)

```lisp
;; pbcopy for OSX
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))
(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)
```

그리고 Emacs 를 리스타트 하면 설정 끝!





