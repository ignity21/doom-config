;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/notes/+roam.el
(when (modulep! :lang org +roam)
  (setopt org-roam-completion-functions nil)


  (after! org-roam
    (setopt
      org-roam-completion-everywhere nil
      ;; One fixed root and one database make all categories linkable.
      ;; Use an absolute path: org-roam-ui compares directory-filter values
      ;; against the absolute file names stored in org-roam's database.
      org-roam-directory (expand-file-name cc/roam-notes-dir)
      org-roam-db-location (expand-file-name ".cache/org-roam.db"
                             cc/roam-notes-dir)
      org-roam-dailies-directory "dailies/"
      org-roam-capture-templates
      `(("d" "default" plain "%?"
          :if-new (file+head
                    ,(concat cc/org-roam-default-category
                       "/${slug}-%<%Y%m%d>.org")
                    "#+title: ${title}\n")
          :unnarrowed t)))

    (define-advice org-export-dispatch (:before (&rest _) cc/load-org-roam-export)
      "Load org-roam export support before selecting an export backend."
      (require 'org-roam-export)))

  (defvar cc/org-roam-ui--pending-command nil
    "Command to run when org-roam-ui's browser connection opens.")

  (defun cc/org-roam-ui--run-or-defer (command)
    "Run COMMAND now, or after org-roam-ui's browser connection opens."
    (if (and (boundp 'org-roam-ui-ws-socket)
             (websocket-openp org-roam-ui-ws-socket))
        (funcall command)
      (setq cc/org-roam-ui--pending-command command)
      (org-roam-ui-open)
      (message "Opening org-roam UI; the current node will be shown when it connects")))

  (defun cc/org-roam-ui--run-pending-command ()
    "Run and clear the org-roam-ui command deferred for a browser connection."
    (when-let ((command cc/org-roam-ui--pending-command))
      (setq cc/org-roam-ui--pending-command nil)
      (funcall command)))

  (defun cc/org-roam-ui-sync-theme ()
    "Sync the active org-roam-ui browser with the current Emacs theme."
    (interactive)
    (cc/org-roam-ui--run-or-defer #'org-roam-ui-sync-theme))

  (defun cc/org-roam-ui-node-local ()
    "Show the current node's local graph in org-roam-ui."
    (interactive)
    (cc/org-roam-ui--run-or-defer #'org-roam-ui-node-local))

  (defun cc/org-roam-ui-node-zoom ()
    "Zoom org-roam-ui to the current node."
    (interactive)
    (cc/org-roam-ui--run-or-defer #'org-roam-ui-node-zoom))

  (defun cc/org-roam-ui-close ()
    "Stop org-roam-ui and discard any deferred UI command."
    (interactive)
    (setq cc/org-roam-ui--pending-command nil)
    (when (bound-and-true-p org-roam-ui-mode)
      (org-roam-ui-mode -1)))

  (use-package! org-roam-ui
    :commands (org-roam-ui-mode org-roam-ui-open)
    :config
    (setopt org-roam-ui-sync-theme t
      org-roam-ui-follow t
      org-roam-ui-update-on-save t
      org-roam-ui-open-on-start t)
    ;; org-roam-ui exposes no public hook for its browser WebSocket opening.
    ;; This advice runs only the command deferred by `cc/org-roam-ui--run-or-defer'.
    (define-advice org-roam-ui--ws-on-open (:after (&rest _) cc/run-pending-command)
      "Run a UI command deferred until the browser connection was ready."
      (cc/org-roam-ui--run-pending-command))
    :init
    (map!
      :map org-mode-map
      :prefix ("C-c n u" . "<org-roam-ui>")
      :desc "Open roam UI" "u" #'org-roam-ui-open
      :desc "Open new UI page" "o" #'org-roam-ui-open
      :desc "Close roam UI" "q" #'cc/org-roam-ui-close
      :desc "Sync UI theme" "s" #'cc/org-roam-ui-sync-theme
      :desc "Show ui node local" "g" #'cc/org-roam-ui-node-local
      :desc "Zoom ui node" "z" #'cc/org-roam-ui-node-zoom)))
