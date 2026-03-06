;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-langs/cpp/config.el

;;; References:
;; https://github.com/doomemacs/doomemacs/tree/master/modules/lang/cc
;; https://emacs-lsp.github.io/lsp-mode/tutorials/CPP-guide/

(defun cc/configure--disaster ()
  ;; add to display-buffer-alist for disaster-buffer-assembly
  (add-to-list 'display-buffer-alist
               `(,disaster-buffer-assembly
                 (display-buffer-reuse-window display-buffer-in-side-window)
                 (side . right)
                 (window-width . 0.4)
                 (reusable-frames . visible)))
  (advice-add #'disaster :after #'cc/focus-on-disaster-buffer)
  (map! :map asm-mode-map "q" #'kill-buffer-and-window)
  (add-hook! 'asm-mode-hook (display-line-numbers-mode -1)))

(when (modulep! :lang cc)
  (add-to-list 'auto-mode-alist '("conanfile\\.txt\\'" . conf-unix-mode))
  (after! disaster (cc/configure--disaster))
  (setq-hook! 'c++-mode-hook
    standard-indent cc/cpp-default-tab-width
    c-basic-offset cc/cpp-default-tab-width
    tab-width cc/cpp-default-tab-width)
  (add-hook! 'c++-mode-hook
             #'cc/cpp-set-default-sytle
             #'cc/cpp-set-default-capf)
  (add-hook! 'lsp-completion-mode-hook #'cc/cpp-set-lsp-capf)
  (add-hook! 'compilation-finish-functions #'cc/close-compilation-buffer-if-successful)
  (map! :after cc-mode
        (:map c++-mode-map
              (:prefix "C-c r"
               :desc "C++ Quick run" "q" #'cc/cpp-quick-run
               :desc "C++ Quick debug" "d" #'cc/cpp-quick-debug)
              (:prefix "C-c c"
               :desc "Quick compile" "c" #'cc/cpp-quick-compile
               :desc "C++ Insights" "i" #'cppinsights-run
               :desc "Disassemble" "d" #'disaster
               (:prefix
                ("b" . "<build>")
                (:when (modulep! :tools make)
                  :desc "make command" "m" #'+make/run
                  :desc "make last" "l" #'+make/run-last))))
        (:map cmake-mode-map
              (:prefix
               "C-c c"
               (:prefix
                ("b" . "<build>")
                (:when (modulep! :lang cc)
                  :desc "CMake command" "c" #'cmake-command-run)
                (:when (modulep! :cc-langs cpp)
                  :desc "CMake generate build files" "g" #'cc/cmake-generate-build-files
                  :desc "CMake debug build files" "d" #'cc/cmake-gen-debug-build-files
                  :desc "CMake build" "b" #'cc/cmake-build
                  :desc "CMake ctest" "t" #'cc/cmake-ctest
                  )))))

  ;; cmake-mode
  (setq-hook! 'cmake-mode-hook cmake-tab-width 4)
  (map! :map cmake-mode-map
        :desc "CMake doc" "C-c k k" #'cmake-help)
  (advice-add #'cmake-help :after #'cc/focus-on-cmake-help)

  (when (modulep! :ui popup)
    (set-popup-rules! '(("^\\*CMake" :size 0.4 :quit t :select t)
                        ("^\\*Shell Command Output\\*" :size 0.4 :quit t :select t))))
  )

(when (modulep! :ui indent-guides)
  (add-hook! 'c-mode-common-hook
    (defun configure-indent-guides ()
      (setq-local indent-bars-treesit-support t
                  indent-bars-treesit-wrap
                  '((c argument_list parameter_list
                     init_declarator parenthesized_expression))))))

(when (and (modulep! :tools lsp) (modulep! :lang cc))
  (after! lsp-clangd
    ;; [project] use compile_commands.json
    ;; [user] use ~/.config/clangd/config.yaml
    (setopt lsp-clients-clangd-args
            '("-j=4"
              "--background-index"
              "--clang-tidy"
              "--limit-results=30"
              "--completion-style=detailed"
              ;; "--header-insertion=never"
              "--header-insertion-decorators=0"
              ))
    (set-lsp-priority! 'clangd 2)))

(when (modulep! :tools debugger +lsp)
  (add-hook! 'c-mode-common-hook
    (defun setup-debugger ()
      (require 'dap-gdb)
      (setq dap-gdb-debug-program '("gdb" "-i" "dap")))))
