// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAllowanceTransferERC721} from "../interfaces/IAllowanceTransferERC721.sol";

library AllowanceERC721 {
    // note if the expiration passed is 0, then it the approval set to the block.timestamp
    uint256 private constant BLOCK_TIMESTAMP_EXPIRATION = 0;

    /// @notice Sets the allowed amount, expiry, and nonce of the spender's permissions on owner's token.
    /// @dev Nonce is incremented.
    /// @dev If the inputted expiration is 0, the stored expiration is set to block.timestamp
    function updateAll(
        IAllowanceTransferERC721.PackedAllowance storage allowed,
        address spender,
        uint48 expiration,
        uint48 nonce
    ) internal {
        uint48 storedNonce;
        unchecked {
            storedNonce = nonce + 1;
        }

        uint48 storedExpiration = expiration == BLOCK_TIMESTAMP_EXPIRATION ? uint48(block.timestamp) : expiration;

        uint256 word = pack(spender, storedExpiration, storedNonce);
        assembly {
            sstore(allowed.slot, word)
        }
    }

    /// @notice Sets the expiry of the spender's permissions on owner's token.
    /// @dev Nonce does not need to be incremented.
    function updateSpenderAndExpiration(
        IAllowanceTransferERC721.PackedAllowance storage allowed,
        address spender,
        uint48 expiration
    ) internal {
        // If the inputted expiration is 0, the allowance only lasts the duration of the block.
        allowed.expiration = expiration == 0 ? uint48(block.timestamp) : expiration;
        allowed.spender = spender;
    }

    /// @notice Computes the packed slot of the amount, expiration, and nonce that make up PackedAllowance
    function pack(address spender, uint48 expiration, uint48 nonce) internal pure returns (uint256 word) {
        word = (uint256(nonce) << 208) | uint256(expiration) << 160 | uint160(spender);
    }
}