#!/bin/bash
cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# Libretro Retroarch build
	if [[ "$var" == "retroarch" ]]; then
	 cd $cur_wd
	  if [ ! -d "retroarch/" ]; then
		git clone https://github.com/libretro/retroarch.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the retroarch libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/retroarch-patch* retroarch/.
	  fi

	 cd retroarch/
	 
	 retroarch_patches=$(find *.patch)
	 
	 if [[ ! -z "$retroarch_patches" ]]; then
	  for patching in retroarch-patch*
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
	  ./configure --disable-opengl --disable-opengl1 --disable-qt --disable-wayland --disable-x11 --enable-alsa --enable-egl --enable-kms --enable-odroidgo2 --enable-opengles --enable-opengles3 --enable-udev --enable-freetype --disable-vulkan --disable-vulkan_display --enable-networking --enable-ozone --disable-caca --enable-opengles3_1 --enable-opengles3_2 --enable-wifi
	  make -j$(nproc)

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest retroarch.  Stopping here."
		exit 1
	  fi

	  strip retroarch

	  if [ ! -d "../retroarch$bitness/" ]; then
		mkdir -v ../retroarch$bitness
	  fi

	  cp retroarch ../retroarch$bitness/.

	  if [[ "$bitness" == "32" ]]; then
		mv ../retroarch$bitness/retroarch ../retroarch$bitness/retroarch32
	  fi

	  echo " "
	  if [[ "$bitness" == "32" ]]; then
		echo "retroarch32 has been created and has been placed in the rk3326_core_builds/retroarch$bitness subfolder"
	  else
		echo "retroarch has been created and has been placed in the rk3326_core_builds/retroarch$bitness subfolder"
	  fi

	  cd gfx/video_filters
	  ./configure
	  make -j$(nproc)
	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the video filters for retroarch.  Stopping here."
		exit 1
	  fi
	  mkdir -p ../../../retroarch$bitness/filters/video
	  cp *.so ../../../retroarch$bitness/filters/video
	  cp *.filt ../../../retroarch$bitness/filters/video
	  echo " "
	  echo "Video filters have been built and copied to the rk3326_core_builds/retroarch$bitness/filters/video subfolder"
	fi