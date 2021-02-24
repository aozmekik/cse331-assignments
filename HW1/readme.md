
Min-Set-Cover problem is used to find the least number of sets that can cover the
union of all given sets.

Write an assembly program that takes different sets Si and then returns the indices
of the sets so that the minimum number of sets are chosen. And the union of
these sets is equal to the union of all sets as explained in the above definition.

Actually optimal solution for that problem has no known polynomial time solution.
It is an NP-complete problem. Therefore, you will implement a sub-optimal greedy
heuristic solution for the problem as shown below:


**Rules:**

1. All project details will be announced at next PS (October 23 ). So attend the
    PS for your own good!
2. Your code must not have any bound on number of given sets.
3. Assembly that cannot be executed can at most get 20pts.
4. You have to use MARS MIPS simulator tool of Missouri State University:
    [http://courses.missouristate.edu/kenvollmar/mars/](http://courses.missouristate.edu/kenvollmar/mars/)
5. No late submissions even if 1 minute.

```
BONUS:
```
```
Taking all sets from a text file instead of MIPS console is a bonus with extra
25pts.
```
# In order to read a file you have to use syscall code 13 to open file and code

```
14 to read file. Details can be found here:
```
```
http://courses.missouristate.edu/kenvollmar/mars/help/syscallhelp.html
```
```
Honor code : It is not a group project. Do not take any code from Internet. Any
cheating means at least - 100 for both sides. Do not share your codes and design
to any one in any circumstance. Do not forget, this is named as HONOR code.
Be honest and uncorrupt not to win but because it is RIGHT!
```

