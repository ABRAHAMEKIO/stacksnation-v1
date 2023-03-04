;; stacknsation nft marketplace-v1
;; be able to list a single item and then a full collection

 (use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

 (define-constant err-low-price (err u100))
 (define-constant err-not-owner (err u200))
 (define-constant err-transfer-failed (err u300))
 (define-constant err-failed (err u400))
 (define-constant err-unlisting-failed (err u500))
 (define-constant err-not-allowed (err u600))
 (define-constant err-frozen (err u700))
 

(define-data-var commision uint u250)

(define-constant contract-owner tx-sender)
(define-constant Admin (as-contract tx-sender))
(define-data-var minimum-price uint u20000)

(define-data-var listing-id uint u0)
(define-data-var purchase-nonce uint u0)


(define-map nft-for-sale {nft-name: principal, id: uint} {seller: principal, price: uint})


(define-map frozen {id: principal} {event: bool, id: principal})

(define-map Collections {nft-name: principal,id: uint}
  {
   name: principal,
   artist: principal,
   description: (string-ascii 50),
   commision: uint
 }
)

;;have to create a map that will store the price of the nft as well as the artist principal from their we can change the 


;; have to create amp that will store 
;;the amount of ids of a collection as well as 
;;set a max lenth of ids for each nft
;; (define-map collection-for-sale )

(define-public (get-listed-collections (nft-contract <nft-trait>) (id uint))
 (ok (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))
)

(define-public (get-nft-for-sale (nft-contract <nft-trait>) (id uint))
 (ok (map-get? nft-for-sale {nft-name: (contract-of nft-contract),id: id}))
)

(define-read-only (get-purchase-nonce)
 (ok (var-get purchase-nonce))
)

(define-read-only (get-frozen (id <nft-trait>))
 (default-to 
  {event: false,id: tx-sender}
  (map-get? frozen {id: (contract-of id)}))
)

;;private functions

(define-public (check-owner (nft-contract <nft-trait>) (nft-id uint))
 ;;#[allow(unchecked_data)]
  (contract-call? nft-contract get-owner nft-id)
)

(define-public (set-commission (com uint))
;;#[allow(unchecked_data)]
 (if (is-eq tx-sender contract-owner)
    (ok (var-set commision com))
  err-not-allowed
 )
)
;; if the seller or creator fails to abide to the terms and policies of the marketplace his nft will be frozen by the admin
(define-public (set-frozen (nft-con <nft-trait>))
;; #[allow(unchecked_data)]
  (if (is-eq tx-sender contract-owner)
    (ok 
  (map-set frozen {id: (contract-of nft-con)} {event: true, id: (contract-of nft-con)})
  )
  err-not-allowed
  )
)
;; if the creator makes an appeal then the admin will unfreeze the colllection
(define-public (undo-frozen (nft-con <nft-trait>))
;;#[allow(unchecked_data)]
 (if (is-eq tx-sender contract-owner)
  (ok (map-delete frozen {id: (contract-of nft-con)}))
  err-not-allowed
)
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

;; have to add frozen code here
 (define-public (change-price (nft-contract <nft-trait>) (id uint) (price uint))
;;#[allow(unchecked_data)]
   (let ((get-sale (map-get? nft-for-sale {nft-name: (contract-of nft-contract),id: id}))
        (get-collection (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))
        )
        (asserts! (> price (var-get minimum-price)) err-low-price)
        (if (is-eq (get seller get-sale) (some tx-sender))
         (if (is-eq (some (contract-of nft-contract)) (get name get-collection))
           (begin 
             (map-set nft-for-sale {nft-name: (contract-of nft-contract),id: id} {seller: tx-sender, price: price})
            (ok {
                  type: "list-item",
                  data: (map-get? nft-for-sale {nft-name: (contract-of nft-contract),id: id}),
                  event: "successful"
                   }
           )
           )
          err-failed
         )
          err-not-owner
        )
   )
 )

;; have to add listing-id
;; listing id most be automated
(define-public (list-item (nft-contract <nft-trait>) (id uint) (desc (string-ascii 50)) (price uint))
 ;;#[allow(unchecked_data)]
 (let ((nft-owner (unwrap! (unwrap-panic (check-owner nft-contract id)) err-not-owner)))
   (asserts! (> price (var-get minimum-price)) err-low-price)
      (if (is-eq nft-owner tx-sender) 
          (match  (unwrap-panic (transfer-item nft-contract id nft-owner Admin))
             success
             (begin 
             (map-set Collections {nft-name: (contract-of nft-contract),id: id} {name: (contract-of nft-contract), artist: nft-owner,description: desc,commision: (var-get commision)})
             (map-set nft-for-sale {nft-name: (contract-of nft-contract),id: id} 
                {seller: nft-owner, price: price}
             )
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
 (let ((nft-owner (unwrap-panic (map-get? Collections {nft-name: (contract-of nft),id: id})))
 )
   (if  (is-eq (get artist nft-owner) tx-sender) 
   ;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft id  tx-sender)
     success
      (begin 
        (map-delete Collections {nft-name: (contract-of nft),id: id})
        (ok 
        {
          type: "Unlist", 
          event: "succesful",
          data: (undo-frozen nft)
        }
        )
      )
     err err-transfer-failed
   )
   err-not-owner
   )
   
 )
)
;; the commision is dynamic, the price determines the commision
;;when i mint code should keep track of amount of purchases 
;; if nft is frozen the buyer cannot purchase the nft
(define-public (purchase-item (nft-con <nft-trait>) (id uint))
;;#[allow(unchecked_data)]
 (let ((get-list (unwrap-panic (map-get? Collections {nft-name: (contract-of nft-con),id: id})))
      (get-sale (unwrap-panic (map-get? nft-for-sale {nft-name: (contract-of nft-con),id: id})))
      (check-frozen (unwrap-panic (map-get? frozen {id: (contract-of nft-con)})))
      (price (get price get-sale))
      (to-contract (/ (* (var-get commision) price) u10000))
      (to-owner (- price to-contract))
      
      )
    (asserts! (not (is-eq (contract-of nft-con) (get id check-frozen))) err-frozen)
     (if (not (is-eq (get artist get-list) tx-sender))
      (match (stx-transfer? to-owner tx-sender (get artist get-list))
       start (match (stx-transfer? to-contract tx-sender Admin) 
        contract-successful 
          (match (transfer-back-to-owner nft-con id tx-sender)
            success (begin 
               (map-delete Collections {nft-name: (contract-of nft-con),id: id})
               (var-set purchase-nonce (+ (var-get purchase-nonce) u1))
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
      err-not-allowed
    )
  )
)

;;check if its admin
;;can transfer nft back to owner 
(define-public (admin-unlist (nft-contract <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))))
  (asserts! (is-eq (contract-of nft-contract) (get name get-list)) err-unlisting-failed)
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