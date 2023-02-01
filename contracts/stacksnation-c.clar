;; stacknsation nft marketplace-v1

;;features
;;list nfts
;;unlist nft 
;;purhase nft 
;;transfer nft

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant err-low-price (err u100))
(define-constant err-not-owner (err u200))
(define-constant err-transfer-failed (err u300))
(define-constant err-failed (err u400))
(define-constant err-not-allowed (err u600))


(define-data-var commision uint u10000)

(define-constant admin tx-sender)
(define-constant contract-owner (as-contract tx-sender))
(define-data-var minimum-floor-price uint u20000)

(define-data-var listing-id uint u0)
(define-data-var purchase-count uint u0)


(define-map listed-collections {nft-name: principal,id: uint}
  {
   artist: principal,
   descrption: (string-ascii 50),
   price: uint,
   floor-price: uint,
   amount: uint,
   commision: uint
 }
)

;;
(define-read-only (get-purchase-count)
 (ok (var-get purchase-count))
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
(define-public (get-listed-collections (nft-con <nft-trait>) (id uint))
 (begin
   (ok (map-get? listed-collections {nft-name: (contract-of nft-con),id: id}))
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
(define-public (list-item (nft-con <nft-trait>) (id uint) (name (string-ascii 28)) (desc (string-ascii 50)) (price uint) (floor-price uint) (amount uint))
 ;;#[allow(unchecked_data)]
 (let ((nft-owner (unwrap! (unwrap-panic (check-owner nft-con id)) err-not-owner)))
   (asserts! (> price (var-get minimum-floor-price)) err-low-price)
      (if (is-eq nft-owner tx-sender) 
          (match  (unwrap-panic (transfer-item nft-con id nft-owner contract-owner))
             success
             (begin (map-set listed-collections {nft-name: (contract-of nft-con),id: id} 
                 {artist: nft-owner,descrption: desc,price: price,floor-price: floor-price,amount: amount,commision: (var-get commision)})
               (print (map-get? listed-collections {nft-name: (contract-of nft-con),id: id}))
               (ok "List Successful")
             )
           err err-transfer-failed
          )
        err-not-owner
     )
   
  )
)
;;Unlist-item
;;users can be able to unlist their nfts(items)
(define-public (unlist-item (nft <nft-trait>) (id uint))
 (let ((nft-owner (unwrap-panic (map-get? listed-collections {nft-name: (contract-of nft),id: id}))))
   (asserts! (is-eq (get artist nft-owner) tx-sender) err-not-owner)
   ;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft id  tx-sender)
     success
      (begin 
        (map-delete listed-collections {nft-name: (contract-of nft),id: id})
        (ok "Unlist successful")
      )
     err err-transfer-failed
   )
 )
)

;;Purchase-nft
;;when i mint code should keep track of amount of purchases 
(define-public (purchase-nft (nft-con <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? listed-collections {nft-name: (contract-of nft-con),id: id})))
      (price (get price get-list))
      (to-contract (get commision get-list))
      (to-owner (- price to-contract)))
      ;;#[allow(unchecked_data)]
     (match (stx-transfer? to-owner tx-sender (get artist get-list))
       haha (match (stx-transfer? to-contract tx-sender contract-owner) 
        contract-successful 
          (match (transfer-back-to-owner nft-con id tx-sender)
            success (begin 
               (map-delete listed-collections {nft-name: (contract-of nft-con),id: id})
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
(define-public (admin-unlist (nft-con <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? listed-collections {nft-name: (contract-of nft-con),id: id}))))
  (if (is-eq tx-sender admin)
;;#[allow(unchecked_data)]
   (match (transfer-back-to-owner nft-con id (get artist get-list))
     succeeded
      (begin  
       (map-delete listed-collections {nft-name: (contract-of nft-con),id: id})
        (ok "Admin-unlist successful")
      )
    err err-failed
   ) 
   err-not-allowed
  )
 )
)
 
