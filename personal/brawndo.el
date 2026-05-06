;; TODO: bytecompile? compile angel HATES lsp-mode.el.....
;; TODO: diminish and delight + use-package?
;; TODO: setup lsp for elisp? setup paredit like old school? setup rust?
;; TODO: check that my changes to the emacs prelude source stuck or are not needed
;; TODO: add custom file with font faces to repo
;; TODO: cleanup this config file and make a new branch
;; TODO: FIX YASNIPPET CONFIG
;; TODO: why don't i get the lispdoc comments and shit about not having a preamble?
;; TODO consider perspective.el? consider adding monky for hg support?

;; NOTE: C-o inserts line...interesting....need to remember crux stuff M-o
;; NOTE: C-x C-l downcase region....also rember mark popping with C-SPACE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bootstrapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(eval-when-compile
  (require 'use-package))

(use-package emacs
  :init (setq recenter-positions '(top middle bottom)
              load-prefer-newer t
              helm-move-to-line-cycle-in-source nil ;; no C-o to move to next source
              help-window-select t
              warning-minimum-level :emergency
              use-package-always-ensure t
              use-package-always-demand (when (daemonp) t))

  :custom
  (display-battery-mode t)
  (global-flycheck-mode nil)
  (menu-bar-mode nil)
  (display-time-mode t)
  (global-display-line-numbers-mode nil)

  :hook (prog-mode . display-line-numbers-mode))

(use-package gcmh
  :hook (after-init . gcmh-mode)) ;; for startup performance

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package cyberpunk-theme
  :init (disable-theme 'zenburn)
  :config (load-theme 'cyberpunk t)
  :custom-face
  (line-number ((t (:inherit (shadow default) :foreground "#9fc59f"))))
  (line-number-current-line ((t (:inherit line-number :background "#333333"))))
)

(use-package mood-line
  :config (mood-line-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Development
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package modern-cpp-font-lock
  :hook (c++-mode . modern-c++-font-lock-mode ))

;; NOTE(BK): not sure if this should be axed or combined with code from
;; https://stackoverflow.com/questions/39894233/extract-emacs-c-style-options-from-clang-format-style
(use-package clang-format+
  :hook (c++-mode . clang-format+-mode))

(defun brawndo-pop-to-compilation-buffer (buffer _why)
  "Pop to `*compilation*' BUFFER as part of `compilation-finish-functions'."
  (when (string-match-p "\\`\\*compilation\\*\\'" (buffer-name buffer))
    (pop-to-buffer buffer)))

(add-to-list 'compilation-finish-functions #'brawndo-pop-to-compilation-buffer)

(use-package evil-nerd-commenter
  :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package forge
  :init
  (setq forge-owned-accounts '(("brawndology" . nil)
                               ;; ("Brandon-Kmetz-NS" . nil)
                               ;; ("brawndo" . nil)
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

(use-package lsp-sonarlint
  :custom
  (lsp-sonarlint-auto-download t)
  (lsp-sonarlint-download-url
   (cond ((eq system-type 'gnu/linux)
          "https://github.com/SonarSource/sonarlint-vscode/releases/download/5.2.1%2B80172/sonarlint-vscode-linux-x64-5.2.1.vsix")
         ((eq system-type 'darwin)
          "https://github.com/SonarSource/sonarlint-vscode/releases/download/5.2.1%2B80172/sonarlint-vscode-darwin-x64-5.2.1.vsix")
         ))
  )

;; NOTE(BK): install buildifer w/ go, put ~/go/bin on path and you're done
(use-package bazel
  :config
  (setq bazel-buildifier-before-save t)
  (add-to-list 'auto-mode-alist '("\\.\\(BUILD\\)\\'" . bazel-mode)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cruft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; (use-package quelpa)
;; (use-package quelpa-use-package
;;   :demand
;;   :config (quelpa-use-package-activate-advice))
