// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;


contract ReceiptSystem{
    uint public ReceiptCount = 0;
    struct Receipt{
        uint Rid;
        string DateTime;
        uint Cost;
        uint Mid;
        uint Cid;
    }
    event LogReceipt(uint Rid,string DateTime, uint Cost, uint Mid, uint Cid, uint ReceiptCount );
    mapping(uint => Receipt) private Receipts;
    function insertReceipt(
        uint _Rid,
        string memory _DateTime,
        uint _Cost,
        uint _Mid,
        uint _Cid)
        public {
            ReceiptCount++;
            Receipts[ReceiptCount].Rid = _Rid;
            Receipts[ReceiptCount].DateTime = _DateTime;
            Receipts[ReceiptCount].Cost = _Cost;
            Receipts[ReceiptCount].Mid = _Mid;
            Receipts[ReceiptCount].Cid = _Cid;
            emit LogReceipt(_Rid,_DateTime, _Cost, _Mid,_Cid,ReceiptCount);
            return;
    }
    function getReceipt(
        uint index
    )
    public 
    view
    returns(uint Rid,string memory DateTime, uint Cost, uint Mid, uint Cid){
        return(
            Receipts[index].Rid,
            Receipts[index].DateTime,
            Receipts[index].Cost,
            Receipts[index].Mid,
            Receipts[index].Cid);
        
    }
    function getReceiptCount() 
    public 
    view
    returns(uint count){
        return ReceiptCount;
    }
    
}
