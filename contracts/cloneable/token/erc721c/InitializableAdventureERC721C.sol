// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../utils/InitializableCreatorTokenBase.sol";
import "../../adventures/InitializableAdventureERC721.sol";

/**
 * @title AdventureERC721C
 * @author Limit Break, Inc.
 * @notice Extends Limit Break's AdventureERC721 implementation with Creator Token functionality, which
 *         allows the contract owner to update the transfer validation logic by managing a security policy in
 *         an external transfer validation security policy registry.  See {CreatorTokenTransferValidator}.
 */
abstract contract InitializableAdventureERC721C is InitializableAdventureERC721, InitializableCreatorTokenBase {

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ICreatorToken).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @dev Ties the adventure erc721 _beforeTokenTransfer hook to more granular transfer validation logic
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize) internal virtual override {

        uint256 tokenId;
        for (uint256 i = 0; i < batchSize;) {
            tokenId = firstTokenId + i;
            if(blockingQuestCounts[tokenId] > 0) {
                revert InitializableAdventureERC721__AnActiveQuestIsPreventingTransfers();
            }

            if(transferType == TRANSFERRING_VIA_ERC721) {
                _validateBeforeTransfer(from, to, tokenId);
            }

            unchecked {
                ++i;
            }
        }
    }

    /// @dev Ties the adventure erc721 _afterTokenTransfer hook to more granular transfer validation logic
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize) internal virtual override {
        for (uint256 i = 0; i < batchSize;) {
            _validateAfterTransfer(from, to, firstTokenId + i);
            unchecked {
                ++i;
            }
        }
    }
}
