# ASCII Frame (x86-64 Assembly)

This is an educational project written in x86-64 assembly using NASM.
The program draws an ASCII frame with a custom border symbol and
prints text in the center.

# Instruction:
- Input width and height
- Custom border symbol
- Centered text

## Build and Run:
- nasm -f elf64 frame.asm -o frame.o
- ld frame.o -o frame
- ./frame
