# Friendly unikernel

This is a slack bot unikernel that sends a randomly chosen message from a list of happy messages to a slack channel. It does so recurrently every 5 seconds. :)

## How to build and run the unikernel

Hopefully, the following should do:

Set-up a switch and install MirageOs in it; e.g.:
```
opam switch create . --empty
opam install mirage
```

Build the unikernel, for simplicity e.g. with the UNIX target:
```
mirage configure -t unix
make
```

Run the unikernel that's now inside `dist/`. If it was built with the UNIX target:
```
dist/friendly-unikernel --token=<slack bot token> --channel=<channel ID>
```