;;; -*- lexical-binding: t; no-byte-compile: t; ---
;;; cc/notes/roam.el
(when (modulep! :lang org +roam)
  (advice-add 'org-roam-node-find :before #'cc/org-roam-choose-dir-if-not-set)
  (advice-add 'org-roam-capture :before #'cc/org-roam-choose-dir-if-not-set)
  (advice-add 'org-roam-node-insert :before #'cc/org-roam-choose-dir-if-not-set)
  (setopt org-roam-completion-functions nil)


  (after! org-roam
    (setopt
      org-roam-completion-everywhere nil
      org-roam-dailies-directory cc/roam-dailies-dir
      org-roam-capture-templates
      '(("d" "default" plain "%?"
          :if-new (file+head "${slug}-%<%Y%m%d>.org"
                    "#+title: ${title}\n")
          :unnarrowed t)))

    ;; To export roam note correctly
    (advice-add 'org-export-dispatch
      :before
      (lambda (&rest _)
        (require 'org-roam-export))))

  (use-package! org-roam-ui
    :commands org-roam-ui-mode
    :config
    (setopt org-roam-ui-sync-theme t
      org-roam-ui-follow t
      org-roam-ui-update-on-save t
      org-roam-ui-open-on-start t)
    :init
    (map! :prefix ("C-c n u" . "<org-roam-ui>")
      :desc "Start roam UI" "u" #'org-roam-ui-mode
      :desc "Open new UI page" "o" #'org-roam-ui-open
      :desc "Sync UI theme" "s" #'org-roam-ui-sync-theme
      :map org-mode-map
      :desc "Show ui node local" "g" #'org-roam-ui-node-local
      :desc "Zoom ui node" "z" #'org-roam-ui-node-zoom)))
