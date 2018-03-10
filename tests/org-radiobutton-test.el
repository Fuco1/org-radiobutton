;; -*- lexical-binding: t -*-

(require 'org-radiobutton)
(require 'org-radiobutton-test-helpers)

(describe "Org radiobutton"

  (describe "when org-radiobutton-mode is not active"

    (it "should not do anything special"
      (org-radiobutton-with-temp-org-file "
#+attr_org: :radio
- [X] foo
- [X] b|ar"
        (call-interactively 'org-ctrl-c-ctrl-c)
        (org-radiobutton-buffer-equals "
#+attr_org: :radio
- [X] foo
- [ ] b|ar"))))

  (describe "when org-radiobutton-mode is active"

    (describe "when the list has the :radio property"

      (it "should deselect all selected checkboxes except the one under cursor."
        (org-radiobutton-with-temp-org-file "
#+attr_org: :radio
- [X] foo
- [X] b|ar
- [X] baz"
          (org-radiobutton-mode 1)
          (call-interactively 'org-ctrl-c-ctrl-c)
          (org-radiobutton-buffer-equals "
#+attr_org: :radio
- [ ] foo
- [X] b|ar
- [ ] baz")))

      (it "should reselect selected checkbox if it is the one under the cursor"
        (org-radiobutton-with-temp-org-file "
#+attr_org: :radio
- [X] f|oo
- [ ] bar"
          (org-radiobutton-mode 1)
          (call-interactively 'org-ctrl-c-ctrl-c)
          (org-radiobutton-buffer-equals "
#+attr_org: :radio
- [X] f|oo
- [ ] bar"))))

    (describe "when the list does not have the :radio property"

      (it "should do nothing speial"
        (org-radiobutton-with-temp-org-file "
- [X] foo
- [X] b|ar
- [X] baz"
          (org-radiobutton-mode 1)
          (call-interactively 'org-ctrl-c-ctrl-c)
          (org-radiobutton-buffer-equals "
- [X] foo
- [ ] b|ar
- [X] baz"))))

    (describe "recocnizing lists"

      (it "when the point is at the bol"
        (org-radiobutton-with-temp-org-file "
#+attr_org: :radio
- [X] foo
|- [ ] bar"
          (org-radiobutton-mode 1)
          (call-interactively 'org-ctrl-c-ctrl-c)
          (org-radiobutton-buffer-equals "
#+attr_org: :radio
- [ ] foo
|- [X] bar")))

      (it "when the point is in the checkbox"
        (org-radiobutton-with-temp-org-file "
#+attr_org: :radio
- [X] foo
- [| ] bar"
          (org-radiobutton-mode 1)
          (call-interactively 'org-ctrl-c-ctrl-c)
          (org-radiobutton-buffer-equals "
#+attr_org: :radio
- [ ] foo
- |[X] bar")))

      (it "when the point is in the text"
        (org-radiobutton-with-temp-org-file "
#+attr_org: :radio
- [X] foo
- [ ] b|ar"
          (org-radiobutton-mode 1)
          (call-interactively 'org-ctrl-c-ctrl-c)
          (org-radiobutton-buffer-equals "
#+attr_org: :radio
- [ ] foo
- [X] b|ar")))

      (it "when the point is at the beginning of the list"
        (org-radiobutton-with-temp-org-file "
#+attr_org: :radio
|- [ ] foo
- [X] bar"
          (org-radiobutton-mode 1)
          (call-interactively 'org-ctrl-c-ctrl-c)
          (org-radiobutton-buffer-equals "
#+attr_org: :radio
|- [X] foo
- [ ] bar")))))

  (describe "getting radiobox values"

    (describe "if called with no name"

      (it "should select list at point"
        (org-radiobutton-with-temp-org-file "
- [X] foo
- [ ] b|ar"
          (expect (org-radiobutton-value) :to-equal "foo")))

      (it "should select nothing if point is not on a list"
        (org-radiobutton-with-temp-org-file "
- [X] foo
- [ ] bar

Some ot|her text"
          (expect (org-radiobutton-value) :to-be nil))))

    (describe "if called with name"

      (it "should select named list even if point is at another list"
        (org-radiobutton-with-temp-org-file "
#+NAME: first
- [X] foo
- [ ] b|ar

#+NAME: second
- [X] baz
- [ ] flux"
          (expect (org-radiobutton-value "second") :to-equal "baz")))

      (it "should select nothing if no list is named with such name"
        (org-radiobutton-with-temp-org-file "
#+NAME: some-silly-name
- [X] foo
- [ ] bar

Some ot|her text"
          (expect (org-radiobutton-value "not-found") :to-be nil))))))
