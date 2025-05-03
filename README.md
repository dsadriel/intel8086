# 🖥️ Power Quality Analyzer (Assembly 8086)

This project was developed for the course **Computer Architecture and Organization I** (INF01024 - UFRGS). The program, written in Assembly 8086, simulates an electric power quality analyzer by processing an input file with second-by-second voltage readings and generating a quality report.

> See [assignmentDefinition.md](assignmentDefinition.md) for more information. 

## ⚙️ Features

- Reads command-line arguments (from PSP):
  - `-i <file>`: Input file (`.in`)
  - `-o <file>`: Output file (`.out`)
  - `-v <value>`: Nominal voltage value (127 or 220)
- Validates voltage measurements:
  - Zero voltage (0)
  - Good quality voltage: between 117–137 (for 127V) or 210–230 (for 220V)
- Generates a report including:
  - Total number of seconds analyzed
  - Time with good quality voltage
  - Time with no voltage
- Outputs the report to both screen and output file (`.out`)

## 🛠️ Requirements

- DOSBox
- MASM (Microsoft Macro Assembler)

## ▶️ How to Run

1. Compile the program using MASM:
   ```
   masm analyzer.asm;
   link analyzer.obj;
   ```

2. Run it with desired arguments:
   ```
   analyzer.exe -i a.in -o result.out -v 127
   ```

## 📌 Notes

- Argument order does not affect execution.
- If the `-v` parameter is not provided, the default value is **127**.
- The program prints error messages and halts if arguments are missing or invalid.