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

internal int sign_of_int32(int32 val) {
	return val > 0 ? 1 : (val == 0 ? 0 : -1);
}

internal int sign_of_uint32(uint32 val) {
	return val == 0 ? 0 : 1;
}

internal int sign_of_int64(int64 val) {
	return val > 0 ? 1 : (val == 0 ? 0 : -1);
}

internal int sign_of_uint64(uint64 val) {
	return val == 0 ? 0 : 1;
}

/**
 * This method converts the given character to its numeric (not ascii!)
 * value.
 * @param c the character to convert, in [0-9a-zA-Z]
 */
internal uint32 char_to_int(char c) {
	// TODO proper error handling
	if(c >= '0' && c <= '9') {
		return c - '0';
	} else if(c >= 'a' && c <= 'z') {
		return c - 'a' + 10;
	} else if(c >= 'A' && c <= 'Z') {
		return c - 'A' + 10;
	} else {
		// TODO throw error
		return 0;
	}
}

}
