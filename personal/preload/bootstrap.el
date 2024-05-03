(eval-when-compile
  (require 'use-package))

(when (daemonp)
  (setq use-package-always-demand t))

(setq use-package-always-ensure t)

(use-package quelpa)

(use-package quelpa-use-package
  :demand
  :config
  (quelpa-use-package-activate-advice))
