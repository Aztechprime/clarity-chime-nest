;; Sleep reward token
(define-fungible-token sleep-token)

;; Constants
(define-constant reward-amount u100)
(define-constant min-sleep-duration u28800) ;; 8 hours in blocks

;; Public functions
(define-public (reward-sleep (session-id uint))
  (let ((session (unwrap! (contract-call? .sleep-tracker get-session tx-sender session-id)
                          err-not-found)))
    (if (>= (get duration session) min-sleep-duration)
      (ft-mint? sleep-token reward-amount tx-sender)
      (err u1)
    )
  )
)
