cb() { # cd up to a certain name
    pushd `pwd | sed -r "s/($1).*/\\1/"`
}

find_file_w_extension() {
    find . -type f -name $1
}

scala_files() {
    find_file_w_extension "*.scala"
}

groovy_files() {
    find_file_w_extension "*.groovy"
}

java_files() {
    find_file_w_extension "*.java"
}

grepit() {
    xargs ack-grep --color $1
}

find_whatev() {
    if [ $3 ]
    then
        $1 | grep -v $3 | grepit $2
    else
        $1 | grepit $2
    fi
}

find_whatev_i() {
    if [ $3 ]
    then
        $1 | grep -v $3 | grepit -i $2
    else
        $1 | grepit -i $2
    fi
}

fs() { # find scala
	find_whatev scala_files $1 $2
}

fsi() { # find scala, case-insensitive
	find_whatev_i scala_files $1 $2
}

fa() { # find all
	find . -type f | grepit $1
}

fsf() { # find scala file
	scala_files | grep -i $1
}

fgr () { # find groovy :(
	find_whatev groovy_files $1 $2
}

fgri () { # find groovy :( case-insensitive
	find_whatev_i groovy_files $1 $2
}

fj() { # find java 
	find_whatev java_files $1 $2
}

fji() { # find java 
	find_whatev_i java_files $1 $2
}

fjar() { # find jar in ivy cache
	find ~/.ivy2/cache/ -iname "$@.jar"
}

fclass() { # find class in ivy cache
	find ~/.ivy2/cache/ -name "*.jar" -exec grep -il --color "$@" {} \;
}

fni() { # find any file
	find . -type f -iname "$1"
}

killgrep() {
	ps aux | grep $@ | awk '{print $2}' | xargs kill -9
	echo "$2 should be killed, check the list below"
	echo `ps -ef | grep $2`
}

manifest() {
	unzip -p "$@" META-INF/MANIFEST.MF
}
