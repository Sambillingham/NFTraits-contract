const { expect } = require("chai");
const { ethers } = require("hardhat");
// const ObjectsToCsv = require('objects-to-csv');
require('dotenv').config();

// const intrinsicCount = [50,49,46,39,28,16,9,5,4,4];
// let tokenData = [] ;
// let output = [];

// for (let i = 0; i < intrinsicCount.length; i++) {
//     const count = intrinsicCount[i];
//     const iv = i;
//     for (let j = 0; j < count; j++) {
//         tokenData.push(i+1)        
//     }
// }

// function calcRarity() {
//     const R = Math.random() 
//     if(R < 0.6317){
//         return 1;
//     } else if (R < (0.015 + 0.6317 + 0.237) ){
//         return 2; 
//     } else if (R  < (0.6317 + 0.237 + 0.092)) {
//         return 3; 
//     } else if (R  < (0.6317 + 0.237 + 0.092 + 0.0387)) {
//         return 4; 
//     } else {
//         return 5; // 50%
//     }
// } 

const layerData = [
    '215682144387859885109560000158392704357296514047503851826402060958901',
    
    '113495160187518652357887046427394540778109649156032018159923869571255770415376',
    
    '114458615335068111925400406002890694146136894957349272561245014035095357504',
    
    '68766103483569937662513708549859923285450492847168159137152153767996253588488',
    
    '21707652254501729341814189060312831910816671851240568055151831437276516171775',
    
    '105060702740336674949450205062761313470070461062538888241171392817388038078468',
    
    '90483771983532903410350651096131134977356082598926730204084869447954567845888',
    
    '3618513250813712781840556741640594899713099323876223831232090022539173560320',
    
    '3570242327362256528346628777396278034205535825761063157769186910199972102144',
    
    '1973683778179814790934449679809183038147012189679844965797257778561049346',
    
    '1865790672645049829111385181648507797476502342419054634590799887347450005777',
    
    '3619847201169310000537636195435547372432291438586266532023741909509070389504',
    
    '59080187917310571997773614854898290689934687265847019665440174222454720611100',
    
    '14484722787089638624620897340188568784111297597974053460222604832485134041088',
    
    '10617474036067209766761853975571453175553726692720378320591224929257914884',
    
    '61083436779756929259736982906024513812310116245655772117689761365130381412099',
    
    '82320828122681316274862947693816722685102357950503518575583016686035520303104',
    
    '7950855390791510082117091047993063946722441876616019704697862996560445440',
    
    ];
describe("NFTraits", async function () {
    
    
    it("get URI", async function () {
        const NFTraitsFactory = await hre.ethers.getContractFactory("NFTraits");
        
        
        const NFTraits = await NFTraitsFactory.attach('0xD2069193dE6161110a263Ef075BFE0794581beaD');
    
        // await NFTraits.store( 0,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 1,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 2,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 3,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 4,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 5,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 6,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 7,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 8,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 9,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 10,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 11,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 12,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 13,layerData,6,'SXNsYW5k');
        // await NFTraits.store( 14,layerData,6,'SXNsYW5k');

        // const uri = await NFTraits.uri(0);
        console.log('...complete')
    });




    // it("Generate Rarity CSVs", async function () {
    //     const NFTraitsFactory = await hre.ethers.getContractFactory("NFTraits");
    //     const NFTraits = await NFTraitsFactory.deploy();
    
    //     await NFTraits.deployed();
    
    //     console.log("NFTraits => deployed to:", NFTraits.address);

    //     NFTraits.mintBatch()


        
    //     for (let i = 0; i < 10000; i++) {
    //         const tokenGroup = Math.floor(Math.random() * 250);
    //         const iv = tokenData[tokenGroup];
    //         const r = calcRarity();
    //         const tokenId = (tokenGroup * 5) + r;

    //         console.log(tokenId, iv, r);
    //         output.push({
    //             tokenId,
    //             r,
    //             iv
    //         })
    //     }

    //     ///
    //     let values = output.reduce((accumulator, value) => {
    //         const {iv, r} = value;
    //         const name = `${iv}`;
    //        const a = {...accumulator, [name]: (accumulator[name] || 0) + 1};
    //        return a;
    //     }, {});

    //     let groupIv = []

    //     for (const key in values) {
    //             groupIv.push({
    //                 iv: key,
    //                 count: values[key],
    //             })
    //     }
        
    //     const csvG = new ObjectsToCsv(groupIv);
    //     csvG.toDisk('./groupIv.csv');
        
    //     //
    //     let rarity = output.reduce((accumulator, value) => {
    //         const {r} = value;
    //         const name = `${r}`;
    //        const a = {...accumulator, [name]: (accumulator[name] || 0) + 1};
    //        return a;
    //     }, {});

    //     let groupR = []

    //     for (const key in rarity) {
    //         groupR.push({
    //                 iv: key,
    //                 count: rarity[key],
    //             })
    //     }

    //     const csvR = new ObjectsToCsv(groupR);
    //     csvR.toDisk('./groupR.csv');

    //     /// iv + R
    //         let grouping = output.reduce((accumulator, value) => {
    //             const {iv, r} = value;
    //             const name = `${iv}-${r}`;
    //            const a = {...accumulator, [name]: (accumulator[name] || 0) + 1};
    //            return a;
    //         }, {});

    //     let groupArr = []

    //     for (const key in grouping) {
    //             groupArr.push({
    //                 token: key,
    //                 count: grouping[key],
    //             })
    //     }

    //     console.log(groupArr)

    //         const csv = new ObjectsToCsv(groupArr);
        
    //         // // Save to file:
    //         csv.toDisk('./grouping.csv');
        
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
    // });
});
