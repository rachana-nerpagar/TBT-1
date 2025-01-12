;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                     ;;;
;;;                     Carnegie Mellon University                      ;;;
;;;                  and Alan W Black and Kevin Lenzo                   ;;;
;;;                      Copyright (c) 1998-2000                        ;;;
;;;                        All Rights Reserved.                         ;;;
;;;                                                                     ;;;
;;; Permission is hereby granted, free of charge, to use and distribute ;;;
;;; this software and its documentation without restriction, including  ;;;
;;; without limitation the rights to use, copy, modify, merge, publish, ;;;
;;; distribute, sublicense, and/or sell copies of this work, and to     ;;;
;;; permit persons to whom this work is furnished to do so, subject to  ;;;
;;; the following conditions:                                           ;;;
;;;  1. The code must retain the above copyright notice, this list of   ;;;
;;;     conditions and the following disclaimer.                        ;;;
;;;  2. Any modifications must be clearly marked as such.               ;;;
;;;  3. Original authors' names are not deleted.                        ;;;
;;;  4. The authors' names are not used to endorse or promote products  ;;;
;;;     derived from this software without specific prior written       ;;;
;;;     permission.                                                     ;;;
;;;                                                                     ;;;
;;; CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK        ;;;
;;; DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING     ;;;
;;; ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT  ;;;
;;; SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE     ;;;
;;; FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES   ;;;
;;; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN  ;;;
;;; AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,         ;;;
;;; ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF      ;;;
;;; THIS SOFTWARE.                                                      ;;;
;;;                                                                     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Lexicon, LTS and Postlexical rules for iitm_bodo
;;;

;;; Load any necessary files here

(define (iitm_bodo_addenda)
  "(iitm_bodo_addenda)
Basic lexicon should (must ?) have basic letters, symbols and punctuation."

;;; Pronunciation of letters in the alphabet
;(lex.add.entry '("a" nn (((a) 0))))
;(lex.add.entry '("b" nn (((b e) 0))))
;(lex.add.entry '("c" nn (((th e) 0))))
;(lex.add.entry '("d" nn (((d e) 0))))
;(lex.add.entry '("e" nn (((e) 0))))
; ...

;;; Symbols ...
;(lex.add.entry 
; '("*" n (((a s) 0) ((t e) 0) ((r i1 s) 1)  ((k o) 0))))
;(lex.add.entry 
; '("%" n (((p o r) 0) ((th i e1 n) 1) ((t o) 0))))

;; Basic punctuation must be in with nil pronunciation
(lex.add.entry '("." punc nil))
;(lex.add.entry '("." nn (((p u1 n) 1) ((t o) 0))))
(lex.add.entry '("'" punc nil))
(lex.add.entry '(":" punc nil))
(lex.add.entry '(";" punc nil))
(lex.add.entry '("," punc nil))
;(lex.add.entry '("," nn (((k o1) 1) ((m a) 0))))
(lex.add.entry '("-" punc nil))
(lex.add.entry '("\"" punc nil))
(lex.add.entry '("`" punc nil))
(lex.add.entry '("?" punc nil))
(lex.add.entry '("!" punc nil))
(lex.add.entry '("*" nil (((sp) 0))))
)

(require 'lts)

;;;  Function called when word not found in lexicon
;;;  and you've trained letter to sound rules
(define (iitm_bodo_lts_function word features)
  "(iitm_bodo_lts_function WORD FEATURES)
Return pronunciation of word not in lexicon."
  (if (not boundp 'iitm_bodo_lts_rules)
      (require 'iitm_bodo_lts_rules))
  (let ((dword (downcase word)) (phones) (syls))
    (set! phones (lts_predict dword iitm_bodo_lts_rules))
    (set! syls (iitm_bodo_lex_syllabify_phstress phones))
    (list word features syls)))

;; utf8 letter based one
;(define (iitm_bodo_lts_function word features)
;  "(iitm_bodo_lts_function WORD FEATURES)
;Return pronunciation of word not in lexicon."
;  (let ((dword word) (phones) (syls))
;    (set! phones (utf8explode dword))
;    (set! syls (iitm_bodo_lex_syllabify_phstress phones))
;    (list word features syls)))

(define (iitm_bodo_is_vowel x)
  (string-equal "+" (phone_feature x "vc")))

(define (iitm_bodo_contains_vowel l)
  (member_string
   t
   (mapcar (lambda (x) (iitm_bodo_is_vowel x)) l)))

(define (iitm_bodo_lex_sylbreak currentsyl remainder)
  "(iitm_bodo_lex_sylbreak currentsyl remainder)
t if this is a syl break, nil otherwise."
  (cond
   ((not (iitm_bodo_contains_vowel remainder))
    nil)
   ((not (iitm_bodo_contains_vowel currentsyl))
    nil)
   (t
    ;; overly naive, I mean wrong
    t))
)

(define (iitm_bodo_lex_syllabify_phstress phones)
 (let ((syl nil) (syls nil) (p phones) (stress 0))
    (while p
     (set! syl nil)
     (set! stress 0)
     (while (and p (not (iitm_bodo_lex_sylbreak syl p)))
       (if (string-matches (car p) "xxxx")
           (begin
             ;; whatever you do to identify stress
             (set! stress 1)
             (set syl (cons (car p-stress) syl)))
           (set! syl (cons (car p) syl)))
       (set! p (cdr p)))
     (set! syls (cons (list (reverse syl) stress) syls)))
    (reverse syls)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; OR: Hand written letter to sound rules
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ;;;  Function called when word not found in lexicon

(define (iitm_bodo_lts_function word features)
   "(iitm_bodo_lts_function WORD FEATURES)
 Return pronunciation of word not in lexicon."
(cond
((string-equal "" word )())
(t
;;(print "called")
(set! myfilepointer (fopen ( path-append iitm_bodo_female::dir "parser.sh") "w"))

;(set! myfilepointer1 (fopen ( path-append iitm_bodo_female::dir "input.txt") "w"))
;(format myfilepointer1 "%s" word)
;(fclose myfilepointer1)
;(format myfilepointer "perl %s %s" (path-append iitm_bodo_female::dir "monophone2common.pl") "input.txt")
(format myfilepointer "./%s %s" (path-append iitm_bodo_female::dir "bin/monophone_parser") word)
;    (format myfilepointer "perl %s %s %s" (path-append iitm_bodo_female::dir "bin/il_parser_utf8-bodo.pl") word iitm_bodo_female::dir)
    (fclose myfilepointer)

(system (string-append "chmod +x " ( path-append iitm_bodo_female::dir "parser.sh")))
  (system ( path-append iitm_bodo_female::dir "parser.sh"))
  (load (path-append iitm_bodo_female::dir "wordpronunciation"))
  (list word nil wordstruct)
)

))
; (define (iitm_bodo_lts_function word features)
;   "(iitm_bodo_lts_function WORD FEATURES)
; Return pronunciation of word not in lexicon."
;   (format stderr "failed to find pronunciation for %s\n" word)
;   (let ((dword (downcase word)))
;     ;; Note you may need to use a letter to sound rule set to do
;     ;; casing if the language has non-ascii characters in it.
;     (if (lts.in.alphabet word 'iitm_bodo)
; 	(list
; 	 word
; 	 features
; 	 ;; This syllabification is almost certainly wrong for
; 	 ;; this language (its not even very good for English)
; 	 ;; but it will give you something to start off with
; 	 (lex.syllabify.phstress
; 	   (lts.apply word 'iitm_bodo)))
; 	(begin
; 	  (format stderr "unpronouncable word %s\n" word)
; 	  ;; Put in a word that means "unknown" with its pronunciation
; 	  '("nepoznat" nil (((N EH P) 0) ((AO Z) 0) ((N AA T) 0))))))
; )

; ;; You may or may not be able to write a letter to sound rule set for
; ;; your language.  If its largely lexicon based learning a rule
; ;; set will be better and easier that writing one (probably).
; (lts.ruleset
;  iitm_bodo
;  (  (Vowel WHATEVER) )
;  (
;   ;; LTS rules 
;   ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Postlexical Rules 
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (iitm_bodo::postlex_rule1 utt)
  "(iitm_bodo::postlex_rule1 utt)
A postlexical rule form correcting phenomena over word boundaries."
  (mapcar
   (lambda (s)
     ;; do something
     )
   (utt.relation.items utt 'Segment))
   utt)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Lexicon definition
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(lex.create "iitm_bodo")
(lex.set.phoneset "iitm_bodo")
(lex.set.lts.method 'iitm_bodo_lts_function)
(if (probe_file (path-append iitm_bodo_female::dir "festvox/iitm_bodo_lex.out"))
    (lex.set.compile.file (path-append iitm_bodo_female::dir 
                                       "festvox/iitm_bodo_lex.out")))
(iitm_bodo_addenda)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Lexicon setup
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (iitm_bodo_female::select_lexicon)
  "(iitm_bodo_female::select_lexicon)
Set up the lexicon for iitm_bodo."
  (lex.select "iitm_bodo")

  ;; Post lexical rules
  (set! postlex_rules_hooks (list iitm_bodo::postlex_rule1))
)

(define (iitm_bodo_female::reset_lexicon)
  "(iitm_bodo_female::reset_lexicon)
Reset lexicon information."
  t
)

(provide 'iitm_bodo_female_lexicon)
