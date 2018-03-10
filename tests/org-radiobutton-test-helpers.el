;; -*- lexical-binding: t -*-

(require 'shut-up)

(defmacro org-radiobutton-test-with-temp-buffer (initial initform &rest forms)
  "Setup a new buffer, then run FORMS.

First, INITFORM are run in the newly created buffer.

Then INITIAL is inserted (it is expected to evaluate to string).
If INITIAL contains | put point there as the initial
position (the character is then removed).  If it contains M, put
mark there (the character is then removed).

Finally, FORMS are run."
  (declare (indent 2)
           (debug (form form body)))
  `(save-window-excursion
     (let ((case-fold-search nil))
       (with-temp-buffer
         (set-window-buffer (selected-window) (current-buffer))
         (set-input-method nil)
         ,initform
         (insert ,initial)
         (goto-char (point-min))
         (when (search-forward "M" nil t)
           (delete-char -1)
           (set-mark (point))
           (activate-mark))
         (goto-char (point-min))
         (when (search-forward "|" nil t)
           (delete-char -1))
         ,@forms))))

(defmacro org-radiobutton-with-temp-org-file (initial &rest body)
  "Setup a temporary org file with INITIAL content then execute BODY."
  (declare (indent 1))
  `(let ((file (make-temp-file "tests")))
     (unwind-protect
         (org-radiobutton-test-with-temp-buffer ,initial
             (org-mode)
           (shut-up
             (write-region nil nil file)
             (set-visited-file-name file)
             ,@body))
       (ignore-errors (delete-file file)))))

(defun org-radiobutton-buffer-equals (result)
  "Compare buffer to RESULT.

RESULT is a string which should equal the result of
`buffer-string' called in the current buffer.

If RESULT contains |, this represents the position of `point' and
should match.

If RESULT contains M, this represents the position of `mark' and
should match."
  (expect (buffer-string) :to-equal (replace-regexp-in-string "[|M]" "" result))
  (when (string-match-p "|" result)
    (expect (1+ (string-match-p
                 "|" (replace-regexp-in-string "[M]" "" result)))
            :to-be (point)))
  (when (string-match-p "M" result)
    (expect (1+ (string-match-p
                 "M" (replace-regexp-in-string "[|]" "" result)))
            :to-be (mark))))

(provide 'org-radiobutton-test-helpers)
