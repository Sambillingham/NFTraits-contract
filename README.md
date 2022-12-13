# NFTraits \[WIP\]
    - Implements the pixel grid artwork @ https://github.com/Sambillingham/pixel-grid-svg-renderer
    
## Rarity Distribution 
Rarity is controlled by two values, Intrinsic Value(IV) and Rarity Level(RL). IV is set by the artist during deployment. The intention for Intrinsic value is to match a cumulative distribution function with each IV becoming less common as the value increases. Rarity Level describes the Common, Uncommon, Rare, Ledgendary, 1/1 status decided seperately from the Intrinsic Value. 

Chainlink VRF is used to secure random numbers for distribution. Equal weighting for choosing a TokenGroup - represents the base token (pre rarity probability) which has assigned IV/metadata. Probability for selecting RL is outline below. Where a 1/1 token within a TokenGroup has already been minted the rarity will be downranked to 'Legendary'.

Season 1 Intrinsic Value - #250 Token groups

| Intrinsic Value | count |
|-----------------|-------|
|               1 |    50 |
|               2 |    49 |
|               3 |    46 |
|               4 |    39 |
|               5 |    28 |
|               6 |    16 |
|               7 |     9 |
|               8 |     5 |
|               9 |     4 |
|              10 |     4 |

Rarity Probability 

| Tier      | Probability |
|-----------|-------------|
| Common    | 55%         |
| Uncommon  | 30%         |
| Rare      | 10%         |
| Legendary | 5%          |
| Unique    | 1%(1 of 1)  |
