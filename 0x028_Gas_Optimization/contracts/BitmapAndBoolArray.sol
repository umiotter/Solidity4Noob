
contract BitmapAndBoolArray {
    bool[8] implementationWithBool;
    uint8 implementationWithBitmap;

    function setDataWithBoolArray(bool[8] memory data) external {
        implementationWithBool = data;
    }

    function setDataWithBitmap(uint8 data) external {
        implementationWithBitmap = data;
    }

    function readWithBoolArray(uint8 index) external view returns (bool) {
        return implementationWithBool[index];
    }

    function readWithBitmap(uint indexFromRight) external view returns (bool) {
        uint256 bitAtIndex = implementationWithBitmap & (1 << indexFromRight);
        return bitAtIndex > 0;
    }
}