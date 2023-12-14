+++
title = "Bash Shortcuts"
date = "2016-08-02"
tags = ["tooling","bash"]
+++

The bash shell has a very rich set of convenient shortcuts. This ability to
edit the command line is provided by the **GNU Readline** library.

Readline keybindings are taken from the **Emacs** text editor.

In these notes:
- `C-a`: stands for press `Ctrl` plus the `a` key
- `A-a`: stands for press `Alt` plus the `a` key

## Emacs mode

### Moving around

| Keys      | Action                                   | 
| --------- | ---------------------------------------- |
| `C-a`     | Go to the beginning of the line (begin)  |
| `C-e`     | Go to the end of the line (end)          |
| `C-b`     | Back one character (left arrow)          |
| `C-f`     | Forward one character (right arrow)      |
| `A-b`     | Backward one word                        |
| `A-f`     | Forward one word                         |
| `C-xx`    | Toggle between two positions             |

### Editing

| Keys      | Action                                            |
| --------- | ------------------------------------------------- |
| `C-l`     | Clear the screen, similar to the `clear` command  |
| `A-Del`   | Cut the word before the cursor (excluded)         |
| `A-d`     | Cut the word after the cursor (included)          |
| `C-h`     | Delete character before the cursor                |
| `C-d`     | Delete character under the cursor                 |
| `C-w`     | Cut the word before the cursor                    |
| `C-k`     | Cut the line after the cursor (included)          |
| `C-u`     | Cut the line before the cursor (excluded)         |
| `C-y`     | Paste the last cutted thing being cut (yank)      | 
| `A-t`     | Swap current word with previous                   |
| `C-t`     | Swap the character under the cursor with the previous one |
| `A-c`     | Capitalize the character under the cursor and move to end of word |
| `A-u`     | Makes uppercase from cursor to end of word        |
| `A-l`     | Makes lowercase from cursor to end of word        |
| `C-_`     | Undo                                              |
| `A-r`     | Cancel the changes and restore the original line  |
| `Tab`     | Completion for file/directory names               |

### History

| Keys      | Action                                            |
| --------- | ------------------------------------------------- |
| `C-r`     | Recall a previous command. Keep searching backward for matches by pressing `C-r` again |
| `C-p`     | Previous command in history (up arrow)            |
| `C-n`     | Next command (down arrow)                         |
| `C-s`     | Go back to the most recent command                |
| `C-o`     | Execute the command found via `C-r` or `C-s`      |
| `C-g`     | Escape from history searching mode                |
| `!!`      | Repeat the last command                           |
| `!abc`    | Run the last command starting with *abc*          |
| `!abc:p`  | Print the last command starting with *abc*        |
| `!$`      | Last argument of previous command                 |
| `!$:p`    | Print the last argument of previous command       |
| `!\*`     | All arguments or the previous command             |
| `!\*:p`   | Print all arguments or the previous command       |
| `^ab^cde`  | Run previous command, replacing *ab* with *cde*  |

### Process control

| Keys      | Action                                            |
| --------- | ------------------------------------------------- |
| `C-c`     | Interrupt/kill the current foreground running program (SIGINT)  |
| `C-z`     | Stop/sleep the current running foreground program |
| `C-d`     | EOF, close the terminal                           |
| `C-s`     | Stops output to the screen                        |
| `C-q`     | Allows output to the screen                       |


## Vi mode

To use Vi mode in Bash and any other tool that uses GNU Readline, you need only
to put the following line in your `.inputrc` file:

```
    set editing-mode vi
```

If you only want to use this mode just in Bash, an alternative is to put the
following line in your `.bashrc` file.

```
    set -o vi
```

## References

- Readline [documentation](https://cnswww.cns.cwru.edu/php/chet/readline/readline.html)
- Readline on [Wikipedia](https://en.wikipedia.org/wiki/GNU_Readline)
