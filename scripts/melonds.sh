#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3326 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro melonds build
	if [[ "$var" == "melonds" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "melonds/" ]; then
		git clone https://github.com/libretro/melonds.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/melonds-patch* melonds/.
	  fi

	 cd melonds/
	 
	 melonds_patches=$(find *.patch)
	 
	 if [[ ! -z "$melonds_patches" ]]; then
	  for patching in melonds-patch*
	  do
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching" 
	  done
	 fi

	  make clean
	  make -j$(($(nproc) - 1))

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest lr-melonds core.  Stopping here."
		exit 1
	  fi

	  strip melonds_libretro.so

	  if [ ! -d "../cores64/" ]; then
		mkdir -v ../cores64
	  fi

	  cp melonds_libretro.so ../cores64/.

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/melonds_libretro.so.commit

	  echo " "
	  echo "melonds_libretro.so has been created and has been placed in the rk3326_core_builds/cores64 subfolder"
	fi
