# tmux => Terminal Emulator

## Default prefix
```bash
Ctrl + b
```
## Tmux config file content
```bash
curl --silent --output ~/.tmux.conf https://raw.githubusercontent.com/simplyatul/TechNotes/refs/heads/main/tmux.conf
```

## Create new session
```bash
tmux new -s s1 -n w1
s1 => Session name
w1 => Window name
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
capture-pane -S -; save-buffer t0.log + enter
# - means start at the beginning of history
# saves the complete pane history in file t0.log

# Or
capture-pane -S -; save-buffer '#P'.log + enter
# Or
capture-pane -S -; save-buffer '#{pane_index}'.log + enter
# #P => pane index (pane_index)

# Or
capture-pane -S -; save-buffer '#W-#P-#S'.log
```

## Clear scroll-back history
```bash
Prefix + clear-history

# Or 

tmux clear-history

# above command clears pane history in which it has ran

```

## List Sessions
```bash
tmux ls

s1: 1 windows (created Sun Aug 25 17:11:03 2024) (attached)
s2: 1 windows (created Sun Aug 25 17:12:19 2024) (attached)
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
## Split window in horizontal panes
```bash
prefix + "
```

## Zoom pane to full window
```bash
prefix + z
```

## Close a pane
```bash
prefix + x
```

## List panes
```bash
tmux list-panes
```

## Sample script to create session, windows and panes
```bash
wget -4 -O - https://raw.githubusercontent.com/simplyatul/vagrant-vms/refs/heads/main/cilium-devbox/shared-with-vm/tmux-setup.sh > tmux-setup.sh
bash tmux-setup.sh
```

# References
1. https://man7.org/linux/man-pages/man1/tmux.1.html