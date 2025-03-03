;; Sleep reward token
(define-fungible-token sleep-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))
(define-constant err-insufficient-sleep (err u405))

(define-constant base-reward-amount u100)
(define-constant quality-multiplier u10)
(define-constant min-sleep-duration u28800) ;; 8 hours in blocks
(define-constant max-reward-amount u1000)

;; Public functions
(define-public (reward-sleep (session-id uint))
  (let 
    ((session (unwrap! (contract-call? .sleep-tracker get-session tx-sender session-id)
                    err-not-found)))
    (if (>= (get duration session) min-sleep-duration)
      (let 
        ((quality-bonus (* (get quality-score session) quality-multiplier))
         (total-reward (min (+ base-reward-amount quality-bonus) max-reward-amount)))
        (ft-mint? sleep-token total-reward tx-sender)
      )
      (err err-insufficient-sleep)
    )
  )
)

;; Read only functions
(define-read-only (get-token-balance (account principal))
  (ft-get-balance sleep-token account)
)
