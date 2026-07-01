;;; -*- lexical-binding: t -*-

;; TODO: use treesitter modes? YES set this up TODAY, test with abseill
;; TODO: doxygen highlighting stuff, want "///" to highlight, not just "/// " (w/ space)
;; TODO: add org-mode stuff: daily auto-saved and auto-opened notes like at BG
;; TODO: experiment with combobulate

;; TODO: diminish and delight + use-package?
;; TODO: make seperate files for lsp/eglot?
;; TODO: setup lsp for elisp? setup paredit like old school? setup rust?
;; TODO: why don't i get the lispdoc comments and shit about not having a preamble?

;; TODO: FIX YASNIPPET CONFIG
;; TODO consider perspective.el? consider adding monky for hg support?

;; NOTE: C-o inserts line...interesting....need to remember crux stuff M-o
;; NOTE: C-x C-l downcase region....also rember mark popping with C-SPACE

;; TODO job cuopt -- series of lin constraints, build graph as a node and system of constraints is edges so you also use int value constraints 1,2,3 drones
;; graph of depo depos have supplies have trucks moving } asset effectiveness, not kills per hour

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(eval-when-compile
  (require 'use-package))

(use-package emacs
  :init (setq recenter-positions '(top middle bottom)
              load-prefer-newer t
              help-window-select t
              warning-minimum-level :emergency
              use-package-always-ensure t
              use-package-always-demand (when (daemonp) t)
              prelude-lsp-client 'lsp-mode

              projectile-enable-cmake-presets t

              ;;c-doc-comment-style 'doxygen ;; TODO work on this later, also might not work with c-ts-mode!
              ;;flycheck-global-modes '(not c-ts-mode c++-ts-mode c-mode c++-mode)
              )
  :custom
  (display-battery-mode t)
  (menu-bar-mode nil)
  (display-time-mode t)
  (global-display-line-numbers-mode nil)

  :hook (prog-mode . display-line-numbers-mode))

(use-package gcmh
  :hook (after-init . gcmh-mode)) ;; for startup performance

(use-package compile-angel
  :demand t
  :config

  (setq compile-angel-verbose t)
  (push "/init.el" compile-angel-excluded-files)
  (push "/early-init.el" compile-angel-excluded-files)
  ;; (compile-angel-on-load-mode 1)

  :hook (emacs-lisp-mode . compile-angel-on-save-local-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package cyberpunk-theme
  :init (disable-theme 'zenburn)
  :config (load-theme 'cyberpunk t)
  :custom-face
  (line-number ((t (:inherit (shadow default) :foreground "#9fc59f"))))
  (line-number-current-line ((t (:inherit line-number :background "#333333")))))

(use-package mood-line
  :config (mood-line-mode))

(use-package vterm
  :ensure t
  :bind ("C-x m" . vterm)) ;; because eshell sucks!

(use-package helm
  :init (setq helm-move-to-line-cycle-in-source nil)) ;; no C-o to move to next source

(use-package shackle
  :ensure t
  :hook (after-init . shackle-mode)
  :config
  (setq shackle-default-size 0.4
        shackle-rules
        `(
          ("\\*eldoc.*" :align t :select t :regexp t)
          ("\\*compilation.*" :align right :select t :regexp t :size 0.5)
          ;; ("\\*Flymake diagnostics.*" :align t :select t :regexp t)
          ;; TODO: have this handle help window select as well?
          )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Development
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flycheck
  :init
  (setq global-flycheck-mode nil)
  ;; ;; (setq flycheck-highlighting-mode nil)
  ;; (setq-default flycheck-indication-mode 'left-margin)
  ;; :hook(flycheck-mode . flycheck-set-indication-mode)
  )


(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt) ;; t: auto install; 'prompt: ask first; nil: do nothing
  :config
  (treesit-auto-add-to-auto-mode-alist)
  (global-treesit-auto-mode))

;; (use-package modern-cpp-font-lock
;;   :hook (c++-mode . modern-c++-font-lock-mode ))

;; TODO(BK): try incorporating this
;; https://stackoverflow.com/questions/39894233/extract-emacs-c-style-options-from-clang-format-style

;; TODO(BK): can this run alongside apheleia? do i even want apheleia?
(use-package clang-format+
  :hook (c-mode-common . clang-format+-mode) ) ;; this works just fine

(use-package evil-nerd-commenter
  :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package forge
  :init
  (setq forge-owned-accounts '(("brawndology" . nil)
                               ;; ("Brandon-Kmetz-NS" . nil)
                               ;; ("brawndo" . nil)
                               )
        auth-sources '("~/.authinfo")))

;; TODO: this should use C-x g M a after ghub-post to set the remote since the
;; context is that you have a local repo that isn't (yet) pushed upstream

(use-package ghub
  :init

  ;; FIXME: still need to use C-x g M or magit-remote-add after both of these

  (defun create-upstream-repo (repo)
    "Create empty repo with name REPO on GitHub"
    (interactive "sEnter repo name: ") ;; TODO: use read-string instead?
    (ghub-post "/user/repos" `((name . ,repo))))

  (defun smoopy ()
    "THIS SPACE FOR RENT!"
    (interactive)
    (when-let ((git-root (locate-dominating-file default-directory ".git"))
               (basename (file-name-nondirectory (directory-file-name git-root))))
      (ghub-post "/user/repos" `((name . ,basename)))

      ;; TODO: maybe check if we have remotes/origin?
      ;; TODO: extract hub:/brawndology from ssh config somehow?
      (magit-remote-add "origin" (concat "hub:/brawndology/" basename ".git"))))
  )


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

;; (use-package highlight-doxygen
;;   ;;:custom (highlight-doxygen-triple-slash-comment-regexp "/\\\\{3,\\\\}")
;;   :config (highlight-doxygen-global-mode 1))

;; https://stackoverflow.com/questions/62624352/can-i-use-gcc-compiler-and-clangd-language-server
;; https://ianyepan.github.io/posts/emacs-ide/
;; https://taingram.org/blog/emacs-lsp-ide.html

(use-package lsp-mode
  :init
  ;; (setq lsp-log-io t)
  (setq lsp-clients-clangd-args '("--background-index"
                                  "--clang-tidy"
                                  ;; "--completion-style=detailed"
                                  ;; "--parse-forwarding-functions"
                                  ;; "--fallback-style=Google"
                                  "--pretty"
                                  "--log=verbose"
                                  "--log=info"
                                  "--pch-storage=memory"
                                  "--header-insertion=never"
                                  ))

  (when (eq system-type 'gnu/linux)
    (add-to-list 'lsp-clients-clangd-args "--query-driver=/usr/bin/c++"))

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

  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-update-mode 'line
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-ignore-duplicate t

        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-delay 0.05

        lsp-ui-doc-enable t ; nil
        lsp-ui-doc-border (face-foreground 'default)
        lsp-ui-doc-header t
        lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'at-point

        lsp-ui-imenu-enable t
        lsp-eldoc-enable-hover nil)
  )

;; (use-package lsp-sonarlint
;;   :custom

;;   (lsp-sonarlint-auto-download t)
;;   (lsp-sonarlint-download-url
;;    (cond
;;     ((eq system-type 'gnu/linux)
;;      "https://github.com/SonarSource/sonarlint-vscode/releases/download/5.2.3%2B80233/sonarlint-vscode-linux-x64-5.2.3.vsix")

;;     ((eq system-type 'darwin)
;;      "https://github.com/SonarSource/sonarlint-vscode/releases/download/5.2.1%2B80172/sonarlint-vscode-darwin-x64-5.2.1.vsix")
;;     ))

;;   ;; (lsp-sonarlint-download-url
;;   ;;  (concat
;;   ;;   "https://github.com/SonarSource/sonarlint-vscode/releases/download/5.2.3%2B80233/"
;;   ;;   (cond
;;   ;;    ((eq system-type 'gnu/linux)
;;   ;;     "sonarlint-vscode-linux-x64-5.2.3.vsix")

;;   ;;    ((eq system-type 'darwin)
;;   ;;     "/sonarlint-vscode-darwin-x64-5.2.1.vsix")
;;   ;;    ))
;;   ;;  )

;;   ;;(lsp-sonarlint-use-system-jre t)
;;   (lsp-sonarlint-enabled-analyzers '("java"))
;;   (lsp-sonarlint-cfamily-compile-commands-path "${workspaceFolder}/build/compile_commands.json")

;;   (lsp-sonarlint-show-analyzer-logs t)
;;   (lsp-sonarlint-verbose-logs t)
;;   )

;; NOTE(BK): install buildifer w/ go, put ~/go/bin on path and you're done
(use-package bazel
  :config
  (setq bazel-buildifier-before-save t)
  (add-to-list 'auto-mode-alist '("\\.\\(BUILD\\)\\'" . bazel-mode)))

;; NOTE(BK): this provides a bit more featureful experience than projectile
;; NOTE(BK): this also SEEMS to be confused by conan 2 monorepos, but that's okay
;; bc that feature is bleeding edge and can probably be ignored (for now...)
(use-package cmake-integration
  :vc (:url "https://github.com/darcamo/cmake-integration.git"
	    :rev :newest))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cruft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; (defun brawndo-pop-to-compilation-buffer (buffer _why)
;;   "Pop to `*compilation*' BUFFER as part of `compilation-finish-functions'."
;;   (when (string-match-p "\\`\\*compilation\\*\\'" (buffer-name buffer))
;;     (pop-to-buffer buffer)))
;;
;; (add-to-list 'compilation-finish-functions #'brawndo-pop-to-compilation-buffer)




;; (use-package flymake
;;   :init (setq flymake-margin-indicator-position 'right-margin))

;; (use-package eglot
;;   :init
;;   ;;(setq eldoc-echo-area-use-multiline-p nil)
;;   :config
;;   (add-to-list 'eglot-server-programs
;;                ;; TODO: and semgrep..semgrep is installed locally

;;                '((c--ts-mode c++-ts-mode)
;;                  . ("clangd"
;;                     "--background-index"
;;                     "-query-driver=/usr/bin/c++"
;;                     "--clang-tidy"
;;                     "--pretty"
;;                     "--completion-style=detailed"))))

;; (use-package sideline-eglot
;;   :hook (eglot-mode . sideline-mode))

;; (use-package sideline-flymake
;;   :custom
;;   (sideline-flymake-display-mode 'line)
;;   :hook (flymake-mode . sideline-mode))

;; (use-package sideline
;;   :custom
;;   (sideline-backends-right '(sideline-eglot
;;                              ;;sideline-flymake

;;                              )))

;; (use-package kkp
;;   :ensure t
;;   :config
;;   (global-kkp-mode 1))
