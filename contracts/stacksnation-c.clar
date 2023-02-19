;; stacknsation nft marketplace-v1


 (use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

 (define-constant err-low-price (err u100))
 (define-constant err-not-owner (err u200))
 (define-constant err-transfer-failed (err u300))
 (define-constant err-failed (err u400))
 (define-constant err-unlisting-failed (err u500))
 (define-constant err-not-allowed (err u600))

(define-data-var commision uint u10000)

(define-constant admin tx-sender)
(define-constant contract-owner (as-contract tx-sender))
(define-data-var minimum-floor-price uint u20000)

(define-data-var listing-id uint u0)
(define-data-var purchase-count uint u0)



(define-map On-sale {nft-name: principal,id: uint}
  {
   artist: principal,
   description: (string-ascii 50),
   price: uint,
   commision: uint
 }
)

(define-public (get-listed-collections (nft-con <nft-trait>) (id uint))
 (begin
   (ok (map-get? On-sale {nft-name: (contract-of nft-con),id: id}))
 )
)
(define-read-only (get-purchase-count)
 (ok (var-get purchase-count))
)

;;private functions

(define-public (check-owner (nft-con <nft-trait>) (nft-id uint))
 ;;#[allow(unchecked_data)]
  (contract-call? nft-con get-owner nft-id)
)

(define-private (transfer-back-to-owner (nft-con <nft-trait>) (id uint) (recipient principal))
 (begin
  (as-contract (contract-call? nft-con transfer id contract-owner recipient))
 )
)


;;public functions
(define-public (transfer-item (nft-con <nft-trait>) (id uint ) (sender principal) (recipient principal))
  (begin
  ;;#[allow(unchecked_data)]
     (ok (contract-call? nft-con transfer id sender recipient)) 
  )
)


;;  (define-public (change-price (nft-con <nft-trait>) (name (string-ascii 28)) (id (string-ascii 28)) (price uint))
;;    (let ((get-onsale-data (map-get? On-sale {Id: id}))

;;         )
;;         (map-set On-sale {Id: id} {name: name,id: id,price: price})
;;    (ok "")
;;    )
;;  )


(define-public (list-item (nft-con <nft-trait>) (id uint) (name (string-ascii 28)) (desc (string-ascii 50)) (price uint))
 ;;#[allow(unchecked_data)]
 (let ((nft-owner (unwrap! (unwrap-panic (check-owner nft-con id)) err-not-owner)))
   (asserts! (> price (var-get minimum-floor-price)) err-low-price)
      (if (is-eq nft-owner tx-sender) 
          (match  (unwrap-panic (transfer-item nft-con id nft-owner contract-owner))
             success
             (begin 
             (map-set On-sale {nft-name: (contract-of nft-con),id: id} {artist: nft-owner,description: desc,price: price,commision: (var-get commision)})
               (ok 
                 {
                  type: "list-item",
                  data: (map-get? On-sale {nft-name: (contract-of nft-con),id: id}),
                  event: "successful"
                 }
               )
             )
           err err-transfer-failed
          )
        err-not-owner
     )
   
  )
)

(define-public (unlist-item (nft <nft-trait>) (id uint))
 (let ((nft-owner (unwrap-panic (map-get? On-sale {nft-name: (contract-of nft),id: id}))))
   (if  (is-eq (get artist nft-owner) tx-sender) 
   
   ;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft id  tx-sender)
     success
      (begin 
        (map-delete On-sale {nft-name: (contract-of nft),id: id})
        (ok "Unlist successful")
      )
     err err-transfer-failed
   )
   err-not-owner
   )
   
 )
)

;;when i mint code should keep track of amount of purchases 
(define-public (purchase-nft (nft-con <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? On-sale {nft-name: (contract-of nft-con),id: id})))
      (price (get price get-list))
      (to-contract (get commision get-list))
      (to-owner (- price to-contract)))
      ;;#[allow(unchecked_data)]
     (match (stx-transfer? to-owner tx-sender (get artist get-list))
       start (match (stx-transfer? to-contract tx-sender contract-owner) 
        contract-successful 
          (match (transfer-back-to-owner nft-con id tx-sender)
            success (begin 
               (map-delete On-sale {nft-name: (contract-of nft-con),id: id})
               (var-set purchase-count (+ (var-get purchase-count) u1))
              (ok 
              {
                type: "purchase-nft",
                event: "successful"
              }
              )
           )
           err3 err-not-owner
         )
         err2 err-transfer-failed
       )
      err1 err-failed
    )
  )
)

;;check if its admin
;;can transfer nft back to owner
(define-public (admin-unlist (nft-con <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? On-sale {nft-name: (contract-of nft-con),id: id}))))
  (if (is-eq tx-sender admin)
;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft-con id (get artist get-list))
     succeeded
      (begin  
       (map-delete On-sale {nft-name: (contract-of nft-con),id: id})
         (ok 
              {
                type: "Admin-unlist successful",
                event: "successful"
              }
              )
      )
    err err-failed
   ) 
   err-not-allowed
  )
 )
)