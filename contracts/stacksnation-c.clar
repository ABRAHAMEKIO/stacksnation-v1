;; stacknsation nft marketplace-v1
;; be able to list a single item and then a full collection

 (use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

 (define-constant ERR_LOW_PRICE (err u100))
 (define-constant ERR_NOT_OWNER (err u200))
 (define-constant ERR_TRANSFER_FAILED (err u300))
 (define-constant ERR_FAILED (err u400))
 (define-constant ERRR_UNLIST_FAILED (err u500))
 (define-constant ERR_NOT_ALLOWED (err u600))
 (define-constant ERR_FROZEN (err u700))
 

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

;; helper function to check if an nft is listed or is up for sale
(define-public (get-listed-collections (nft-contract <nft-trait>) (id uint))
 (ok (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))
)

;; helper function to check if an nft is listed or is up for sale
(define-public (get-nft-for-sale (nft-contract <nft-trait>) (id uint))
 (ok (map-get? nft-for-sale {nft-name: (contract-of nft-contract),id: id}))
)

;; helper function to keep track of purchases made
(define-read-only (get-purchase-nonce)
 (ok (var-get purchase-nonce))
)

;; helper function to get the list of frozen collections
(define-read-only (get-frozen (id <nft-trait>))
 (default-to 
  {event: false,id: tx-sender}
  (map-get? frozen {id: (contract-of id)}))
)


;; users can be able to check the owner of a given nft
(define-public (check-owner (nft-contract <nft-trait>) (nft-id uint))
 ;;#[allow(unchecked_data)]
  (contract-call? nft-contract get-owner nft-id)
)

;; the owner of this contract is able to change the commision
(define-public (set-commission (com uint))
;;#[allow(unchecked_data)]
 (if (is-eq tx-sender contract-owner)
    (ok (var-set commision com))
  ERR_NOT_ALLOWED
 )
)

;; if the seller or creator fails to abide to the terms
;; and policies of the marketplace his nft will be frozen by the admin
(define-public (set-frozen (nft-con <nft-trait>))
;; #[allow(unchecked_data)]
  (if (is-eq tx-sender contract-owner)
    (ok 
       (map-set frozen {id: (contract-of nft-con)} {event: true, id: (contract-of nft-con)})
    )
    ERR_NOT_ALLOWED
  )
)

;; if the selller or creator makes an appeal to the admin
;; then the contract-owner or admin will unfreeze the collection
(define-public (undo-frozen (nft-con <nft-trait>))
;;#[allow(unchecked_data)]
 (if (is-eq tx-sender contract-owner)
   (ok (map-delete frozen {id: (contract-of nft-con)}))
  ERR_NOT_ALLOWED
)
)


(define-private (transfer-back-to-owner (nft-contract <nft-trait>) (id uint) (recipient principal))
 (begin
  (as-contract (contract-call? nft-contract transfer id Admin recipient))
 )
)

;; users (creators/sellers/buyers) can be able to transfer nfts
(define-public (transfer-item (nft-contract <nft-trait>) (id uint ) (sender principal) (recipient principal))
  (begin
  ;;#[allow(unchecked_data)]
     (ok (contract-call? nft-contract transfer id sender recipient)) 
  )
)

;; creators and sellers can be able to change price of an nft they have listed up for sale
 (define-public (change-price (nft-contract <nft-trait>) (id uint) (price uint))
;;#[allow(unchecked_data)]
   (let ((get-sale (map-get? nft-for-sale {nft-name: (contract-of nft-contract),id: id}))
         (get-collection (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))
         (get-frozen1 (map-get? frozen {id: (contract-of nft-contract)}))
        )
        (asserts! (> price (var-get minimum-price)) ERR_LOW_PRICE)
        (asserts! (is-none (map-get? frozen {id: (contract-of nft-contract)})) ERR_FROZEN)
        (if (is-eq (get seller get-sale) (some tx-sender))
         (if (is-eq (some (contract-of nft-contract)) (get name get-collection))
           (begin 
             (map-set nft-for-sale {nft-name: (contract-of nft-contract),id: id} {seller: tx-sender, price: price})
            (ok 
            {
              type: "Change-price",
              data: (map-get? nft-for-sale {nft-name: (contract-of nft-contract),id: id}),
              event: "successful"
            }
           )
           )
          ERR_FAILED
         )
          ERR_NOT_OWNER
        )
   )
 )

;; have to add listing-id
;; listing id most be automated
(define-public (list-item (nft-contract <nft-trait>) (id uint) (desc (string-ascii 50)) (price uint))
 ;;#[allow(unchecked_data)]
 (let ((nft-owner (unwrap! (unwrap-panic (check-owner nft-contract id)) ERR_NOT_OWNER))
       (listing-nonce (var-get listing-id))
    )
   (asserts! (> price (var-get minimum-price)) ERR_LOW_PRICE)
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
                  data: {name: (contract-of nft-contract), description: desc, commision: (var-get commision), price: price},
                  event: "successful",
                  nonce: (var-set listing-id (+ listing-nonce u1))
                 }
               )
             )
           err ERR_TRANSFER_FAILED
          )
        ERR_NOT_OWNER
     )
     
  )
)

;; creator or seller can be able to unlist their nft
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
     err ERR_TRANSFER_FAILED
   )
   ERR_NOT_OWNER
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
    (asserts! (not (is-eq (contract-of nft-con) (get id check-frozen))) ERR_FROZEN)
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
           err3 ERR_NOT_OWNER
         )
         err2 ERR_TRANSFER_FAILED
       )
      err1 ERR_FAILED
    )
      ERR_NOT_ALLOWED
    )
  )
)

;; admin can unlist the nft if the creator does not follow the rules and regulations
(define-public (admin-unlist (nft-contract <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? Collections {nft-name: (contract-of nft-contract),id: id}))))
  (asserts! (is-eq (contract-of nft-contract) (get name get-list)) ERRR_UNLIST_FAILED)
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
    err ERR_FAILED
   ) 
   ERR_NOT_ALLOWED
  )
 )
)