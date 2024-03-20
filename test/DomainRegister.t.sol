// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/DomainRegister.sol";

contract DomainRegistrationTest is Test {
    DomainRegister private domainRegister;
    address private owner;
    address private nonOwner1;
    address private nonOwner2;
    uint256 private constant SUFFICIENT_FEE = 0.005 ether;
    uint256 private constant INSUFFICIENT_FEE = 0.001 ether;
    uint256 private constant NEW_FEE = 0.01 ether;

    function setUp() public {
        owner = address(this);
        nonOwner1 = makeAddr("nonOwner1");
        nonOwner2 = makeAddr("nonOwner2");
        domainRegister = new DomainRegister();
    }

    function testValidDomainRegistration() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        vm.expectEmit();

        string memory domain = "example.com";

        emit DomainRegister.DomainRegistered(address(owner), domain, block.timestamp, 1);
        domainRegister.registerDomain{value: SUFFICIENT_FEE}(domain);
        vm.stopPrank();
    }

    function testRejectRegistrationWithInsufficientFee() public {
        vm.expectRevert(bytes("Insufficient fee"));
        domainRegister.registerDomain{value: INSUFFICIENT_FEE}("example.com");
    }


    function testInvalidDomainRegistrations() public {
        string[] memory invalidDomains = new string[](6);
        invalidDomains[0] = string(abi.encodePacked(repeatChar("a", 253), ".com"));
        invalidDomains[1] = ".example.com";
        invalidDomains[2] = "example.com.";
        invalidDomains[3] = "example..com";
        invalidDomains[4] = "example*com";
        invalidDomains[5] = "";

        for (uint i = 0; i < invalidDomains.length; i++) {
            vm.expectRevert(bytes("Invalid domain"));
            domainRegister.registerDomain{value: SUFFICIENT_FEE}(invalidDomains[i]);
        }
    }

    function testOwnerCanUpdateRegistrationFee() public {
        vm.startPrank(owner);
        vm.expectEmit();
        emit DomainRegister.FeeUpdated(NEW_FEE);
        domainRegister.updateRegistrationFee(NEW_FEE);
        vm.stopPrank();
    }

    function repeatChar(string memory char, uint times) internal pure returns (string memory) {
        bytes memory repeatedBytes = new bytes(times);
        bytes memory charBytes = bytes(char);
        require(charBytes.length == 1, "Function is designed to repeat a single character.");

        for (uint i = 0; i < times; i++) {
            repeatedBytes[i] = charBytes[0];
        }

        return string(repeatedBytes);
    }
}
