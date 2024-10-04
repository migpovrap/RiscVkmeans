# K-Means Clustering in RISC-V Assembly using Ripes

## Description
This project implements the K-Means clustering algorithm in RISC-V assembly language. The implementation is designed to run on the Ripes simulator, which provides a visual and interactive environment for RISC-V assembly programming.

## Installation
1. **Install Ripes**:
   - Download and install Ripes from the [official website](https://github.com/mortbopet/Ripes).
   - Follow the installation instructions for your operating system.

2. **Clone the Repository**:
   ```sh
   git clone https://github.com/migpovrap/RiscVkmeans.git
   cd RiscVkmeans
3. **Use Ripes**
    - Open the .s assembly file on ripes
    - Define a 32x32 LED Matrix with a 25 Led size
    - Comment the array that you want to use or define a new one
        # Input A - Linha Inclinada
            n_points:    .word 9
            points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7, 8,8

        # Input B - Cruz
            n_points:    .word 5
            points:      .word 4,2, 5,1, 5,2, 5,3, 6,2

        # Input C
            n_points:    .word 23
            points:      .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

        # Input D
            n_points:    .word 30
            points:      .word 16,1, 17,2, 18,6, 20,3, 21,1, 17,4, 21,7, 16,4, 21,6, 19,6, 4,24, 6,24, 8,23, 6,26, 6,26, 6,23, 8,25, 7,26, 7,20, 4,21, 4,10, 2,10, 3,11, 2,12, 4,13, 4,9, 4,9, 3,8, 0,10, 4,10

        # Input E
            n_points:    .word 30
            points:      .word 16,1, 17,2, 18,6, 20,3, 21,1, 17,4, 21,7, 16,4, 21,6, 19,6, 4,24, 6,24, 8,23, 6,26, 5,26, 6,23, 8,25, 7,26, 7,20, 4,21, 4,10, 2,10, 3,11, 2,12, 4,13, 4,9, 4,8, 3,8, 0,10, 4,11
# Authors
- [Miguel Raposo](https://github.com/migpovrap)
- [António Hernâni Correia](https://github.com/hernanicorreia)
- [Pedro Nazareth](https://github.com/PNazareth)

## Disclaimer
    All teacher material is propretie of João Pedro Faria Mendonça Barreto @ IST
