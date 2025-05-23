;; Agency Verification Contract
;; This contract validates government entities that can participate in the system

(define-data-var admin principal tx-sender)

;; Map to store verified agencies
(define-map verified-agencies principal bool)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-VERIFIED (err u101))
(define-constant ERR-NOT-VERIFIED (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Set a new admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))))

;; Verify an agency
(define-public (verify-agency (agency principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-none (map-get? verified-agencies agency)) ERR-ALREADY-VERIFIED)
    (map-set verified-agencies agency true)
    (ok true)))

;; Revoke agency verification
(define-public (revoke-agency (agency principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? verified-agencies agency)) ERR-NOT-VERIFIED)
    (map-delete verified-agencies agency)
    (ok true)))

;; Check if an agency is verified
(define-read-only (is-verified (agency principal))
  (default-to false (map-get? verified-agencies agency)))
