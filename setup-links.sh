#!/bin/bash

srcdir=$1

if [ -z $srcdir ]; then
	echo "you must supply the path of your environment directory"
	exit 666
fi

bashdir=${HOME}/.bashrc.d

if [ ! -d $bashdir ]; then
	mkdir $bashdir
	ln -s "$srcdir/bashrc" "${HOME}/.bashrc"
	ln -s "$srcdir/bash_aliases" $bashdir
	ln -s "$srcdir/bash_completion" $bashdir
	ln -s "$srcdir/bash_functions" $bashdir
	ln -s "$srcdir/bash_ps1" $bashdir
fi



