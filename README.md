# vsd-riscv


---

# Getting Started with RISC-V on GitHub Codespaces

Follow the steps below to set up and run programs in your own Codespace.

## Step 1. Open the Repository

Go to:
[https://github.com/vsdip/vsd-riscv](https://github.com/vsdip/vsd-riscv)

## Step 2. Create a Codespace

1. Log in with your GitHub account.
2. Click the green **Code** button.
3. Select **Open with Codespaces** → **New codespace**.
4. Wait while the environment builds. (First time may take 10–15 minutes.)

## Step 3. Verify the Setup

In the terminal that opens, type:

```
riscv64-unknown-elf-gcc --version
spike --version
iverilog -V
```

You should see version information for each tool.

## Step 4. Run Your First Program

1. Go to the `samples` folder.
2. Compile the program:

   ```
   riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c
   ```
3. Run it with Spike:

   ```
   spike pk sum1ton.o
   ```

Expected output:

```
Sum from 1 to 9 is 45
```

## Step 5. Next Steps

* You can edit and run your own C programs.
* You can also try Verilog programs using `iverilog`.

---

