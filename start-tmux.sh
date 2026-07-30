#!/usr/bin/env bash

# 1. Start a new detached tmux session
tmux new-session -s my_session -d

# 2. Split the window vertically (side-by-side) to create 2 base panes
tmux split-window -h

# 3. Create the remaining 8 vertical splits across both sides
tmux select-pane -t 0
tmux split-window -h
tmux split-window -h
tmux split-window -h
tmux select-pane -t 4
tmux split-window -h
tmux split-window -h
tmux split-window -h

# 4. Horizontally split (stack) all panes to reach 5 tall in each of the 2 columns
for i in {0..9}; do
  tmux select-pane -t $i
  tmux split-window -v
done

# 5. Attach to the completed session
tmux attach-session -t my_session
