/*
 * Copyright (C) 2014 Andre Kupka
 *
 * This file is part of Sliderule.
 *
 * Sliderule is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * Sliderule is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Sliderule.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Math {

/**
 * An arbitrary unsigned integer class.
 */
public class BigUnsigned {
	/**
	 * The number of blocks that are actually used to represent the number.
	 */
	private int length;
	/**
	 * The blocks that are internally used to represent the BigUnsigned.
	 */
	private uint32[] blocks;

	/**
	 * Number of bits in one block.
	 */
	private static const uint BITS_PER_BLOCK = 32;

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
	 * Creates a new BigUnsigned with the given value.
	 * @param val the given value
	 */
	public BigUnsigned.from_uint64(uint64 val) {
		uint32 low = (uint32)(val & 0xFFFFFFFF);
		uint32 high = (uint32)(val >> 32);
		this.from_blocks({low, high});
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
	 * Creates a new BigUnsigned, which value will be the value of the given
	 * string representation in the specified radix.
	 * @param val the value's string representation
	 * @param radix the radix, in [2:36]
	 */
	public BigUnsigned.from_radix_string(string val, uint radix) {
		this();
		assign_from_radix_string(val, radix);
	}

	/**
	 * Creates a new BigUnsigned, which value will be the value of the given
	 * decimal string representation.
	 * @param val the value's decimal string representation
	 */
	public BigUnsigned.from_string(string val) {
		this.from_radix_string(val, 10);
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
	 * Returns a copy of this BigUnsigned.
	 */
	public BigUnsigned create_copy() {
		return new BigUnsigned.copy(this);
	}

	/**
	 * Returns whether this BigUnsigned is zero.
	 */
	public bool is_zero() {
		return length == 0;
	}

	/**
	 * Returns the sign of this BigUnsigned.
	 * @return 0 or 1 if this is zero or positive
	 */
	public int signum() {
		return length == 0 ? 0 : 1;
	}

	/**
	 * Resets this to zero. This means that the length will be set to zero and
	 * all blocks will be zeroed.
	 */
	internal void reset_to_zero() {
		length = 0;
		for(int i = 0; i < blocks.length; i++) {
			blocks[i] = 0;
		}
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
	 * Assigns the value of the given string representation in the specified
	 * radix to this.
	 * @param val the value's string representation
	 * @param radix the radix, in [2:36]
	 */
	public BigUnsigned assign_from_radix_string(string val, uint radix) {
		// TODO proper error handling for illegal value string
		if(radix < 2 || radix > 36) {
			radix = 10;
		}

		reset_to_zero();
		BigUnsigned b = new BigUnsigned.from_uint32(radix);

		for(int i = 0; i < val.length; i++) {
			if(i > 0) {
				multiply_assign(b);
			}

			var x = char_to_int(val.get(i));
			if(x >= radix) {
				// TODO throw error
			}
			var addend = new BigUnsigned.from_uint32(x);
			add_assign(addend);
		}

		return this;
	}

	/**
	 * Assigns the value of the given decimal string representation to this.
	 * @param val the value's decimal string representation
	 */
	public BigUnsigned assign_from_string(string val) {
		return assign_from_radix_string(val, 10);
	}

	/**
	 * Sets this BigUnsigned to the value (this + 1).
	 */
	public BigUnsigned increment_assign() {
		int i;
		bool carry = true;
		for(i = 0; i < length && carry; i++) {
			blocks[i]++;
			carry = (blocks[i] == 0);
		}

		if(carry) {
			if(length == blocks.length) {
				blocks += 1;
			} else {
				blocks[i] = 1;
			}
			length++;
		}

		return this;
	}

	/**
	 * Returns a BigUnsigned with the value (this + 1).
	 */
	public BigUnsigned increment() {
		var result = create_copy();
		return result.increment_assign();
	}

	/**
	 * Sets this BigUnsigned to the value (this - 1). If the result is negative
	 * a MathError.NEGATIVE_RESULT will be thrown.
	 */
	public BigUnsigned decrement_assign() {
		if(is_zero()) {
			// TODO improve error message, probably unsigned decrement?
			throw new MathError.NEGATIVE_RESULT(
					"negative result within unsigned subtraction");
		}

		int i;
		var borrow = true;
		for(i = 0; borrow; i++) {
			borrow = (blocks[i] == 0);
			blocks[i]--;
		}

		if(blocks[length - 1] == 0) {
			length--;
		}

		return this;
	}

	/**
	 * Returns a BigUnsigned with the value (this - 1). If the result is
	 * negative a MathError.NEGATIVE_RESULT will be thrown.
	 */
	public BigUnsigned decrement() {
		var result = create_copy();
		return result.decrement_assign();
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
		var result = create_copy();
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
		var result = create_copy();
		return result.subtract_assign(subtrahend);
	}

	/**
	 * Returns the index-th block of (n << shift).
	 * @param n the BigUnsigned to shift
	 * @param index the block index, in [0:n.length]
	 * @param shift the shift width, in [0:BITS_PER_BLOCK-1]
	 */
	private uint32 get_shifted_block(BigUnsigned n, int index, uint shift) {
		// calculate the lower part of the resulting block
		// if index or shift is zero, the lower part will always be zero
		uint32 part0 = (index == 0 || shift == 0) ?
				0 : (n.blocks[index - 1] >> (BITS_PER_BLOCK - shift));
		// calcuate the upper part of the resulting block
		// if index is n.length, the upper part will always be zero
		uint32 part1 = (index == n.length) ? 0 : (n.blocks[index] << shift);
		return part0 | part1;
	}

	/**
	 * Sets the value of this to (this * factor).
	 * @param factor the value to multiply with
	 */
	public BigUnsigned multiply_assign(BigUnsigned factor) {
		return assign(multiply(factor));
	}

	/**
	 * Returns a BigUnsigned with the value (this * subtrahend).
	 * @param factor the factor to multiply with
	 */
	public BigUnsigned multiply(BigUnsigned factor) {
		// if one of the factors is zero, return zero as result
		if(is_zero() || factor.is_zero()) {
			return new BigUnsigned();
		}

		// determine the smaller number of this and factor (in terms of blocks)
		bool this_smaller = length < factor.length;
		var a = this_smaller ? this : factor;
		var b = this_smaller ? factor : this;

		var result = new BigUnsigned.with_size(length + factor.length);

		// iterate over all blocks of a
		for(int i = 0; i < a.length; i++) {
			// iterate over all bits in the current block of a
			for(int j = 0; j < BITS_PER_BLOCK; j++) {
				// if the current bit is not set, just continue, there is
				// nothing to add in this step
				if(((a.blocks[i] >> j) & 0x1) == 0) {
					continue;
				}

				int l, k;
				uint32 tmp;
				bool carryIn = false;
				bool carryOut = false;
				// iterate over all blocks of b
				for(k = 0, l = i; k <= b.length; k++, l++) {
					// add the shifted block of b and the current result block
					tmp = result.blocks[l] + get_shifted_block(b, k, j);
					carryOut = (tmp < result.blocks[l]);
					if(carryIn) {
						tmp++;
						carryOut |= (tmp == 0);
					}
					result.blocks[l] = tmp;
					carryIn = carryOut;
				}

				// increase the current block by one as long as a carry bit is
				// set
				for(; carryIn; l++) {
					result.blocks[k]++;
					carryIn = (result.blocks[k] == 0);
				}
			}
		}

		result.remove_leading_zeros();

		return result;
	}

	/**
	 * Sets the value of this to (this / divisor). If the divisor is zero, a
	 * MathError.DIVISION_BY_ZERO will be thrown.
	 * @param divisor the value this is to be divided through
	 */
	public BigUnsigned divide_assign(BigUnsigned divisor) throws MathError {
		var q = new BigUnsigned();
		divide_with_remainder(divisor, q);
		assign(q);
		return this;
	}

	/**
	 * Returns a BigUnsigned with the value (this / divisor). If the divisor is
	 * zero, a MathError.DIVISION_BY_ZERO will be thrown.
	 * @param divisor the value this is to be divided through
	 */
	public BigUnsigned divide(BigUnsigned divisor) throws MathError {
		var q = new BigUnsigned();
		var r = create_copy();
		r.divide_with_remainder(divisor, q);
		return q;
	}

	/**
	 * Sets the value of this to (this mod divisor). If the divisor is zero, a
	 * MathError.DIVISION_BY_ZERO will be thrown.
	 * @param divisor the value this is to be divided through
	 */
	public BigUnsigned mod_assign(BigUnsigned divisor) throws MathError {
		var q = new BigUnsigned();
		divide_with_remainder(divisor, q);
		return this;
	}

	/**
	 * Returns a BigUnsigned with the value (this mod divisor). If the divisor
	 * is zero, a MathError.DIVISION_BY_ZERO will be thrown.
	 * @param divisor the value this is to be divided through
	 */
	public BigUnsigned mod(BigUnsigned divisor) throws MathError {
		var q = new BigUnsigned();
		var r = create_copy();
		r.divide_with_remainder(divisor, q);
		return r;
	}

	/**
	 * Divides this through divisor. The resulting quotient will be stored in
	 * quotient. The remainder will be stored in this. If the divisor is zero, a
	 * MathError.DIVISION_BY_ZERO will be thrown.
	 * @param divisor the value this is to be divided through
	 * @param quotient the BigUnsigned to store the quotient result in
	 */
	public BigUnsigned divide_with_remainder(BigUnsigned divisor,
			BigUnsigned quotient) throws MathError {
		// division by zero is not allowed
		if(divisor.is_zero()) {
			throw new MathError.DIVISION_BY_ZERO("division by zero");
		}
		// if the dividend is zero, quotient and remainder will be zero
		// if the dividend is less than the divisor, the quotient will be zero
		// and the remainder will have the dividend's value
		if(is_zero() || length < divisor.length) {
			quotient.reset_to_zero();
			return this;
		}

		// resize internal blocks by one element if necessary
		int old_length = length;
		length++;
		if(blocks.length < length) {
			blocks.resize(length);
		}
		blocks[old_length] = 0;

		var buffer = new uint32[length];

		// TODO improve quotient initialization
		quotient.length = old_length - divisor.length + 1;
		quotient.blocks = new uint32[quotient.length];

		int i, j, k;
		uint l;
		uint32 tmp;
		bool borrowIn = false;
		bool borrowOut = false;

		// iterate over all possible blocks of the quotient
		i = quotient.length;
		while(i > 0) {
			i--;

			quotient.blocks[i] = 0;
			// iterate over all possible shift widths
			l = BITS_PER_BLOCK;
			while(l > 0) {
				l--;

				// subtract the divisor shifted left by i blocks and l bits
				// from this.
				// store the result in the temporary buffer
				borrowIn = false;
				for(j = 0, k = i; j <= divisor.length; j++, k++) {
					tmp = blocks[k] - get_shifted_block(divisor, j, l);
					borrowOut = (tmp > blocks[k]);
					if(borrowIn) {
						borrowOut |= (tmp == 0);
						tmp--;
					}
					buffer[k] = tmp;
					borrowIn = borrowOut;
				}

				// subtract one from every remaining block as long as there is a
				// borrow bit
				for(; k < old_length && borrowIn; k++) {
					borrowIn = (blocks[k] == 0);
					buffer[k] = blocks[k] - 1;
				}

				// the subtraction's result is not negative, so set the
				// corresponding bit in the quotient and subtract the buffer
				// from this
				if(!borrowIn) {
					quotient.blocks[i] |= (1 << l);
					while(k > i) {
						k--;
						blocks[k] = buffer[k];
					}
				}
			}
		}

		quotient.remove_leading_zeros();
		remove_leading_zeros();

		return this;
	}

	/**
	 * Compares this and val for equality.
	 * @param val the value to which this is to be compared
	 * @return true if this is equal to val, otherwise false
	 */
	public bool equals(BigUnsigned val) {
		return compare_to(val) == 0;
	}

	/**
	 * Compares this to val.
	 * @param val the value to which this is to be compared
	 * @return -1, 0 or 1 if this is less than, equal to or greater than val
	 */
	public int compare_to(BigUnsigned val) {
		// compare lengths of this and val
		if(length < val.length) {
			return -1;
		} else if(length > val.length) {
			return 1;
		}

		// both lengths are equal, so iterate over all blocks
		for(int i = length-1; i >= 0; i--) {
			if(blocks[i] < val.blocks[i]) {
				return -1;
			} else if(blocks[i] > val.blocks[i]) {
				return 1;
			}
		}
		// all blocks are equal, so this == val
		return 0;
	}

	/**
	 * Returns the string representation of this BigUnsigned in the given radix.
	 * @param radix the radix, in [2:36]
	 */
	public string to_radix_string(uint radix) {
		// TODO IMPROVE PERFORMANCE, EXCHANGE ALGORITHM
		if(radix < 2 || radix > 36) {
			// TODO add documentation or throw error
			radix = 10;
		}

		if(is_zero()) {
			return "0";
		}

		var result = new StringBuilder();

		var b = new BigUnsigned.from_uint32(radix);
		var q = new BigUnsigned();
		var tmp = create_copy();
		while(!tmp.is_zero()) {
			try {
				tmp.divide_with_remainder(b, q);
			} catch(MathError e) {
				// ignore, can not happen because the divisor b is not zero
			}
			if(tmp.is_zero()) {
				result.prepend_unichar('0');
			} else {
				var val = tmp.blocks[0];
				if(val < 10) {
					result.prepend_unichar((char)('0' + val));
				} else {
					result.prepend_unichar((char)('A' + val));
				}
			}

			tmp.assign(q);
		}

		return result.str;
	}

	/**
	 * Returns the decimal string representation of this BigUnsigned.
	 */
	public string to_string() {
		return to_radix_string(10);
	}
}

}
