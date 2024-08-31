// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./IERC20Errors.sol";

contract SpicaToken is IERC20, IERC20Metadata, IERC20Errors {
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    string private _name = "Spica";
    string private _symbol = "SPCA";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 5000000000 * 10 ** _decimals;

    constructor() {
        // Mint total supply of tokens to deployer address
        address deployer = msg.sender;
        _balances[deployer] = _totalSupply;

        emit Transfer(address(0), deployer, _totalSupply);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) external override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, value);

        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) external override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) external override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);

        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if(from == address(0))
            revert ERC20InvalidSender(address(0));
        
        if(to == address(0))
            revert ERC20InvalidReceiver(address(0));

        uint256 fromBalance = _balances[from];
        if(fromBalance < value)
            revert ERC20InsufficientBalance(from, fromBalance, value);
        
        unchecked {
            // Ignore overflow check, which we know fits into a uint256
            _balances[from] = fromBalance - value;
            _balances[to] += value;
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        if(owner == address(0))
            revert ERC20InvalidApprover(address(0));
        
        if(spender == address(0))
            revert ERC20InvalidSpender(address(0));
        
        _allowances[owner][spender] = value;

        emit Approval(owner, spender, value);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal {
        uint256 currentAllowance = _allowances[owner][spender];
        if(currentAllowance != type(uint256).max) {
            if(currentAllowance < value)
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            
            unchecked {
                // Ignore overflow check, which we know fits into a uint256
                _allowances[owner][spender] = currentAllowance - value;
            }
        }
    }
}
