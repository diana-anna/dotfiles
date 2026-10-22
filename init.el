;; -*- lexical-binding: t; -*-

(add-to-list 'exec-path (expand-file-name "~/.nix-profile/bin"))
(setq bookmark-default-file (expand-file-name "~/dotfiles/.emacs.bookmarks.el"))
(setq backup-directory-alist '(("." . "~/.emacs.d.vanilla/backups/")))

(setq straight-profiles `((nil . ,(expand-file-name "~/dotfiles/emacs-lockfiles/default.el"))))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

  ;; start of not bootstrapped code
  (straight-use-package 'use-package)
  (straight-use-package 'project)
  (setq straight-use-package-by-default t)

(column-number-mode 1)
(electric-pair-mode 1)
(global-visual-line-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(which-key-mode 1)
(setq epg-pinentry-mode 'loopback)
(setopt use-short-answers t)
(setq-default fill-column 80)

(use-package exec-path-from-shell
  :ensure t
  :if (daemonp)
  :config
  (add-to-list 'exec-path-from-shell-variables "GPG_TTY")
  (exec-path-from-shell-initialize))


(use-package transient)

(use-package magit
  :after transient)

(use-package dash
  :ensure t)

(use-package magit-delta
  :after magit
  :hook (magit-mode . magit-delta-mode))

(setq auth-sources'("~/.authinfo.gpg"))

(use-package forge
  :after magit)

(use-package org
  :custom
  (org-hide-emphasis-markers t)
  (org-return-follows-link t))

(use-package ob-mermaid
  :ensure t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (js . t)
   (mermaid . t)
   (plantuml . t)
   (python . t)
   (shell . t)))

(add-to-list 'org-src-lang-modes '("js" . js-ts))
(add-to-list 'org-src-lang-modes '("nix" . nix-ts))

(use-package org-modern
  :ensure t
  :after org
  :hook ((org-mode) . org-modern-mode)
  :custom (org-modern-star 'replace))

(use-package org-modern-indent
  :straight (org-modern-indent :type git :host github :repo "jdtsmith/org-modern-indent")
  :config ; add late to hook
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

(use-package org-roam
  :ensure t
  :after org
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert))
  :custom
  (org-roam-directory (file-truename "~/org-notes/roam"))
  (org-capture-bookmark nil)
  :config
  (org-roam-db-autosync-mode))

(use-package verb
  :ensure t
  :after org
  :custom
  (verb-enable-ctrl-c-ctrl-c nil)
  :config
  (define-key org-mode-map (kbd "C-c C-v C-v") verb-command-map))

(setq org-publish-project-alist
      '(("copilot"
	 :base-directory "~/dotfiles/copilot-org"
	 :base-extension "org"
	 :recursive t
	 :publishing-directory "~/dotfiles/.copilot"
	 :publishing-function org-md-publish-to-md
	 :with-toc nil)))
(setq org-publish-use-timestamps-flag nil)

(use-package ibuffer-project
  :config
  (add-hook
      'ibuffer-hook
      (lambda ()
      (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))
      (unless (eq ibuffer-sorting-mode 'project-file-relative)
          (ibuffer-do-sort-by-project-file-relative)))))

  (use-package ghostel
  :bind (("C-x m" . ghostel)
         :map ghostel-semi-char-mode-map
         ("C-s"  . consult-line)
         ("C-k"  . my/ghostel-send-C-k-and-kill)
         ;; I'm used to go up/down the shell history with M-n/p from eshell
         ;; Simulate this behavior in ghostel by sending C-p and C-n
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl")))
         :map project-prefix-map
         ("m" . ghostel-project)
         ("M" . ghostel-project-list-buffers))
  :config
  (defun my/ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package vertico
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package marginalia
  :ensure t
  :init (marginalia-mode))

(use-package consult
  :ensure t
  :bind
  (("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
   ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
   ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
   ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
   ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
   ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
   ;; M-s bindings in `search-map'
   ("M-s d" . consult-find)                  ;; Alternative: consult-fd
   ("M-s c" . consult-locate)
   ("M-s g" . consult-grep)
   ("M-s G" . consult-git-grep)
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   ("M-s k" . consult-keep-lines)
   ("M-s u" . consult-focus-lines)
   ;; Isearch integration
   ("M-s e" . consult-isearch-history)
   :map isearch-mode-map
   ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
   ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
   ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
   ("M-s L" . consult-line-multi)))          ;; needed by consult-line to detect isearch

(use-package corfu
  :ensure t
  :hook ((prog-mode) . corfu-mode))

(use-package js-ts-mode
  :ensure nil ; Built-in, do not try to download via package manager
  :straight nil
  :mode (("\\.[mc]?jsx?\\'" . js-ts-mode)))

(use-package typescript-ts-mode
  :ensure nil ; Built-in, do not try to download via package manager
  :straight nil
  :mode (("\\.ts\\'" . typescript-ts-mode)
	 ("\\.tsx\\'" . tsx-ts-mode)))

(use-package jest-test-mode
  :commands jest-test-mode
  :hook (js-ts-mode typescript-ts-base-mode)
  :custom
  (jest-test-command-string "source $HOME/.nvm/nvm.sh && echo $(npm root)/.bin; npx %s jest %s %s")
  :bind (:map jest-test-mode-map
              ("C-c C-t f" . jest-test-run)
              ("C-c C-t p" . jest-test-run-at-point)
              ("C-c C-t t" . jest-test-run-all-tests)))

(use-package jsdoc
  :ensure t)

(use-package nvm
  :after typescript-ts-mode
  :hook ((js-ts-mode typescript-ts-base-mode) . nvm-use-for-buffer))

(use-package json-ts-mode
  :ensure nil
  :straight nil
  :mode "\\.json\\'")

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'")

(use-package editorconfig
  :ensure nil
  :hook
  ((js-ts-mode json-ts-mode markdown-mode org-mode typescript-ts-base-mode yaml-ts-mode) . editorconfig-mode))

(use-package eglot
  :ensure nil
  :hook ((js-ts-mode json-ts-mode nix-ts-mode typescript-ts-base-mode yaml-ts-mode) . eglot-ensure))

(use-package envrc
:ensure t
:hook (after-init . envrc-global-mode))

(use-package evil
  :ensure t
  :hook
  ((js-ts-mode json-ts-mode markdown-mode nix-ts-mode org-mode typescript-ts-base-mode yaml-ts-mode) . evil-local-mode)
  :custom (evil-want-C-i-jump nil)
  :bind (:map evil-normal-state-map
	      ("M-." . nil)))

(set-face-attribute 'default nil :family "Iosevka" :height 130 :width 'expanded)

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t)) ; if nil, italics is universally disabled

(straight-use-package 'catppuccin-theme)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package winum
  :ensure t
  :config (winum-mode 1))

(use-package auto-dark
  :init (auto-dark-mode)
  :defer t
  :ensure t
  :custom
  (auto-dark-allow-osascript t)
  :hook
  (auto-dark-dark-mode
   . (lambda ()
       (setq catppuccin-flavor 'frappe)
       (catppuccin-reload)))
  (auto-dark-light-mode
   . (lambda ()
       (setq catppuccin-flavor 'latte)
       (catppuccin-reload)))
  :config
  (ignore-errors
    (setq auto-dark-themes '((catppuccin) (catppuccin)))))

(use-package ligature
  :ensure t
  :hook ((js-ts-mode typescript-ts-base-mode) . ligature-mode)
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'prog-mode
			  '(;; == === ==== => =| =>>=>=|=>==>> ==< =/=//=// =~
			    ;; =:= =!=
			    ("=" (rx (+ (or ">" "<" "|" "/" "~" ":" "!" "="))))
                            ;; ;; ;;;
                            (";" (rx (+ ";")))
                            ;; && &&&
                            ("&" (rx (+ "&")))
                            ;; !! !!! !. !: !!. != !== !~
                            ("!" (rx (+ (or "=" "!" "\." ":" "~"))))
                            ;; ?? ??? ?:  ?=  ?.
                            ("?" (rx (or ":" "=" "\." (+ "?"))))
                            ;; %% %%%
                            ("%" (rx (+ "%")))
                            ;; |> ||> |||> ||||> |] |} || ||| |-> ||-||
                            ;; |->>-||-<<-| |- |== ||=||
                            ;; |==>>==<<==<=>==//==/=!==:===>
                            ("|" (rx (+ (or ">" "<" "|" "/" ":" "!" "}" "\]"
                                            "-" "=" ))))
                            ;; \\ \\\ \/
                            ("\\" (rx (or "/" (+ "\\"))))
                            ;; ++ +++ ++++ +>
                            ("+" (rx (or ">" (+ "+"))))
                            ;; :: ::: :::: :> :< := :// ::=
                            (":" (rx (or ">" "<" "=" "//" ":=" (+ ":"))))
                            ;; // /// //// /\ /* /> /===:===!=//===>>==>==/
                            ("/" (rx (+ (or ">"  "<" "|" "/" "\\" "\*" ":" "!"
                                            "="))))
                            ;; .. ... .... .= .- .? ..= ..<
                            ("\." (rx (or "=" "-" "\?" "\.=" "\.<" (+ "\."))))
                            ;; -- --- ---- -~ -> ->> -| -|->-->>->--<<-|
                            ("-" (rx (+ (or ">" "<" "|" "~" "-"))))
                            ;; *> */ *)  ** *** ****
                            ("*" (rx (or ">" "/" ")" (+ "*"))))
                            ;; www wwww
                            ("w" (rx (+ "w")))
                            ;; <> <!-- <|> <: <~ <~> <~~ <+ <* <$ </  <+> <*>
                            ;; <$> </> <|  <||  <||| <|||| <- <-| <-
                            ;; <<-> <= <=> <<==<<==>=|=>==/==//=!==:=>
                            ;; << <<< <<<<
                            ("<" (rx (+ (or "\+" "\*" "\$" "<" ">" ":" "~"  "!"
                                            "-"  "/" "|" "="))))
                            ;; >: >- >>- >--|-> >>-|-> >= >== >>== >=|=:=>>
                            ;; >> >>> >>>>
                            (">" (rx (+ (or ">" "<" "|" "/" ":" "=" "-"))))
                            ;; #: #= #! #( #? #[ #{ #_ #_( ## ### #####
                            ("#" (rx (or ":" "=" "!" "(" "\?" "\[" "{" "_(" "_"
                                         (+ "#"))))
                            ;; ~~ ~~~ ~=  ~-  ~@ ~> ~~>
                            ("~" (rx (or ">" "=" "-" "@" "~>" (+ "~"))))
                            ;; __ ___ ____ _|_ __|____|_
                            ("_" (rx (+ (or "_" "|"))))
                            ;; Fira code: 0xFF 0x12
                            ("0" (rx (and "x" (+ (in "A-F" "a-f" "0-9")))))
                            ;; Fira code:
                            "Fl"  "Tl"  "fi"  "fj"  "fl"  "ft"
                            ;; The few not covered by the regexps.
                            "{|"  "[|"  "]#"  "(*"  "}#"  "$>"  "^=")))
