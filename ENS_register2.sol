// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract ENSRegister2 {
    struct User {
        address oAddr;
        uint timeOfCreation;
        uint price;
        uint yearsRent;
    }

    address public immutable owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner!");
        _; // выполнить тело той функции, к которой был применён этот модификатор
    }
    constructor() {
        owner = msg.sender;
    }

    mapping(string => User) public ensOwner;

    uint public totalWithdrawn;

    uint public yearPrice;
    function setYearPrice(uint _newPrice) public onlyOwner {
        yearPrice = _newPrice; // установка новой цены за год
    }

    uint public coeff;
    function setCoeff(uint _newCoeff) public onlyOwner {
        coeff = _newCoeff; // установка нового коэффициента
    }

    // функция для регистрации домена
    function registerENS(string memory _name, uint _yearsRent) public payable {
        uint totalTime = _yearsRent * 365 * 24 * 60 * 60;

        // Проверка: домен должен быть свободен для регистрации
        require((ensOwner[_name].oAddr == address(0)) && (block.timestamp >= ensOwner[_name].timeOfCreation + totalTime), "Domain is already registered.");

        // Проверка на валидность временного промежутка для регистрации домена
        require(_yearsRent >= 1 && _yearsRent <= 10, "Invalid year registration.");


        // Проверка: пользователь заплатил достаточно за регистрацию
        require(msg.value >= (yearPrice * _yearsRent) * 1 ether, "Not enough ether provided to register domain.");

        ensOwner[_name].oAddr = msg.sender; // присвоение доменного имени
        ensOwner[_name].timeOfCreation = block.timestamp; // время присвоения
        ensOwner[_name].price = yearPrice; // цена, которую заплатили за домен
        ensOwner[_name].yearsRent = _yearsRent; // на сколько лет регистрация домена
    }

    function extendRegistration(string memory _name, uint _yearsRent) public payable {
        // Проверка: принадлежит ли домен отправителю транзакции на данный момент
        require(ensOwner[_name].oAddr == msg.sender, "You are not an owner of this domain or it is not yet expired");

        uint extendPrice = ensOwner[_name].price * coeff;
        // Проверка: достаточно эфира для продления 
        require(msg.value >= (extendPrice * _yearsRent) * 1 ether, "Not enough ether provided to extend domain registration.");

        ensOwner[_name].yearsRent += _yearsRent; // на сколько всего лет регистрация домена
    }

    function getOwner(string memory _name) public view returns(address, uint) {
        return (ensOwner[_name].oAddr, ensOwner[_name].yearsRent); // возвращаем владельца домена и срок
    }
	
	// функция для вывода всех полученных денег
    function withdrawAll() public onlyOwner {   
        uint balanceToSend = address(this).balance; 
        totalWithdrawn += balanceToSend; // сумма выведенных средств
        payable(owner).transfer(balanceToSend); // вывод всех имеющихся средств
    }

    // function destroy() public {
    //     selfdestruct(payable(owner));
    // }
}