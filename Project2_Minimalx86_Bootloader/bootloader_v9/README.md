## Command + Arguments  

### Task: 
Add argument support to your commands, so that your shell can process input

```
name devjit
```

### Learnings:

- How to split user input into command + arguments
- How to store the argument for later use
- How to match command strings only on the first token

### Steps:

- Read the user input into input_buf (already working).
- After Enter is pressed, split it into:
- cmd_buf: first word (the command)
- arg_buf: rest of the line (argument)
- Then compare cmd_buf with name, help, clear, etc.
- Use arg_buf for extended behavior.
