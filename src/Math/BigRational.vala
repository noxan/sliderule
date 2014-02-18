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
	 * Creates a new BigRational with the given numerator and denominator.
	 * @param num the numerator
	 * @param den the denominator
	 */
	public BigRational.from_fraction(BigInteger num, BigInteger den)
		requires(!den.is_zero()) {
		// TODO copy?
		this.num = num;
		this.den = den;
		normalize();
	}

	/**
	 * Creates a new BigRational, which value will be the value of the given
	 * string representation in the specified radix. The default radix is 10.
	 * @param val the value's decimal string representation (in fraction format)
	 * @param radix the radix, in [2:36]
	 */
	public BigRational.from_string(string val, uint radix=10) {
		this();
		assign_from_string(val, radix);
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
	 * Normalizes this BigRational. This means, that the numerator and the
	 * denominator will be divided by their greatest common divisor. If the
	 * numerator is zero, then the denominator will be set to one. If the
	 * denominator is negative, the numerator and the denominator will be
	 * negated.
	 */
	private void normalize() {
		if(num.is_zero()) {
			// TODO replace assign_from_string
			den.assign_from_string("1");
		} else {
			var gcd = num.gcd(den);
			try {
				num.divide_assign(gcd);
				den.divide_assign(gcd);
			} catch(MathError err) {
				// ignore, cannot happen because gcd is not zero
			}
		}
		if(den.is_negative()) {
			den.negate_assign();
			num.negate_assign();
		}
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
	 * Assigns the given value to this BigRational.
	 * @param val the value to assign
	 */
	public BigRational assign(BigRational val) {
		num = val.num.create_copy();
		den = val.den.create_copy();
		return this;
	}

	/**
	 * Assigns the value of the given string representation in the specified
	 * radix to this. The default radix is 10.
	 * @param val the value's string representation (in fraction format)
	 * @param radix the radix, in [2:36]
	 */
	public BigRational assign_from_string(string val, uint radix=10)
		requires(radix >= 2 && radix <= 36) {
		if(val.contains("/")) {
			var split = val.split("/");
			num.assign_from_string(split[0], radix);
			den.assign_from_string(split[1], radix);
			normalize();
		} else {
			num.assign_from_string(val, radix);
			den.assign_from_string("1", 2);
		}
		return this;
	}

	/**
	 * Sets this to the value (this + 1).
	 */
	public BigRational increment_assign() {
		num.add_assign(den);
		normalize();
		return this;
	}

	/**
	 * Returns a BigRational with the value (this + 1).
	 */
	public BigRational increment() {
		var result = create_copy();
		return result.increment_assign();
	}

	/**
	 * Sets this to the value (this - 1).
	 */
	public BigRational decrement_assign() {
		num.subtract_assign(den);
		normalize();
		return this;
	}

	/**
	 * Returns a BigRational with the value (this - 1).
	 */
	public BigRational decrement() {
		var result = create_copy();
		return result.decrement_assign();
	}

	/**
	 * Sets this to the value (this + addend).
	 * @param addend the value to add
	 */
	public BigRational add_assign(BigRational addend) {
		num.multiply_assign(addend.den);
		num.add_assign(addend.num.multiply(den));
		den.multiply_assign(addend.den);
		normalize();
		return this;
	}

	/**
	 * Returns a BigRational with the value (this + addend).
	 * @param addend the value to add
	 */
	public BigRational add(BigRational addend) {
		var result = create_copy();
		return result.add_assign(addend);
	}

	/**
	 * Sets this to the value (this - subtrahend).
	 * @param subtrahend the value to subtract
	 */
	public BigRational subtract_assign(BigRational subtrahend) {
		num.multiply_assign(subtrahend.den);
		num.subtract_assign(subtrahend.num.multiply(den));
		den.multiply_assign(subtrahend.den);
		normalize();
		return this;
	}

	/**
	 * Returns a BigRational with the value (this - subtrahend).
	 * @param subtrahend the value to subtract
	 */
	public BigRational subtract(BigRational subtrahend) {
		var result = create_copy();
		return result.subtract_assign(subtrahend);
	}

	/**
	 * Sets the value of this to (this * factor).
	 * @param factor the value to multiply with
	 */
	public BigRational multiply_assign(BigRational factor) {
		num.multiply_assign(factor.num);
		den.multiply_assign(factor.den);
		normalize();
		return this;
	}

	/**
	 * Returns a BigRational with the value (this * subtrahend).
	 * @param factor the factor to multiply with
	 */
	public BigRational multiply(BigRational factor) {
		var result = create_copy();
		return result.multiply_assign(factor);
	}

	/**
	 * Sets the value of this to (this / divisor). If the divisor is zero, a
	 * MathError.DIVISION_BY_ZERO will be thrown.
	 * @param divisor the value this is to be divided through
	 */
	public BigRational divide_assign(BigRational divisor) throws MathError {
		if(divisor.is_zero()) {
			throw new MathError.DIVISION_BY_ZERO("division by zero");
		}
		num.multiply_assign(divisor.den);
		den.multiply_assign(divisor.num);
		normalize();
		return this;
	}

	/**
	 * Returns a BigRational with the value (this / divisor). If the divisor is
	 * zero, a MathError.DIVISION_BY_ZERO will be thrown.
	 * @param divisor the value this is to be divided through
	 */
	public BigRational divide(BigRational divisor) throws MathError {
		var result = create_copy();
		return result.divide_assign(divisor);
	}

	/**
	 * Sets the value of this to -this;
	 */
	public BigRational negate_assign() {
		num.negate_assign();
		return this;
	}

	/**
	 * Returns a BigRational with the value -this;
	 */
	public BigRational negate() {
		var result = create_copy();
		return result.negate_assign();
	}

	/**
	 * Compares this and val for equality.
	 * @param val the value to which this is to be compared
	 * @return true if this is equal to val, otherwise false
	 */
	public bool equals(BigRational val) {
		return num.equals(val.num) && den.equals(val.den);
	}

	/**
	 * Returns the string representation of this BigRational in the given radix
	 * in decimal fraction format.
	 * TODO proper for decimal fraction format
	 */
	}

	/**
	 * Returns the string representation of this BigRational in the given radix
	 * in fraction format. The default radix is 10.
	 * @param radix the radix, in [2:36]
	 */
	public string to_string(uint radix=10)
		requires(radix >= 2 && radix <= 36) {
		return num.to_string(radix) + "/" + den.to_string(radix);
	}
}

}
