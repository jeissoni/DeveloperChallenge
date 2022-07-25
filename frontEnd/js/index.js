let provider, signer

const btnRefresh = document.getElementById("btnRefresh")
const btnConnet = document.getElementById("btnConnet")
const btnConvert = document.getElementById("btnConvert")
const btnStock = document.getElementById("btnStock")
const viewOnEtherscan = document.querySelector('.viewOnEtherscan')


const contractAdress = "0xf00A2aA81dC0b1830ecAc080B94c63D8358bF88C"
const contractAbi = [{
        "inputs": [{
            "internalType": "uint256[]",
            "name": "amountPerDenomination",
            "type": "uint256[]"
        }],
        "name": "changeStock",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [{
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
        }],
        "name": "convertDenom",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [{
                "internalType": "address",
                "name": "account",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "id",
                "type": "uint256"
            }
        ],
        "name": "balanceOf",
        "outputs": [{
            "internalType": "uint256",
            "name": "",
            "type": "uint256"
        }],
        "stateMutability": "view",
        "type": "function"
    }
]


window.addEventListener("load", async function (e) {
    if (window.ethereum) {

        provider = ethers.getDefaultProvider()
        const contract = new ethers.Contract(contractAdress, contractAbi, provider);

    } else {
        //installAlert.classList.add("showAlert")

    }
})

async function refresh() {

    const arrayValue = [100, 50, 20, 10, 5, 1]
    let value = []
    let providerTmp = ethers.getDefaultProvider("rinkeby")
    const contract = new ethers.Contract(contractAdress, contractAbi, providerTmp)

    for (let index = 0; index < arrayValue.length; index++) {
        const contents = await contract.balanceOf(contractAdress, arrayValue[index])
        value.push(contents.toNumber())
    }

    for (let index = 0; index < arrayValue.length; index++) {
        document.getElementById(arrayValue[index]).innerHTML = value[index]
    }
    console.log(value)
}


btnRefresh.onclick = refresh;



// login and logout

async function connectWallet() {

    await window.ethereum
        .request({
            method: 'wallet_requestPermissions',
            params: [{
                eth_accounts: {}
            }]
        })
        .then(() => {
            let catch1 = /^\w{5}/
            let catch2 = /\w{4}$/
            let test1 = ethereum.selectedAddress.match(catch1)
            let test2 = ethereum.selectedAddress.match(catch2)
            btnConnet.innerHTML = test1 + '...' + test2
            isConnected = true
        }).catch((x) => {
            console.log(x.message)
        })
}

async function changeChain() {
    ethereum.on('chainChanged', (chainId) => {
        if (chainId === '0x4') {
            disConnectedToMainet.classList.remove("showAlert")
            connectedToMainet.classList.add("showAlert")
            connectedToMainet.style.zIndex = 50
            setTimeout(() => {
                connectedToMainet.classList.remove("showAlert")
                connectedToMainet.style.zIndex = 0
            }, 5000)

        } else {
            disConnectedToMainet.classList.add("showAlert")
        }

    });
    return await window.ethereum.request({
        "id": 1,
        "jsonrpc": "2.0",
        "method": "wallet_switchEthereumChain",
        "params": [{
            "chainId": "0x4",
        }]
    })
}


async function login() {
    if (window.ethereum) {
        connectWallet()
        changeChain()
    } else {
        installAlert.classList.add("showAlert")
    }
}


let isConnected = false

btnConnet.addEventListener('click', async function () {
    if (!isConnected) {
        login()
    } else {
        //log out
        location.reload()
    }
})


async function convertDenom() {
    provider = new ethers.providers.Web3Provider(window.ethereum)
    signer = provider.getSigner();
    const contract = new ethers.Contract(contractAdress, contractAbi, signer);
    const amount = document.getElementById("nptDenom").value
    const alert = document.getElementById('liveAlertDenom')
    let wrapper = document.createElement('div')
    await contract.convertDenom(amount)
    .then((tx) => {      
        wrapper.innerHTML = [
            `<div class="alert alert-success alert-dismissible" role="alert">`,
            `   <div>https://rinkeby.etherscan.io/tx/${tx.hash}</div>`,
            '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
            '</div>'
          ].join('')
        alert.append(wrapper)
    })
    .catch((x) => {
        wrapper.innerHTML = [
            `<div class="alert alert-danger alert-dismissible" role="alert">`,
            `   <div>${x.error.message}</div>`,
            '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
            '</div>'
          ].join('')
        alert.append(wrapper)    
    })    
}


async function changeStock(){
    provider = new ethers.providers.Web3Provider(window.ethereum)
    signer = provider.getSigner();
    const contract = new ethers.Contract(contractAdress, contractAbi, signer);
    const amount = document.getElementById("nptStock").value
    const array = amount.split(",").map(Number);
    const alert = document.getElementById('liveAlertStock')
    let wrapper = document.createElement('div')
    await contract.changeStock(array)
    .then((tx) => {       
        wrapper.innerHTML = [
            `<div class="alert alert-success alert-dismissible" role="alert">`,
            `   <div>https://rinkeby.etherscan.io/tx/${tx.hash}</div>`,
            '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
            '</div>'
          ].join('')
        alert.append(wrapper)        
    })
    .catch((x) => {
    wrapper.innerHTML = [
        `<div class="alert alert-danger alert-dismissible" role="alert">`,
        `   <div>${x.error.message}</div>`,
        '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
        '</div>'
      ].join('')
    alert.append(wrapper)    
    }) 


}

btnConvert.addEventListener('click', async function(){
    if(isConnected){
        if(ethereum.chainId === '0x4'){            
            convertDenom()
        } else {
            changeChain()
        }
      } else {
        const alert = document.getElementById('liveAlert')
        let wrapper = document.createElement('div')
        wrapper.innerHTML = [
            `<div class="alert alert-warning alert-dismissible" role="alert">`,
            `   <div>¡ No account connected !</div>`,
            '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
            '</div>'
          ].join('')
        alert.append(wrapper)       
      }
})

btnStock.addEventListener('click', async function(){
    if(isConnected){
        if(ethereum.chainId === '0x4'){            
            changeStock()
        } else {
            changeChain()
        }
      } else {
        const alert = document.getElementById('liveAlert')
        let wrapper = document.createElement('div')
        wrapper.innerHTML = [
            `<div class="alert alert-warning alert-dismissible" role="alert">`,
            `   <div>¡ No account connected !</div>`,
            '   <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>',
            '</div>'
          ].join('')
        alert.append(wrapper)     
        
      }
})


