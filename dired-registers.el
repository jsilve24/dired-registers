;;; dired-registers.el --- evil like registers for dired -*- lexical-binding: t -*-

;; Author: Justin Silverman (justinsilverman@psu.edu)
;; Maintainer: Justin Silverman (justinsilverman@psu.edu)
;; Version: 0.1
;; Package-Requires: (dired)
;; Homepage: tbd
;; Keywords: dired


;; This file is not part of GNU Emacs
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; Simple package that implements evil register like behavior (e.g., evil's interface to emacs
;; marks) for dired without evil. In essence these are like temporary bookmarks that do not persist
;; across emacs sessions and therefore. Useful for quickly markikng a directory to come back to.

;; When jumping to a register location, if current buffer is a dired buffer then replaces that
;; buffer when jumping to register (to avoid making a new dired buffer, otherwise makes a new dired
;; buffer).

;;; Code:

;;;; Requirements
(require 'dired-single)


(defvar dired-registers--register-alist
  (mapcar (lambda (c) (cons c nil)) (number-sequence ?a ?z))
  "Alist of symbols and paths, the datastructure of the registers.")

(defun dired-registers-store (reg &optional path)
  "Store path to register REG (passed as a character). If PATH is not provided, then use default-directory."
  (interactive "c")
  (let ((path
	 (if path path default-directory)))
    (setf (cdr (assoc reg dired-registers--register-alist)) path)))

(defun dired-registers--dired-single-buffer (dir)
    "Same as dired-single-buffer but only replace current buffer is current buffer is a dired buffer."
    (if (string= major-mode "dired-mode")
	(dired-single-buffer dir)
      (dired dir)))

(defun dired-registers-goto (reg)
  "Dired to register stored in REG (passed as character)."
  (interactive "c")
  (let ((path (cdr (assoc reg dired-registers--register-alist))))
    (if (file-exists-p path)
        (if (file-directory-p path)
            (dired-registers--dired-single-buffer path)
          (find-file path))
      (message (format
		"No valid path stored in regiseter %c"
		reg)))))

(defun dired-registers--annotation-function (s)
  (let ((item (assoc (string-to-char s) dired-registers--register-alist)))
    (when item (concat "\t" (cdr item)))))

(defun dired-registers--filter-function (s)
  (cdr (assoc (string-to-char s) dired-registers--register-alist)))

(defun dired-registers-goto-completing-read ()
  "Select register to goto by completing-read."
  (interactive)
  (let* ((cands (mapcar
		 (lambda (s) (char-to-string (car s)))
		 dired-registers--register-alist))
	 (completion-extra-properties '(:annotation-function
					dired-registers--annotation-function))
	 (sel (completing-read "Register: " cands
			       #'dired-registers--filter-function)))
    (dired-registers-goto (string-to-char sel))))

(provide 'dired-registers)

;;; dired-registers.el ends here
