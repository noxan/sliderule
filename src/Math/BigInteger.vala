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

}

}
