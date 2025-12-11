;; -*- no-byte-compile: t; -*-
;;; cc-langs/python/packages.el

(disable-packages!
 anaconda-mode
 conda
 pipenv
 pip-requirements
 pyenv
 ;; pyvenv
 pyimport
 py-isort)

(package! sphinx-doc)
;; (package! pet
;;   :recipe (:host github :repo "wyuenho/emacs-pet" :files ("*.el")))
