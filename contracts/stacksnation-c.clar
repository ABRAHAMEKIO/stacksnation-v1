;; stacknsation nft marketplace-v1

;;features
;;list nfts
;;unlist nft 
;;purhase nft 
;;nft air-drop

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)
(define-constant err-low-price (err u100))
(define-constant err-not-owner (err u200))
(define-constant err-transfer-failed (err u300))
(define-constant err-failed (err u400))
(define-constant err-haha (err u500))
(define-constant err-not-allowed (err u600))

(define-data-var commision uint u10000)

(define-constant admin (as-contract tx-sender))
(define-data-var minimum-floor-price uint u20000)

(define-data-var listing-id uint u0)


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

(define-public (get-listed-collections (nft-con <nft-trait>) (id uint))
 (begin
   (ok (map-get? listed-collections {nft-name: (contract-of nft-con),id: id}))
 )
)
(define-private (check-owner (nft-con <nft-trait>) (nft-id uint))
  (contract-call? nft-con get-owner nft-id)
)
(define-public (transfer-item (nft-con <nft-trait>) (id uint ) (sender principal) (recipient principal))
  (begin
  ;;#[filter(nft-con, amount, sender , recipient)]
     (ok (contract-call? nft-con transfer id sender recipient)) 
  )
)

(define-private (transfer-back-to-owner (nft-con <nft-trait>) (id uint) (recipient principal))
 (begin
  (as-contract (contract-call? nft-con transfer id (as-contract tx-sender) recipient))
 )
)

(define-public (list-item (nft-con <nft-trait>) (id uint) (name (string-ascii 28)) (desc (string-ascii 50)) (price uint) (floor-price uint) (amount uint))
 ;;#[filter(nft-con,id,artist, desc, floor-price, amount)]
 (let ((nft-owner (unwrap! (unwrap-panic (check-owner nft-con id)) err-not-owner)))
   (asserts! (> price (var-get minimum-floor-price)) err-low-price)
      (if (is-eq nft-owner tx-sender) 
          (match  (unwrap-panic (transfer-item nft-con id nft-owner (as-contract tx-sender)))
             success
             (begin (map-set listed-collections {nft-name: (contract-of nft-con),id: id} { artist: nft-owner,descrption: desc,price: price,floor-price: floor-price,amount: amount,commision: (var-get commision)})
             (ok (map-get? listed-collections {nft-name: (contract-of nft-con),id: id}))
          )
         err err-transfer-failed
   )
        err-not-owner
     )
   
  )
)

(define-public (unlist-item (nft <nft-trait>) (id uint))
 (let ((nft-owner (unwrap-panic (map-get? listed-collections {nft-name: (contract-of nft),id: id}))))
   (asserts! (is-eq (get artist nft-owner) tx-sender) err-not-owner)
   ;;#[filter(nft, id)]
   (match (transfer-back-to-owner nft id  tx-sender)
     success
      (begin 
        (map-delete listed-collections {nft-name: (contract-of nft),id: id})
        (ok true)
      )
    err err-transfer-failed
   )
   
 )
)


(define-public (purchase-nft (nft-con <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? listed-collections {nft-name: (contract-of nft-con),id: id})))
      (price (get price get-list))
      (to-contract (get commision get-list))
      (to-owner (- price to-contract)))
      ;;#[filter(nft-con, id, sender)]
     (match (stx-transfer? to-owner tx-sender (get artist get-list))
       haha (match (stx-transfer? to-contract tx-sender (as-contract tx-sender)) 
        contract-successful 
          (match (transfer-back-to-owner nft-con id tx-sender)
            success (begin 
               (map-delete listed-collections {nft-name: (contract-of nft-con),id: id})
              (ok true)
           )
           err3 err-failed
         )
         err2 err-transfer-failed
       )
      err1 err-haha
    )
  )
)

;;check if its admin
;;can transfer nft back to owner
(define-public (admin-unlist (nft-con <nft-trait>) (id uint))
 (let ((get-list (unwrap-panic (map-get? listed-collections {nft-name: (contract-of nft-con),id: id}))))
  (if (is-eq tx-sender admin)
;;#[filter(nft-con,id)]
   (match (transfer-back-to-owner nft-con id (get artist get-list))
     succeeded
      (begin  
       (map-delete listed-collections {nft-name: (contract-of nft-con),id: id})
        (ok true)
      )
    err err-failed
   ) 
   err-not-allowed
  )
 )
)