;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Cruft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package simple-modeline
;;   :hook (after-init . simple-modeline-mode))

;; (use-package rmsbolt) ;; FIXME maybe need to change the bindings? it uses C-c C-c..

(defun which-active-modes ()
  "Give a message of which minor modes are enabled in the current buffer."
  (interactive)
  (let ((active-modes))
    (mapc (lambda (mode) (condition-case nil
                             (if (and (symbolp mode) (symbol-value mode))
                                 (add-to-list 'active-modes mode))
                           (error nil) ))
          minor-mode-list)
    (message "Active modes are %s" active-modes)))

;; NOTE(BK): as of emacs 29.1, use-package is builtin!

;; (unless (package-installed-p 'use-package)
;;   (unless package-archive-contents
;;     (package-refresh-contents))
;;   (package-install 'use-package))

;;(use-package vscode-dark-plus-theme)
;;(use-package tron-legacy-theme)
;;(use-package clues-theme)
;;(use-package github-theme)
;;(use-package darkokai-theme)
;;(use-package spacemacs-theme)

;; (use-package dashboard
;;   :config
;;   (dashboard-setup-startup-hook)
;;   ;; Edits
;;   (setq dashboard-banner-logo-title "Welcome, my master. They shall look upon our works and des
;; pair!")
;;   (setq dashboard-startup-banner 'logo)
;;   (setq dashboard-items '((recents   . 5)
;;                           (bookmarks . 5)
;;                           (agenda    . 5))))

;; XXX  https://github.com/hedronvision/bazel-compile-commands-extractor

;; (setq warning-minimum-level :emergency)
