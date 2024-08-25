# tmux => Terminal Emulator

## Default prefix
```bash
Ctrl + b
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

## Exist from session
```bash
prefix + d
```
## Attach to session
```bash
tmux a -t s2
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
Ctrl+ b [ => enables scroll back history
Ctrl + s => then type search string. Hit enter
         => press n/shift n to search next/backward
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

## List panes
```bash
tmux list-panes
```


