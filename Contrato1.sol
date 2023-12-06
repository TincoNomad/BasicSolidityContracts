//SPDX-License-Identifier: GPL-3.0
//Lincencia 👆🏽

//Version
pragma solidity >0.8.0 <0.9.0;

contract ContadorVisitas {
    //Variables
    uint public visitas;
    address implementador;

    //Constructor
    constructor(uint valorInicial){
        visitas = valorInicial;
        implementador = msg.sender;
    }

    //Función
    function incrementarVicitas() SoloImplementador public {
        visitas++;
    }

    //Modificadorees
    modifier SoloImplementador {
        require(msg.sender == implementador, "La cuenta no implemento el contrato");
        _;
    }
}