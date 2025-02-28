;; Sleep reward token
(define-fungible-token sleep-token)

;; Constants
(define-constant base-reward-amount u100)
(define-constant quality-multiplier u10)
(define-constant min-sleep-duration u28800) ;; 8 hours in blocks

;; Public functions
(define-public (reward-sleep (session-id uint))
  (let 
    ((session (unwrap! (contract-call? .sleep-tracker get-session tx-sender session-id)
                      err-not-found)))
    (if (>= (get duration session) min-sleep-duration)
      (let 
        ((quality-bonus (* (get quality-score session) quality-multiplier))
         (total-reward (+ base-reward-amount quality-bonus)))
        (ft-mint? sleep-token total-reward tx-sender)
      )
      (err u1)
    )
  )
)

;; Read only functions
(define-read-only (get-token-balance (account principal))
  (ft-get-balance sleep-token account)
)
