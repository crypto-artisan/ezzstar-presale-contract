// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals of the token.
     */
    function decimals() external view returns (uint8);
}
