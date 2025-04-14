# Vim

## Copy-paste side-by-side Or vertically

Say, you have content like below
```bash
1
22
333333
44
555

a
b
c
d
e
```
And you want it to arrange like below
```bash
1               a
22              b
333333          c
44              d
555             e
```

Then follow these steps
- Put cursor on a
- Ctrl+v => Go into visual mode
- Using arrow keys, select till e
- press y => yank => vim will show messages as ```block of 5 lines yanked```
- Put cursor on end of line one
- Go in insert mode
- Give enough spaces so cursor column > length of longest row, which is 3rd (333333) in above case
- Ctrl+v => Go into visual mode again
- Press p => paste

