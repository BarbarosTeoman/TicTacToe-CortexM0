# Tic-Tac-Toe on Cortex M0

This repository contains the source code for a Tic-Tac-Toe game developed by Alperen Bölükbaş, Ömer Bahadır Gökmen, and myself. The project is implemented in Cortex M0 assembly language, designed for a microcontroller and interfaced with an LCD display to represent the 3x3 game grid.

**Note:** To make the LCD peripheral work, you will need to extend Keil with the provided DLL files. For this, you need to copy the two .dll files LCDDLL.dll and SDL2.dll into C:\Keil_v5\ARM\BIN folder (or to the BIN folder under whereever you installed Keil if you didn’t choose the default location) and then restart Keil. You can then open the LCD window from the Peripherals menu after starting the debugger by selecting the “Start/Stop Debugging Session” from the Debug menu. Do not forget to build your code by selecting “Build Target” option from the Project menu before starting the debugger; otherwise, you may get an error or your changes to the code may not take effect.

## Project Description

Our implementation of Tic-Tac-Toe includes several key aspects:

- Efficient use of RAM to track game states
- An effective grid drawing method
- Dynamic cell movement
- Gray and white painting system
- A reset function
- Distinct mechanics for drawing the X or O
- A system to detect win conditions

## Implementation Details

### RAM

We have used RAM to track the game states. The first byte holds the current cell, the second byte indicates the next move (X or O), and the remaining bytes store the current state of each cell.

### Map Drawing

The map drawing functionality moves to the top left corner of the LCD and paints the screen white. It draws a 3x3 grid for the game.

### Cell Movement

The cell movement is governed by the global r4 and r6 registers, corresponding to row and column values respectively. When a button is pressed, an interrupt occurs, resulting in an update to these registers and the current cell's state in RAM.

### Gray Painting and White Painting

These functions take care of painting the cells gray or white depending on the movement. A check is incorporated after gray painting to re-draw the symbol if the cell previously held one.

### Reset Function

A reset function is implemented, which is invoked on pressing button B. This redraws the map, resets the RAM, and moves the control back to the first cell.

### Drawing X or O

When button A is pressed, a check is performed to see if the cell is empty. If it is, the cell is painted with an "X" or an "O" depending on the next move value in RAM.

### Winning Condition Detection

After each move, a check is performed to see if a winning condition has been met. It checks for a horizontal, vertical, or diagonal sequence of three similar symbols.

## Team Members

This project was jointly developed by Alperen Bölükbaş, Ömer Bahadır Gökmen, and myself. We all equally contributed to all parts of the project.

## Discussion and Future Improvements

While our Tic-Tac-Toe implementation works well, we have identified two areas for potential improvement:

- **Optimized painting system:** Currently, when moving within the same cell, symbols are unnecessarily repainted and redrawn. A preliminary check can be added to identify if the transition is to a different cell to avoid these steps, enhancing performance.
  
- **Efficient win detection mechanism:** Currently, all possible win conditions are checked after each move. An improvement could involve checking only the row, column, and diagonals associated with the most recent move, thereby reducing the number of checks and improving the performance of the game.
