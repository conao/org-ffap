;;; org-src-ffap.el ---                              -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Naoya Yamashita

;; Author: Naoya Yamashita <conao@Naoya-MacBook-Air.local>
;; Keywords: org-mode

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; org-src-ffap adds ffap link to src block in org-mode.

;;; Code:

(require 'org)
(require 'org-element)

(defgroup org-ffap nil
  "Add ffap link to src block in org-mode."
  :group 'org)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; variables
;;

(defcustom org-ffap-begin-header "#+source-bgn:"
  "Begin header for org-ffap."
  :group 'org-ffap)

(defcustom org-ffap-end-header "#+source-end:"
  "End header for org-ffap."
  :group 'org-ffap)

(defvar org-ffap-data nil
  "Store point information at killing.
Org-ffap internal data.  Should not Change.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; functions
;;

(defun org-ffap-store-point (beg end &optional region)
  "Killing with store point data.
This function will run before `kill-ring-save'(BEG END &optional REGION)"
  (let ((begin-line (save-excursion
                      (goto-char beg)
                      (string-to-number (format-mode-line "%l"))))
        (end-line   (save-excursion
                      (goto-char end)
                      (string-to-number (format-mode-line "%l")))))
    (setq org-ffap-data `("store-point"
                          :file-name ,buffer-file-name
                          :begin ,beg
                          :end ,end
                          :begin-line ,begin-line
                          :end-line ,end-line))))

(defun org-ffap-yank-with-point (&optional arg)
  "Yank with point data when `org-mode' buffer.
This function will run before `yank'(&optional ARG)"
  (when (eq major-mode 'org-mode)
    (let* ((type  (org-element-at-point))
           (env   (car type))
           (plist (cadr type))
           (store (cdr org-ffap-data)))
      (when (eq env 'src-block)
        (save-excursion
          (goto-char (plist-get plist :begin))
          (insert (format "%s %s:%s\n"
                          (org-ffap-begin-header)
                          (plist-get store :file-name)
                          (plist-get store :begin-line)
                          ))
          (insert (format "%s %s:%s\n"
                          (org-ffap-end-header)
                          (plist-get store :file-name)
                          (plist-get store :end-line))))))))

(advice-add 'kill-ring-save :before 'org-ffap-store-point)
(advice-add 'yank :before 'org-ffap-yank-with-point)
(provide 'org-src-ffap)
;;; org-src-ffap.el ends here

