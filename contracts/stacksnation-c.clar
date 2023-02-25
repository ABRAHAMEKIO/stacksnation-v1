;; stacknsation nft marketplace-v1


 (use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

 (define-constant err-low-price (err u100))
 (define-constant err-not-owner (err u200))
 (define-constant err-transfer-failed (err u300))
 (define-constant err-failed (err u400))
 (define-constant err-unlisting-failed (err u500))
 (define-constant err-not-allowed (err u600))

(define-data-var commision uint u10000)

(define-constant contract-owner tx-sender)
(define-constant Admin (as-contract tx-sender))
(define-data-var minimum-price uint u20000)

(define-data-var listing-id uint u0)
(define-data-var purchase-count uint u0)



(define-map Collections {nft-name: principal,id: uint}
  {
   name: principal,
   artist: principal,
   description: (string-ascii 50),
   price: uint,
   commision: uint
 }
)

;;hqve to create a map that will store the price of the nft as well as the artist principal from their we can change the 


;; have to create amp that will store 
;;the amount of ids of a collection as well as 
;;set a max lenth of ids for each nft
;; (define-map collection-for-sale )

(define-public (get-listed-collections (nft-contract <nft-trait>) (id uint))
 (begin
   (ok (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))
 )
)
(define-read-only (get-purchase-count)
 (ok (var-get purchase-count))
)

;;private functions

(define-public (check-owner (nft-contract <nft-trait>) (nft-id uint))
 ;;#[allow(unchecked_data)]
  (contract-call? nft-contract get-owner nft-id)
)

(define-private (transfer-back-to-owner (nft-contract <nft-trait>) (id uint) (recipient principal))
 (begin
  (as-contract (contract-call? nft-contract transfer id Admin recipient))
 )
)

;;public functions
(define-public (transfer-item (nft-contract <nft-trait>) (id uint ) (sender principal) (recipient principal))
  (begin
  ;;#[allow(unchecked_data)]
     (ok (contract-call? nft-contract transfer id sender recipient)) 
  )
)


;;  (define-public (change-price (nft-contract <nft-trait>) (id uint))
;;    (let ((get-onsale-data (unwrap-panic (map-get? Collections {nft-name: (contract-of nft-contract),id: id})))

;;         )

;;         (if (is-eq (get artist get-onsale-data) tx-sender)
         
;;          (match (map-set Collections {nft-name: (contract-of nft-contract),id: id})
;;           success
;;            (begin (ok "")
           
;;            )
;;             err   err-failed
;;          )
;;           err-not-owner
;;         )
;;    )
;;  )
 

;;not listing id most be automated
(define-public (list-item (nft-contract <nft-trait>) (id uint) (desc (string-ascii 50)) (price uint))
 ;;#[allow(unchecked_data)]
 (let ((nft-owner (unwrap! (unwrap-panic (check-owner nft-contract id)) err-not-owner)))
   (asserts! (> price (var-get minimum-price)) err-low-price)
      (if (is-eq nft-owner tx-sender) 
          (match  (unwrap-panic (transfer-item nft-contract id nft-owner Admin))
             success
             (begin 
             (map-set Collections {nft-name: (contract-of nft-contract),id: id} {name: (contract-of nft-contract), artist: nft-owner,description: desc,price: price,commision: (var-get commision)})
               (ok 
                 {
                  type: "list-item",
                  data: (map-get? Collections {nft-name: (contract-of nft-contract),id: id}),
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
 (let ((nft-owner (unwrap-panic (map-get? Collections {nft-name: (contract-of nft),id: id}))))
   (if  (is-eq (get artist nft-owner) tx-sender) 
   
   ;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft id  tx-sender)
     success
      (begin 
        (map-delete Collections {nft-name: (contract-of nft),id: id})
        (ok 
        {
          type: "Unlist", 
          event: "succesful"
        }
        
        )
      )
     err err-transfer-failed
   )
   err-not-owner
   )
   
 )
)

;;when i mint code should keep track of amount of purchases 
(define-public (purchase-nft (nft-contract <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? Collections {nft-name: (contract-of nft-contract),id: id})))
      (price (get price get-list))
      (to-contract (get commision get-list))
      (to-owner (- price to-contract)))
      ;;#[allow(unchecked_data)]
     (match (stx-transfer? to-owner tx-sender (get artist get-list))
       start (match (stx-transfer? to-contract tx-sender contract-owner) 
        contract-successful 
          (match (transfer-back-to-owner nft-contract id tx-sender)
            success (begin 
               (map-delete Collections {nft-name: (contract-of nft-contract),id: id})
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
(define-public (admin-unlist (nft-contract <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))))
  (if (is-eq tx-sender contract-owner)
;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft-contract id (get artist get-list))
     succeeded
      (begin  
       (map-delete Collections {nft-name: (contract-of nft-contract),id: id})
         (ok 
              {
                type: "Admin-unlist",
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
