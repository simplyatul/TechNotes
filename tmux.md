# tmux => Terminal Emulator

## Default prefix
```bash
Ctrl + b
```
## Tmux config file content
```bash
curl --silent --output ~/.tmux.conf https://raw.githubusercontent.com/simplyatul/TechNotes/refs/heads/main/tmux.conf
```

## Copy to tmux buffer using mouse
```
Select the text using mouse.
Keep left button pressed
And hit Enter

Now to paste use
Prefix + ]
```
## Copy text to system clipboard

```
Press Shift Key
Select the text using mouse.
Right Click + Copy Or Ctrl + Insert
```

## Copy scroll-back of pane into the file
```bash
Prefix + :
capture-pane -S - + return # - means start at the beginning of history
Prefix + :
save-buffer filename.txt + return
```

## List Sessions
```bash
tmux ls

s1: 1 windows (created Sun Aug 25 17:11:03 2024) (attached)
s2: 1 windows (created Sun Aug 25 17:12:19 2024) (attached)
```

## Create new session
```bash
tmux new -s s1 -n w1
s1 => Session name
w1 => Window name
```

## Exit from session
```bash
prefix + d
```
## Attach to session
```bash
tmux a -t s2
a => attach
-t => target-session
s2 => Session name
```
## List all sessions + windows
```bash
prefix + w
```
## Create new window
```bash
prefix + c
```

## Search in scroll back history
```bash
prefix + [ => enables scroll back history
Ctrl + s + / => then type search string. Hit enter
         => press n/Shift n to search next/backward
```

## Rename window
```bash
prefix + :rename-window <new name>
```
Or

```bash
prefix + ,
```

## Split window in vertical panes
```bash
prefix + %
```
## Close a pane
```bash
prefix + x
```


## List panes
```bash
tmux list-panes
```


# References
1. https://man7.org/linux/man-pages/man1/tmux.1.html