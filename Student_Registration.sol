// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;



contract Student_Registration_Contract {
    address public owner;
    
    constructor () {
        owner = msg.sender;
    }

    /*--------Events--------*/
    event StudentRegistered(string _name, string _major, uint8 _age, bool _isRegistered);
    event StudentDetailsUpdated(); 
    event StudentDeleted();


    /*--------Struct--------*/
    struct StudentStruct {
        string name;
        string major;
        uint8 age;
        bool isRegistered;
    }


    /*--------mapping--Array--------*/
    mapping (address => StudentStruct) public students;
    address [] public studentsAddresses;


    /*--------Modifiers--------*/
    modifier isRegistered (address _addr) {
        require(students[_addr].isRegistered,"Student does not exist!");
        _;
    }

    modifier OnlyOwner () {
        require(owner == msg.sender, "Only owner can call this function!");
        _;
    }

    /*----------Register-Student----------*/
    function registerStudent (string memory _name, string memory _major, uint8 _age) public {
        require(!students[msg.sender].isRegistered, "Student already Registered!");
        require(_age >= 18, "Student has to be 18 or older than 18 in order to register!");

        students[msg.sender] = StudentStruct(_name, _major, _age, true);
        studentsAddresses.push(msg.sender);

        emit StudentRegistered(_name, _major, _age, true);
    }
    

    /*----------Get-Student-Details----------*/
    function getStudentDetails (address _addr) public view isRegistered(_addr) returns(StudentStruct memory) {
        require(_addr == msg.sender || msg.sender == owner, "You can not have access to other students!");
        return students[_addr];
    }


    /*----------Update-Student-Detials----------*/
    function updateStudentDetails (address _addr, string memory _name, string memory _major, uint8 _age) public isRegistered(_addr) {
        require(_addr == msg.sender || msg.sender == owner, "You can not have access to other students!");
        
        StudentStruct storage student= students[_addr];

        if (bytes(_name).length > 0) {
            student.name = _name;
        }

        if (_age >= 18) {
            student.age = _age;
        }

        if (bytes(_major).length > 0) {
            student.major = _major;
        }

        emit StudentDetailsUpdated();
    }


    /*----------Delete-Student----------*/
    function deletStudent (address _addr) public OnlyOwner isRegistered(_addr) {
        delete students[_addr];

        for (uint i = 0; i < studentsAddresses.length -1 ; i++) {
            if (studentsAddresses[i] == _addr) {
                delete studentsAddresses[i];
                return;
            }
        }

        emit StudentDeleted();
    }


    /*----------Get-All-Students----------*/
    function getAllStudents () public view OnlyOwner returns(StudentStruct[] memory) {
        StudentStruct[] memory allStudents = new StudentStruct[](studentsAddresses.length);

        for (uint i = 0; i < studentsAddresses.length -1 ; i++) {
            allStudents[i] = students[studentsAddresses[i]];
        }
        
        return allStudents;
    }
}