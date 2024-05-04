;; NOTE(BK): requires emacs 29.1 or above

;; TODO: figure out why packages are lazily installed?
;; TODO: find config for slime/lisp mode....smartparens...
;; TODO setup lisp mode with parens on braces! like the OLD DAYS!

;; TODO consider perspective.el?
;; TODO treemacs
;; TODO consider adding monky for hg support?

;; NOTE: C-o inserts line...interesting....need to remember crux stuff
;; NOTE: C-x C-l downcase region....also rember mark popping with C-SPACE

;; TODO: should i put a use-package decl in here to force cmake-mode installation?
;; melpa very freakily auto-installed it when I opened a CMakeLists.txt... also
;; wondering if i should install the cmake intellisense crap from melpa?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package gcmh
  :hook (after-init . gcmh-mode))

;; (setq warning-minimum-level :emergency)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO is this really necessary?
(disable-theme 'zenburn) ;; NOTE(BK): must disable so prelude respects our theme

;;(use-package vscode-dark-plus-theme
;;  :config (load-theme 'vscode-dark-plus t))

;;(use-package tron-legacy-theme
;;  :config (load-theme 'tron-legacy t))

(use-package cyberpunk-theme
  :config (load-theme 'cyberpunk t))

;; HACK(BK): cyberpunk doesn't have a face for display-line-numbers-mode!
;; this should go in custom.el if it isn't there already
;;
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;
;;  '(line-number ((t (:inherit (shadow default) :foreground "#9fc59f"))))
;;  '(line-number-current-line ((t (:inherit line-number :background "#333333"))))
;; )

(setq recenter-positions '(top middle bottom))
(setq load-prefer-newer t)
(setq helm-move-to-line-cycle-in-source nil) ;; no C-o to move to next "source"
(setq help-window-select t)

;; TODO  fix cyberpunk theme
(use-package simple-modeline
  :hook (after-init . simple-modeline-mode))

(menu-bar-mode 0)
(display-time-mode 1)

(global-display-line-numbers-mode -1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compilation buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; NOTE(BK): shamelessly stolen from https://stackoverflow.com/a/73760499
;;(add-hook 'compilation-start-hook 'compilation-started)
;;(add-hook 'compilation-finish-functions 'hide-compile-buffer-if-successful)

;; TODO want to make just give focus to the comp buffer so i can close it whenever?
(defcustom auto-hide-compile-buffer-delay 2
  "Time in seconds before auto hiding compile buffer."
  :group 'compilation
  :type 'number)

(defun hide-compile-buffer-if-successful (buffer string)
  (setq compilation-total-time (time-subtract nil compilation-start-time))
  (setq time-str (concat " (Time: " (format-time-string "%s.%3N" compilation-total-time) "s)"))

  (if
      (with-current-buffer buffer
        (setq warnings (eval compilation-num-warnings-found))
        (setq warnings-str (concat " (Warnings: " (number-to-string warnings) ")"))
        (setq errors (eval compilation-num-errors-found))

        (if (eq errors 0) nil t))

      ;;If Errors then
      (message (concat "Compiled with Errors" warnings-str time-str))

    ;;If Compiled Successfully or with Warnings then
    (progn
      (bury-buffer buffer)
      (run-with-timer auto-hide-compile-buffer-delay nil 'delete-window (get-buffer-window buffer 'visible))
      (message (concat "Compiled Successfully" warnings-str time-str)))))

(make-variable-buffer-local 'compilation-start-time)
(defun compilation-started (proc)
  (setq compilation-start-time (current-time)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C++ config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package rmsbolt) ;; FIXME maybe need to change the bindings? it uses C-c C-c..

(use-package modern-cpp-font-lock
  :hook
  (c++-mode . modern-c++-font-lock-mode ))

;; NOTE(BK): not sure if this should be axed or combined with code from
;; https://stackoverflow.com/questions/39894233/extract-emacs-c-style-options-from-clang-format-style
(use-package clang-format+
  :config
  :hook (c++-mode . clang-format+-mode) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; IDE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package forge
  :config
  (setq forge-owned-accounts '(("brawndology")))
  (setq auth-sources '("~/.authinfo")))

;; TODO: this should use C-x g M a after the ghub-post to set the remote
;; this makes sense because the context here is that you have already started
;; working on some code, and now you want to add it to a repo and have that repo
;; be pushed upstream
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

;; NOTE(BK): default 'alien' method doesn't respect ignoring files/directories in .projectile
;;(setq projectile-indexing-method 'native)

(defun my-pop-to-compilation-buffer (buffer _why)
  "Pop to `*compilation*' BUFFER.
Intended as an element of `compilation-finish-functions'."
  (when (string-match-p "\\`\\*compilation\\*\\'" (buffer-name buffer))
    (pop-to-buffer buffer)))

(add-to-list 'compilation-finish-functions #'my-pop-to-compilation-buffer)

(use-package git-gutter
  :hook
  (prog-mode . git-gutter-mode ))

;; (use-package yasnippet-snippets
;;   :after yasnippet)

;; (use-package yasnippet
;;   :diminish yas-minor-mode
;;   :config
;;   (yas-global-mode t)
;;   (yas-reload-all)

;;   ;;(define-key yas-minor-mode-map (kbd "<tab>") nil)
;;   ;;(define-key yas-minor-mode-map (kbd "C-'") #'yas-expand)

;;   ;;(add-to-list #'yas-snippet-dirs "snippets")
;;   (yas-reload-all)

;;   ;; TODO: what about this? i don't acutally use ido...
;;   (setq yas-prompt-functions '(yas-ido-prompt)))

(use-package highlight-doxygen
  :config
  (highlight-doxygen-global-mode 1))

;; https://stackoverflow.com/questions/62624352/can-i-use-gcc-compiler-and-clangd-language-server
;; https://ianyepan.github.io/posts/emacs-ide/
;; https://taingram.org/blog/emacs-lsp-ide.html

(use-package lsp-mode
  :init
  (when (eq system-type 'darwin)
    (setq lsp-clients-clangd-executable "/opt/local/libexec/llvm-17/bin/clangd")
    (setq lsp-clients-clangd-library-directories '("/usr/" "/opt/custom/gcc-devel/")))

  (when (eq system-type 'gnu/linux)
    (setq lsp-clients-clangd-executable "/home/brawndo/sandbox/llvm-project/build/bin/clangd")
    (setq lsp-clients-clangd-library-directories '("/usr" "~/sandbox/llvm-project/build/lib"))

    (setenv "LD_LIBRARY_PATH" "/opt/local/gcc-devel/lib64/:$LD_LIBRARY_PATH"))
    (setenv "LD_LIBRARY_PATH" "/home/brawndo/sandbox/llvm-project/build/lib/x86_64-unknown-linux-gnu/:$LD_LIBRARY_PATH"))

  ;; TODO consider query-driver for project-local variable
  (setq lsp-clients-clangd-args '("-j=12"
                                  "--background-index"
                                  "--clang-tidy"
                                  "--pretty"
                                  "--query-driver=/opt/local/gcc-devel/bin/g++"
                                  "--log=verbose"
                                  "--header-insertion=never"))

  :hook (((c-mode c++-mode) . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))

  :commands lsp)

(use-package helm-lsp)
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

;; NOTE(BK): install buildifer w/ go, put ~/go/bin on path and you're done
(use-package bazel
  :config
  (setq bazel-buildifier-before-save t)
  (add-to-list 'auto-mode-alist '("\\.\\(BUILD\\)\\'" . bazel-mode)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Cruft
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
;;
;; (unless (package-installed-p 'use-package)
;;   (unless package-archive-contents
;;     (package-refresh-contents))
;;   (package-install 'use-package))

;;(use-package clues-theme  :defer t)
;;(use-package github-theme  :defer t)
;;(use-package darkokai-theme :defer t)
;;(use-package tron-legacy-theme :defer t)
;;(use-package spacemacs-theme :defer t)


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

;; XXX need compile commands for my projects since clangd is dumb and insists on treating
;; macports clang as the default (unless told otherwise by compile_commands.json)
;; https://github.com/hedronvision/bazel-compile-commands-extractor

(global-flycheck-mode -1)
;;(remove-hook 'prog-mode 'flycheck-mode)

;;(display-battery-mode t)

;; Remove battery-mode-line-string from global-mode-string
;;(setq global-mode-string (delq 'battery-mode-line-string global-mode-string))



;;(setq column-number-mode t)




;; (use-package treemacs
;;   :ensure t
;;   :defer t
;;   :init
;; ;  (with-eval-after-load 'winum
;;  ;   (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
;;   :config
;;   (progn
;;     (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
;;           treemacs-deferred-git-apply-delay        0.5
;;           treemacs-directory-name-transformer      #'identity
;;           treemacs-display-in-side-window          t
;;           treemacs-eldoc-display                   'simple
;;           treemacs-file-event-delay                5000
;;           treemacs-file-extension-regex            treemacs-last-period-regex-value
;;           treemacs-file-follow-delay               0.2
;;           treemacs-file-name-transformer           #'identity
;;           treemacs-follow-after-init               t
;;           treemacs-expand-after-init               t
;;           treemacs-find-workspace-method           'find-for-file-or-pick-first
;;           treemacs-git-command-pipe                ""
;;           treemacs-goto-tag-strategy               'refetch-index
;;           treemacs-header-scroll-indicators        '(nil . "^^^^^^")'
;;           treemacs-hide-dot-git-directory          t
;;           treemacs-indentation                     2
;;           treemacs-indentation-string              " "
;;           treemacs-is-never-other-window           nil
;;           treemacs-max-git-entries                 5000
;;           treemacs-missing-project-action          'ask
;;           treemacs-move-forward-on-expand          nil
;;           treemacs-no-png-images                   nil
;;           treemacs-no-delete-other-windows         t
;;           treemacs-project-follow-cleanup          nil
;;           treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
;;           treemacs-position                        'left
;;           treemacs-read-string-input               'from-child-frame
;;           treemacs-recenter-distance               0.1
;;           treemacs-recenter-after-file-follow      nil
;;           treemacs-recenter-after-tag-follow       nil
;;           treemacs-recenter-after-project-jump     'always
;;           treemacs-recenter-after-project-expand   'on-distance
;;           treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
;;           treemacs-show-cursor                     nil
;;           treemacs-show-hidden-files               t
;;           treemacs-silent-filewatch                nil
;;           treemacs-silent-refresh                  nil
;;           treemacs-sorting                         'alphabetic-asc
;;           treemacs-select-when-already-in-treemacs 'move-back
;;           treemacs-space-between-root-nodes        t
;;           treemacs-tag-follow-cleanup              t
;;           treemacs-tag-follow-delay                1.5
;;           treemacs-text-scale                      nil
;;           treemacs-user-mode-line-format           nil
;;           treemacs-user-header-line-format         nil
;;           treemacs-wide-toggle-width               70
;;           treemacs-width                           35
;;           treemacs-width-increment                 1
;;           treemacs-width-is-initially-locked       t
;;           treemacs-workspace-switch-cleanup        nil)

;;     ;; The default width and height of the icons is 22 pixels. If you are
;;     ;; using a Hi-DPI display, uncomment this to double the icon size.
;;     ;;(treemacs-resize-icons 44)

;;     (treemacs-follow-mode t)
;;     (treemacs-filewatch-mode t)
;;     (treemacs-fringe-indicator-mode 'always)
;;     (when treemacs-python-executable
;;       (treemacs-git-commit-diff-mode t))

;;     (pcase (cons (not (null (executable-find "git")))
;;                  (not (null treemacs-python-executable)))
;;       (`(t . t)
;;        (treemacs-git-mode 'deferred))
;;       (`(t . _)
;;        (treemacs-git-mode 'simple)))

;;     (treemacs-hide-gitignored-files-mode nil))
;;   :bind
;;   (:map global-map
;;         ("M-0"       . treemacs-select-window)
;;         ("C-x t 1"   . treemacs-delete-other-windows)
;;         ("C-x t t"   . treemacs)
;;         ("C-x t d"   . treemacs-select-directory)
;;         ("C-x t B"   . treemacs-bookmark)
;;         ("C-x t C-t" . treemacs-find-file)
;;         ("C-x t M-t" . treemacs-find-tag)))


;(use-package treemacs-projectile :after (treemacs projectile))
;(use-package treemacs-icons-dired :hook (dired-mode . treemacs-icons-dired-enable-once))
;(use-package treemacs-magit :after (treemacs magit))
;(use-package lsp-treemacs)
