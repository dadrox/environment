#!/bin/bash

srcdir=$1

if [ -z $srcdir ]; then
	echo "you must supply the path of your environment directory"
	exit 666
fi

bashdir="${HOME}/.bashrc.d"

if [ ! -d $bashdir ]; then
	ln -s "$srcdir/bashrc" "${HOME}/.bashrc"
	ln -s "$srcdir/bashrc.d" $bashdir
fi



