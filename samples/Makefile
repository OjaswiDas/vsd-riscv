.PHONY: hello-spike clean

hello-spike:
	@echo 'int main(){volatile int x=42; return x;}' > hello.c
	riscv64-unknown-elf-gcc -o hello.elf hello.c
	@echo "Running on spike+pk..."
	spike pk ./hello.elf || true
	@echo "Done."

clean:
	rm -f hello.c hello.elf
