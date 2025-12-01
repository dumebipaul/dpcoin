(define-constant CONTRACT-NAME "dpcoin")
(define-constant TOKEN-SYMBOL "DPC")
(define-constant TOKEN-DECIMALS u6)

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))

(define-data-var owner principal tx-sender)
(define-data-var total-supply uint u0)

(define-map balances
  { account: principal }
  { balance: uint })

;; ======== Read-only helpers ========

(define-read-only (get-owner)
  (ok (var-get owner)))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (who principal))
  (ok (get balance (default-to { balance: u0 }
                               (map-get? balances { account: who })))))

;; ======== Internal helpers ========

(define-private (is-owner (who principal))
  (is-eq who (var-get owner)))

(define-private (assert-owner)
  (if (is-owner tx-sender)
      (ok true)
      ERR-NOT-AUTHORIZED))

(define-private (credit (who principal) (amount uint))
  (let ((current (get balance (default-to { balance: u0 }
                                          (map-get? balances { account: who })))))
    (map-set balances { account: who } { balance: (+ current amount) })
    true))

(define-private (debit (who principal) (amount uint))
  (let ((current (get balance (default-to { balance: u0 }
                                          (map-get? balances { account: who })))) )
    (if (< current amount)
        ERR-INSUFFICIENT-BALANCE
        (begin
          (map-set balances { account: who } { balance: (- current amount) })
          (ok true)))))

;; ======== Public functions ========

;; Mint new tokens to a recipient. Only the owner can mint.
(define-public (mint (recipient principal) (amount uint))
  (begin
    (try! (assert-owner))
    (if (is-eq amount u0)
        ERR-INVALID-AMOUNT
        (let ((current-supply (var-get total-supply)))
          (begin
            (credit recipient amount)
            (var-set total-supply (+ current-supply amount))
            (ok true))))))

;; Burn tokens from the caller's balance.
(define-public (burn (amount uint))
  (let ((caller tx-sender))
    (if (is-eq amount u0)
        ERR-INVALID-AMOUNT
        (let ((current-supply (var-get total-supply)))
          (begin
            (try! (debit caller amount))
            (var-set total-supply (- current-supply amount))
            (ok true))))))

;; Transfer tokens from tx-sender to recipient.
(define-public (transfer (recipient principal) (amount uint))
  (let ((sender tx-sender))
    (if (is-eq amount u0)
        ERR-INVALID-AMOUNT
        (begin
          (try! (debit sender amount))
          (credit recipient amount)
          (ok true)))))

;; Optional: allow the owner to change ownership.
(define-public (set-owner (new-owner principal))
  (begin
    (try! (assert-owner))
    (var-set owner new-owner)
    (ok true)))
