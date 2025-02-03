;; Sleep tracking core contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-already-exists (err u409))

;; Data structures
(define-map sleep-sessions 
  { user: principal, session-id: uint }
  { start-time: uint, 
    end-time: uint,
    duration: uint,
    quality-score: uint }
)

(define-data-var session-counter uint u0)

;; Public functions
(define-public (start-session)
  (let ((session-id (+ (var-get session-counter) u1)))
    (map-insert sleep-sessions
      { user: tx-sender, session-id: session-id }
      { start-time: block-height,
        end-time: u0,
        duration: u0,
        quality-score: u0 }
    )
    (ok session-id)
  )
)

(define-public (end-session (session-id uint) (quality uint))
  (let ((session (unwrap! (map-get? sleep-sessions 
                  { user: tx-sender, session-id: session-id })
                  err-not-found)))
    (map-set sleep-sessions
      { user: tx-sender, session-id: session-id }
      { start-time: (get start-time session),
        end-time: block-height,
        duration: (- block-height (get start-time session)),
        quality-score: quality }
    )
    (ok true)
  )
)

;; Read only functions  
(define-read-only (get-session (user principal) (session-id uint))
  (map-get? sleep-sessions { user: user, session-id: session-id })
)
