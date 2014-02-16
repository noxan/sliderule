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
 * An arbitrary rational number class.
 */
public class BigRational {
	/**
	 * The numerator.
	 */
	private BigInteger num;

	/**
	 * The denominator. It is always a number greater than zero.
	 */
	private BigInteger den;

	/**
	 * Creates a new BigRational with the value zero.
	 */
	public BigRational() {
		this.from_int32(0);
	}

	/**
	 * Creates a new BigRational with the given value.
	 * @param val the given value
	 */
	public BigRational.from_int32(int32 val) {
		num = new BigInteger.from_int32(val);
		den = new BigInteger.from_int32(1);
	}

	/**
	 * Creates a new BigRational with the given value.
	 * @param val the given value
	 */
	public BigRational.from_int64(int64 val) {
		num = new BigInteger.from_int64(val);
		den = new BigInteger.from_int32(1);
	}


	/**
	 * Creates a copy of the given BigRational.
	 * @param val the BigRational to copy
	 */
	public BigRational.copy(BigRational val) {
		num = val.num.create_copy();
		den = val.den.create_copy();
	}

	/**
	 * Returns a copy of this BigRational.
	 */
	public BigRational create_copy() {
		return new BigRational.copy(this);
	}


	/**
	 * Returns whether this BigRational is negative.
	 */
	public bool is_negative() {
		return num.is_negative();
	}

	/**
	 * Returns whether this BigRational is zero.
	 */
	public bool is_zero() {
		return num.is_zero();
	}

	/**
	 * Returns whether this BigRational is positive.
	 */
	public bool is_positive() {
		return num.is_positive();
	}

	/**
	 * Returns the sign of this BigRational.
	 * @return -1, 0 or 1 if this is negative, zero or positive
	 */
	public int signum() {
		return num.signum();
	}


	/**
	 * Compares this and val for equality.
	 * @param val the value to which this is to be compared
	 * @return true if this is equal to val, otherwise false
	 */
	public bool equals(BigRational val) {
		return num.equals(val.num) && den.equals(val.den);
	}

	public string to_radix_string(uint radix)
		requires(radix >= 2 && radix <= 36) {
		return num.to_radix_string(radix) + "/" + den.to_radix_string(radix);
	}

	public string to_string() {
		return to_radix_string(10);
	}
}

}
