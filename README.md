

![marketplace](Untitled_Artwork_3.png)


## Introduction
**Stacksnation** is an NFT marketplace that is designed to support creators in [Africa](https://en.wikipedia.org/wiki/Africa) and bring more innovation to Bitcoin NFTs in the Stacks ecosystem. The platform is built on the Stacks blockchain, which is a decentralized platform that allows for the creation and trading of non-fungible tokens (NFTs).

This is a submission to the [Building on Bitcoin Hackathon](https://building-on-btc-hack.devpost.com/?ref_content=default&ref_feature=challenge&ref_medium=portfolio) Series.

## Why Stacksnation?:

Certainly! As an NFT marketplace that is focused on the African market, Stacksnation has the potential to tap into a significant and growing user base of crypto enthusiasts in Nigeria. With over 32 million internet users in Nigeria and a large and growing population of young, tech-savvy individuals, there is a significant opportunity for Stacksnation to capture a portion of this market. Additionally, the fact that Nigeria has the highest number of Bitcoin searches globally highlights the strong interest in cryptocurrency in the country. By focusing on innovation in Bitcoin-based NFTs and providing education and support to NFT creators in Africa, Stacksnation is uniquely positioned to drive innovation in the NFT space and capture a significant share of the African NFT market. Overall, Stacksnation is a promising platform that has the potential to become a major player in the NFT space, and could bring new territories to Stacks and drive innovation in the Bitcoin NFT ecosystem.

## Features:

• **Support for African Creators**:

 Stacksnation is focused on providing a platform for creators in Africa to showcase and sell their work. This includes artists, musicians, and other creators who are looking to monetize their talents (though not only african creators can showcase but other creator but thats our aim).

• **Bitcoin NFTs**: 

 Stacksnation is built to support the creation and trading of Bitcoin NFTs. This means that users can mint, buy, and sell NFTs that are backed by Bitcoin, providing a new way to use the cryptocurrency through stacks.

• **NFT project acceleration**:

 Stacksnation is designed to bring more innovation to the NFT space by accelerating NFT projects in the stacks ecosystem to provide new ways for NFTs to be used and users to engage with NFTs.

• **NFT Hackathons**:

we also plan to hold NFT hackathons to support and empower existing and potential NFT artists and creators. These hackathons will provide a platform for creators to learn about the latest trends, technologies, and best practices in the NFT space, and to connect with other creators and industry experts.

## Smart contract:

### Public functions of the marketplace
the marketplace provides this functions to:
 
- `List-item`: users (creators/sellers) can be able to put the nft up for sale

- `Unlist-item`: creator or seller can be able to unlist their nft at will

- `Admin-unlist`: admin can unlist the nft if the creator does not follow the rules and regulations

- `Purchase-item`: users (buyers) can be able to purchase an nft but if nft is frozen the buyer cannot purchase the nft
to transfers stx transfer will be made one for the seller and one for the contract
the commision is dynamic price determines commission amount

- `Transfer-item`: users (creators/sellers/buyers) can be able to transfer nfts


## Assisting / Other functions

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