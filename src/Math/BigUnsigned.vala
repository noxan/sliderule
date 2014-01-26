namespace Math {

/**
 * An arbitrary unsigned integer class.
 */
class BigUnsigned {
	/**
	 * The number of blocks that are actually used to represent the number.
	 */
	private int length;
	/**
	 * The blocks that are internally used to represent the BigUnsigned.
	 */
	private uint32[] blocks;

	/**
	 * Creates a new BigUnsigned with the value zero.
	 */
	public BigUnsigned() {
		this.from_uint32(0);
	}

	/**
	 * Creates a new BigUnsigned with the given value.
	 * @param val the given value
	 */
	public BigUnsigned.from_uint32(uint32 val) {
		if(val == 0) {
			blocks = {};
			length = 0;
		} else {
			blocks = {val};
			length = 1;
		}
	}

	/**
	 * Creates a new BigUnsigned with the given blocks.
	 * @param blocks the given value blocks, index 0 is the LSB
	 */
	public BigUnsigned.from_blocks(uint32[] blocks)  {
		this.blocks = blocks;
		remove_leading_zeros();
	}

	/**
	 * Creates a copy of the given BigUnsigned.
	 * @param val the BigUnsigned to copy
	 */
	public BigUnsigned.copy(BigUnsigned val) {
		length = val.length;
		blocks = val.blocks;
	}

	/**
	 * Creates a BigUnsigned with a prereserved number of blocks. This method is
	 * only for internal usage.
	 * @param length the number of blocks to reserve
	 */
	private BigUnsigned.with_size(int length) {
		this.length = length;
		this.blocks = new uint32[length];
	}

	/**
	 * Returns whether this number is zero.
	 */
	public bool is_zero() {
		return length == 0;
	}

	/**
	 * Calculates and sets the actual internal length. This is equal to removing
	 * leading zeros.
	 */
	private void remove_leading_zeros() {
		length = blocks.length;
		// as long as there are leading zeros, decrease the length by one
		while(blocks[length-1] == 0 && length > 0) {
			length--;
		}
	}

	/**
	 * Assigns the given value to this BigUnsigned.
	 * @param val the value to assign
	 */
	public BigUnsigned assign(BigUnsigned val) {
		blocks = val.blocks;
		length = val.length;
		return this;
	}

	/**
	 * Sets this BigUnsigned to the value (this + addend).
	 * @param addend the value to add
	 */
	public BigUnsigned add_assign(BigUnsigned addend) {
		// if the given value is zero there is nothing to add so just return
		if(addend.is_zero()) {
			return this;
		}

		// resize so that there is enough space for the result
		length = int.max(length, addend.length) + 1;
		blocks.resize(length);

		int i;
		uint32 tmp;
		var carryIn = false;
		var carryOut = false;

		// add all blocks that exist in both numbers
		for(i = 0; i < addend.length; i++) {
			tmp = blocks[i] + addend.blocks[i];
			carryOut = (tmp < blocks[i]);
			if(carryIn) {
				tmp++;
				carryOut |= (tmp == 0);
			}
			blocks[i] = tmp;
			carryIn = carryOut;
		}

		// add the remaining blocks from the bigger number as long as there is a
		// carry bit
		for(; i < length-1 && carryIn; i++) {
			tmp = blocks[i] + 1;
			carryIn = (tmp == 0);
			blocks[i] = tmp;
		}

		// if there is a carry bit left, set the most significant block to one
		if(carryIn) {
			blocks[i] = 1;
		// otherwise decrease the length by one
		} else {
			length--;
		}

		return this;
	}

	/**
	 * Returns a BigUnsigned with the value (this + addend).
	 * @param addend the value to add
	 */
	public BigUnsigned add(BigUnsigned addend) {
		var result = new BigUnsigned.copy(this);
		return result.add_assign(addend);
	}

	/**
	 * Sets the value of this to (this - subtrahend). If the result is negative,
	 * a MathError.NEGATIVE_RESULT will be thrown.
	 * @param subtrahend the value to subtract
	 */
	public BigUnsigned subtract_assign(BigUnsigned subtrahend) throws MathError {
		// if the subtrahend is zero
		if(subtrahend.is_zero()) {
			return this;
		}

		// check whether the result will not be negative
		if(length < subtrahend.length) {
			throw new MathError.NEGATIVE_RESULT(
					"negative result within unsigned subtraction");
		}

		int i;
		uint32 tmp;
		bool borrowIn = false;
		bool borrowOut = false;

		// subtract blocks that exists in both numbers
		for(i = 0; i < subtrahend.length; i++) {
			tmp = blocks[i] - subtrahend.blocks[i];
			borrowOut = (tmp > blocks[i]);
			if(borrowIn) {
				borrowOut |= (tmp == 0);
				tmp--;
			}
			blocks[i] = tmp;
			borrowIn = borrowOut;
		}

		// subtract one from the remaining blocks as long as there is a borrow
		// bit
		for(; i < length && borrowIn; i++) {
			borrowIn = (blocks[i] == 0);
			blocks[i] -= 1;
		}

		// if there is still a borrow bit, the result would be negative, so
		// raise an exception
		if(borrowIn) {
			throw new MathError.NEGATIVE_RESULT(
					"negative result within unsigned subtraction");
		}

		remove_leading_zeros();

		return this;
	}

	/**
	 * Returns a BigUnsigned with the value (this - subtrahend). If the result
	 * is negative, a MathError.NEGATIVE_RESULT will be thrown.
	 * @param subtrahend the value to subtract
	 */
	public BigUnsigned subtract(BigUnsigned subtrahend) throws MathError {
		var result = new BigUnsigned.copy(this);
		return result.subtract_assign(subtrahend);
	}

	public BigUnsigned multiply_assign(BigUnsigned factor) {
		return assign(multiply(factor));
	}

	public BigUnsigned multiply(BigUnsigned factor) {
		// if one of the factors is zero, return zero as result
		if(is_zero() || factor.is_zero()) {
			return new BigUnsigned();
		}

		var result = new BigUnsigned.with_size(length + factor.length);
		return result;
	}

	// JUST TESTING CODE
	// WILL BE REMOVED OR REPLACED LATER

	private string to_bin(uint32 l) {
		var result = new StringBuilder();
		for(int i = 31; i >= 0; i--) {
			uint32 b = (l>>i)&0x1;
			result.append(b.to_string());
		}
		return result.str;
	}

	public string to_binary_string() {
		var result = new StringBuilder();
		for(int i = length-1; i >= 0; i--) {
			result.append(to_bin(blocks[i]));
			if(i != 0) {
				result.append_unichar(' ');
			}
		}
		return result.str;
	}

	private string to_hex(uint32 l) {
		if(is_zero()) {
			return "0";
		}
		var result = new StringBuilder();
		for(int i = 28; i >= 0; i -= 4) {
			uint32 b = (l>>i)&0xF;
			if(b < 10) {
				result.append(b.to_string());
			} else {
				result.append_unichar((char)('A' + (b-10)));
			}
		}
		return result.str;
	}

	public string to_hex_string() {
		if(is_zero()) {
			return "0";
		}
		var result = new StringBuilder();
		for(int i = length-1; i >= 0; i--) {
			result.append(to_hex(blocks[i]));
			if(i != 0) {
				result.append_unichar(' ');
			}
		}
		return result.str;
	}
}

}
