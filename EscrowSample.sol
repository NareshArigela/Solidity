pragma solidity ^0.4.16;


contract EscrowSample {
    uint mBalance;
    bool mBuyerAccept;
    bool mSellerAccept;
    address public mBuyerAddress;
    address public mSellerAddress;
    address private mEscrowAddress;
    uint private mStartTime;
   
function EscrowSample(address _buyerAddress, address _sellerAddress) public {
    
        //Intialization
        mBuyerAddress = _buyerAddress;
        mSellerAddress = _sellerAddress;
        mEscrowAddress = msg.sender;
        mStartTime = now; // It will show the present block Time Stamp 
    }
    
    function accept() public {
        if (msg.sender == mBuyerAddress){
            mBuyerAccept = true;
        } else if (msg.sender == mSellerAddress){
            mSellerAccept = true;
        }
        if (mBuyerAccept && mSellerAccept){
            payBalance();
        } else if (mBuyerAccept && !mSellerAccept && now > mStartTime +  2 days) {
            // Freeze it for Two days
            selfdestruct(mBuyerAddress);
        }
    }
    
    function payBalance() private {
        //  sending fee to escrew account
        mEscrowAddress.transfer(this.balance / 100);
        // send seller the balance
        if (mSellerAddress.send(this.balance)) {
            mBalance = 0;
        } else {
            throw;
        }
    }
    function deposit() public payable {
        if (msg.sender == mBuyerAddress) {
            mBalance += msg.value;
        }
    }
    
    function cancel() public {
        if (msg.sender == mBuyerAddress){
            mBuyerAccept = false;
        } else if (msg.sender == mSellerAddress){
            mSellerAccept = false;
        }
        // if both buyer and seller would like to cancel, money is returned to buyer 
        if (!mBuyerAccept && !mSellerAccept){
            selfdestruct(mBuyerAddress);
        }
    }
    
    function kill() public constant {
        if (msg.sender == mEscrowAddress) {
            selfdestruct(mBuyerAddress);
        }
    }
}