;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/autoload.el

;; ;;;###autoload
;; (defun cc/gptel-mcp-register-tools ()
;;   (let ((tools (mcp-hub-get-all-tool :asyncp t :categoryp t)))
;;     (mapcar #'(lambda (tool)
;;                 (apply #'gptel-make-tool
;;                        tool))
;;             tools)))

;; ;;;###autoload
;; (defun cc/gptel-enable-all-mcp-tools ()
;;   (interactive)
;;   (let ((tools (mcp-hub-get-all-tool :asyncp t :categoryp t)))
;;     (mapcar #'(lambda (tool)
;;                 (let ((path (list (plist-get tool :category)
;;                                   (plist-get tool :name))))
;;                   (push (gptel-get-tool path)
;;                         gptel-tools)))
;;             tools)))

;; ;;;###autoload
;; (defun cc/gptel-disable-all-mcp-tools ()
;;   (interactive)
;;   (let ((tools (mcp-hub-get-all-tool :asyncp t :categoryp t)))
;;     (mapcar
;;      #'(lambda (tool)
;;          (let ((path (list (plist-get tool :category)
;;                            (plist-get tool :name))))
;;            (setq gptel-tools
;;                  (cl-remove-if
;;                   #'(lambda (tool)
;;                       (equal path
;;                              (list (gptel-tool-category tool)
;;                                    (gptel-tool-name tool))))
;;                   gptel-tools))))
;;      tools)))
