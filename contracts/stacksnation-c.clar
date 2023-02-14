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


(define-map On-sale {Id: (string-ascii 28)}
  {
   name: (string-ascii 28),
   artist: principal,
   descrption: (string-ascii 50),
   price: uint,
   commision: uint
 }
)

;;Get-purchase-count
;;get the amount of time a user has purchased an nft from that collection
(define-read-only (get-purchase-count)
 (ok (var-get purchase-count))
)

(define-public (change-price (nft-con <nft-trait>) (name (string-ascii 28)) (id (string-ascii 28)) (price uint))
  (let ((get-onsale-data (map-get? On-sale {Id: id}))

       )
  (ok "")
  )
)

;;Transfer-back-to-owner
;;smart contract can be able to transfer nft back to the owners
(define-private (transfer-back-to-owner (nft-con <nft-trait>) (id uint) (recipient principal))
 (begin
  (as-contract (contract-call? nft-con transfer id contract-owner recipient))
 )
)


;;Get-listed-collections
;;users can get a the list of listed collections
(define-public (get-listed-collections (nft-con <nft-trait>) (id (string-ascii 28)))
 (begin
   (ok (map-get? On-sale {Id: id}))
 )
)

;;Transfer item
;;users can be able to transfer nfts (items) to a given recipient
(define-public (transfer-item (nft-con <nft-trait>) (id uint ) (sender principal) (recipient principal))
  (begin
  ;;#[allow(unchecked_data)]
     (ok (contract-call? nft-con transfer id sender recipient)) 
  )
)

;;Check nft-owner
;;users can be able to check the owner of an nft (item)
(define-public (check-owner (nft-con <nft-trait>) (nft-id uint))
 ;;#[allow(unchecked_data)]
  (contract-call? nft-con get-owner nft-id)
)

;;List nft
;;users can be able to list their nfts (item)
(define-public (list-item (nft-con <nft-trait>) (id (string-ascii 28)) (name (string-ascii 28)) (desc (string-ascii 50)) (price uint) (item-id uint))
 ;;#[allow(unchecked_data)]
 (let ((nft-owner (unwrap! (unwrap-panic (check-owner nft-con item-id)) err-not-owner)))
   (asserts! (> price (var-get minimum-floor-price)) err-low-price)
      (if (is-eq nft-owner tx-sender) 
          (match  (unwrap-panic (transfer-item nft-con item-id nft-owner contract-owner))
             success
             (begin 
              (map-set On-sale {Id: id} 
                 {name: name, artist: (contract-of nft-con),descrption: desc,price: price,commision: (var-get commision)})
               (print {
                  event: "list-item",
                  data: (map-get? On-sale {Id: id})}
               )
               (ok "list successful")
             )
           err err-transfer-failed
          )
        err-not-owner
     )
   
  )
)
;;Unlist-item
;;users can be able to unlist their nfts(items)
(define-public (unlist-item (nft <nft-trait>) (id (string-ascii 28)) (item-id uint))
 (let ((nft-owner (unwrap-panic (map-get? On-sale {Id: id}))))
   (asserts! (is-eq (get artist nft-owner) tx-sender) err-not-owner)
   ;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft item-id  tx-sender)
     success
      (begin 
        (print 
          {
           event: "unlist-item",
           data: (map-delete On-sale {Id: id})
          }
        )
        (ok "unlist successful")
      )
     err err-unlisting-failed
   )
 )
)

;;Purchase-nft
;;when i mint code should keep track of amount of purchases 
(define-public (purchase-nft (nft-con <nft-trait>) (id (string-ascii 28)) (item-id uint))
 (let ((get-list (unwrap-panic (map-get? On-sale {Id: id})))
      (price (get price get-list))
      (to-contract (get commision get-list))
      (to-owner (- price to-contract)))
      ;;#[allow(unchecked_data)]
     (match (stx-transfer? to-owner tx-sender (get artist get-list))
       haha (match (stx-transfer? to-contract tx-sender contract-owner) 
        contract-successful 
          (match (transfer-back-to-owner nft-con item-id tx-sender)
            success (begin 
               (map-delete On-sale {Id: id})
               (var-set purchase-count (+ (var-get purchase-count) u1))
              (ok "Purchase successful")
           )
           err3 err-not-owner
         )
         err2 err-transfer-failed
       )
      err1 err-failed
    )
  )
)

;;Admin unlist
;;the assigned admin can forcefully unlist the collect due to some complecations
(define-public (admin-unlist (nft-con <nft-trait>) (id (string-ascii 28)) (item-id uint))
 (let ((get-list (unwrap-panic (map-get? On-sale {Id: id}))))
   (asserts! (is-eq id (get name get-list)) err-unlisting-failed)
  (if (is-eq tx-sender admin)
;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft-con item-id (get artist get-list))
     succeeded
      (begin  
       (map-delete On-sale {Id: id})
        (ok "Admin-unlist successful")
      )
    failed err-unlisting-failed
   ) 
   err-not-allowed
  )
 )
)