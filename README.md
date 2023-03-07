

![marketplace](Untitled_Artwork_3.png)


## Introduction

**Stacksnation** is an NFT marketplace that is designed to support creators in [Africa](https://en.wikipedia.org/wiki/Africa) and bring more innovation to Bitcoin NFTs in the Stacks ecosystem. The platform is built on the Stacks blockchain, which is a decentralized platform that allows for the creation and trading of non-fungible tokens (NFTs).

This is a submission to the [Building on Bitcoin Hackathon](https://building-on-btc-hack.devpost.com/?ref_content=default&ref_feature=challenge&ref_medium=portfolio) Series.

## Why Stacksnation?:

Certainly! As an NFT marketplace that is focused on the African market, Stacksnation has the potential to tap into a significant and growing user base of crypto enthusiasts in Nigeria. With over 32 million internet users in Nigeria and a large and growing population of young, tech-savvy individuals, there is a significant opportunity for Stacksnation to capture a portion of this market. Additionally, the fact that Nigeria has the highest number of Bitcoin searches globally highlights the strong interest in cryptocurrency in the country. By focusing on innovation in Bitcoin-based NFTs and providing education and support to NFT creators in Africa, Stacksnation is uniquely positioned to drive innovation in the NFT space and capture a significant share of the African NFT market. Overall, Stacksnation is a promising platform that has the potential to become a major player in the NFT space, and could bring new territories to Stacks and drive innovation in the Bitcoin NFT ecosystem.

## Features:

#### List-item

with the **list-item** feature Nft creators or sellers have the ability to put an Nft for sale in the marketplace, however if the nft that have been put up for sale fails to follow the terms and policies of the marketplace it will be frozen.

#### Change-price

with the **change-price** feature, either the creators or sellers can adjust the price of an nft that has been listed for sale, however the price can not be lowered below 1 stx.

#### Unlist-item

with the **unlist-item** feature, creators and sellers have the ability to remove their Nft from sale at any time, even if it has been previously been frozen by the markeplace.

#### Purchase-item

with the **purchase-item** feature, buyers have the ablilty to purchase an nft at any time, but if the nft has been frozen by the marketplace it can't be purchased

#### Admin-unlist

with the **admin-unlist** feature the admin is able to unlist an nft if nessesary or if the creator or seller violates the terms and policies

#### transfer-item

with the **transfer-item** feature users can be able to transfer an nft to a chosen address

## Smart contract:

## Public functions of the marketplace
the marketplace provides this functions to:
 
- `List-item`: with the list-item function, Nft creators or sellers have the ability to put an Nft for sale in the marketplace, however if the nft that have been put up for sale fails to follow the terms and policies of the marketplace it will be frozen.

- `Unlist-item`: with the unlist-item function, creators and sellers have the ability to remove their Nft from sale at any time, even if it has been previously been frozen by the markeplace.

- `Admin-unlist`: with the admin-unlist function the admin is able to unlist an nft if nessesary or if the creator or seller violates the terms and policies

- `Purchase-item`: with the purchase-item function, buyers have the ablilty to purchase an nft at any time, but if the nft has been frozen by the marketplace it can't be purchased,
the commision is dynamic price determines commission amount

- `Transfer-item`: with the transfer-item function, users can be able to transfer an nft to a chosen address

- `Change-price`: with the change-price function, either the creators or sellers can adjust the price of an nft that has been listed for sale, however the price can not be lowered below 1 stx.


## Assisting / Other functions

- `set-frozen`: 

with the set-frozen function admin can be able to freeze an nft if the cretor of the nft violates the terms and policies of the marketplace

- `undo-frozen`:
 with the undo-frozen function admin can be able to unfreeze an nft if the creator makes an apeal

- `get-listed-collections`:
 with the get-listed-collections function users can be able to search for an nft

- `get-nft-for-sale`:
with the get-nft-for-sale function users can be able to checker the price of the nft

- `check-owner`:
with the checker-owner function user can be able to check the owner of the nft (the contract use this function to check if the seller is the true owner of the nft)

- `set-commission`: with the set-commision function admin or contract owner can modify the  amount commission 

## Read-only functions

- `get-purchase-nonce`

- `get-listing-nonce`

- `get-frozen`

## Tests
note: this contract is'nt thoroughfully tested and a unit test was not written but you can test or call the functions manually

- **Main functions**:

`(contract-call? .sip009 mint tx-sender)`

`(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stacksnation-c list-item  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip009 u1 "crypt" u30000)`

`(contract-call? .stacksnation-c unlist-item 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip009 u1)`
`(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stacksnation-c purchase-item 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip009 u1)`

`(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stacksnation-c transfer-item 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip009 u1 tx-sender 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)`

`(contract-call? 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.stacksnation-c admin-unlist ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.sip009 u1)`

- **Other functions**:

`(contract-call? .stacksnation-c change-price .sip009 u1 u300000)`

`(contract-call? .stacksnation-c set-frozen .sip009)`

`(contract-call? .stacksnation-c undo-frozen .sip009)`


## Deployment

`$ clarinet deployment generate --testnet --medium-cost`

## Future work