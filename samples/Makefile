hello-spike:
	echo 'int main(){volatile int x=42; return x;}' > hello.c
	riscv64-unknown-elf-gcc -o hello.elf hello.c
	spike pk hello.elf || true
