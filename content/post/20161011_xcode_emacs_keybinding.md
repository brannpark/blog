+++
Categories = ["Development"]
Description = "Xcode emacs keybinding"
Tags = ["xcode", "emacs", "keybinding"]
date = "2016-10-11T14:52:05+09:00"
title = "Emacs Keybinding for Mac osx"

+++

# 시작은.. Xcode 에 Emacs keybinding 적용해보기!

Xcode 는 기본적으로 Emacs 키바인딩을 지원하지 않는다. Option 메타키를 사용하는것을 쉽사리 허용하지 않는데..

이리저리 찾아보고 하다가 최종 적용한 방법이 있어 정리해본다.

맥에서 실행되는 모든 Cocoa 어플리케이션들의 키바인딩을 오버라이딩 하는 개념으로 이해하면 된다. 따라서 Xcode 뿐 아니라

맥의 모든 프로그램(Notes, TextEdit 같은 편집기도 마찬가지!) 에서도 설정된 키바인딩으로 사용 가능하다.

다만 아래 바인딩 된 단축키셋은 기존 설정이 오버라이드 되어버리므로,

기존 Option 키를 이용한 특수기호를 입력하는게 불가능해진다는 단점이 있다... (그런기능이었는지도 몰랐...)

```
BEWARE:
This file uses the Option key as a meta key.  This has the side-effect
of overriding Mac OS keybindings for the option key, which generally
make common symbols and non-english letters.
```


## DefaultKeyBinding.dict

```bash
$ cd ~/Library
$ ls | grep KeyBindings (디렉토리가 없다면 생성)
$ cd KeyBindings
$ touch DefaultKeyBinding.dict (파일이 없다면 생성)
```

DefaultKeyBinding.dict 파일에 다음과 같이 작성.
```javascript
{
/* Keybindings for emacs emulation.  Compiled by Jacob Rus.
 *
 * To use: copy this file to ~/Library/KeyBindings/
 * after that any Cocoa applications you launch will inherit these bindings
 *
 * This is a pretty good set, especially considering that many emacs bindings
 * such as C-o, C-a, C-e, C-k, C-y, C-v, C-f, C-b, C-p, C-n, C-t, and
 * perhaps a few more, are already built into the system.
 *
 * BEWARE:
 * This file uses the Option key as a meta key.  This has the side-effect
 * of overriding Mac OS keybindings for the option key, which generally
 * make common symbols and non-english letters.
 */

/* Ctrl shortcuts */
    "^l"        = "centerSelectionInVisibleArea:";  /* C-l          Recenter */
    "^/"        = "undo:";                          /* C-/          Undo */
    "^_"        = "undo:";                          /* C-_          Undo */
    "^ "        = "setMark:";                       /* C-Spc        Set mark */
    "^\@"       = "setMark:";                       /* C-@          Set mark */
    "^w"        = "deleteToMark:";                  /* C-w          Delete to mark */
    "^y"	= "yank:";               /* C-y          Cycle through kill ring */

    /* Meta shortcuts */
    "~f"        = "moveWordForward:";               /* M-f          Move forward word */
    "~b"        = "moveWordBackward:";              /* M-b          Move backward word */
    "~<"        = "moveToBeginningOfDocument:";     /* M-<          Move to beginning of document */
    "~>"        = "moveToEndOfDocument:";           /* M->          Move to end of document */
    "~v"        = "pageUp:";                        /* M-v          Page Up */
    "~/"        = "complete:";                      /* M-/          Complete */
    "~c"        = ( "capitalizeWord:",              /* M-c          Capitalize */
                    "moveForward:",
                    "moveForward:");                                
    "~u"        = ( "uppercaseWord:",               /* M-u          Uppercase */
                    "moveForward:",
                    "moveForward:");
    "~l"        = ( "lowercaseWord:",               /* M-l          Lowercase */
                    "moveForward:",
                    "moveForward:");
    "~d"        = "deleteWordForward:";             /* M-d          Delete word forward */
    "^~h"       = "deleteWordBackward:";            /* M-C-h        Delete word backward */
    "~\U007F"   = "deleteWordBackward:";            /* M-Bksp       Delete word backward */
    "~t"        = "transposeWords:";                /* M-t          Transpose words */
    "~\@"       = ( "setMark:",                     /* M-@          Mark word */
                    "moveWordForward:",
                    "swapWithMark");
    "~h"        = ( "setMark:",                     /* M-h          Mark paragraph */
                    "moveToEndOfParagraph:",
                    "swapWithMark:");
    "~w"        = ( "deleteToMark:",
		    "yankAndSelect:",
		    "moveDown:",
		    "moveUp:");
}
```


이렇게 하면 기본적으로 TextEdit 과 같은 프로그램들에서 위에 정의된 키바인딩들이 가능해진다. 다만 순차 조합 키바인딩, 예를 들어 ^x^f(파일열기) 혹은 ^x^s(파일저장) 과 같은 키바인딩은 동작하지 않는다. (이리저리 해보았지만 결국 실패..!!)





