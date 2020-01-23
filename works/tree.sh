dir()
{
	pwd
	for f in *; do 
		if [ -f $f ]; then
			cmd="$1 $f"; 
			echo $cmd; 
# 			$cmd;
		fi
		if [ -d $f ]; then
			cd $f; dir "$1"; cd ..
		fi
	done
}

#dir "dos2unix"
dir "unix2dos"
