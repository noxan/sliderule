using Math;

public static int main(string[] args) {
	stdout.printf("Hello this is Sliderule\n");
	uint64 max = ~0;
	var a = new Math.BigUnsigned.from_blocks({1,2,3,4});
	var b = new Math.BigUnsigned.from_blocks({1,2,3,3});
	var c = a.subtract(b);
	stdout.printf(a.to_binary_string() + "\n");
	stdout.printf(b.to_binary_string() + "\n");
	stdout.printf(c.to_binary_string() + "\n");
	return 0;
}
