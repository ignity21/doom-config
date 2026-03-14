;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc-new/keymaps/init.el

;;; modules/cc/keymaps/init.el
(defmacro cc/def-keymap (name key desc)
  "Define a named keymap and bind it to KEY with DESC for which-key.
NAME is the variable name (unquoted), KEY is the key string, DESC is the which-key description."
  (let ((full-desc (concat "<" desc ">")))
    `(progn
       (defvar ,name (make-sparse-keymap) ,full-desc)
       (keymap-set global-map ,key ,name)
       (which-key-add-key-based-replacements ,key ,full-desc))))

(cc/def-keymap cc/ctl-c-file-map "C-c f" "file")
(cc/def-keymap cc/ctl-c-search-map "C-c s" "search")
(cc/def-keymap cc/ctl-c-lookup-map "C-." "lookup")
