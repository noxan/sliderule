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
 * An arbitrary signed integer class.
 */
public class BigInteger {
	/**
	 * This BigInteger's sign, can be -1, 0 or 1 if the value is negative, zero
	 * or positive.
	 */
	private int sign;

	/**
	 * This BigInteger's magnitude.
	 */
	private BigUnsigned mag;

	/**
	 * Creates a new BigInteger with the value zero.
	 */
	public BigInteger() {
		sign = 0;
		mag = new BigUnsigned();
	}

	/**
	 * Creates a new BigInteger with the given value.
	 * @param val the given value
	 */
	public BigInteger.from_int32(int32 val) {
		sign = sign_of_int32(val);
		// TODO fix absolute value hack
		this.mag = new BigUnsigned.from_uint64(((int64)val).abs());
	}

	/**
	 * Creates a new BigInteger with the given value.
	 * @param val the given value
	 */
	public BigInteger.from_int64(int64 val) {
		sign = sign_of_int64(val);
		this.mag = new BigUnsigned.from_uint64(val.abs());
	}

	public BigInteger.from_big_unsigned(int sign, BigUnsigned mag)
		requires(sign >= -1 && sign <= 1) {
		this.sign = sign;
		// TODO copy of big unsigned?
		this.mag = mag;
	}


	/**
	 * Creates a copy of the given BigInteger.
	 * @param val the BigInteger to copy
	 */
	public BigInteger.copy(BigInteger val) {
		sign = val.sign;
		this.mag = val.mag.create_copy();
	}

	/**
	 * Returns a copy of this BigInteger.
	 */
	public BigInteger create_copy() {
		return new BigInteger.copy(this);
	}

	/**
	 * Returns whether this BigInteger is negative.
	 */
	public bool is_negative() {
		return sign == -1;
	}

	/**
	 * Returns whether this BigInteger is zero.
	 */
	public bool is_zero() {
		return sign == 0;
	}

	/**
	 * Returns whether this BigInteger is positive.
	 */
	public bool is_positive() {
		return sign == 1;
	}

	/**
	 * Returns the sign of this BigInteger.
	 * @return -1, 0 or 1 if this is negative, zero or positive
	 */
	public int signum() {
		return sign;
	}

	/**
	 * Resets this to zero. This means that the length will be set to zero and
	 * all blocks will be zeroed.
	 */
	internal void reset_to_zero() {
		sign = 0;
		mag.reset_to_zero();
	}

	/**
	 * Assigns the given value to this BigInteger.
	 * @param val the value to assign
	 */
	public BigInteger assign(BigInteger val) {
		sign = val.sign;
		this.mag = new BigUnsigned.copy(val.mag);
		return this;
	}


	/**
	 * Sets this BigInteger to the value (this + addend).
	 * @param addend the value to add
	 */
	public BigInteger add_assign(BigInteger addend) {
		// this is zero, set this to the addend
		if(sign == 0) {
			assign(addend);
		// the addend is zero, just return this
		} else if(addend.sign == 0) {
			return this;
		// both numbers have equal sign, so their magnitudes add up
		} else if(sign == addend.sign) {
			mag.add_assign(addend.mag);
		} else {
			var cmp = mag.compare_to(addend.mag);
			try {
				if(cmp == 0) {
					reset_to_zero();
				} else if(cmp > 0) {
					mag.subtract_assign(addend.mag);
				} else {
					// TODO try to avoid copy
					var cpy = create_copy();
					assign(addend);
					mag.subtract_assign(cpy.mag);
				}
			} catch(MathError e) {
				// ignore, cannot happen because in every subtraction the
				// minuend is greater then the subtrahend
			}
		}
		return this;
	}

	/**
	 * Returns a BigInteger with the value (this + addend).
	 * @param addend the value to add
	 */
	public BigInteger add(BigInteger addend) {
		var result = create_copy();
		return result.add_assign(addend);
	}

	/**
	 * Sets this BigInteger to the value (this - subtrahend).
	 * @param subtrahend the value to subtract
	 */
	public BigInteger subtract_assign(BigInteger subtrahend) {
		// this is zero, so set this to -subtrahend
		if(sign == 0) {
			mag = new BigUnsigned.copy(subtrahend.mag);
			sign = -subtrahend.sign;
		// nothing to subtract, just return this
		} else if(subtrahend.sign == 0) {
			return this;
		// both numbers have different signs, so this will keep its sign and
		// both magnitudes just add up
		} else if(sign != subtrahend.sign) {
			mag.add_assign(subtrahend.mag);
		// both numbers have equal signs
		} else {
			// compare both magnitudes
			var cmp = mag.compare_to(subtrahend.mag);
			try {
				// both magnitudes are equal, set this to zero
				if(cmp == 0) {
					reset_to_zero();
				// this magnitude is greater, subtract the subtrahend's magnitude
				// from this
				} else if(cmp > 0) {
					mag.subtract_assign(subtrahend.mag);
				// the subtrahend's magnitude is greater, take the opposite sign of
				// the subtrahend and subtract this from the subtrahend
				} else {
					var cpy = create_copy();
					assign(subtrahend);
					mag.subtract_assign(cpy.mag);
					sign = -sign;
				}
			} catch(MathError e) {
				// ignore, cannot happen because in every subtraction the
				// minuend is greater then the subtrahend
			}
		}
		return this;
	}

	/**
	 * Returns a BigInteger with the value (this - subtrahend).
	 * @param subtrahend the value to subtract
	 */
	public BigInteger subtract(BigInteger subtrahend) {
		var result = create_copy();
		return result.subtract_assign(subtrahend);
	}


	/**
	 * Compares this and val for equality.
	 * @param val the value to which this is to be compared
	 * @return true if this is equal to val, otherwise false
	 */
	public bool equals(BigInteger val) {
		return compare_to(val) == 0;
	}

	/**
	 * Compares this to val.
	 * @param val the value to which this is to be compared
	 * @return -1, 0 or 1 if this is less than, equal to or greater than val
	 */
	public int compare_to(BigInteger val) {
		// this is definitly less than val
		if(sign < val.sign) {
			return -1;
		// this is definitly greater than val
		} else if(sign > val.sign) {
			return 1;
		// both sign are equal, compare depending on the sign
		} else {
			// if sign == 0, 0 will be returned
			// if sign == 1, this.mag.compare_to(val.mag )will be returned
			// if sign == -1, -this.mag.compare_to(val.mag) will be returned
			return sign * this.mag.compare_to(val.mag);
		}
	}

	/**
	 * Returns the string representation of this BigInteger in the given radix.
	 * @param radix the radix, in [2:36]
	 */
	public string to_radix_string(uint radix) {
		var vstr = mag.to_radix_string(radix);
		if(is_negative()) {
			return "-" + vstr;
		} else {
			return vstr;
		}
	}

	/**
	 * Returns the decimal string representation of this BigInteger.
	 */
	public string to_string() {
		return to_radix_string(10);
	}
}

}
