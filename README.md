# tic-tac-toe-minimax-assembly-2015
Tic Tac Toe with Minimax Algorithm implemented in Assembly I've made back in 2015!

There is no need to explain what Tic Tac Toe is, but what is interesting in the repo is the implementation of the minimax algorithm


### How to run:
NOTE: Need to run using DosBox and TASM
1. First, clone the repository:
`git clone https://github.com/adamcohenhillel/tic-tac-toe-minimax-assembly-2015`

2. Then, open DosBox and run the following commands:
```
mount c: c:\
c:
cd C:\location\to\tic-tac-toe-minimax-assembly-2015
C:\tasm\bin\tasm.exe /zi xomain.asm
C:\tasm\bin\tlink.exe /v xomain.obj
```



### Screenshots:
![Alt text](/screenshots/image1.png?raw=true "Screenshot 1")

### Minimax explained:
Minimax is an algorithm that is, in simple words (by [Wikipedia](https://en.wikipedia.org/wiki/Minimax)), trying to "minimizing the possible loss for a worst case (maximum loss) scenario". It does that by conducting a depth-first search to explore the complete game tree (all different outcomes from the current state of the board) and then proceeds down to the leaf node of the tree, then backtracks the tree using recursive calls to calculate "score" to each move. The player then choose the step with the highest score. In the next turn, the tree is being calculated again with a different inital state of the board.


![alt text](https://upload.wikimedia.org/wikipedia/commons/6/6f/Minimax.svg)


TODO: Explain implementation
TODO: Documenting code
