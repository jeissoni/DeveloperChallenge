# Smart Contract Developer Challenge

En nuestro proyecto estrella vamos a entregar NFTs que representan las monedas y billetes de un país con distintas denominaciones.

•	1 peso

•	5 pesos

•	20 pesos

•	10 pesos

•	50 pesos

•	100 pesos

Necesitamos entregar el mínimo de cada NFTs por cada transacción. Tu misión es calcular la función que convierte un número en una lista de NFTs mínimos para entregar.

Debes incluir las siguientes queries:

•	ConvertDenom (int) //retorna la conversión de monedas

•	ChangeStock([int, int, int, int, int]) //actualiza el stock disponible de cada denominación. Solo debe ser accionable desde la cuenta admin.

## Solución:

Se usa Foundry (https://book.getfoundry.sh/)  como entorno de desarrollo y pruebas (Solidity). Se crea un contrato que sea la abstracción de las denominaciones de las monedas, se elige un contrato que cumpla el estándar ERC1155, este contrato es quien manejara los saldos de cada de nominación y entregara desde la función `convertDenom` los valores correspondientes para el cambio. Esta función se hace de manera lineal por el costo en gas, al usar un buble los costos se aumentan. 

El contrato inicia con los siguientes saldos. 

https://rinkeby.etherscan.io/address/0xf00a2aa81dc0b1830ecac080b94c63d8358bf88c#tokentxnsErc1155

![alt text](https://raw.githubusercontent.com/jeissoni/DeveloperChallenge/main/frontEnd/img/saldo.png)


El contrato es desplegado en la red de prueba rinkeby, se usa HardHat para ese el despliegue y la verificación del contrato.
https://rinkeby.etherscan.io/address/0xf00A2aA81dC0b1830ecAc080B94c63D8358bF88C#code

### Reporte de Gas

•	Función `convertDenom` de manera lineal 

![alt text](https://raw.githubusercontent.com/jeissoni/DeveloperChallenge/main/frontEnd/img/lineal.png)


•	Función `convertDenom` usando un bucle 


![alt text](https://raw.githubusercontent.com/jeissoni/DeveloperChallenge/main/frontEnd/img/for.png)

![alt text](https://raw.githubusercontent.com/jeissoni/DeveloperChallenge/main/frontEnd/img/gasFor.png)

Dentro del repositorio en la carpeta `frontEnd` se encuentra una interfaz gráfica básica para poder interactuar con el contrato.

![alt text](https://raw.githubusercontent.com/jeissoni/DeveloperChallenge/main/frontEnd/img/frond.png)


