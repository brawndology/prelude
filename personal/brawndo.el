;; NOTE(BK): requires emacs 29.1 or above

;; TODO: FIX YASNIPPET CONFIG

;; TODO: why don't i get the lispdoc comments and shit about not having a preamble?
;; TODO consider perspective.el? consider adding monky for hg support?

;; NOTE: C-o inserts line...interesting....need to remember crux stuff
;; NOTE: C-x C-l downcase region....also rember mark popping with C-SPACE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(eval-when-compile
  (require 'use-package))

(when (daemonp)
  (setq use-package-always-demand t))

(setq use-package-always-ensure t)

(use-package quelpa)
(use-package quelpa-use-package
  :demand
  :config (quelpa-use-package-activate-advice))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package gcmh
  :hook (after-init . gcmh-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package cyberpunk-theme
  :init (disable-theme 'zenburn)
  :config (load-theme 'cyberpunk t))

;; HACK(BK): cyberpunk doesn't have a face for display-line-numbers-mode!
;; copypasta these values into custom.el's custom-set-faces
;;
;;  '(line-number ((t (:inherit (shadow default) :foreground "#9fc59f"))))
;;  '(line-number-current-line ((t (:inherit line-number :background "#333333"))))

(use-package mood-line
  :config (mood-line-mode))

(setq recenter-positions '(top middle bottom)
      load-prefer-newer t
      helm-move-to-line-cycle-in-source nil ;; no C-o to move to next "source"
      help-window-select t)

(display-battery-mode t)
(global-flycheck-mode -1)
(menu-bar-mode 0)
(display-time-mode 1)

(global-display-line-numbers-mode -1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C++ config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package modern-cpp-font-lock
  :hook (c++-mode . modern-c++-font-lock-mode ))

;; NOTE(BK): not sure if this should be axed or combined with code from
;; https://stackoverflow.com/questions/39894233/extract-emacs-c-style-options-from-clang-format-style
(use-package clang-format+
  :hook (c++-mode . clang-format+-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; IDE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun brawndo-pop-to-compilation-buffer (buffer _why)
  "Pop to `*compilation*' BUFFER.
Intended as an element of `compilation-finish-functions'."
  (when (string-match-p "\\`\\*compilation\\*\\'" (buffer-name buffer))
    (pop-to-buffer buffer)))

(add-to-list 'compilation-finish-functions #'brawndo-pop-to-compilation-buffer)

(use-package evil-nerd-commenter
  :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package forge
  :init
  (setq forge-owned-accounts '(("brawndology" . nil)
                               ;; ("Brandon-Kmetz-NS" . nil)
                               )
        auth-sources '("~/.authinfo")))

;; TODO: can i declare these functions in the forge macro?

;; TODO: this should use C-x g M a after ghub-post to set the remote since the
;; context is that you have a local repo that isn't (yet) pushed upstream
(require 'ghub)
(defun create-upstream-repo (repo)
  "Create repo with name REPO on GitHub"
  (interactive "sEnter repo name: ")
  (ghub-post "/user/repos" `((name . ,repo))))

;; here we assume that you already made a local git repo and want an upstream .git
;; would STILL need C-x g M a to set our remote!

;; XXX potentially dangerous to use...
(defun smoopy ()
  ""
  (interactive "p")
  (when-let ((git-root (locate-dominating-file default-directory ".git"))
             (basename (file-name-nondirectory (directory-file-name git-root))))
    (ghub-post "/user/repos" `((name . ,basename)))))

;; NOTE: prelude auto installs hl-todo, maybe put someting in here w/ use-package
;; so LINT and other more useful things can be added WITHOUT using custom.el?

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode ))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (yas-global-mode t)

  ;;(define-key yas-minor-mode-map (kbd "<tab>") nil)
  ;;(define-key yas-minor-mode-map (kbd "C-'") #'yas-expand)

  ;;(add-to-list #'yas-snippet-dirs "snippets")
  (yas-reload-all)

  ;; TODO: what about this? i don't acutally use ido...
  ;;(setq yas-prompt-functions '(yas-ido-prompt))
  )

(use-package highlight-doxygen
  :config (highlight-doxygen-global-mode 1))

;; https://stackoverflow.com/questions/62624352/can-i-use-gcc-compiler-and-clangd-language-server
;; https://ianyepan.github.io/posts/emacs-ide/
;; https://taingram.org/blog/emacs-lsp-ide.html

(use-package lsp-mode
  :init

  ;; TODO consider query-driver for project-local variable
  (setq lsp-clients-clangd-args '("-j=12" ;; TODO: will it just default to max number of threads?
                                  "--background-index"
                                  "--clang-tidy"
                                  "--pretty"
                                  ;;"--log=verbose"
                                  "--log=info"
                                  "--pch-storage=memory"
                                  "--header-insertion=never"))

  (when (eq system-type 'gnu/linux)
    ;; TODO: if using clang, can this hurt?
    ;;(add-to-list 'lsp-clients-clangd-args "--query-driver=/usr/bin/g++")
    )

  (when (eq system-type 'darwin)
    (add-to-list 'lsp-clients-clangd-args "--query-driver=/opt/custom/gcc-devel/bin/g++")
    (setq lsp-clients-clangd-executable "/opt/local/libexec/llvm-17/bin/clangd")
    (setq lsp-clients-clangd-library-directories '("/usr/" "/opt/custom/gcc-devel/")))


  :hook (((c-mode c++-mode) . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))

  :commands lsp lsp-deferred)

(use-package helm-lsp
  :commands helm-lsp-workspace-symbol)

(use-package lsp-ui
  :bind (:map lsp-ui-mode-map
              ("C-c C-l w" . helm-lsp-workspace-symbol)
              ("C-c C-l g" . lsp-find-definition))
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-doc-header t
        lsp-ui-doc-include-signature t
        lsp-ui-doc-border (face-foreground 'default)
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-delay 0.05)

  ;; (setq lsp-ui-sideline-enable t
  ;;       lsp-ui-sideline-update-mode 'line
  ;;       lsp-ui-sideline-show-code-actions t
  ;;       lsp-ui-sideline-show-hover t
  ;;       lsp-ui-sideline-ignore-duplicate t

  ;;       lsp-ui-sideline-show-code-actions t
  ;;       lsp-ui-sideline-delay 0.05

  ;;       lsp-ui-doc-enable t ; nil
  ;;       lsp-ui-doc-border (face-foreground 'default)
  ;;       lsp-ui-doc-header t
  ;;       lsp-ui-doc-include-signature t
  ;;       lsp-ui-doc-position 'at-point

  ;;       lsp-ui-imenu-enable t
  ;;       lsp-eldoc-enable-hover nil)

  )

;; (use-package lsp-sonarlint
;;   :custom
;;   ;; Allow sonarlint to download and unzip the official VSCode extension
;;   ;; If nil, you'll have to do that yourself. See also `lsp-sonarlint-download'
;;   ;; `lsp-sonarlint-download-url' and `lsp-sonarlint-download-dir'
;;   (lsp-sonarlint-auto-download t)

;;   ;; Choose which analyzers you want enabled. By default all are enabled
;;   ;; See command `lsp-sonarlint-available-analyzers' for the full list.
;;   (lsp-sonarlint-enabled-analyzers '("java"
;;                                      "cfamily"
;;                                      "python"
;;                                      "text")))

;; NOTE(BK): install buildifer w/ go, put ~/go/bin on path and you're done
(use-package bazel
  :config
  (setq bazel-buildifier-before-save t)
  (add-to-list 'auto-mode-alist '("\\.\\(BUILD\\)\\'" . bazel-mode)))

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
