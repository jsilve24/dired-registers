# dired-registers
Evil-like registers for dired 
 
* No dependence on evil
* Functions can be used outside of dired as well
 
# Slightly more detail
I like emacs bookmarks but I rarely want to create something so permanent to just hold my place when moving between directories (e.g., when copying and pasting files between directories; see [dired-copy-paste](https://github.com/jsilve24/dired-copy-paste) for more on copying and pasting in dired). This package lowers the barrier to keeping your place by implementing registers storing a directory and making it easy to jump back later. Think of these registers like temporary bookmarks that don't persist between sessions (just like evil registers). 

# Install and Configuration Example
The following use-package snippet uses straight to install the package and then set some registers I use frequently. 

```
(use-package dired-registers
  :straight (dired-registers :type git :host github :repo "jsilve24/dired-registers")
  :config
  (dired-registers-store ?d "~/Downloads/")
  (dired-registers-store ?h "~/")
  (dired-registers-store ?c "~/.emacs.d/")
  (dired-registers-store ?g "~/Dropbox/Faculty/Grants/")
  (dired-registers-store ?t "~/Dropbox/Faculty/Teaching/")
  (dired-registers-store ?p "~/Dropbox/Faculty/Presentations/")
  (dired-registers-store ?o "~/Dropbox/org/"))
  ```
  
There are two main functions and one helper function in this package. The main functions are 

* `dired-registers-store` which, when called interactively, prompts the user for a character (a-z) then stores the current value of `default-directory` in that register. 
* `dired-registers-goto` which, when called interactively, prompts the user for a character (a-z) and then jumps to the directory stored in that register. Also, if currently visited buffer has major-mode `dired-mode` then moves current buffer rather than cluttering things up by creating a new dired buffer. If not a dired buffer, then creates a new dired buffer (to avoid overwriting another dired buffer you may be looking at in a different window). 

Beyond these main functions, users can also use the function `dired-registers-goto-completing-read` to view the registers and jump using completing-read. 

## My Bindings for This Package
The following uses `general.el` for binding. 

I bind the following for quick use in dired-mode. 
```
(general-define-key 
 :states 'normal
 :keymaps 'dired-mode-map
 ";m" #'dired-registers-store
 ";j" #'dired-registers-goto)
```

I bind the following for use everywhere under my leader key (`SPC`). 
```
(jds/leader-def
  "j" '(:ignore t :which-key "jump")
  "j RET" #'dired-registers-goto-completing-read
  "j m"   #'dired-registers-store
  "j j"   #'dired-registers-goto)
```
