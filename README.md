# dist_build
Scripts to build essential packages

# sequences
```
build kernel with existing compiler to get kernel headers
build binutils to get linker
build bootstrap gcc
build bootstrap libc with bootstrap gcc
build final gcc with bootstrap gcc
build final libc with final gcc

build all other packages with final gcc
```
