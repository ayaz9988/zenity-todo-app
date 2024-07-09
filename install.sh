#!/usr/bin/env bash
$(mkdir -p $HOME/.local/share/applications/)
$(mkdir -p $HOME/.local/bin/)
$(mkdir -p $HOME/.icons/)
$(echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.profile)
$(cp MyTodo.desktop $HOME/.local/share/applications/)
$(cp todo.sh $HOME/.local/bin/)
$(cp to-do-list.png $HOME/.icons/)
