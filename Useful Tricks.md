* [1]
To start a screen process with a script (automatically), we can use the bash command
```
screen -d -m command
```

like 
```
screen -d -m ls
```

But note that: if the command finishes before you re-attach, the screen will go away. But if the command keeps running (like I use it to start a PHP service), then we can re-attach it.

reference: http://serverfault.com/questions/104668/create-screen-and-run-command-without-attaching
