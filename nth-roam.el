;;; nth-roam.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 Raj Patil
;;
;; Author: Raj Patil <rajp152k@gmail.com>
;; Maintainer: Raj Patil <rajp152k@gmail.com>
;; Created: April 02, 2025
;; Modified: April 02, 2025
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/rp152k/nth-roam
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'org-roam)

(defvar nth-roam--vaults (list))
(defvar nth-roam-current-vault "")
(defvar nth-roam-default-vault "")

(defun nth-roam-register-vault (tag vault-dir)
  (setq nth-roam--vaults (cons (cons tag
                                     (file-truename vault-dir))
                               nth-roam--vaults))
  (message (format "registered roam vault : %s" tag)))

(defun nth-roam-default-vault-register (tag vault-dir)
  (setq nth-roam-default-vault tag)
  (nth-roam-register-vault tag vault-dir))

(defun nth-roam-delete-vault ()
  (interactive)
  (let ((deletion-candidate (completing-read "nth roam vault delete: " nth-roam--vaults)))
    (setq nth-roam--vaults (cl-remove-if (lambda (ele)
                                           (equal (car ele)
                                                  deletion-candidate))
                                         nth-roam--vaults))
    (delete-file (locate-user-emacs-file "nth-roam-%s.db" deletion-candidate))
    (message (format "deleted roam vault : %s" deletion-candidate))))

(defun nth-roam-select-db ()
  (setq org-roam-db-location
        (locate-user-emacs-file (format "nth-roam-%s.db" nth-roam-current-vault)))
  (unless (file-exists-p org-roam-db-location)
    (org-roam-db-sync)))

(defun nth-roam-init (init-vault-tag)
  (setq nth-roam-current-vault init-vault-tag)
  (nth-roam-select-db))

(defun nth-roam-init-default-fallback ()
  (org-roam-db--close-all)
  (setq nth-roam-current-vault nth-roam-default-vault)
  (setq org-roam-directory (cdr (assoc nth-roam-current-vault nth-roam--vaults)))
  (nth-roam-select-db)
  (org-roam-db-sync))

(defun nth-roam-doctor ()
  "check for state inconsitencies, and init default fallback when needed"
  (interactive)
  (if (and  (equal (cdr (assoc nth-roam-current-vault nth-roam--vaults))
                   org-roam-directory)
            (equal (locate-user-emacs-file (format "nth-roam-%s.db" nth-roam-current-vault))
                   org-roam-db-location)
            (file-exists-p org-roam-db-location))
      (message "nth-roam state consistent, all good")
    (progn
      (message "nth-roam state inconsistent, initiating fallback vault")
      (nth-roam-init-default-fallback))))


(defun nth-roam-yield-current-vault ()
  (interactive)
  (message (format "current roam vault: %s" nth-roam-current-vault)))


(defun nth-roam-select-vault ()
  (interactive)
  (let ((vault (completing-read "nth-roam-vault: " nth-roam--vaults)))
    (message (format "pre switch vault sync init"))
    (org-roam-db-sync)
    (org-roam-db--close)
    (message (format "context switching to roam vault: %s" vault))
    (setq nth-roam-current-vault vault)
    (setq org-roam-directory (cdr (assoc nth-roam-current-vault nth-roam--vaults)))
    (nth-roam-select-db)
    (message (format "conn init with %s roam db" nth-roam-current-vault))
    (org-roam-db--get-connection)
    (message "vault alter succeeded")))

(provide 'nth-roam)
;;; nth-roam.el ends here
