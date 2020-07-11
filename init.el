;;; -*- lexical-binding: t -*-

(defun tangle-init ()
  "If the current buffer is 'init.org' the code-blocks are
tangled, and the tangled file is compiled."
  (when (equal (buffer-file-name)
               (expand-file-name (concat user-emacs-directory "init.org")))
    ;; Avoid running hooks when tangling.
    (let ((prog-mode-hook nil))
      (org-babel-tangle)
      (byte-compile-file (concat user-emacs-directory "init.el")))))

(add-hook 'after-save-hook 'tangle-init)

(add-hook
 'after-init-hook
 (lambda ()
   (let ((private-file (concat user-emacs-directory "private.el")))
     (when (file-exists-p private-file)
       (load-file private-file))
     (server-start))))

;(lexical-let ((old-gc-treshold gc-cons-threshold))
;  (setq gc-cons-threshold most-positive-fixnum)
;  (add-hook 'after-init-hook
;            (lambda () (setq gc-cons-threshold old-gc-treshold))))

(require 'cl)
(require 'package)
(package-initialize)

(setq package-archives
      '(
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("MELPA Stable" . "https://stable.melpa.org/packages/")
        ("MELPA"        . "https://melpa.org/packages/")
        )
      package-archive-priorities
      '(("MELPA Stable" . 10)
        ("gnu"          . 5)
        ("MELPA"        . 0)
        ))

(let* ((package--builtins nil)
       (packages
        '(auto-compile             ; automatically compile Emacs Lisp libraries
;;             cider                ; Clojure Interactive Development Environment
;;             clj-refactor         ; Commands for refactoring Clojure code
;;             company              ; Modular text completion framework
;;             company-coq          ; A collection of extensions PG's Coq mode
          define-word              ; display the definition of word at point
          diminish                 ; Diminished modes from modeline
          doom-themes              ; An opinionated pack of modern color-themes
          erlang                   ; Erlang major mode
;;             expand-region        ; Increase selected region by semantic units
          focus                    ; Dim color of text in surrounding sections
          git-gutter-fringe        ; Fringe version of git-gutter.el
          golden-ratio             ; Automatic resizing windows to golden ratio
          haskell-mode             ; A Haskell editing mode
          helm                     ; Incremental and narrowing framework
          helm-ag                  ; the silver searcher with helm interface
;;             helm-company         ; Helm interface for company-mode
          helm-dash             ; Offline documentation using Dash docsets.
          helm-projectile       ; Helm integration for Projectile
          helm-swoop            ; Efficiently hopping squeezed lines
          jedi                  ; Python auto-completion for Emacs
          js2-mode              ; Improved JavaScript editing mode
          leuven-theme          ; djl added
          magit                 ; control Git from Emacs
          markdown-mode         ; Emacs Major mode for Markdown-formatted files
;;             maude-mode           ; Emacs mode for the programming language Maude
;;             minizinc-mode        ; Major mode for MiniZinc code
;;             multiple-cursors     ; Multiple cursors for Emacs
;;             olivetti             ; Minor mode for a nice writing environment
          org                    ; Outline-based notes management and organizer
          org-bullets            ; Show bullets in org-mode as UTF-8 characters
          org-ref                ; citations bibliographies in org-mode
          org-super-agenda       ; djl: suggested by Reed
          paredit                ; minor mode for editing parentheses
          pdf-tools              ; Emacs support library for PDF files
          plantuml-mode          ; djl added
          projectile             ; Manage and navigate projects in Emacs easily
;;             proof-general        ; A generic Emacs interface for proof assistants
          racket-mode                   ; Major mode for Racket language
          real-auto-save                ; djl added
;;             slime                ; Superior Lisp Interaction Mode for Emacs
          tango-plus-theme       ; djl added
          try                          ; Try out Emacs packages
          which-key)))                 ; Display available keybindings in popup
  (when (memq window-system '(mac ns))
    (push 'exec-path-from-shell packages)
    (push 'reveal-in-osx-finder packages))
  (let ((packages (remove-if 'package-installed-p packages)))
    (when packages
      ;; Install uninstalled packages
      (package-refresh-contents)
      (mapc 'package-install packages))))

(when (memq window-system '(mac ns))
  (setq ns-pop-up-frames nil
        mac-option-modifier nil
        mac-command-modifier 'meta
        select-enable-clipboard t)
  (exec-path-from-shell-initialize)
  (when (fboundp 'mac-auto-operator-composition-mode)
    (mac-auto-operator-composition-mode 1)))

(setq auto-revert-interval 1            ; Refresh buffers fast
         custom-file (make-temp-file "")   ; Discard customization's
         default-input-method "TeX"        ; Use TeX when toggling input method
         echo-keystrokes 0.1               ; Show keystrokes asap
         inhibit-startup-screen t          ; No splash screen please
         initial-scratch-message nil       ; Clean scratch buffer
         recentf-max-saved-items 100       ; Show more recent files
;;         ring-bell-function 'ignore        ; Quiet
         scroll-margin 1                   ; Space between cursor and top/bottom
         sentence-end-double-space nil)    ; No double space
   ;; Some mac-bindings interfere with Emacs bindings.
   (when (boundp 'mac-pass-command-to-system)
     (setq mac-pass-command-to-system nil))

(setq-default tab-width 4                       ; Smaller tabs
              fill-column 79                    ; Maximum line width
              truncate-lines nil                ; Don't fold lines...
              truncate-partial-width-windows nil; ... even in narrow windows
              indent-tabs-mode nil              ; Use spaces instead of tabs
              split-width-threshold 160         ; Split verticly by default
              split-height-threshold nil        ; Split verticly by default
              auto-fill-function 'do-auto-fill) ; Auto-fill-mode everywhere

(let ((default-directory (concat user-emacs-directory "site-lisp/")))
  (when (file-exists-p default-directory)
    (setq load-path
          (append
           (let ((load-path (copy-sequence load-path)))
             (normal-top-level-add-subdirs-to-load-path)) load-path))))

;   (fset 'yes-or-no-p 'y-or-n-p)

(defvar emacs-autosave-directory
  (concat user-emacs-directory "autosaves/")
  "This variable dictates where to put auto saves. It is set to a
  directory called autosaves located wherever your .emacs.d/ is
  located.")

;; Sets all files to be backed up and auto saved in a single directory.
(setq backup-directory-alist
      `((".*" . ,emacs-autosave-directory))
      auto-save-file-name-transforms
      `((".*" ,emacs-autosave-directory t)))

(set-language-environment "UTF-8")

(put 'narrow-to-region 'disabled nil)

(add-hook 'doc-view-mode-hook 'auto-revert-mode)

(dolist (mode
         '(tool-bar-mode                ; No toolbars, more room for text
           menu-bar-mode                ; No menubars either
;;           scroll-bar-mode              ; No scroll bars either
           blink-cursor-mode)
         )          ; The blinking cursor gets old
  (funcall mode 0))

(dolist (mode
         '(abbrev-mode                  ; E.g. sopl -> System.out.println
           column-number-mode           ; Show column number in mode line
           delete-selection-mode        ; Replace selected text
           dirtrack-mode                ; directory tracking in *shell*
           ;;djl global-company-mode          ; Auto-completion everywhere
           global-git-gutter-mode       ; Show changes latest commit
           global-prettify-symbols-mode ; Greek letters should look greek
           projectile-mode              ; Manage and navigate projects
           recentf-mode                 ; Recently opened files
           show-paren-mode              ; Highlight matching parentheses
           which-key-mode))             ; Available keybindings in popup
  (funcall mode 1))

(when (version< emacs-version "24.4")
  (eval-after-load 'auto-compile
    '((auto-compile-on-save-mode 1))))  ; compile .el files on save

(defun set-git-gutter-colors ()
  "Set the colors to use for changes (per git) in the gutter"
  (dolist (p '((git-gutter:added    . "#0c0")
               (git-gutter:deleted  . "#c00")
               (git-gutter:modified . "#c0c")))
    (set-face-foreground (car p) (cdr p))
    (set-face-background (car p) (cdr p))))


(if
    ;; (load-theme 'light-blue t)
    (load-theme 'tango-plus t)
    ;; (load-theme 'whiteboard t)
    ;; (load-theme 'leuven t)
    ;; (load-theme 'doom-one-light t)
    (set-git-gutter-colors))

(defun cycle-themes ()
  "Returns a function that lets you cycle your themes."
  (lexical-let
      ((themes
        '#1=(light-blue tango-plus leuven whiteboard doom-one-light doom-one . #1#)))
    (lambda ()
      (interactive)
      ;; Rotates the thme cycle and changes the current theme.
      (load-theme (car (setq themes (cdr themes))) t)
      (message (concat "Switched to " (symbol-name (car themes)))))))

(cond ((member "Hasklig" (font-family-list))
       (set-face-attribute 'default nil :font "Hasklig-14"))
      ((member "Inconsolata" (font-family-list))
       (set-face-attribute 'default nil :font "Inconsolata-14")))

(defmacro safe-diminish (file mode &optional new-name)
  `(with-eval-after-load ,file
     (diminish ,mode ,new-name)))

(diminish 'auto-fill-function)
(safe-diminish "eldoc" 'eldoc-mode)
(safe-diminish "flyspell" 'flyspell-mode)
(safe-diminish "helm-mode" 'helm-mode)
(safe-diminish "projectile" 'projectile-mode)
(safe-diminish "paredit" 'paredit-mode "()")

(with-eval-after-load 'git-gutter-fringe
  (set-git-gutter-colors))

(setq-default prettify-symbols-alist '(("lambda" . ?λ)
                                       ("delta" . ?Δ)
                                       ("gamma" . ?Γ)
                                       ("phi" . ?φ)
                                       ("psi" . ?ψ)))

(add-to-list 'auto-mode-alist '("\\.pdf\\'" . pdf-tools-install))

(add-hook 'pdf-view-mode-hook
          (lambda () (setq mode-line-format nil)))

;; (setq company-idle-delay 0
;;       company-echo-delay 0
;;       company-dabbrev-downcase nil
;;       company-minimum-prefix-length 2
;;       company-selection-wrap-around t
;;       company-transformers '(company-sort-by-occurrence
;;                              company-sort-by-backend-importance))

(require 'helm)
(require 'helm-config)
(setq helm-split-window-in-side-p t
      helm-M-x-fuzzy-match t
      helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match t
      helm-move-to-line-cycle-in-source t
      projectile-completion-system 'helm
      helm-mini-default-sources '(helm-source-buffers-list
                                  helm-source-recentf
                                  helm-source-bookmarks
                                  helm-source-buffer-not-found))

(when (executable-find "ack")
  (setq helm-grep-default-command
        "ack -Hn --no-group --no-color %e %p %f"
        helm-grep-default-recurse-command
        "ack -H --no-group --no-color %e %p %f"))

(set-face-attribute 'helm-selection nil :background "cyan")

(helm-mode 1)
(helm-projectile-on)
(helm-adaptive-mode 1)

(setq helm-dash-browser-func 'eww)
(add-hook 'emacs-lisp-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Emacs Lisp"))))
(add-hook 'erlang-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Erlang"))))
(add-hook 'java-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Java"))))
(add-hook 'haskell-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Haskell"))))
(add-hook 'clojure-mode-hook
          (lambda () (setq-local helm-dash-docsets '("Clojure"))))

(add-hook 'text-mode-hook 'turn-on-flyspell)

;;djl (add-hook 'prog-mode-hook 'flyspell-prog-mode)

(defun cycle-languages ()
  "Changes the ispell dictionary to the first element in
ISPELL-LANGUAGES, and returns an interactive function that cycles
the languages in ISPELL-LANGUAGES when invoked."
  (lexical-let ((ispell-languages '#1=("american" "norsk" . #1#)))
    (ispell-change-dictionary (car ispell-languages))
    (lambda ()
      (interactive)
      ;; Rotates the languages cycle and changes the ispell dictionary.
      (ispell-change-dictionary
       (car (setq ispell-languages (cdr ispell-languages)))))))

(defadvice turn-on-flyspell (before check nil activate)
  "Turns on flyspell only if a spell-checking tool is installed."
  (when (executable-find ispell-program-name)
    (local-set-key (kbd "C-c l") (cycle-languages))))

;; (defadvice flyspell-prog-mode (before check nil activate)
;;   "Turns on flyspell only if a spell-checking tool is installed."
;;   (when (executable-find ispell-program-name)
;;     (local-set-key (kbd "C-c l") (cycle-languages))))

(setq org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-confirm-babel-evaluate nil
      org-edit-src-content-indentation 0)

(with-eval-after-load 'org
  (setcar (nthcdr 2 org-emphasis-regexp-components) " \t\n,")
  (custom-set-variables `(org-emphasis-alist ',org-emphasis-alist)))

(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(defun cycle-spacing-delete-newlines ()
  "Removes whitespace before and after the point."
  (interactive)
  (if (version< emacs-version "24.4")
      (just-one-space -1)
    (cycle-spacing -1)))

(defun jump-to-symbol-internal (&optional backwardp)
  "Jumps to the next symbol near the point if such a symbol
exists. If BACKWARDP is non-nil it jumps backward."
  (let* ((point (point))
         (bounds (find-tag-default-bounds))
         (beg (car bounds)) (end (cdr bounds))
         (str (isearch-symbol-regexp (find-tag-default)))
         (search (if backwardp 'search-backward-regexp
                   'search-forward-regexp)))
    (goto-char (if backwardp beg end))
    (funcall search str nil t)
    (cond ((<= beg (point) end) (goto-char point))
          (backwardp (forward-char (- point beg)))
          (t  (backward-char (- end point))))))

(defun jump-to-previous-like-this ()
  "Jumps to the previous occurrence of the symbol at point."
  (interactive)
  (jump-to-symbol-internal t))

(defun jump-to-next-like-this ()
  "Jumps to the next occurrence of the symbol at point."
  (interactive)
  (jump-to-symbol-internal))

(defun kill-this-buffer-unless-scratch ()
  "Works like `kill-this-buffer' unless the current buffer is the
*scratch* buffer. In witch case the buffer content is deleted and
the buffer is buried."
  (interactive)
  (if (not (string= (buffer-name) "*scratch*"))
      (kill-this-buffer)
    (delete-region (point-min) (point-max))
    (switch-to-buffer (other-buffer))
    (bury-buffer "*scratch*")))

(defun duplicate-thing (comment)
  "Duplicates the current line, or the region if active. If an argument is
given, the duplicated region will be commented out."
  (interactive "P")
  (save-excursion
    (let ((start (if (region-active-p) (region-beginning) (point-at-bol)))
          (end   (if (region-active-p) (region-end) (point-at-eol)))
          (fill-column most-positive-fixnum))
      (goto-char end)
      (unless (region-active-p)
        (newline))
      (insert (buffer-substring start end))
      (when comment (comment-region start end)))))

(defun tidy ()
  "Ident, untabify and unwhitespacify current buffer, or region if active."
  (interactive)
  (let ((beg (if (region-active-p) (region-beginning) (point-min)))
        (end (if (region-active-p) (region-end) (point-max))))
    (indent-region beg end)
    (whitespace-cleanup)
    (untabify beg (if (< end (point-max)) end (point-max)))))

(defun org-sync-pdf ()
  (interactive)
  (let ((headline (nth 4 (org-heading-components)))
        (pdf (concat (file-name-base (buffer-name)) ".pdf")))
    (when (file-exists-p pdf)
      (find-file-other-window pdf)
      (pdf-links-action-perform
       (cl-find headline (pdf-info-outline pdf)
                :key (lambda (alist) (cdr (assoc 'title alist)))
                :test 'string-equal)))))

(defadvice eval-last-sexp (around replace-sexp (arg) activate)
  "Replace sexp when called with a prefix argument."
  (if arg
      (let ((pos (point)))
        ad-do-it
        (goto-char pos)
        (backward-kill-sexp)
        (forward-sexp))
    ad-do-it))

(defadvice load-theme
    (before disable-before-load (theme &optional no-confirm no-enable) activate)
  (mapc 'disable-theme custom-enabled-themes))

(lexical-let* ((default (face-attribute 'default :height))
               (size default))

  (defun global-scale-default ()
    (interactive)
    (setq size default)
    (global-scale-internal size))

  (defun global-scale-up ()
    (interactive)
    (global-scale-internal (incf size 20)))

  (defun global-scale-down ()
    (interactive)
    (global-scale-internal (decf size 20)))

  (defun global-scale-internal (arg)
    (set-face-attribute 'default (selected-frame) :height arg)
    (set-temporary-overlay-map
     (let ((map (make-sparse-keymap)))
       (define-key map (kbd "C-=") 'global-scale-up)
       (define-key map (kbd "C-+") 'global-scale-up)
       (define-key map (kbd "C--") 'global-scale-down)
       (define-key map (kbd "C-0") 'global-scale-default) map))))

(add-hook 'compilation-filter-hook 'comint-truncate-buffer)

(lexical-let ((last-shell ""))
  (defun toggle-shell ()
    (interactive)
    (cond ((string-match-p "^\\*shell<[1-9][0-9]*>\\*$" (buffer-name))
           (goto-non-shell-buffer))
          ((get-buffer last-shell) (switch-to-buffer last-shell))
          (t (shell (setq last-shell "*shell<1>*")))))

  (defun switch-shell (n)
    (let ((buffer-name (format "*shell<%d>*" n)))
      (setq last-shell buffer-name)
      (cond ((get-buffer buffer-name)
             (switch-to-buffer buffer-name))
            (t (shell buffer-name)
               (rename-buffer buffer-name)))))

  (defun goto-non-shell-buffer ()
    (let* ((r "^\\*shell<[1-9][0-9]*>\\*$")
           (shell-buffer-p (lambda (b) (string-match-p r (buffer-name b))))
           (non-shells (cl-remove-if shell-buffer-p (buffer-list))))
      (when non-shells
        (switch-to-buffer (first non-shells))))))

;;djl (defadvice shell (after kill-with-no-query nil activate)
;;djl  (set-process-query-on-exit-flag (get-buffer-process ad-return-value) nil))

(defun clear-comint ()
  "Runs `comint-truncate-buffer' with the
`comint-buffer-maximum-size' set to zero."
  (interactive)
  (let ((comint-buffer-maximum-size 0))
    (comint-truncate-buffer)))

(dolist (mode '(cider-repl-mode
                clojure-mode
                ielm-mode
                racket-mode
                racket-repl-mode
                slime-repl-mode
                lisp-mode
                emacs-lisp-mode
                lisp-interaction-mode
                scheme-mode))
  ;; add paredit-mode to all mode-hooks
  (add-hook (intern (concat (symbol-name mode) "-hook")) 'paredit-mode))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)

(defun activate-slime-helper ()
  (when (file-exists-p "~/.quicklisp/slime-helper.el")
    (load (expand-file-name "~/.quicklisp/slime-helper.el"))
    (define-key slime-repl-mode-map (kbd "C-l")
      'slime-repl-clear-buffer))
  (remove-hook 'common-lisp-mode-hook #'activate-slime-helper))

(add-hook 'common-lisp-mode-hook #'activate-slime-helper)

(setq inferior-lisp-program "sbcl")

(setq lisp-loop-forms-indentation   6
      lisp-simple-loop-indentation  2
      lisp-loop-keyword-indentation 6)

(setq python-shell-interpreter "python3")
(add-hook 'python-mode-hook
          (lambda () (setq forward-sexp-function nil)))

(defun c-setup ()
  (local-set-key (kbd "C-c C-c") 'compile))

(add-hook 'c-mode-hook 'c-setup)

(define-abbrev-table 'java-mode-abbrev-table
  '(("psv" "public static void main(String[] args) {" nil 0)
    ("sopl" "System.out.println" nil 0)
    ("sop" "System.out.printf" nil 0)))

(defun java-setup ()
  (abbrev-mode t)
  (setq-local compile-command (concat "javac " (buffer-name))))

(add-hook 'java-mode-hook 'java-setup)

(defun asm-setup ()
  (setq comment-start "#")
  (local-set-key (kbd "C-c C-c") 'compile))

(add-hook 'asm-mode-hook 'asm-setup)

(add-to-list 'auto-mode-alist '("\\.tex\\'" . latex-mode))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (add-hook 'hack-local-variables-hook
                      (lambda ()
                        (setq-local compile-command
                                    (concat "latexmk -pdf -pvc "
                                            (if (eq TeX-master t)
                                                (file-name-base (buffer-name))
                                              TeX-master))))
                      t t)))

(setq-default bibtex-dialect 'biblatex)

(eval-after-load 'org
  '(add-to-list 'org-latex-packages-alist '("" "minted")))
(setq org-latex-listings 'minted)

(eval-after-load 'tex-mode
  '(setcar (cdr (cddaar tex-compile-commands)) " -shell-escape "))

(eval-after-load 'ox-latex
  '(setq org-latex-pdf-process
         '("latexmk -pdflatex='pdflatex -shell-escape -interaction nonstopmode' -pdf -f %f")))

(eval-after-load "ox-latex"
  '(progn
     (add-to-list 'org-latex-classes
                  '("ifimaster"
                    "\\documentclass{ifimaster}
[DEFAULT-PACKAGES]
[PACKAGES]
[EXTRA]
\\usepackage{babel,csquotes,ifimasterforside,url,varioref}"
                    ("\\chapter{%s}" . "\\chapter*{%s}")
                    ("\\section{%s}" . "\\section*{%s}")
                    ("\\subsection{%s}" . "\\subsection*{%s}")
                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                    ("\\paragraph{%s}" . "\\paragraph*{%s}")
                    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
     (add-to-list 'org-latex-classes
                  '("easychair" "\\documentclass{easychair}"
                    ("\\section{%s}" . "\\section*{%s}")
                    ("\\subsection{%s}" . "\\subsection*{%s}")
                    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                    ("\\paragraph{%s}" . "\\paragraph*{%s}")
                    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
     (custom-set-variables '(org-export-allow-bind-keywords t))))

(require 'org)
(add-to-list 'org-file-apps '("\\.pdf\\'" . emacs))

(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(defun insert-markdown-inline-math-block ()
  "Inserts an empty math-block if no region is active, otherwise wrap a
math-block around the region."
  (interactive)
  (let* ((beg (region-beginning))
         (end (region-end))
         (body (if (region-active-p) (buffer-substring beg end) "")))
    (when (region-active-p)
      (delete-region beg end))
    (insert (concat "$math$ " body " $/math$"))
    (search-backward " $/math$")))

(add-hook 'markdown-mode-hook
          (lambda ()
            (auto-fill-mode 0)
            (visual-line-mode 1)
            (ispell-change-dictionary "norsk")
            (local-set-key (kbd "C-c b") 'insert-markdown-inline-math-block)) t)

(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

(setq haskell-process-args-ghci
      '("-ferror-spans" "-fshow-loaded-modules"))

(setq haskell-process-args-cabal-repl
      '("--ghc-options=-ferror-spans -fshow-loaded-modules"))

(setq haskell-process-args-stack-ghci
      '("--ghci-options=-ferror-spans -fshow-loaded-modules"
        "--no-build" "--no-load"))

(setq haskell-process-args-cabal-new-repl
      '("--ghc-options=-ferror-spans -fshow-loaded-modules"))

(add-hook 'maude-mode-hook
          (lambda ()
            (setq-local comment-start "---")))

(with-eval-after-load 'maude-mode
  (add-to-list 'maude-command-options "-no-wrap"))

(add-to-list 'auto-mode-alist '("\\.mzn\\'" . minizinc-mode))

(defun minizinc-setup ()
  (let ((command (concat "minizinc " (buffer-file-name) " "))
        (f (concat (file-name-base (buffer-file-name)) ".dzn")))
    (local-set-key (kbd "C-c C-c") 'recompile)
    (setq-local compile-command (concat command (if (file-exists-p f) f "")))))

(add-hook 'minizinc-mode-hook 'minizinc-setup)

;; (add-hook 'coq-mode-hook #'company-coq-mode)

(defvar custom-bindings-map (make-keymap)
  "A keymap for custom bindings.")

(define-key custom-bindings-map (kbd "C-c D") 'define-word-at-point)

(define-key custom-bindings-map (kbd "C->")  'er/expand-region)
(define-key custom-bindings-map (kbd "C-<")  'er/contract-region)

;  (define-key custom-bindings-map (kbd "C-c e")  'mc/edit-lines)
;  (define-key custom-bindings-map (kbd "C-c a")  'mc/mark-all-like-this)
;  (define-key custom-bindings-map (kbd "C-c n")  'mc/mark-next-like-this)

(define-key custom-bindings-map (kbd "C-c m") 'magit-status)

;; (define-key company-active-map (kbd "C-d") 'company-show-doc-buffer)
;; (define-key company-active-map (kbd "C-n") 'company-select-next)
;; (define-key company-active-map (kbd "C-p") 'company-select-previous)
;; (define-key company-active-map (kbd "<tab>") 'company-complete)

;; (define-key company-mode-map (kbd "C-:") 'helm-company)
;; (define-key company-active-map (kbd "C-:") 'helm-company)

(define-key helm-map            (kbd "<tab>")   'helm-execute-persistent-action)
(define-key helm-map            (kbd "C-i")     'helm-execute-persistent-action)
(define-key helm-map            (kbd "C-z")     'helm-select-action)
(define-key helm-map            (kbd "<left>")  'helm-previous-source)
(define-key helm-map            (kbd "<right>") 'helm-next-source)
(define-key custom-bindings-map (kbd "C-c h")   'helm-command-prefix)
(define-key custom-bindings-map (kbd "M-x")     'helm-M-x)
(define-key custom-bindings-map (kbd "M-y")     'helm-show-kill-ring)
(define-key custom-bindings-map (kbd "C-x b")   'helm-mini)
(define-key custom-bindings-map (kbd "C-x C-f") 'helm-find-files)
(define-key custom-bindings-map (kbd "C-c h d") 'helm-dash-at-point)
(define-key custom-bindings-map (kbd "C-c h o") 'helm-occur)
(define-key custom-bindings-map (kbd "C-c h g") 'helm-google-suggest)
(define-key custom-bindings-map (kbd "M-i")     'helm-swoop)
(define-key custom-bindings-map (kbd "M-I")     'helm-multi-swoop-all)

(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(with-eval-after-load 'cider
  (define-key cider-repl-mode-map (kbd "C-l") 'cider-repl-clear-buffer))

(define-key custom-bindings-map (kbd "M-u")         'upcase-dwim)
   (define-key custom-bindings-map (kbd "M-c")         'capitalize-dwim)
   (define-key custom-bindings-map (kbd "M-l")         'downcase-dwim)
   (define-key custom-bindings-map (kbd "M-]")         'other-frame)
   (define-key custom-bindings-map (kbd "C-j")         'newline-and-indent)
   (define-key custom-bindings-map (kbd "C-c s")       'ispell-word)
;;   (define-key comint-mode-map     (kbd "C-l")         'clear-comint)

(define-key global-map          (kbd "M-p")     'jump-to-previous-like-this)
(define-key global-map          (kbd "M-n")     'jump-to-next-like-this)
(define-key custom-bindings-map (kbd "M-,")     'jump-to-previous-like-this)
(define-key custom-bindings-map (kbd "M-.")     'jump-to-next-like-this)
(define-key custom-bindings-map (kbd "C-c .")   (cycle-themes))
(define-key custom-bindings-map (kbd "C-x k")   'kill-this-buffer-unless-scratch)
(define-key custom-bindings-map (kbd "C-c C-0") 'global-scale-default)
(define-key custom-bindings-map (kbd "C-c C-=") 'global-scale-up)
(define-key custom-bindings-map (kbd "C-c C-+") 'global-scale-up)
(define-key custom-bindings-map (kbd "C-c C--") 'global-scale-down)
(define-key custom-bindings-map (kbd "C-c j")   'cycle-spacing-delete-newlines)
(define-key custom-bindings-map (kbd "C-c d")   'duplicate-thing)
(define-key custom-bindings-map (kbd "<C-tab>") 'tidy)
(define-key custom-bindings-map (kbd "M-`")     'toggle-shell)
(dolist (n (number-sequence 1 9))
  (global-set-key (kbd (concat "M-" (int-to-string n)))
                  (lambda () (interactive) (switch-shell n))))
(define-key custom-bindings-map (kbd "C-c C-q")
  '(lambda ()
     (interactive)
     (focus-mode 1)
     (focus-read-only-mode 1)))
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-'") 'org-sync-pdf))

(define-minor-mode custom-bindings-mode
  "A mode that activates custom-bindings."
  t nil custom-bindings-map)

;    (setq emacs-local-directory "/home/derrell/ME/xemacs-lib/site-lisp")

(setenv "SHELL" "/bin/csh")

                                        ;    (nconc load-path (list emacs-local-directory))

                                        ; Use js2 mode for JavaScript files
                                        ;
                                        ; TO RETRIEVE THE LATEST js2-mode:
                                        ;   M-x package-install RET js2-mode RET
                                        ;
                                        ; which installs it in ~/.emacs.d
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(load "hexl")                ; hex editor for binary files
(require 'linum)

                                        ; load parenthesis matching stuff
(load "paren")

                                        ;    (load "kb-generic")

                                        ; Display time in mode line
(display-time)

                                        ; Reset modeline-format to have time and mail flag first on mode line
(setq-default modeline-format '(" %* " global-mode-string " %n  " mode-line-buffer-identification "  " (-3 . "%p") "  %f  %[(" mode-name mode-line-process ")%]  %-"))

                                        ; Only display 24-hour time
(setq display-time-form-list (list '24-hours 'minutes))

(put 'eval-expression 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'upcase-region 'disabled t)

(defun command-history-hooker ()
  (define-key command-history-map "n" 'next-line)
  (define-key command-history-map "p" 'previous-line))

(defun dired-mode-hooker ()
  (define-key dired-mode-map "!" 'dired-shell-command)
  (define-key dired-mode-map "c" 'dired-do-copy)
  (define-key dired-mode-map "r" 'dired-do-rename)
  (setq dired-mode-hook nil))  ; All fixes are global

(defun edit-picture-hooker ()
  (setq picture-tab-chars "!_~-|")  ; Added some useful characters here
  (keybind-edit-picture-hooker)
  (setq edit-picture-hook nil))  ; All fixes are global

                                        ; Underscores and hash marks in running text are usually in C tokens
(defun nroff-mode-hooker ()
  (modify-syntax-entry ?_ "w")
  (modify-syntax-entry ?# "w"))

(defun c-mode-hooker ()
  (define-key c-mode-map "\M-{"         'insert-braces)
  (define-key c-mode-map "\M-\C-h"   'backward-kill-word)
  (if (string-equal
       (substring (buffer-file-name) 0 25)
       "/var/home/derrell/agranat")
      (c-set-style "virata")
    (c-set-style "Derrell-C")))

(defun c++-mode-hooker ()
  (define-key c++-mode-map "\M-{" 'insert-braces)
  (c-set-style "Derrell-C"))

(defun js-mode-hooker ()
      ;;; js2-mode key bindings
  (auto-fill-mode 0)         ; no auto-fill mode in shell mode
  (define-key js2-mode-map "\M-{"
    (lambda (arg)
      (interactive "P")
      (progn
        (insert ?\{)
        (js2-indent-line)
        (save-excursion
          (newline-and-indent)
          (insert ?\})
          (js2-indent-line))
        (newline-and-indent))))
  (setq Local-map-js2 (make-keymap))
  (define-key js2-mode-map        "\C-q"  Local-map-js2)
  (define-key Local-map-js2 "\C-F" '(lambda (arg)
                                      (interactive "P")
                                      (if (and arg (integerp arg))
                                          (c-forward-function arg)
                                        (c-forward-function 4))))
  (define-key Local-map-js2 "\C-B" '(lambda (arg)
                                      (interactive "P")
                                      (if (and arg (integerp arg))
                                          (c-backward-function arg)
                                        (c-backward-function 4)))))

(defun java-mode-hooker ()
  (c-set-style "java")
  (setq c-basic-offset 2)
  (c-set-offset `substatement-open 0)

  (define-key java-mode-map "\M-{"         'insert-braces)
  (define-key java-mode-map "\M-\C-h"    'backward-kill-word))

(defun text-mode-hooker ()
  (if (or (equal (buffer-name) "makefile")
          (equal (buffer-name) "Makefile"))
      nil                ; don't turn on FILL if its a makefile.
    (turn-on-auto-fill)))

(defun find-file-hooker ()
  (kill-local-variable 'case-fold-search))

(defun blink-paren-hooker ()
  "If cursor is already on a matching right delimiter,
       don't insert another one. Blink the match; move the cursor forward."
  (if (looking-at (char-to-string last-input-char))
      (if insert-mode (delete-char 1)))
  (blink-matching-open))

(defun lisp-interaction-mode-hooker ()
  (keybind-lisp-interaction-mode-hooker))

(defun shell-mode-hooker ()
  (auto-fill-mode 0)         ; no auto-fill mode in shell mode
  (setq truncate-lines nil)  ; wrap, don't truncate
  (define-key shell-mode-map "\t"   'comint-dynamic-complete)
  (define-key shell-mode-map "\C-Ch" 'comint-display-command-history)
  (kb-generic-shell-mode-hooker)
  (keybind-shell-mode-hooker))

(defun shell-selected-hooker ()
  (company-mode 0) ; added for Lars' stuff
  (setq modeline-buffer-identification
        '("%13b") modeline-format '("" global-mode-string
                                    " %n "
                                    modeline-buffer-identification "%p  %[("
                                    mode-name mode-line-process ")%]  "
                                    " %-")))

;;; New emacs version 19 stuff

;; choose syntax display type from:
;;    "color", "font", "none"
(defvar syntax-display-type "color")

;; find out who is running this
(setq user (getenv "USER"))

;; Determine default fill-column dynamically
(setq-default default-fill-column (- (frame-width) 2))

;;; leave regions active always (without highlighting)
;(setq zmacs-regions nil)

;; For Scott Lawrence... don't insert tabs
(setq-default indent-tabs-mode nil)

;; add the host name to the frame title
;;(setq frame-title-format (concat "{" (exec-to-string "hostname -s | tr -d \\\\012") "} %S: %b"))

;;; cc-mode (and c-mode) stuff
(c-add-style
 "Derrell-C"
 '((c-basic-offset . 4)
   (c-hanging-comment-ender-p . nil)
   (c-offsets-alist . (
                       (defun-block-intro     . +)
                       (substatement-open     . 0)
                       ))))

(c-add-style
 "qooxdoo"
 '((c-basic-offset . 2)
   (c-hanging-comment-ender-p . nil)
   (c-offsets-alist . (
                       (defun-block-intro     . +)
                       (class-close           . -)
                       (substatement-open     . 0)
                       ))))

(c-add-style
 "derrell-java"
 '((c-basic-offset . 2)
   (c-comment-only-line-offset 0 . 0)
   (c-hanging-braces-alist
    (substatement-open before after)
    (arglist-cont-nonempty))
   (c-offsets-alist
    (defun-block-intro     . -)
    (block-intro           . +)
    (substatement-open     . 0)
    (inline-open           . 0)
    (statement-block-intro . 0)
    (knr-argdecl-intro . 5)
    (substatement-label . 0)
    (label . 0)
    (statement-case-open . +)
    (statement-cont . +)
    (arglist-intro . c-lineup-arglist-intro-after-paren)
    (arglist-close . c-lineup-arglist)
    (brace-list-open . +)
    (topmost-intro-cont first c-lineup-topmost-intro-cont c-lineup-gnu-DEFUN-intro-cont))
   (c-special-indent-hook . c-gnu-impose-minimum)
   (c-block-comment-prefix . "")))


;; (setq
;;  c-macro-preprocessor            "/usr/libexec/cpp"
;;  c-macro-prompt-flag         t
;;  )


;;; End of new stuff for version 19

(setq

 ;; Automatic backup parameters
 version-control             t
 delete-old-versions         t
 kept-old-versions           0 ; formerly 1
 kept-new-versions           2
 auto-save-interval          100

 ;; Hooks
 text-mode-hook              'text-mode-hooker
 nroff-mode-hook             'nroff-mode-hooker
 blink-paren-function        'blink-matching-open
 asn-mode-hook               'asn-mode-hooker
 find-file-hooks             (list 'find-file-hooker)
 mail-mode-hook              'mail-mode-hooker
 mail-setup-hook             'mail-setup-hooker
 shell-mode-hook             (list 'shell-mode-hooker)
 shell-selected-hook         'shell-selected-hooker
 c-mode-hook                 'c-mode-hooker
 c++-mode-hook               'c++-mode-hooker
 js2-mode-hook               'js-mode-hooker
 java-mode-hook              'java-mode-hooker
 dired-mode-hook             'dired-mode-hooker
 command-history-hook        'command-history-hooker
 ;; lisp-interaction-mode-hook     'lisp-interaction-mode-hooker



 ;; Loose ends
 display-time-interval           10
 default-major-mode              'text-mode
 require-final-newline           t
 scroll-step                     1
 window-min-height               1   ; Enough to watch compilation
 inhibit-startup-message         t   ; Start with shell window
 default-fill-column             70
 term-file-prefix                nil
 keybind-term-file-prefix        "term/kb-"
 dired-listing-switches          "-al"
 display-time-day-and-date       t

 completion-ignored-extensions       '(
                                      ".o"
                                      ".obj"
                                      ".elc"
                                      "~"
                                      ".ln"
                                      ".class")

 ;; C-mode stuff especially automatic indenting of C programs
 c-default-variable-column       16

 ;; Misc. make stuff
 compile-command                 "make"

 ;; Shell stuff
 explicit-shell-file-name        "/bin/csh"
 shell-file-name                 "/bin/csh"
 shell-cd-regexp                 "cd"
 shell-popd-regexp               "popd\\|\-"
 shell-pushd-regexp              "pd\\|pushd\\|\="
 shell-prompt-pattern            "^.*---> \\|(.*-gdb) "

 ;; Don't invert foreground/background to get a password
 passwd-invert-frame-when-keyboard-grabbed nil

 ;; Don't display ssh pass phrase
 comint-password-prompt-regexp
 (concat
  "\\("

  "\\(\\([Oo]ld \\|[Nn]ew \\|[a-zA-Z0-9]+@[a-zA-Z0-9.]+'s |^\\)?"
  "[Pp]assword\\|pass phrase\\)"

  "\\|"
  "\\(Enter passphrase\\( for.*key '[^']+'\\)?\\)"

  "\\|"
  "\\(\\[sudo\\] password for [a-zA-Z0-9]+\\)"

  "\\)"
  ":\\s *\\'")

 ;; Post-script printing
 ps-paper-type               'letter
 )


(setq-default
 track-eol               nil
 mode-line-buffer-identification '(1 . "%b")
 fill-column             70
 )

;;;
;;; Enable modes
;;;
                                        ;(resize-minibuffer-mode)
(icomplete-mode t)

;;(setq-default
;; This, rather than "%b" in format, lets RNEWS and others have their way
;; mode-line-format '(
;;                    " %*"          minor-mode-alist
;;                    "%n  "         mode-line-buffer-identification
;;                    "  "           (-3 . "%p")
;;                    "  %f  %[("    mode-name mode-line-process
;;                    ")%]  "        global-mode-string
;;                    " %-"
;;                    )
;; )

(defvar compilation-error-regexp
  "\\([^ \n]+\\(: *\\|, line \\|(\\)[0-9]+\\)\\|\\([0-9]+.*of *[^ \n]+\\)\\|\\(used inconsistently\\)"
  "Regular expression for filename/linenumber in error in compilation log.")

(make-variable-buffer-local 'track-eol)

;;; Re-define some font-lock functions since they screw us up.
(defun font-lock-use-default-fonts ()
  "Reset the font-lock faces to a default set of fonts."
  (interactive)
  ;;  (font-lock-copy-face 'italic 'font-lock-comment-face)
  ;;  ;; Underling comments looks terrible on tty's
  ;;  (set-face-underline-p 'font-lock-comment-face nil 'global 'tty)
  ;;  (set-face-highlight-p 'font-lock-comment-face t 'global 'tty)
  ;;  (font-lock-copy-face 'font-lock-comment-face 'font-lock-string-face)
  ;;  (font-lock-copy-face 'font-lock-string-face 'font-lock-doc-string-face)
  ;;  (font-lock-copy-face 'bold-italic 'font-lock-function-name-face)
  ;;  (font-lock-copy-face 'bold 'font-lock-keyword-face)
  ;;  (font-lock-copy-face 'bold 'font-lock-preprocessor-face)
  ;;  (font-lock-copy-face 'italic 'font-lock-type-face)
  ;;  ;; is this necessary?
  ;;  (remove-hook 'font-lock-mode-hook 'font-lock-use-default-fonts)
  nil)

(defun font-lock-use-default-colors ()
  "Reset the font-lock faces to a default set of colors."
  (interactive)
  ;;  (font-lock-copy-face 'default 'font-lock-comment-face)
  ;;  (font-lock-set-foreground "#6920ac" 'font-lock-comment-face)
  ;;  (font-lock-copy-face 'default 'font-lock-string-face)
  ;;  (font-lock-set-foreground "green4" 'font-lock-string-face)
  ;;  (font-lock-copy-face 'default 'font-lock-doc-string-face)
  ;;  (font-lock-set-foreground "green4" 'font-lock-doc-string-face)
  ;;  (font-lock-copy-face 'default 'font-lock-function-name-face)
  ;;  (font-lock-set-foreground "red3" 'font-lock-function-name-face)
  ;;  (font-lock-copy-face 'default 'font-lock-keyword-face)
  ;;  (font-lock-set-foreground "blue3" 'font-lock-keyword-face)
  ;;  (font-lock-copy-face 'default 'font-lock-preprocessor-face)
  ;;  (font-lock-set-foreground "blue3" 'font-lock-preprocessor-face)
  ;;  (font-lock-copy-face 'default 'font-lock-type-face)
  ;;  (font-lock-set-foreground "blue3" 'font-lock-type-face)
  ;;  ;; is this necessary?
  ;;  (remove-hook 'font-lock-mode-hook 'font-lock-use-default-colors)
  nil)

(defun global-toggle-case-fold-search (arg)
  (interactive "sSet default case-insensitivity for NEW buffers (T or F): ")
  (if (or (equal arg "F") (equal arg "f"))
      (setq-default case-fold-search nil)
    (setq-default case-fold-search t)))

(defun set-local-case-fold-search (arg)
  "Set case-sensitivity for the current window."

  (interactive "sSet case-insensitivity for current buffer (T or F): ")
  (if (or (equal arg "F") (equal arg "f"))
      (setq case-fold-search nil)
    (setq case-fold-search t)))

;;
;; functions to move to a particular place.
;;

(defun move-to-first-line-of-window (arg)
  "move to the first line of the current window."

  (interactive "p")
  (if (eq arg 4)
      (move-to-window-line (/ (window-height) 4))
    (move-to-window-line 0))
  )

(defun move-to-middle-of-window ()
  "move to the middle of the current window."

  (interactive)
  (move-to-window-line (- (/ (window-height) 2) 1))
  )

(defun move-to-last-line-of-window (arg)
  "move to the (almost) last line of the current window."

  (interactive "p")
  (if (eq arg 4)
      (move-to-window-line
       (+ (/ (window-height) 2) (/ (window-height) 4)))
    (move-to-window-line (- (window-height) 3))))

(defun skip-66-forward ()
  "skip forward 66 lines (one full page)."

  (interactive)
  (next-line 66))

(defun skip-66-backward ()
  "skip backward 66 lines (one full page)."

  (interactive)
  (previous-line 66))

;;(defun insert-tab()
;;  "Insert a tab charcter here."
;;
;;  (interactive)
;;  (self-insert-command 1))

(defun kill-1-line()
  "Kill one whole line, regardless of whether it's empty or not"

  (interactive)
  (beginning-of-line)
  (kill-line 1))

(defun indent-buffer ()
  "Indent each non-blank line in the buffer."
  (interactive)
  (indent-region-func (point-min) (point-max)))

(defun indent-region-func (start end)
  "Indent each nonblank line in the region.
Called from a program, takes two args: START and END."
  (interactive "r\nP")
  (save-excursion
    (goto-char end)
    (setq numlines (count-lines start end))
    (setq end (point-marker))
    (goto-char start)
    (setq curline 1)
    (or (bolp) (forward-line 1))
    (while (< (point) end)
      (message "Indenting line %d of %d" curline numlines)
      (funcall indent-line-function)
      (forward-line 1)
      (setq curline (1+ curline)))
    (move-marker end nil)))

(setq indent-region-function 'indent-region-func)

(defun run-make(param)
  "Run 'make'."

  (interactive "sCompile command: ")
  (compile param)
  (other-window 1)
  (end-of-buffer)
  (insert-string " "))

(defun run-previous-compile()
  "Run previous compile command"

  (interactive)
  (compile ""))


(defun ring-bell()
  "Ring the terminal bell."

  (interactive)
  (beep)
  (beep)
  (beep))


;;
;; ----------------------------------------------------------------------
;; Confirm exit prior to exiting.

(defun confirm-exit-emacs ()
  (interactive)
  (if (y-or-n-p "Exit emacs? ")
      (save-buffers-kill-emacs)
    (beep)))


;;
;; ----------------------------------------------------------------------
;; Modify kill-buffer so that it deletes auto-save files

;; (defun kill-buffer-and-delete-auto-save (buffer)
;;   "Kill a buffer and remove any associated auto-save file."
;;   (interactive "bKill buffer:  ")
;;   (let ((filename nil))
;;     (if (and buffer-auto-save-file-name (recent-auto-save-p))
;;         (if (y-or-n-p "Delete autosave file? ")
;;             (setq filename buffer-auto-save-file-name)))
;;     (kill-buffer buffer)
;;     (if (and filename (not (equal (buffer-name) buffer)))
;;         (delete-file filename))))

(defun top-of-screen ()  (interactive) (move-to-window-line  0))
(defun bot-of-screen ()  (interactive) (move-to-window-line -1))

(defun where-am-i (pt)  (interactive "d")
       (let*
           ((mk (mark))
            (rgn (if (or (eq pt mk) (null mk)) "" (count-lines-region pt mk))))
         ;;
         (message "   %s   Column %d    Character %d of %d    %s"
                  (what-line) (1+ (current-column)) pt (point-max) rgn)))

(defun next-line (arg)  ;; eliminates eob insert of new line
  (interactive "p")
  (line-move arg)
                                        ;  (next-line-internal arg)
  nil)

(defun scroll-other-window-back () (interactive) (scroll-other-window -1))

(defun other-or-make-window (count) (interactive "p")
       (if (one-window-p t) (split-window))
       (other-window count))

(defun shorten-other-window (count) (interactive "p")
       (if (not (one-window-p t)) (enlarge-window count)))

(defun narrow-other-window (count) (interactive "p")
       (if (not (one-window-p t)) (enlarge-window-horizontally count)))

(defun overwrite-or-insert () (interactive)
       (setq insert-mode overwrite-mode)
       (overwrite-mode nil))

(defun label-last-kbd-macro (label)
  "Bind macro to a key, F7 thru S10.
     Apparent EMACS bug ignores non-error minibuffer I/O while macro runs."
  (interactive "aEnter the label on a key from F7 to F10 (or S7 to S10): ")
  (name-last-kbd-macro label)
  (message "Key %s is now the same as typing \"%s\""
           label (symbol-function label)))

(defun funcs-ctl-x-f-sorry () (interactive)
       (beep) (message "No C-x f; use M-x set-fill-column; %d now." fill-column))

(defun funcs-ctl-w-sorry   () (interactive)
       (beep) (message "No C-W; for kill-region, use 'C-Q C-W.'"))

;; We note an undocumented but potentially useful technique:
;; (defun exec (expr-string) (eval (car (read-from-string expr-string))))


(defun none () "Message only"  (interactive) (beep)
       (message "Undefined Function Key; value %s"
                (key-description (this-command-keys))))

(defun right-delimiter (key)
  "Blink even in read-only files"
  (interactive "p")
  (if buffer-read-only
      (progn
        (forward-char)
        (blink-matching-open))
    (self-insert-command key)))

(defun switch-to-number-shell-or-buffer-previous (arg)
  (interactive "P")
  (if (and arg (integerp arg))
      (switch-shell arg)
    (switch-to-buffer (other-buffer))))


(defun funcs-next-buffer ()
  (interactive)
  (let* ((first nil)
         (starting-point (car (buffer-list)))
         file-name)
    (while (and (not first) (not (eq first starting-point)))
      (bury-buffer)
      (setq buffers (buffer-list))
      (setq first (car buffers))
      (setq file-name (buffer-file-name))
      (if (and file-name
               (not (equal (file-name-nondirectory file-name) "RMAIL")))
          ()
        (setq first nil)))
    (message (concat "File: " file-name "      [" (buffer-name first) "]"))))

(defvar current-varying-number 0)
(defvar current-add-number 1)

(defun add-varying-numbers (param)
  (interactive "*P");
  (if param
      (setq current-varying-number param)
    (insert (format add-varying-numbers-base-string current-varying-number))
    (setq current-varying-number
          (+ current-varying-number current-add-number))))

(setq add-varying-numbers-base-string "%d")

(defun set-current-add-number (fmt startnum)
  (interactive "sFormat string: \nNIncrement number by how much each time? ")
  (setq add-varying-numbers-base-string fmt)
  (setq current-add-number startnum))

(defun set-fill-prefix-all-blanks ()
  (interactive)
  (setq fill-prefix (make-string (current-column) 32)))

(setq c-variable-column c-default-variable-column)

(defun c-indent-variable ()
  (interactive)
  (expand-abbrev)
  (let (begin end indentation)
    (end-of-line)
    (setq end (point))
    (beginning-of-line)
    (setq begin (point))
    (if (search-forward ";" end t)
        (progn
          (backward-char 1)
          (skip-chars-backward "*])a-zA-Z0-9_([" begin)
          (just-one-space)
          (kill-line)
          (indent-to (+ (current-indentation) c-variable-column))
          (setq indentation (point-marker))
          (yank)
          (goto-char indentation))
      (end-of-line)
      (delete-horizontal-space)
      (indent-to (+ (current-indentation) c-variable-column)))))

(defun c-set-variable-column (arg)
  "Set the column to which variables will be indented.
With no arg, set the variable column to the current column.
With any arg, set variable column to specified numeric argument."
  (interactive "P")
  (if arg
      (if (>= (prefix-numeric-value arg) 0)
          (setq c-variable-column (prefix-numeric-value arg))
        (setq c-variable-column c-default-variable-column))
    (setq c-variable-column (- (current-column) (current-indentation))))
  (message "Variable column set to %d" c-variable-column))

(defun c-forward-function(arg)
  "Move to beginning of the next C function."

  (interactive "P")
  (let* ((pos (point))
         (brace-offset
          (if arg
              arg
            (c-get-offset '(defun-open . nil))))
         (leading-white-space (make-string brace-offset ?\ ))
         (search-string (concat "^" leading-white-space "{")))
    (forward-char)
    (if (not (re-search-forward search-string (point-max) t))
        (progn
          (beep)
          (goto-char pos))
      (backward-char))))

(defun c-backward-function(arg)
  "Move to beginning of the previous C function."

  (interactive "P")
  (let* ((brace-offset
          (if arg
              arg
            (c-get-offset '(defun-open . nil))))
         (leading-white-space (make-string brace-offset ?\ ))
         (search-string (concat "^" leading-white-space "{")))
    (if (not (re-search-backward search-string (point-min) t))
        (beep)
      (forward-char brace-offset))))


(defun strip-leading-white-space ()
  (interactive)
  (save-excursion
    (beginning-of-line)
    (delete-horizontal-space)
    (while (not (eobp))
      (next-line 1)
      (beginning-of-line)
      (delete-horizontal-space)
      (end-of-line))))


(defun insert-braces (arg)
  "Put braces around next ARG lines.  Leave point at end of last line.
No argument is equivalent to zero: just insert {} and leave point between."
  (interactive "P")
  (if arg
      (let* ((odot (point)))
        (insert ?\{)
        (insert ?\n)
        (next-line (prefix-numeric-value arg))
        (insert ?\})
        (insert ?\n)
        (indent-region odot (point) nil)
        (next-line -2)
        (end-of-line))
    (progn
      (insert ?\{)
      (c-indent-command)
      (save-excursion
        (newline-and-indent)
        (insert ?\})
        (c-indent-command))
      (newline-and-indent))))


(defun insert-braces-around-lines (arg)
  "Put braces around next ARG lines.  Leave point at end of last line."
  (interactive "P")
  (let* ((odot (point)))
    (insert ?\{)
    (insert ?\n)
    (if arg
        (next-line (prefix-numeric-value arg))
      (next-line 1))
    (insert ?\})
    (indent-region odot (point) nil)
    (next-line -1)
    (end-of-line)))




;;; C Comment Edit
;;; Copyright (C) 1987 Kyle E. Jones
;;;
;;; This software may be redistributed provided this notice appears on all
;;; copies and that the further free redistribution of this software is not
;;; restricted in any way.
;;;
;;; This software is distributed 'as is', without warranties of any kind.

(defconst c-comment-leader-regexp
  "^[ \t]*\\(/\\*\\*\\|/\\*\\|\\*/\\|\\*\\|\\*\\*\\)[ ]?"
  "Regexp used to match C comment leaders.")

(defvar c-comment-edit-mode 'indented-text-mode
  "*Mode used by (c-comment-edit) when editing C comments.")

(defvar c-comment-leader " *"
  "*Leader used when rebuilding edited C comments.  The value of this variable should be a two-character string.  Values of \"  \", \" *\" and \"**\" produce the comment styles:
        /*   /*  /*
                 *  **
                 *  **
        */   */ */
respectively.")

(defconst c-comment-doxygen-leader-regexp "^[ \t]*[@\\]"
  "Regexp used to locate any doxygen command.")

(defvar kill-c-comment-edit-buffer nil)

(defun c-comment-edit (create)
  "Edit multi-line C comments.
This command allows the easy editing of a multi-line C comment like this:
   /*
    * ...
    * ...
    */
The comment may be indented or flush with the left margin.

When invoked with point inside a C comment, this function copies the comment
into a \"*C Comment Edit*\" buffer, strips the comment leaders and delimiters,
and performs a recursive-edit on the resulting buffer.  The major mode of this
buffer is controlled by the variable `c-comment-edit-mode'.

Use the `exit-recursive-edit' command once you have finished editing the
comment.  The comment will be inserted into the original buffer
with the appropriate delimiters, replacing the old version of the comment.
If you don't want your edited version of the comment to replace the original,
use the `abort-recursive-edit' command.

Prefix arg or first arg non-nil means to create an empty C comment at point
and then edit that."
  (interactive "*P")
  (let ((indention (current-indentation))
        start end odot comment-size comment-fill-column lead-in-string
        (c-buffer (current-buffer)))
    (save-excursion
      (save-window-excursion
        (cond (create (insert "/*\n*/")(backward-char 3)(c-indent-command)))
                                        ;    (if (and (not (eq indention t)) (not create))
                                        ;        (error "Not within a comment."))
        ;; figure out where the comment begins and ends
        (setq odot (point))
        (search-backward "/*" (point-min))
        (setq comment-fill-column (- 75 (current-column)))
        (setq start (point))
        (goto-char odot)
        (search-forward "*/" (point-max))
        (setq end (point))
        ;; copy the comment to the comment-edit buffer
        (copy-to-buffer "*C Comment Edit*" start end)
        ;; select this buffer for editing
        (switch-to-buffer-other-window "*C Comment Edit*")
        ;; untabify the comment since it won't line up properly without
        ;; leaders and delimiters.
        (untabify (point-min) (point-max))
        ;; mark cursor position since we're going to delete things.
        (goto-char (+ (- odot start) 1))
        (push-mark (point) 'quiet)
        (goto-char (point-min))
        ;; remove the leaders and delimiters
        (while (re-search-forward c-comment-leader-regexp (point-max) t)
          (replace-match "" nil t) (forward-line 1))
        ;; run appropriate major mode
        (funcall c-comment-edit-mode)
        (setq fill-column comment-fill-column)
        (goto-char (point-min))
        ;; delete one leading newline
        (if (looking-at "[ \n]")
            (delete-char 1))
        ;; restore cursor
        (pop-mark)
        (goto-char (mark))
        ;; creation is modification, no?
        (set-buffer-modified-p create)
        ;; edit the comment
                                        ;    (message
                                        ;     (substitute-command-keys
                                        ;      "Type \\[exit-recursive-edit] to end edit, \\[abort-recursive-edit] to abort with no change."))
        (message
         "Type M-C-C to end edit, C-] to abort with no change.")
        (recursive-edit)
        ;; in case the user wandered elsewhere
        (switch-to-buffer-other-window "*C Comment Edit*")
        (cond
         ((buffer-modified-p)
                                        ; rebuild the comment

          ;; untabify the comment since it won't line up properly without
          ;; leaders and delimiters.
          (untabify (point-min) (point-max))

          (goto-char (point-min))
          ;; determine if there are any doxygen elements in the comment
          (setq lead-in-string "/*\n")
          (if (re-search-forward c-comment-doxygen-leader-regexp (point-max) t)
              (setq lead-in-string "/**\n"))
          (goto-char (point-min))
          (insert lead-in-string)
          (while (not (eobp))
            (insert c-comment-leader (if (eolp) "" " "))
            (forward-line 1))
          (insert (cond
                   ((string= c-comment-leader " *") " */")
                   (t "*/")))

          ;; re-tabify the comment.
                                        ; (tabify (point-min) (point-max))
          ;; replace the old comment with the new

          (setq comment-size (buffer-size))
          (switch-to-buffer c-buffer)
          (delete-region start end)
          (goto-char start)
          (insert-buffer-substring "*C Comment Edit*")
          (goto-char start)
          ;; if inserting at other than column 0 we gotta indent, too
          (if (not (zerop (current-column)))
              (progn
                (message "Indenting...")
                (indent-region start (+ start comment-size) nil)
                (message "Done."))))
         (t (message "No change.")))
        (if kill-c-comment-edit-buffer
            (kill-buffer "*C Comment Edit*")
          (bury-buffer "*C Comment Edit*"))))
    ;; save-excursion can't recover point if we deleted things
    (goto-char odot)))

;;;
   ;;; Function keybind-init will get redefined by the real terminal
   ;;; code in the term directory.
   ;;;

   ;; We define VM stuff in this file, but it may not yet be loaded
                                           ;(require 'vm)

   (defun keybind-init ()
     (interactive)
     (keybind-local-mods)
     (keybind-local-alt-mods)

     ;;;
     ;;; Thanks to http://www.emacswiki.org/emacs/CopyAndPaste
     ;;; Make emacs use the X11 clipboard
     ;;;

     (transient-mark-mode 1)    ; Now on by default: makes the region act quite
                                           ; like the text "highlight" in many apps.  (setq
     ;; shift-select-mode t)    ; Now on by default: allows shifted cursor-keys to
                                           ; control the region.
     (setq mouse-drag-copy-region nil)  ; stops selection with a mouse being
                                           ; immediately injected to the kill ring
     (setq select-enable-primary nil)  ; stops killing/yanking interacting
                                           ; with primary X11 selection
     (setq select-enable-clipboard t)  ; makes killing/yanking interact with
                                           ; clipboard X11 selection

                                           ; You need an emacs with bug #902 fixed for this to work properly. It has
                                           ; now been fixed in CVS HEAD.  it makes "highlight/middlebutton" style (X11
                                           ; primary selection based) copy-paste work as expected if you're used to
                                           ; other modern apps (that is to say, the mere act of highlighting doesn't
                                           ; overwrite the clipboard or alter the kill ring, but you can paste in
                                           ; merely highlighted text with the mouse if you want to)
     (setq select-active-regions t) ;  active region sets primary X11 selection
     (global-set-key [mouse-2] 'mouse-yank-primary)  ; make mouse middle-click
                                           ; only paste from primary
                                           ; X11 selection, not
                                           ; clipboard and kill ring.

     ;; with this, doing an M-y will also affect the X11 clipboard, making emacs
     ;; act as a sort of clipboard history, at least of text you've pasted into
     ;; it in the first place.
                                           ; (setq yank-pop-change-selection t) ; makes rotating the kill ring change
                                           ; the X11 clipboard.


     )

   (defun keybind-shell-mode-hooker ()
     nil)

   (defun keybind-lisp-interaction-mode-hooker ()
     nil)

   (defun keybind-local-mods ()
     (interactive)

     ;; Improved rules for matching delimiters; overridden within C mode
     (global-set-key ")" 'right-delimiter)
     (global-set-key "}" 'right-delimiter)
     (global-set-key "]" 'right-delimiter)

     ;; Users asked for these safety features
     (global-set-key "\C-xf" 'funcs-ctl-x-f-sorry)
     (global-set-key "\C-w"  'funcs-ctl-w-sorry))

   (defun keybind-local-alt-mods ()
     (interactive)

     ;; re-assign some common keys I like to use
     (global-set-key "\C-M" 'newline-and-indent)
     (global-set-key "\C-J" 'newline)
     (global-set-key "\C-N" 'next-line)
     (global-set-key "\C-H" 'delete-backward-char)  ; actually reassigning DEL
     (global-set-key "\C-R" 'scroll-down)
     (global-set-key "\C-X\C-C" 'confirm-exit-emacs)
     (global-set-key "\C-X\C-N" 'next-file)
     (global-set-key "\C-X\C-T" 'visit-tags-table)
     (global-set-key "\C-X\C-M" 'run-make)
     (global-set-key "\C-Xm" 'compile)
     (global-set-key "\C-Xk" 'kill-buffer-and-delete-auto-save)
     (global-set-key "\C-X\C-K" 'kill-compilation)
     (global-set-key "\C-C;" 'comment-region)
     (global-set-key "\M-#" 'help-command)
     (global-set-key "\M-:" 'c-comment-edit)
     (global-set-key "\M-\C-h" 'backward-kill-word)
                                           ;  (global-set-key "\C-X\eh" 'list-command-history)
     (fset 'help-command help-map)

     ;; define a set of local (to me) keys which begin with the prefix Cntrl-Q
     (setq Local-map (make-keymap))
     (define-key Local-map "." 'set-fill-prefix-all-blanks)
     (define-key Local-map "a" 'set-current-add-number)
     (define-key Local-map "b" 'bury-buffer)
     (define-key Local-map "c" 'set-local-case-fold-search)
     (define-key Local-map "C" 'global-toggle-case-fold-search)
     (define-key Local-map "f" 'font-lock-mode)
     (define-key Local-map "g" 'magit-status)
     (define-key Local-map "i" 'indent-buffer)
     (setq Local-map-per-user (make-keymap))
     (define-key Local-map "l" Local-map-per-user)

                                           ; Too confusing.  Force me to go into news or read-mail prior to sending.
                                           ; (define-key Local-map "m" 'other-or-make-gnus-window)

     (define-key Local-map "s" '(lambda ()
                                  (interactive)
                                  (speedbar-frame-mode nil)))
     (define-key Local-map "t" 'tags-function)
     (define-key Local-map "{" 'shrink-window)
     (define-key Local-map "}" 'enlarge-window)
     (define-key Local-map "=" 'where-am-i)
     (define-key Local-map "\C-A" 'add-varying-numbers)
     (define-key Local-map "\C-B" 'c-backward-function)
   ;;  (define-key Local-map "\C-C" 'x-copy-primary-selection)
     (define-key Local-map "\C-D" 'gdb)
     (define-key Local-map "\C-F" 'c-forward-function)
     (define-key Local-map "\C-G" 'goto-line)
     (define-key Local-map (kbd "DEL") 'move-to-first-line-of-window)
     (define-key Local-map "\C-I" 'c-indent-variable)
     (define-key Local-map "\C-K" 'kill-1-line)
     (define-key Local-map "\C-L" 'move-to-last-line-of-window)
     (define-key Local-map "\C-M" 'move-to-middle-of-window)
     (define-key Local-map "\C-N" 'funcs-next-buffer)
     (define-key Local-map "\C-O" 'occur)
     (define-key Local-map "\C-P" '(lambda ()
                                     (interactive)
                                     (if (y-or-n-p
                                          "Confirm: Print current buffer? ")
                                         (lpr-buffer)
                                       (message ""))))
     (define-key Local-map "\C-Q" 'quoted-insert)
     (define-key Local-map "\C-R" 'rename-buffer)
     (define-key Local-map "\C-S" '(lambda ()
                                     (interactive)
                                     (beep)
                                     (message "Use M-1 - M-9 instead")))
     (define-key Local-map "\C-V" 'x-yank-clipboard-selection)
     (define-key Local-map "\C-W" 'kill-region)
;;     (define-key Local-map "\C-X" 'x-kill-primary-selection)
     (define-key Local-map "\C-Z" 'suspend-emacs)
     (global-unset-key "\C-q")
     (define-key global-map "\C-q" Local-map)

     (define-key Local-map "\M-i" 'c-set-variable-column)
     (define-key Local-map "\M-b" 'hexl-find-file)
;;     (define-key Local-map "\M-c" 'x-copy-primary-selection)
;;     (define-key Local-map "\M-l" 'show-region)
     (define-key Local-map "\M-r" 'rectangle)
     (define-key Local-map "\M-w" 'what-line)
     (define-key Local-map "\M-v" 'x-yank-clipboard-selection)
     (define-key Local-map "\M-%" 'query-replace-regexp)
     (define-key Local-map "\M-$" 'spell-buffer)
     (define-key Local-map "\M-\\" 'strip-leading-white-space)
     )

   (fset 'quit-command "\007")  ; Keyboard-quit doesn't quit in minibuffer


   ;;; isearch key bindings
   (define-key isearch-mode-map    "\C-h"   'isearch-delete-char)

   ;; use ^H as the rubout character
   (defun keybind-swap-delete-and-backspace ()
     (interactive)

     ;;; Use this in xemacs 19.14

     (keyboard-translate ?\177 ?\C-h)
     (keyboard-translate ?\C-h ?\177))

   (defun kb-generic-shell-mode-hooker ()
     (interactive)

     (define-key shell-mode-map "\C-Q\C-C"
       '(lambda ()
          (interactive)
          (kill-region (point-min) (point-max))
          (comint-send-input)
          (message " All lines killed in this buffer.")))

     (define-key shell-mode-map "\C-Q\C-S"
       'switch-to-number-shell-or-buffer-previous))

   (defvar keybind-shell-mode-hooker nil)   ; defined in term/kb-<termtype>.el

   (keybind-init)
   (keybind-swap-delete-and-backspace)

;;   (keybind-init)
;;   (keybind-swap-delete-and-backspace)

                                           ; Display time in mode line
   (display-time)

                                           ; Reset modeline-format to have time and mail flag first on mode line
   (setq-default modeline-format '(" %* " global-mode-string " %n  " mode-line-buffer-identification "  " (-3 . "%p") "  %f  %[(" mode-name mode-line-process ")%]  %-"))

                                           ; Only display 24-hour time
   (setq display-time-form-list (list '24-hours 'minutes))

   (garbage-collect)

   (put 'eval-expression 'disabled nil)
   (put 'narrow-to-region 'disabled nil)
   (put 'upcase-region 'disabled t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-time-mode t)
 '(indent-tabs-mode nil)
 '(js-indent-level 2)
 '(js2-auto-indent-p t)
 '(js2-basic-offset 2)
 '(js2-bounce-indent-p t)
 '(js2-enter-indents-newline t)
 '(js2-global-externs
   (quote
    ("qx" "console" "require" "module" "Buffer" "location" "document" "window")))
 '(js2-indent-on-enter-key t)
 '(js2-missing-semi-one-line-override nil)
 '(js2-mode-escape-quotes nil)
 '(json-reformat:indent-width 2 t)
                                        ;     '(package-selected-packages (quote (projectile magit js2-mode)))
                                        ;    '(save-place t nil (saveplace))
 '(show-paren-mode t)
                                        ;     '(tool-bar-mode nil)
 )
                                        ;    (custom-set-faces
                                        ;     ;; custom-set-faces was added by Custom.
                                        ;     ;; If you edit it by hand, you could mess it up, so be careful.
                                        ;     ;; Your init file should contain only one such instance.
                                        ;     ;; If there is more than one, they won't work right.
                                        ;     '(font-lock-comment-face ((((class color) (min-colors 88) (background light)) (:foreground "DarkRed"))))
                                        ;     '(font-lock-doc-face ((t (:foreground "DarkRed"))))
                                        ;     '(font-lock-type-face ((((class color) (min-colors 88) (background light)) (:foreground "DarkCyan"))))
                                        ;     '(region ((t (:background "dark khaki" :distant-foreground "gtk_selection_fg_color")))))
(setq enable-local-eval 'maybe)		; query before eval in Local Variables:
(setq enable-local-variables 'maybe)	; query before setting variables

                                        ;    (put 'eval-expression 'disabled nil)

(setq default-fill-column
      (- (frame-width) 2))

                                        ;    (setq browse-url-browser-function 'browse-url-kde)

                                        ;    (font-lock-mode)

(setq json-reformat:indent-width 2)
(put 'downcase-region 'disabled nil)

(defun shell-same-window-advice (orig-fn &optional buffer)
  "Advice to make `shell' reuse the current window.

Intended as :around advice."
  (let* ((buffer-regexp
          (regexp-quote
           (cond ((bufferp buffer)  (buffer-name buffer))
                 ((stringp buffer)  buffer)
                 (:else             "*shell*"))))
         (display-buffer-alist
          (cons `(,buffer-regexp display-buffer-same-window)
                display-buffer-alist)))
    (funcall orig-fn buffer)))

(advice-add 'shell :around #'shell-same-window-advice)

(switch-shell 1)
(garbage-collect)

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c o")
                (lambda () (interactive) (find-file
                                          org-default-notes-file)))
(setq
 org-default-notes-file "/home/derrell/ME/SyncThing/Inbox.org"
 org-refile-targets '((org-agenda-files :maxlevel . 2))
 org-catch-invisible-edits 'smart
 org-agenda-files
 '("~/ME/SyncThing/Inbox.org"
   "~/ME/SyncThing/Work.org"
   "~/ME/SyncThing/Play.org")
 org-enforce-todo-dependencies t
 org-agenda-start-day "+0d"
 org-agenda-span 3
 org-agenda-custom-commands
      '(("n" "Agenda and all TODOs"
        ((agenda #1="")
         (alltodo #1#)
         (stuck #1#)
         )))
 org-capture-templates
 '(      
   ("c" "Comment"
    entry (file org-default-notes-file)
    "* %?   %u\n")

   ("t" "Todo"
    entry (file org-default-notes-file)
    "* TODO %?   %u\n")

   ("l" "Todo w/ Context link and region"
    entry (file org-default-notes-file)
    "* TODO %? %U\n  %i\n  Link: %a")

   ("m" "Minimal note"
    entry (file org-default-notes-file)
    "* %?") 
   )       
 )

;; (setq org-super-agenda-groups
;;      '(
;;        (:name "Deadline"
;;               :and (:deadline past)
;;               )
;;        (:name "Daily Habits"
;;               :time-grid t
;;               :and (:tag "daily" :and (:tag "recurring"))
;;               )
;;        (:name "Scheduled"
;;         :auto-planning t
;;         :time-grid t)
;;        ))

(add-hook 'org-mode-hook 'auto-revert-mode)

(require 'real-auto-save)
(add-hook 'org-mode-hook 'real-auto-save-mode)

(setq org-plantuml-jar-path
      (expand-file-name "/home/derrell/.emacs.d/plantuml.jar"))
(add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
(org-babel-do-load-languages 'org-babel-load-languages '((plantuml . t)))

(require 'ox-beamer)
(require 'ox-latex)
(setq org-export-allow-bind-keywords t)
(setq org-latex-listings 'minted)
(add-to-list 'org-latex-packages-alist '("" "minted"))
(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)
   (python . t)
   (C . t)
   (ruby . t)
   (js . t)
   (ditaa . t)
   ))
(setq
 org-ditaa-jar-path "/usr/share/ditaa/ditaa.jar"
 org-latex-pdf-process
 '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
   "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
   "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
