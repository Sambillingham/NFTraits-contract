const { expect } = require("chai");
const { ethers } = require("hardhat");
const ObjectsToCsv = require('objects-to-csv');


const intrinsicCount = [50,49,46,39,28,16,9,5,4,4];
let tokenData = [] ;
let output = [];

for (let i = 0; i < intrinsicCount.length; i++) {
    const count = intrinsicCount[i];
    const iv = i;
    for (let j = 0; j < count; j++) {
        tokenData.push(i+1)        
    }
}

function calcRarity() {
    const R = Math.random() 
    if(R < 0.6317){
        return 1;
    } else if (R < (0.015 + 0.6317 + 0.237) ){
        return 2; 
    } else if (R  < (0.6317 + 0.237 + 0.092)) {
        return 3; 
    } else if (R  < (0.6317 + 0.237 + 0.092 + 0.0387)) {
        return 4; 
    } else {
        return 5; // 50%
    }
} 

describe("NFTraits", async function () {

    it("Generate Rarity CSVs", async function () {
        const NFTraitsFactory = await hre.ethers.getContractFactory("NFTraits");
        const NFTraits = await NFTraitsFactory.deploy();
    
        await NFTraits.deployed();
    
        console.log("NFTraits => deployed to:", NFTraits.address);

        NFTraits.mintBatch()


        
        for (let i = 0; i < 10000; i++) {
            const tokenGroup = Math.floor(Math.random() * 250);
            const iv = tokenData[tokenGroup];
            const r = calcRarity();
            const tokenId = (tokenGroup * 5) + r;

            console.log(tokenId, iv, r);
            output.push({
                tokenId,
                r,
                iv
            })
        }

        ///
        let values = output.reduce((accumulator, value) => {
            const {iv, r} = value;
            const name = `${iv}`;
           const a = {...accumulator, [name]: (accumulator[name] || 0) + 1};
           return a;
        }, {});

        let groupIv = []

        for (const key in values) {
                groupIv.push({
                    iv: key,
                    count: values[key],
                })
        }
        
        const csvG = new ObjectsToCsv(groupIv);
        csvG.toDisk('./groupIv.csv');
        
        //
        let rarity = output.reduce((accumulator, value) => {
            const {r} = value;
            const name = `${r}`;
           const a = {...accumulator, [name]: (accumulator[name] || 0) + 1};
           return a;
        }, {});

        let groupR = []

        for (const key in rarity) {
            groupR.push({
                    iv: key,
                    count: rarity[key],
                })
        }

        const csvR = new ObjectsToCsv(groupR);
        csvR.toDisk('./groupR.csv');

        /// iv + R
            let grouping = output.reduce((accumulator, value) => {
                const {iv, r} = value;
                const name = `${iv}-${r}`;
               const a = {...accumulator, [name]: (accumulator[name] || 0) + 1};
               return a;
            }, {});

        let groupArr = []

        for (const key in grouping) {
                groupArr.push({
                    token: key,
                    count: grouping[key],
                })
        }

        console.log(groupArr)

            const csv = new ObjectsToCsv(groupArr);
        
            // // Save to file:
            csv.toDisk('./grouping.csv');
        
            // Return the CSV file as string:
            // console.log(await csv.toString());

     
        // console.log(intrinsic)
        // console.log(R)
        


            // var arr = [];
            // for(var i = 0; i < 100000; i++) {
            //     arr.push(rand());
            // }


            // let count = arr.reduce((accumulator, value) => {
            //     const base = Math.floor(value / 100)
            //    const a = {...accumulator, [base]: (accumulator[base] || 0) + 1};
            //    return a;
            // }, {});
            
            
            // console.log(count);
            // Object.keys(count).forEach((key) => {
            //     count[key] = Math.floor(count[key]/400);
            //   });
            //   console.log(count);



            // function rand(){
            //     return Math.floor(Math.pow(Math.random(), 2.4) *1000)
            // }
    });
});
