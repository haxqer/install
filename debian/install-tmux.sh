#!/bin/bash


apt update -y && \
    apt install -y \
        tmux xclip curl && \
curl -o ~/.tmux.conf https://raw.githubusercontent.com/gpakosz/.tmux/master/.tmux.conf -L && \
curl -o ~/.tmux.conf.local https://raw.githubusercontent.com/gpakosz/.tmux/master/.tmux.conf.local -L
