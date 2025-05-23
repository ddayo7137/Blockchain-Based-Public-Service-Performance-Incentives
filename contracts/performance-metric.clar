;; Performance Metric Contract
;; Establishes measurement standards for public service performance

(define-data-var admin principal tx-sender)

;; Metric structure
(define-map metrics
  { metric-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 200),
    unit: (string-ascii 20),
    created-by: principal,
    active: bool
  }
)

;; Counter for metric IDs
(define-data-var metric-id-counter uint u0)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-METRIC-NOT-FOUND (err u101))
(define-constant ERR-METRIC-INACTIVE (err u102))

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

;; Set a new admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-admin) ERR-NOT-AUTHORIZED)
    (ok (var-set admin new-admin))))

;; Create a new metric
(define-public (create-metric
    (name (string-ascii 50))
    (description (string-ascii 200))
    (unit (string-ascii 20)))
  (let ((new-id (var-get metric-id-counter)))
    (begin
      (asserts! (is-admin) ERR-NOT-AUTHORIZED)
      (map-set metrics
        { metric-id: new-id }
        {
          name: name,
          description: description,
          unit: unit,
          created-by: tx-sender,
          active: true
        }
      )
      (var-set metric-id-counter (+ new-id u1))
      (ok new-id))))

;; Get metric details
(define-read-only (get-metric (metric-id uint))
  (map-get? metrics { metric-id: metric-id }))

;; Deactivate a metric
(define-public (deactivate-metric (metric-id uint))
  (let ((metric (map-get? metrics { metric-id: metric-id })))
    (begin
      (asserts! (is-admin) ERR-NOT-AUTHORIZED)
      (asserts! (is-some metric) ERR-METRIC-NOT-FOUND)
      (map-set metrics
        { metric-id: metric-id }
        (merge (unwrap-panic metric) { active: false })
      )
      (ok true))))

;; Activate a metric
(define-public (activate-metric (metric-id uint))
  (let ((metric (map-get? metrics { metric-id: metric-id })))
    (begin
      (asserts! (is-admin) ERR-NOT-AUTHORIZED)
      (asserts! (is-some metric) ERR-METRIC-NOT-FOUND)
      (map-set metrics
        { metric-id: metric-id }
        (merge (unwrap-panic metric) { active: true })
      )
      (ok true))))

;; Check if a metric is active
(define-read-only (is-metric-active (metric-id uint))
  (let ((metric (map-get? metrics { metric-id: metric-id })))
    (if (is-some metric)
      (get active (unwrap-panic metric))
      false)))
