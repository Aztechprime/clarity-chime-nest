;; Sleep tracking core contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-already-exists (err u409))
(define-constant err-invalid-quality (err u400))
(define-constant err-unauthorized (err u401))
(define-constant err-active-session-exists (err u402))
(define-constant err-max-duration-exceeded (err u403))

;; Quality score bounds
(define-constant min-quality u1)
(define-constant max-quality u10)
(define-constant max-session-duration u172800) ;; 48 hours in blocks

;; Data structures
(define-map sleep-sessions 
  { user: principal, session-id: uint }
  { start-time: uint, 
    end-time: uint,
    duration: uint,
    quality-score: uint,
    status: (string-ascii 20) }
)

(define-data-var session-counter uint u0)

;; Events
(define-data-var last-event-id uint u0)

(define-map events 
  { id: uint }
  { event-type: (string-ascii 20), 
    user: principal,
    session-id: uint }
)

;; Private functions
(define-private (is-valid-quality (quality uint))
  (and (>= quality min-quality) (<= quality max-quality))
)

(define-private (has-active-session (user principal))
  (let ((current-counter (var-get session-counter)))
    (some (map-get? sleep-sessions 
      { user: user, session-id: current-counter }))
  )
)

(define-private (emit-event (event-type (string-ascii 20)) (user principal) (session-id uint))
  (let ((event-id (+ (var-get last-event-id) u1)))
    (var-set last-event-id event-id)
    (map-set events
      { id: event-id }
      { event-type: event-type,
        user: user,
        session-id: session-id }
    )
    (ok event-id)
  )
)

;; Public functions
(define-public (start-session)
  (let 
    (
      (current-counter (var-get session-counter))
      (new-session-id (+ current-counter u1))
    )
    (asserts! (is-none (has-active-session tx-sender)) err-active-session-exists)
    (var-set session-counter new-session-id)
    (map-insert sleep-sessions
      { user: tx-sender, session-id: new-session-id }
      { start-time: block-height,
        end-time: u0,
        duration: u0,
        quality-score: u0,
        status: "active" }
    )
    (emit-event "session_start" tx-sender new-session-id)
    (ok new-session-id)
  )
)

(define-public (end-session (session-id uint) (quality uint))
  (let 
    ((session (unwrap! (map-get? sleep-sessions 
              { user: tx-sender, session-id: session-id })
              err-not-found))
     (current-duration (- block-height (get start-time session))))
    (asserts! (is-valid-quality quality) err-invalid-quality)
    (asserts! (<= current-duration max-session-duration) err-max-duration-exceeded)
    (map-set sleep-sessions
      { user: tx-sender, session-id: session-id }
      { start-time: (get start-time session),
        end-time: block-height,
        duration: current-duration,
        quality-score: quality,
        status: "completed" }
    )
    (emit-event "session_end" tx-sender session-id)
    (ok true)
  )
)

;; Read only functions  
(define-read-only (get-session (user principal) (session-id uint))
  (map-get? sleep-sessions { user: user, session-id: session-id })
)

(define-read-only (get-current-counter)
  (ok (var-get session-counter))
)
