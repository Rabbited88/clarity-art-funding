;; Art Funding Contract
;; Enables transparent funding of public art projects

(define-data-var total-funds uint u0)
(define-map projects 
    principal 
    {
        name: (string-ascii 100),
        description: (string-ascii 500),
        funding-goal: uint,
        current-funding: uint,
        completed: bool
    }
)
(define-map contributions 
    {project-owner: principal, funder: principal} 
    uint
)

;; Constants
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-UNAUTHORIZED (err u401))

;; Create new art project
(define-public (create-project (name (string-ascii 100)) (description (string-ascii 500)) (funding-goal uint))
    (let ((project-data {
        name: name,
        description: description,
        funding-goal: funding-goal,
        current-funding: u0,
        completed: false
    }))
    (if (map-insert projects tx-sender project-data)
        (ok true)
        (err ERR-ALREADY-EXISTS)))
)

;; Fund a project
(define-public (fund-project (project-owner principal) (amount uint))
    (let (
        (project (unwrap! (map-get? projects project-owner) ERR-NOT-FOUND))
        (current-contribution (default-to u0 (map-get? contributions {project-owner: project-owner, funder: tx-sender})))
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set contributions {project-owner: project-owner, funder: tx-sender} 
        (+ current-contribution amount))
    (map-set projects project-owner 
        (merge project {current-funding: (+ (get current-funding project) amount)}))
    (var-set total-funds (+ (var-get total-funds) amount))
    (ok true))
)

;; Mark project as completed
(define-public (complete-project)
    (let ((project (unwrap! (map-get? projects tx-sender) ERR-NOT-FOUND)))
    (if (>= (get current-funding project) (get funding-goal project))
        (begin
            (map-set projects tx-sender (merge project {completed: true}))
            (ok true))
        (err ERR-UNAUTHORIZED)))
)

;; Read-only functions
(define-read-only (get-project (project-owner principal))
    (ok (map-get? projects project-owner))
)

(define-read-only (get-contribution (project-owner principal) (funder principal))
    (ok (map-get? contributions {project-owner: project-owner, funder: funder}))
)

(define-read-only (get-total-funds)
    (ok (var-get total-funds))
)
