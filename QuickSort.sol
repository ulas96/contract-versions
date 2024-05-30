// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Sorting {

    function bubbleSort(uint[] memory arr) public pure returns (uint[] memory) {
        uint n = arr.length;
        for (uint i = 0; i < n - 1; i++) {
            for (uint j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    (arr[j], arr[j + 1]) = (arr[j + 1], arr[j]);
                }
            }
        }
        
        return arr;
    }
        

    function quickSort(uint[] memory arr) public pure returns (uint[] memory) {
        if (arr.length <= 1) return arr;
        uint pivot = arr[arr.length / 2];
        uint[] memory left;
        uint[] memory right;
        
        for (uint i = 0; i < arr.length; i++) {
        if (arr[i] < pivot) {
        left.push(arr[i]);
        }
        if (arr[i] > pivot) {
        right.push(arr[i]);
        }
        }
        
        return concat(quickSort(left), pivot, quickSort(right));
    }


    function mergeSort(uint[] memory arr) public pure returns (uint[] memory) {
        if (arr.length <= 1) return arr;
        uint middle = arr.length / 2;
        uint[] memory left = new uint[](middle);
        uint[] memory right = new uint[](arr.length - middle);
        
        for (uint i = 0; i < middle; i++) {
        left[i] = arr[i];
        }
        for (uint i = middle; i < arr.length; i++) {
        right[i - middle] = arr[i];
        }
        
        return merge(mergeSort(left), mergeSort(right));
    }

}

