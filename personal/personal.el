;;; modes
(add-to-list 'auto-mode-alist '("Rakefile" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.el$" . emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("COMMIT_EDITMSG" . diff-mode))
(add-to-list 'auto-mode-alist '("\\.slim$" . slim-mode))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.mdml$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.slidedown$" . markdown-mode))

(setq rinari-minor-mode-prefixes (list "'"))
(global-rinari-mode)
(menu-bar-mode)

(transient-mark-mode t)
(setq default-major-mode 'text-mode)

;; tabs
(setq-default indent-tabs-mode nil)

;; appearance
(line-number-mode t)
(global-linum-mode t)

(add-hook 'font-lock-mode-hook
          '(lambda ()
             (unless (string-equal "org-mode" major-mode)
               ;; in order, match one-line '[TODO ... ]', two-line '[TODO ...\n ... ]'
               ;; then one-line 'TODO ...'
               (font-lock-add-keywords
                nil ;; mode name
                '(("\\[\\(XXX\\|TODO\\|FIXME\\).*\\]\\|\\[\\(XXX\\|TODO\\|FIXME\\).*
 ?.*\\]\\|\\(XXX\\|TODO\\|FIXME\\).*$"
                   0 font-lock-warning-face t)))
               )))


(defun mike:set-theme (theme)
  (load-theme theme)
  (setq mike:theme theme))

(defun mike:next-color-theme ()
  (interactive)
  (if (eq mike:theme 'solarized-dark)
      (mike:set-theme 'solarized-light)
    (mike:set-theme 'solarized-dark)))

(mike:set-theme 'solarized-dark)



;;; i loves me some emacs server.
(cond (window-system
       (server-start)
       ;;; and edit-server for the chrome edit-with-emacs extension
       (require `edit-server)
       (edit-server-start)
))

;; save desktop only when in windowing mode, to avoid getting prompted for
;; saving by 'emacs -nw', which is what my EDITOR envvar is set to (which
;; is used by git, svn, etc.)
(when window-system
  (desktop-save-mode 1)
  (run-with-idle-timer 30 t (lambda () (desktop-save-in-desktop-dir)))
  )

;;;  let's try global-auto-revert in case i need to pair program
;;;  also mo'better auto-save behavior
(global-auto-revert-mode 1)
(setq auto-save-timeout 1)
(setq auto-save-visited-file-name t)

;;  move autosave files somewhere out of the directory path
;;  http://amitp.blogspot.com/2007/03/emacs-move-autosave-and-backup-files.html
(defvar user-temporary-file-directory "~/.emacs.d/auto-save")
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
        (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))



;;;;;;;;;;
;;;  some nice font shit
;;;;;;;;;;
(cond (window-system
       (defun what-font ()
         (interactive)
         (message (frame-parameter nil 'font)))

       (setq mike:font-face nil)
       (setq mike:font-size nil)

       (defun mike:set-font-face (face)
         (interactive "MFont name: ")
         (setq mike:font-face face)
         (mike:enact-font))

       (defun mike:set-font-size (size)
         (interactive "nFont size: ")
         (setq mike:font-size size)
         (mike:enact-font))

       (defun mike:enact-font ()
         (if (and mike:font-face mike:font-size)
             (let* ((font (concat mike:font-face "-" (number-to-string mike:font-size))))
               (set-default-font font)
               (prin1 font))))

       (defun mike:modify-font-size (increment)
         (setq mike:font-size (+ mike:font-size increment))
         (mike:enact-font))

       (defun mike:increase-font-size ()
         (interactive)
         (mike:modify-font-size 1))

       (defun mike:decrease-font-size ()
         (interactive)
         (mike:modify-font-size -1))

       (mike:set-font-size 12)
       (mike:set-font-face "Menlo")
       ))


;;;
;;;  @jvshahid's magic hide-show / folding hack. seriously awesome.
;;;
(defun toggle-magic-code-folding (&optional delta)
  "Trigger selective display to hide lines that have more indentation than the current line. If DELTA was provided it will be added to the current line's indentation."
  (interactive "P")
  (let ((indentation (current-indentation)))
    (if selective-display
        (set-selective-display nil)
      (set-selective-display (+ indentation 1
                                (if delta delta 0))))))


;;
;;  key bindings
;;
(define-key global-map (kbd "C-c C-h") 'toggle-magic-code-folding)
(global-set-key "\C-c;" 'comment-or-uncomment-region)
(global-set-key [?\C-+] 'mike:increase-font-size)
(global-set-key [?\C--] 'mike:decrease-font-size)
(global-set-key "\C-cj" 'join-line)
(global-set-key "\C-c=" 'mike:next-color-theme)
(global-set-key "\C-x\C-w" 'kill-rectangle)
(global-set-key "\C-x\C-y" 'yank-rectangle)
(global-set-key "\C-c\t" 'tab-to-tab-stop)
(global-set-key "\C-c\C-l" 'longlines-mode)

;;; i like underscore as a word delimiter, sorry.
(modify-syntax-entry ?_  "_" )


;; TODO
;; text-mode-hook, markdown-mode-hook, org-mode-hook
;;              (local-set-key "\C-c\C-l" 'longlines-mode)
