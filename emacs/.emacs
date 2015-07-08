(add-to-list 'exec-path "/opt/local/bin")
(setenv "CVS_RSH" "ssh")
(setenv "TMPDIR" "/tmp")
(setenv "CVS_RSH" "SSH_PROXY" "int")
(setenv "PATH" "PATH=/Users/halien/.cask/bin:/opt/local/bin:/opt/local/sbin:/opt/local/lib/mysql51/bin/:/System/Library/Perl/5.12:/System/Library/Perl/5.10:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/git/bin")

;; make sure copy&paste with Cyrillic work
(setq selection-coding-system 'compound-text-with-extensions)

;; imenu hooks
(add-hook 'cperl-mode (function imenu-add-menubar-index))
(add-hook 'c-mode (function imenu-add-menubar-index))

(transient-mark-mode t)
(tool-bar-mode 0)
(scroll-bar-mode 1)
;; (set-default-font "-*-terminus-medium-r-normal-*-16-*-*-*-*-*-*-*")

;; configure perl-mode
(add-to-list 'auto-mode-alist '("\\.t\\'" . cperl-mode))
(add-to-list 'auto-mode-alist '("\\.psgi\\'" . cperl-mode))
(defalias 'perl-mode 'cperl-mode)

;; modes
;;(require 'java-mode)
;;(require html-mode)

;; (load-library ~/extraedit.el)
;; (load-library /usr/share/emacs22/site-lisp/haskell-mode/haskell-ghci.elc)
;;(require 'haskell-mode)

;;(load-library "erlang/erlang")
;;(require 'erlang-start)

;; configure php
(load-library "~/.emacs.d/php-mode.el")
;;(setq interpreter-mode-alist
;;      (cons '("php" . php-mode) interpreter-mode-alist))

(add-to-list 'load-path "/Users/bturchik/.emacs.d/color-theme-6.6.0")
(require 'color-theme)

(add-to-list 'load-path "/Users/bturchik/Tools/emacs")
(require 'sr-speedbar)
(setq speedbar-use-images nil)
(custom-set-faces
 '(speedbar-button-face ((t (:foreground "lightgray"))) t)
 '(speedbar-directory-face ((t (:foreground "yellow"))) t)
 '(speedbar-file-face ((t (:foreground "DeepSkyBlue"))) t)
 '(speedbar-selected-face ((t (:foreground "cyan"))) t)
 '(speedbar-tag-face ((t (:foreground "LightBlue"))) t)
 '(speedbar-highlight-face ((t (:foreground "white" :background "DodgerBlue"))) t)
 )

(add-to-list 'load-path "~/.emacs.d/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d//ac-dict")
(ac-config-default)
(setq ac-auto-start nil)
(setq ac-timer 1.0)
(setq ac-delay 0.3)
(setq ac-sources (list 'ac-source-filename 'ac-source-words-in-same-mode-buffers))
(global-set-key "\M-/" 'auto-complete)
(auto-complete-mode t)
(global-auto-complete-mode t)

;; save all temp files locally
(setq backup-directory-alist
      `((".*" . "~/tmp")))
(setq auto-save-file-name-transforms
      `((".*" "~/tmp" t)))

;; this is to start working from 24.4 - save on focus loss
(defun save-all ()
  (interactive)
  (save-some-buffers t))
(add-hook 'focus-out-hook 'save-all)

;; Enable autocomplete everywhere

(defun auto-complete-mode-maybe ()
  "No maybe for you. Only AC!"
  (unless (minibufferp (current-buffer))
    (auto-complete-mode 1)))

;; OR except minibuffer

;;(defun auto-complete-mode-maybe ()
;;   "No maybe for you. Only AC!"
;;   (unless (minibufferp (current-buffer))
;;     (auto-complete-mode 1)))


;; (add-hook 'cperl-mode-hook
;;           (lambda()
;;             (require 'perl-completion)
;;             (perl-completion-mode t)))

;; (eval-after-load "color-theme"
;; 	'(progn
;; 		(color-theme-initialize)
;; 		(color-theme-hober)))
(color-theme-initialize)
(color-theme-dark-blue2)

;; highlight buffer setup
;; (hi-lock-mode 1)
(if (functionp 'global-hi-lock-mode)
    (global-hi-lock-mode 1)
  (hi-lock-mode 1))

;; C style settings for RMAS
(add-hook 'c-mode-hook
          (function (lambda()
                      (if (string-match "rmassrc" (buffer-file-name))
                          (setq tab-width 4
                                c-basic-offset 4
                                indent-tabs-mode 1)))))

;; PHP style settings for SOAP
(add-hook 'php-mode-hook
          (function (lambda()
                      (if (string-match "soap" (buffer-file-name))
                          (setq tab-width 4
                                c-basic-offset 4
                                indent-tabs-mode nil)))))

(setq-default  
 ;; Tell me if I use M-x <command-name> when there was a key binding for it 
 teach-extended-commands-p t)

(custom-set-variables
 ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
 ;; Your init file should contain only one such instance.
 '(c-basic-offset 4)
 '(column-number-mode t)
 '(cperl-continued-statement-offset 4)
 '(cperl-indent-level 4)
 '(global-auto-revert-mode t nil (autorevert))
 '(global-font-lock-mode t nil (font-lock))
 '(grep-find-command "find . -not -path \"*svn*\" -not -name \"*~*\" -type f -print0 | xargs -0 -e grep -n -e ")
 '(imenu-sort-function (quote imenu--sort-by-name))
 '(indent-tabs-mode nil)
 '(ispell-program-name "aspell")
 '(midnight-mode t nil (midnight))
 '(mouse-wheel-mode t nil (mwheel))
 '(visible-bell t)
 '(c-workfile-version "1"))

;; vertical buffers split
;; (setq split-height-threshold nil)
;; (setq split-width-threshold 0)

(fset 'yes-or-no-p 'y-or-n-p)

;; no ~<filename> backups
(setq make-backup-files nil)

(defun vc-svn-workfile-version (file) nil)

(defun vc-svn-smerge-start-session (param) nil)

(defun smerge-start-session () nil)

;; (require 'vc-hooks)
;; cut/paste vertical selection
;; cut: Ctrl+x, r, k
;; paste: Ctrl+x, r, y
;; select from the top left to bottom right corners of rectangle

;; Create Cyrillic-CP1251 Language Environment menu item
(define-coding-system-alias 'windows-1251 'cp1251)
(set-language-info-alist "Cyrillic-CP1251" `((charset cyrillic-iso8859-5)
                                             ;;(coding-system cp1251)
                                             ;;(coding-priority cp1251)
                                             (input-method . "cyrillic-jcuken")
                                             (features cyril-util)
                                             (unibyte-display . cp1251)
                                             (sample-text . "Russian (Русский) Здравствуйте!")
                                             (documentation . "Support for Cyrillic CP1251."))
                         '("Cyrillic"))

;; experiments
(require 'paren) (show-paren-mode t)
(setq c-hungry-delete-key t)

(require 'tramp)
(setq tramp-default-method "ssh")
;;You can also specify different methods for certain user/host combinations:
;;(add-to-list 'tramp-default-method-alist '("" "john" "ssh"))

'(py-pychecker-command "pychecker")
'(py-pychecker-command-args (quote ("")))
'(python-check-command "pychecker")

(defvar sys-perl-lib "/Users/halien/devel/uservice/uslicer/:/Users/halien/devel/uservice/uslicer/Paraquestor:/Users/halien/devel/uservice/uslicer/API/REST/lib:/Users/halien/devel/uservice/uslicer/API/REST:/Users/halien/devel/uservice/uslicer/UI/lib:/Library/Perl/5.12/darwin-thread-multi-2level:/Library/Perl/5.12:/Network/Library/Perl/5.12/darwin-thread-multi-2level:/Network/Library/Perl/5.12:/Library/Perl/Updates/5.12.4/darwin-thread-multi-2level:/Library/Perl/Updates/5.12.4:/System/Library/Perl/5.12/darwin-thread-multi-2level:/System/Library/Perl/5.12:/System/Library/Perl/Extras/5.12/darwin-thread-multi-2level:/System/Library/Perl/Extras/5.12")
(defvar pservice-code-path (concat (getenv "HOME") "/devel/uservice/uslicer/"))
(setenv "PERL5LIB" (concat sys-perl-lib
                           ":" pservice-code-path
                           ":" pservice-code-path "Paraquestor" 
                           ":" pservice-code-path "API/REST/lib" 
                           ":" pservice-code-path "API/REST" 
                           ":" pservice-code-path "UI/lib"))

;; (load-library "~/.emacs.d/flymake.el")

;; (require 'flymake)

;; (setq flymake-run-in-place nil)
;; ;; This lets me say where my temp dir is.
;; (setq temporary-file-directory "/tmp/")

;; (setq flymake-log-file-name "/tmp/fly.log")
;; (setq flymake-log-level -1)

;; (custom-set-faces
;;  '(flymake-errline ((((class color)) (:background "red"))))
;;  '(flymake-warnline ((((class color)) (:background "yellow")))))

;; ;; (defun flymake-simple-cleanup ()
;; ;;   "Do cleanup after `flymake-init-create-temp-buffer-copy'.
;; ;; Delete temp file."
;; ;;   (flymake-safe-delete-file flymake-temp-source-file-name)
;; ;;   (setq flymake-last-change-time nil))


;; ;; I want to see all errors for the line.
;; (setq flymake-number-of-errors-to-display nil)

;; (add-to-list 'flymake-allowed-file-name-masks 
;;              '("\\.t\\'" flymake-perl-init)
;;              '("\\.tpl\\'" flymake-xml-init))

;; (defun flymake-perl-init ()
;;   (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-copy))
;; 	 (local-file  (file-relative-name
;;                        temp-file
;;                        (file-name-directory buffer-file-name)))
;;          (lib-dir     (file-name-directory buffer-file-name)))
;;     (list "perl" (list (concat "-I" lib-dir ".. ") "-wc " local-file))))

;; ;;(flymake-mode t)
;; ;;(defun libs-list () (list "~/devel/bayse/pservice"))

;; ;;(flymake-get-project-include-dirs-function libs-list)
;; (add-hook 'find-file-hook 'flymake-find-file-hook)
;; (global-set-key [?\C-c ?\C-/] 'flymake-display-err-menu-for-current-line)
;; (global-set-key [?\C-c ?\C-,] 'flymake-goto-prev-error)
;; (global-set-key [?\C-c ?\C-.] 'flymake-goto-next-error)

;; (defun flymake-pyflakes-init () 
;;   (let* ((temp-file (flymake-init-create-temp-buffer-copy 
;;                      'flymake-create-temp-copy)) 
;;          (local-file (file-relative-name 
;;                       temp-file 
;;                       (file-name-directory buffer-file-name)))) 
;;     (list "pyflakes" (list local-file))))


;; (add-to-list 'flymake-allowed-file-name-masks 
;;              '("\\.py\\'" flymake-pyflakes-init))

(global-set-key (kbd "<backtab>") 'align-regexp)

(global-set-key (kbd "C-c f") 'rgrep)
(global-set-key (kbd "C-c s") 'occur)
(global-set-key (kbd "C-c C-f") 'rgrep)
(global-set-key (kbd "C-c C-s") 'occur)

(global-set-key (kbd "C-c o") 'speedbar)

(global-set-key (kbd "C-x C-\\") 'indent-region)
(global-set-key (kbd "C-|") 'indent-region)
(global-set-key (kbd "C-x C-/") 'indent-region)

(global-set-key (kbd "C-#") 'comment-region)
(global-set-key (kbd "C-M-#") 'uncomment-region)

;; http://www.emacswiki.org/emacs/NavigatingParentheses
(global-set-key (kbd "C-{") 'backward-sexp)
(global-set-key (kbd "C-}") 'forward-sexp)
(global-set-key (kbd "C-<") 'backward-sexp)
(global-set-key (kbd "C->") 'forward-sexp)

(global-set-key (kbd "C-<left>") 'beginning-of-line)                                 
(global-set-key (kbd "C-<right>") 'end-of-line) 

(global-set-key (kbd "M-<left>") 'backward-word)                                 
(global-set-key (kbd "M-<right>") 'forward-word) 
(global-set-key (kbd "M-<down>") (kbd "C-<down>"))
(global-set-key (kbd "M-<up>") (kbd "C-<up>"))

(global-set-key (kbd "C-a") (kbd "C-x h"))
(global-set-key (kbd "C-v") (kbd "C-y"))

;; values can be 'control, 'alt, 'meta, 'super, 'hyper, nil (setting to nil allows the OS to assign values)
(setq mac-command-modifier 'control)
;;(setq mac-option-modifier 'control)
(global-set-key (kbd "╠") (kbd "~"))
(global-set-key (kbd "╖") (kbd "`"))
(global-set-key (kbd "s-/") (kbd "M-/"))

(normal-erase-is-backspace-mode 1)
;;(setq ns-function-modifier 'hyper)
;;(global-set-key [(hyper delete)] 'delete-char)

;; C-x r s char - copy selection to <char>-named register
;; C-x r i char - paste from <char>-named register
;; (global-set-key [(control shift f)] 'find-name-dired) - bind to name-search

;; help pasting unicode
(set-selection-coding-system 'utf-8)

(load-file "~/.emacs.d/git-grep.el")
(global-set-key (kbd "C-c g") 'git-grep)

;; copy buffer browser
;;(require 'browse-kill-ring)
;;(global-set-key (kbd "C-c C-k") 'browse-kill-ring)

;;(add-to-list 'load-path "~/.emacs.d/el-get/")
;;(add-to-list 'load-path "/usr/share/emacs/site-lisp/el-get/")
;;(load-library "~/.emacs.d/el-get/csv-mode/csv-mode")
;;(load-library "el-get/el-get")
;;(load-library "~/conf/yasnippet/yasnippet.el")
;;(el-get 'sync)

;;(load-library "~/.emacs.d/markdown-mode.el")
;;(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;(load-file "/home/halien/conf/iponweb.el")
(add-to-list 'auto-mode-alist '("\\.tt\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\'" . html-mode))
(add-to-list 'auto-mode-alist '("\\.inc\\'" . html-mode))

(add-hook 'cperl-mode (lambda () (electric-indent-local-mode -1)))

(defun my-tab-indent ()
  (setq tab-width 4
        indent-tabs-mode nil
        js-indent-level 4))

(add-hook 'html-mode-hook
          'my-tab-indent)

(add-hook 'js-mode-hook 
          'my-tab-indent)

(add-hook 'javascript-mode-hook
          'my-tab-indent)

(add-hook 'css-mode-hook
          'my-tab-indent)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)

;;(setq tramp-shell-prompt-pattern "\\(?:^\\|\\)[^]#$%>\n]*#?[]#$%>]+ *\\(\\[[0-9;]*[a-zA-Z] *\\)*")
