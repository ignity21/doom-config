;;; -*- lexical-binding: t; no-byte-compile: t; -*-
;;; cc/ai/+tools.el

(require 'project)

(defconst cc/gptel-file-tool-max-read-bytes (* 1024 1024)
  "Maximum size of a file returned by `cc/gptel-file-read'.")

(defun cc/gptel-file--roots ()
  "Return the canonical roots available to gptel file tools."
  (let ((roots
          (or cc/gptel-file-tool-roots
            (list
              (if-let* ((project (project-current nil default-directory)))
                (project-root project)
                default-directory)))))
    (mapcar
      (lambda (root)
        (when (file-remote-p root)
          (error "Remote file-tool root is not supported: %s" root))
        (unless (file-directory-p root)
          (error "File-tool root is not a directory: %s" root))
        (file-name-as-directory (file-truename root)))
      roots)))

(defun cc/gptel-file--resolve (path &optional must-exist)
  "Resolve PATH inside an allowed root.
When MUST-EXIST is non-nil, signal an error unless PATH exists."
  (unless (and (stringp path) (not (string-empty-p path)))
    (error "Path must be a non-empty string"))
  (when (file-remote-p path)
    (error "Remote paths are not supported: %s" path))
  (let* ((roots (cc/gptel-file--roots))
         (expanded (expand-file-name path (car roots)))
         (canonical
           (cond
             ((file-exists-p expanded) (file-truename expanded))
             (must-exist (error "Path does not exist: %s" path))
             (t
               (let ((parent (file-name-directory expanded)))
                 (unless (file-directory-p parent)
                   (error "Parent directory does not exist: %s" parent))
                 (expand-file-name
                   (file-name-nondirectory expanded)
                   (file-truename parent)))))))
    (unless
        (seq-some
          (lambda (root)
            (or (equal (directory-file-name canonical)
                  (directory-file-name root))
              (file-in-directory-p canonical root)))
          roots)
      (error "Path is outside cc/gptel-file-tool-roots: %s" path))
    canonical))

(defun cc/gptel-file-list-directory (path)
  "Return a newline-separated listing of directory PATH."
  (let ((directory (cc/gptel-file--resolve path t)))
    (unless (file-directory-p directory)
      (error "Not a directory: %s" path))
    (string-join
      (mapcar
        (lambda (entry)
          (concat (file-name-nondirectory entry)
            (when (file-directory-p entry) "/")))
        (directory-files directory t directory-files-no-dot-files-regexp))
      "\n")))

(defun cc/gptel-file-read (path)
  "Return the contents of text file PATH."
  (let ((file (cc/gptel-file--resolve path t)))
    (unless (file-regular-p file)
      (error "Not a regular file: %s" path))
    (let ((size (file-attribute-size (file-attributes file))))
      (when (> size cc/gptel-file-tool-max-read-bytes)
        (error "File is too large to read (%d bytes; limit %d)"
          size cc/gptel-file-tool-max-read-bytes)))
    (with-temp-buffer
      (insert-file-contents file)
      (buffer-string))))

(defun cc/gptel-file-write (path content)
  "Write CONTENT to PATH and return a status message."
  (let ((file (cc/gptel-file--resolve path)))
    (when (file-directory-p file)
      (error "Cannot write over a directory: %s" path))
    (let ((coding-system-for-write 'utf-8-unix))
      (with-temp-buffer
        (insert content)
        (write-region (point-min) (point-max) file nil 'silent)))
    (format "Wrote %d characters to %s" (length content) file)))

(defun cc/gptel-file-replace (path old-text new-text)
  "Replace the single occurrence of OLD-TEXT with NEW-TEXT in PATH."
  (when (string-empty-p old-text)
    (error "old_text must not be empty"))
  (let ((file (cc/gptel-file--resolve path t)))
    (unless (file-regular-p file)
      (error "Not a regular file: %s" path))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (unless (search-forward old-text nil t)
        (error "old_text was not found in %s" path))
      (let ((end (point))
            (start (- (point) (length old-text))))
        (when (save-excursion (search-forward old-text nil t))
          (error "old_text occurs more than once in %s" path))
        (delete-region start end)
        (goto-char start)
        (insert new-text))
      (let ((coding-system-for-write 'utf-8-unix))
        (write-region (point-min) (point-max) file nil 'silent)))
    (format "Replaced text in %s" file)))

(after! gptel
  (let ((tools
          (list
            (gptel-make-tool
              :name "list_directory"
              :function #'cc/gptel-file-list-directory
              :description
              "List files and directories at a path inside the allowed project roots. Relative paths use the current project root."
              :args '((:name "path" :type string
                        :description "Absolute path, or path relative to the current project root"))
              :category "cc-filesystem")
            (gptel-make-tool
              :name "read_file"
              :function #'cc/gptel-file-read
              :description
              "Read a text file inside the allowed project roots. Relative paths use the current project root."
              :args '((:name "path" :type string
                        :description "Absolute path, or path relative to the current project root"))
              :category "cc-filesystem")
            (gptel-make-tool
              :name "write_file"
              :function #'cc/gptel-file-write
              :description
              "Create or overwrite a UTF-8 text file inside the allowed project roots. The parent directory must already exist."
              :args '((:name "path" :type string
                        :description "Absolute path, or path relative to the current project root")
                      (:name "content" :type string
                        :description "Complete new contents of the file"))
              :category "cc-filesystem"
              :confirm t)
            (gptel-make-tool
              :name "replace_in_file"
              :function #'cc/gptel-file-replace
              :description
              "Replace one exact, uniquely occurring text fragment in a UTF-8 file inside the allowed project roots."
              :args '((:name "path" :type string
                        :description "Absolute path, or path relative to the current project root")
                      (:name "old_text" :type string
                        :description "Exact text to replace; it must occur exactly once")
                      (:name "new_text" :type string
                        :description "Replacement text"))
              :category "cc-filesystem"
              :confirm t))))
    ;; Replace stale structs after `doom/reload' while preserving other tools.
    ;; `setopt' cannot validate gptel's `(repeat gptel-tool)' custom type in
    ;; current upstream, so this runtime-computed list must use `setq'.
    (setq gptel-tools
      (append tools
        (seq-remove
          (lambda (tool)
            (equal (gptel-tool-category tool) "cc-filesystem"))
          gptel-tools)))))
