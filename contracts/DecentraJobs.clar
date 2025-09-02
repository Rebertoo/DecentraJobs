;; -------------------------------
;; Job Board Smart Contract
;; -------------------------------

(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_JOB_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_APPLIED (err u102))
(define-constant ERR_ALREADY_COMPLETED (err u103))
(define-constant ERR_NOT_APPLIED (err u104))

;; -------------------------------
;; Data storage
;; -------------------------------
(define-data-var job-counter uint u0)

(define-map jobs
  {id: uint}
  {
    employer: principal,
    title: (string-ascii 100),
    reward: uint,
    taken: bool,
    worker: (optional principal),
    completed: bool
  }
)

(define-map applications
  {job-id: uint, applicant: principal}
  {applied: bool}
)

;; -------------------------------
;; Read-only helpers
;; -------------------------------
(define-read-only (get-job (job-id uint))
  (map-get? jobs {id: job-id})
)

(define-read-only (get-application (job-id uint) (applicant principal))
  (map-get? applications {job-id: job-id, applicant: applicant})
)

;; -------------------------------
;; Post a job
;; -------------------------------
(define-public (post-job (title (string-ascii 100)) (reward uint))
  (begin
    (var-set job-counter (+ (var-get job-counter) u1))
    (let ((job-id (var-get job-counter)))
      (map-set jobs {id: job-id}
        {
          employer: tx-sender,
          title: title,
          reward: reward,
          taken: false,
          worker: none,
          completed: false
        })
      (ok job-id)
    )
  )
)

;; -------------------------------
;; Apply for a job
;; -------------------------------
(define-public (apply-job (job-id uint))
  (match (map-get? jobs {id: job-id})
    job
    (if (is-some (map-get? applications {job-id: job-id, applicant: tx-sender}))
      ERR_ALREADY_APPLIED
      (begin
        (map-set applications {job-id: job-id, applicant: tx-sender} {applied: true})
        (ok true)
      )
    )
    ERR_JOB_NOT_FOUND
  )
)

;; -------------------------------
;; Employer accepts a worker
;; -------------------------------
(define-public (accept-worker (job-id uint) (worker principal))
  (match (map-get? jobs {id: job-id})
    job
    (if (is-eq (get employer job) tx-sender)
      (begin
        (map-set jobs {id: job-id}
          {
            employer: (get employer job),
            title: (get title job),
            reward: (get reward job),
            taken: true,
            worker: (some worker),
            completed: false
          })
        (ok true)
      )
      ERR_NOT_AUTHORIZED
    )
    ERR_JOB_NOT_FOUND
  )
)

;; -------------------------------
;; Employer marks job completed & pays worker
;; -------------------------------
(define-public (complete-job (job-id uint))
  (match (map-get? jobs {id: job-id})
    job
    (if (and (is-eq (get employer job) tx-sender) (not (get completed job)))
      (match (get worker job)
        some-worker
        (begin
          (map-set jobs {id: job-id}
            {
              employer: (get employer job),
              title: (get title job),
              reward: (get reward job),
              taken: true,
              worker: (some some-worker),
              completed: true
            })
          (stx-transfer? (get reward job) tx-sender some-worker)
        )
        ERR_NOT_APPLIED
      )
      ERR_NOT_AUTHORIZED
    )
    ERR_JOB_NOT_FOUND
  )
)
