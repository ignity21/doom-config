;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; config.d.new/ui.el

(when (modulep! :ui popup)
  (map! :map +popup-buffer-mode-map
    :desc "Raise popup" "C-c C-p" #'+popup/raise))

;; `+dashboard-name' is set in init.el — it must precede the dashboard module's
;; early buffer bootstrap, which runs before this file loads.

(when (modulep! :ui treemacs)
  (map! :map treemacs-mode-map
    "C-c C-p" nil
    "C-c C-w" nil
    :desc "Select window" "C-x o" #'treemacs-select-window
    (:prefix
      ("p" . "<tree-project>")
      :desc "Switch project" "o" #'treemacs-projectile
      :desc "Add project" "a" #'treemacs-add-project-to-workspace
      :desc "Remove project" "r" #'treemacs-remove-project-from-workspace
      :desc "Unfold all" "c" #'treemacs-collapse-all-projects
      :desc "Rename project" "m" #'treemacs-rename-project)
    (:prefix
      ("w" . "<tree-workspace>")
      :desc "Create workspace" "c" #'treemacs-create-workspace
      :desc "Remove workspace" "r" #'treemacs-remove-workspace
      :desc "Edit workspaces" "e" #'treemacs-edit-workspaces
      :desc "Rename workspace" "m" #'treemacs-rename-workspace
      :desc "Switch workspace" "o" #'treemacs-switch-workspace))
  (setopt +treemacs-git-mode 'deferred)
  (when (modulep! :ui treemacs +lsp)
    (setopt lsp-treemacs-sync-mode t
      treemacs-width 30
      lsp-treemacs-error-list-expand-depth 3)
    (map! :map lsp-treemacs-generic-map
      :desc "Select window" "C-x o" #'other-window)))

(when (modulep! :ui window-select)
  (custom-set-faces!
    '(aw-leading-char-face :inherit 'font-lock-builtin-face :height 4.5)))

(when (and (modulep! :ui window-select)
        (modulep! :ui treemacs))
  (after! (:and treemacs ace-window)
    (setopt aw-ignored-buffers (delq 'treemacs-mode aw-ignored-buffers))))

(defun cc/workspace-save-current ()
  "Save the current workspace under its own name."
  (interactive)
  (+workspace/save (persp-name (get-current-persp))))

(when (modulep! :ui workspaces)
  (map! :map persp-mode-map
    "C-c p" nil)
  (map! :desc "Save Current" "C-c w s" #'cc/workspace-save-current))

(defun cc/zen-disable-line-numbers ()
  "Hide line numbers while writeroom is active."
  (display-line-numbers-mode -1))

(defun cc/zen-enable-line-numbers ()
  "Restore line numbers after leaving writeroom."
  (display-line-numbers-mode +1))

(when (modulep! :ui zen)
  (setopt +zen-text-scale 0.8)
  (add-hook 'writeroom-mode-enable-hook #'cc/zen-disable-line-numbers)
  (add-hook 'writeroom-mode-disable-hook #'cc/zen-enable-line-numbers))
