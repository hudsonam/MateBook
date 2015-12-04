MB_DIR=$(abspath .)

MB_VER=2141

OS := $(shell uname)
SHELL := $(shell which bash)

ifeq ($(OS), Darwin)
	LIB_EXT=dylib
	GUI=$(MB_DIR)/gui/MateBook.app/Contents/MacOS/MateBook
	NJOBS=$(shell sysctl hw.ncpu | awk '{print $$2}')
else
	LIB_EXT=so
	GUI=$(MB_DIR)/gui/MateBook
	NJOBS=$(shell cat /proc/cpuinfo | grep processor | wc -l)
endif
TRACKER=$(MB_DIR)/tracker/build.gcc/tracker

LAME_VER=3.99.5
YASM_VER=1.2.0
FFMPEG_VER=2.1
CMAKE_VER=2.8.12.1
OPENCV_VER=2.4.11# 2.4.7 has a bug with MD5 on linux
BOOST_VER=1_54_0
ZLIB_VER=1.2.8
QT_VER=4.8.6
PHONON_VER=4.7.1

LIB_DIR=${MB_DIR}/usr/lib
BIN_DIR=${MB_DIR}/usr/bin
INCLUDE_DIR=${MB_DIR}/usr/include
SHARE_DIR=${MB_DIR}/usr/share

CMAKE_BIN = $(BIN_DIR)/cmake

FFMPEG_LIBS = \
$(LIB_DIR)/libavcodec.$(LIB_EXT) \
$(LIB_DIR)/libavdevice.$(LIB_EXT) \
$(LIB_DIR)/libavfilter.$(LIB_EXT) \
$(LIB_DIR)/libavformat.$(LIB_EXT) \
$(LIB_DIR)/libavutil.$(LIB_EXT) \
$(LIB_DIR)/libswresample.$(LIB_EXT) \
$(LIB_DIR)/libswscale.$(LIB_EXT)

BOOST_LIBS = \
$(LIB_DIR)/libboost_filesystem.$(LIB_EXT) \
$(LIB_DIR)/libboost_system.$(LIB_EXT)

LAME_LIBS = $(LIB_DIR)/libmp3lame.$(LIB_EXT)

OPENCV_LIBS = \
$(LIB_DIR)/libopencv_calib3d.$(LIB_EXT) \
$(LIB_DIR)/libopencv_contrib.$(LIB_EXT) \
$(LIB_DIR)/libopencv_core.$(LIB_EXT) \
$(LIB_DIR)/libopencv_features2d.$(LIB_EXT) \
$(LIB_DIR)/libopencv_flann.$(LIB_EXT) \
$(LIB_DIR)/libopencv_gpu.$(LIB_EXT) \
$(LIB_DIR)/libopencv_highgui.$(LIB_EXT) \
$(LIB_DIR)/libopencv_imgproc.$(LIB_EXT) \
$(LIB_DIR)/libopencv_legacy.$(LIB_EXT) \
$(LIB_DIR)/libopencv_ml.$(LIB_EXT) \
$(LIB_DIR)/libopencv_nonfree.$(LIB_EXT) \
$(LIB_DIR)/libopencv_objdetect.$(LIB_EXT) \
$(LIB_DIR)/libopencv_ocl.$(LIB_EXT) \
$(LIB_DIR)/libopencv_photo.$(LIB_EXT) \
$(LIB_DIR)/libopencv_stitching.$(LIB_EXT) \
$(LIB_DIR)/libopencv_superres.$(LIB_EXT) \
$(LIB_DIR)/libopencv_video.$(LIB_EXT) \
$(LIB_DIR)/libopencv_videostab.$(LIB_EXT) \
$(LIB_DIR)/libopencv_ts.a

YASM_LIBS = $(LIB_DIR)/libyasm.a

ZLIB = $(LIB_DIR)/libz.$(LIB_EXT)

ifeq ($(OS), Linux)
  QT_LIBS = \
  $(LIB_DIR)/libQtCore.$(LIB_EXT) \
  $(LIB_DIR)/libQtGui.$(LIB_EXT) \
  $(LIB_DIR)/libQtOpenGL.$(LIB_EXT)

  PHONON_LIBS = $(LIB_DIR)64/libphonon.$(LIB_EXT)
endif

DEPS = $(CMAKE_BIN) $(FFMPEG_LIBS) $(BOOST_LIBS) $(LAME_LIBS) $(OPENCV_LIBS) $(YASM_LIBS) $(ZLIB)

all : gui tracker
gui : $(GUI)
tracker : $(TRACKER)
install : installgui installtracker
.PHONY : all gui tracker install

$(CMAKE_BIN) : ${MB_DIR}/deps/cmake-${CMAKE_VER}.tar.gz
${MB_DIR}/deps/cmake-${CMAKE_VER}.tar.gz :
	make cleancmake
	curl -L http://www.cmake.org/files/v2.8/cmake-${CMAKE_VER}.tar.gz > ${MB_DIR}/deps/cmake-${CMAKE_VER}.tar.gz
	cd ${MB_DIR}/deps && tar xvzf cmake-${CMAKE_VER}.tar.gz
	cd ${MB_DIR}/deps/cmake-${CMAKE_VER} && ./bootstrap --parallel=${NJOBS} --prefix=${MB_DIR}/usr/
	cd ${MB_DIR}/deps/cmake-${CMAKE_VER} && make -j ${NJOBS} && make install

$(FFMPEG_LIBS) : ${MB_DIR}/deps/ffmpeg-${FFMPEG_VER}.tar.gz
${MB_DIR}/deps/ffmpeg-${FFMPEG_VER}.tar.gz : $(YASM_LIBS) $(LAME_LIBS)
	make cleanffmpeg
	curl -L http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VER}.tar.gz > ${MB_DIR}/deps/ffmpeg-${FFMPEG_VER}.tar.gz
	cd ${MB_DIR}/deps && tar xvzf ffmpeg-${FFMPEG_VER}.tar.gz
	cd ${MB_DIR}/deps/ffmpeg-${FFMPEG_VER} && PATH=${MB_DIR}/usr/bin:${PATH} ./configure \
	--prefix=${MB_DIR}/usr/ \
	--extra-cflags="-I${MB_DIR}/usr/include" \
	--extra-ldflags="-L${MB_DIR}/usr/lib" \
	--enable-libmp3lame --enable-gpl --enable-pthreads --arch=x86_64 \
	--enable-ssse3 --disable-debug --enable-shared # --disable-static  --cc=clang
	cd ${MB_DIR}/deps/ffmpeg-${FFMPEG_VER} && PATH=${MB_DIR}/usr/bin:${PATH} make -j ${NJOBS} && make install

$(BOOST_LIBS) : ${MB_DIR}/deps/boost_${BOOST_VER}.tar.gz
${MB_DIR}/deps/boost_${BOOST_VER}.tar.gz :
	make cleanboost
	curl -L http://sourceforge.net/projects/boost/files/boost/1.54.0/boost_${BOOST_VER}.tar.gz/download > ${MB_DIR}/deps/boost_${BOOST_VER}.tar.gz
	cd ${MB_DIR}/deps && tar xvzf boost_${BOOST_VER}.tar.gz
	cd ${MB_DIR}/deps/boost_${BOOST_VER} && ./bootstrap.sh --prefix=${MB_DIR}/usr/ --with-libraries=filesystem,system
	cd ${MB_DIR}/deps/boost_${BOOST_VER} && ./b2 --stagedir=${MB_DIR}/usr/
	ln -s ${MB_DIR}/deps/boost_${BOOST_VER}/boost ${MB_DIR}/usr/include/boost

$(LAME_LIBS) : ${MB_DIR}/deps/lame-${LAME_VER}.tar.gz
${MB_DIR}/deps/lame-${LAME_VER}.tar.gz :
	make cleanlame
	curl -L http://sourceforge.net/projects/lame/files/lame/3.99/lame-${LAME_VER}.tar.gz/download > ${MB_DIR}/deps/lame-${LAME_VER}.tar.gz
	cd ${MB_DIR}/deps && tar xvzf lame-${LAME_VER}.tar.gz
	cd ${MB_DIR}/deps/lame-${LAME_VER} && ./configure --prefix=${MB_DIR}/usr/
	cd ${MB_DIR}/deps/lame-${LAME_VER} && make -j ${NJOBS} && make install

$(OPENCV_LIBS) : ${MB_DIR}/deps/opencv-${OPENCV_VER}.zip
${MB_DIR}/deps/opencv-${OPENCV_VER}.zip : $(CMAKE_BIN) $(ZLIB)
	make cleanopencv
	curl -L https://github.com/Itseez/opencv/archive/${OPENCV_VER}.zip > ${MB_DIR}/deps/opencv-${OPENCV_VER}.zip
	cd ${MB_DIR}/deps && unzip opencv-${OPENCV_VER}.zip
	# edit release/CMakeCache.txt, set VERBOSE=ON/TRUE
	sed s+\$${MB_DIR}+${MB_DIR}+ < patch_opencv.diff | patch ${MB_DIR}/deps/opencv-${OPENCV_VER}/modules/highgui/CMakeLists.txt
	mkdir ${MB_DIR}/deps/opencv-${OPENCV_VER}/release
	cd ${MB_DIR}/deps/opencv-${OPENCV_VER}/release && \
	PKG_CONFIG_PATH=${MB_DIR}/usr/lib/pkgconfig \
	CMAKE_INCLUDE_PATH=${MB_DIR}/usr/include \
	CMAKE_LIBRARY_PATH=${MB_DIR}/usr/lib \
	${MB_DIR}/usr/bin/cmake \
	-D WITH_TIFF=OFF -D WITH_JASPER=OFF -D WITH_OPENEXR=OFF \
	-D ZLIB_LIBRARY=${MB_DIR}/usr/lib/libz.so.${ZLIB_VER} \
	-D CMAKE_INSTALL_PREFIX=${MB_DIR}/usr/ ..  #  -D BUILD_SHARED_LIBS=OFF -G "Xcode"
	cd ${MB_DIR}/deps/opencv-${OPENCV_VER}/release && make -j ${NJOBS} && make install

$(YASM_LIBS) : ${MB_DIR}/deps/yasm-${YASM_VER}.tar.gz
${MB_DIR}/deps/yasm-${YASM_VER}.tar.gz :
	make cleanyasm
	curl -L http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VER}.tar.gz > ${MB_DIR}/deps/yasm-${YASM_VER}.tar.gz
	cd ${MB_DIR}/deps && tar xvzf yasm-${YASM_VER}.tar.gz
	cd ${MB_DIR}/deps/yasm-${YASM_VER} && ./configure --prefix=${MB_DIR}/usr/
	cd ${MB_DIR}/deps/yasm-${YASM_VER} && make -j ${NJOBS} && make install

$(ZLIB) : ${MB_DIR}/deps/zlib-${ZLIB_VER}.tar.gz
${MB_DIR}/deps/zlib-${ZLIB_VER}.tar.gz :
	make cleanzlib
	curl -L http://zlib.net/zlib-${ZLIB_VER}.tar.gz > ${MB_DIR}/deps/zlib-${ZLIB_VER}.tar.gz
	cd ${MB_DIR}/deps && tar xvzf zlib-${ZLIB_VER}.tar.gz
	cd ${MB_DIR}/deps/zlib-${ZLIB_VER} && ./configure --prefix=${MB_DIR}/usr
	cd ${MB_DIR}/deps/zlib-${ZLIB_VER} && make -j ${NJOBS} && make install

ifeq ($(OS), Linux)
$(QT_LIBS) : ${MB_DIR}/deps/qt-${QT_VER}.tar.gz
${MB_DIR}/deps/qt-${QT_VER}.tar.gz : $(CMAKE_BIN)
	make cleanqt
	curl -L http://download.qt-project.org/official_releases/qt/4.8/${QT_VER}/qt-everywhere-opensource-src-${QT_VER}.tar.gz > ${MB_DIR}/deps/qt-${QT_VER}.tar.gz
	cd ${MB_DIR}/deps && tar xvzf qt-${QT_VER}.tar.gz
	cd ${MB_DIR}/deps/qt-everywhere-opensource-src-${QT_VER} && ./configure --prefix=${MB_DIR}/usr/ --opensource <<<yes
	cd ${MB_DIR}/deps/qt-everywhere-opensource-src-${QT_VER} && make -j ${NJOBS} && make install

$(PHONON_LIBS) : ${MB_DIR}/deps/phonon-${PHONON_VER}.tar.xz
${MB_DIR}/deps/phonon-${PHONON_VER}.tar.xz : $(CMAKE_BIN) ${QT_LIBS}
	make cleanphonon
	curl -L http://download.kde.org/stable/phonon/4.7.1/phonon-${PHONON_VER}.tar.xz > ${MB_DIR}/deps/phonon-${PHONON_VER}.tar.xz
	cd ${MB_DIR}/deps && tar xvf phonon-${PHONON_VER}.tar.xz
	mkdir ${MB_DIR}/deps/phonon-${PHONON_VER}/release
	cd ${MB_DIR}/deps/phonon-${PHONON_VER}/release && \
	PKG_CONFIG_PATH=${MB_DIR}/usr/lib/pkgconfig \
	CMAKE_INCLUDE_PATH=${MB_DIR}/usr/include \
	CMAKE_LIBRARY_PATH=${MB_DIR}/usr/lib \
	${MB_DIR}/usr/bin/cmake \
	-D CMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,${MB_DIR}/usr/lib/ \
	-D CMAKE_INSTALL_PREFIX=${MB_DIR}/usr/ \
	-D PHONON_QT_IMPORTS_INSTALL_DIR=${MB_DIR}/deps/qt-everywhere-opensource-src-${QT_VER} \
	-D PHONON_QT_MKSPECS_INSTALL_DIR=${MB_DIR}/deps/qt-everywhere-opensource-src-${QT_VER} \
	-D PHONON_QT_PLUGIN_INSTALL_DIR=${MB_DIR}/deps/qt-everywhere-opensource-src-${QT_VER} \
	-D QT_QMAKE_EXECUTABLE=${BIN_DIR}/qmake ..
	cd ${MB_DIR}/deps/phonon-${PHONON_VER}/release && make -j ${NJOBS} && make install
endif

ifeq ($(OS), Darwin)
$(GUI) : $(DEPS) $(MB_DIR)/gui/source/*.cpp $(MB_DIR)/gui/source/*.hpp
	cd gui && MB_DIR=${MB_DIR} QT_VER=${QT_VER} BIN_DIR=${BIN_DIR} ./update.sh $(OS) && make -j ${NJOBS}
	
installgui :
	rsync -r ${MB_DIR}/gui/MateBook.app ${BIN_DIR}
	LIB_DIR=${LIB_DIR} ./bundle_libs_in_app.sh ${BIN_DIR}/MateBook.app

else
$(GUI) : $(DEPS) $(QT_LIBS) $(PHONON_LIBS) $(MB_DIR)/gui/source/*.cpp $(MB_DIR)/gui/source/*.hpp
	cd gui && MB_DIR=${MB_DIR} QT_VER=${QT_VER} BIN_DIR=${BIN_DIR} ./update.sh $(OS) && make -j ${NJOBS}
	
installgui :
	cp $(MB_DIR)/gui/MateBook $(BIN_DIR)
	#printf [Paths]\\nPlugins='.' >> $(BIN_DIR)/qt.conf
  #${BIN_DIR}/qmake -set QT_INSTALL_PLUGINS ${MB_DIR}/usr
endif
.PHONY : installgui

$(TRACKER) : $(DEPS) $(MB_DIR)/tracker/source/*.cpp $(MB_DIR)/tracker/source/*.hpp
	cd $(MB_DIR)/tracker/build.gcc && MB_DIR=${MB_DIR} make -j ${NJOBS}

ifeq ($(OS), Darwin)
installtracker : 
	mkdir -p $(BIN_DIR)/MateBook.app/Contents/MacOS
	cp $(MB_DIR)/tracker/build.gcc/tracker $(BIN_DIR)/MateBook.app/Contents/MacOS
	cp $(MB_DIR)/tracker/source/*.sh $(BIN_DIR)/MateBook.app/Contents/MacOS
	LIB_DIR=${LIB_DIR} ./bundle_libs_in_app.sh $(BIN_DIR)/MateBook.app

else
installtracker : 
	mkdir -p $(BIN_DIR)/tracker/${MB_VER}
	cp $(MB_DIR)/tracker/build.gcc/tracker $(BIN_DIR)/tracker/${MB_VER}
	cp $(MB_DIR)/tracker/source/*.sh $(BIN_DIR)/tracker/${MB_VER}
	chmod a+x $(BIN_DIR)/tracker/${MB_VER}/*
endif
.PHONY : installtracker

cleanzlib :
	rm -rf $(MB_DIR)/deps/zlib-*
	rm -rf $(LIB_DIR)/libz*
	rm -rf $(INCLUDE_DIR)/zlib.h
cleanyasm :
	rm -rf $(MB_DIR)/deps/yasm-*
	rm -rf $(LIB_DIR)/libyasm*
	rm -rf $(BIN_DIR)/*asm
	rm -rf $(INCLUDE_DIR)/libyasm*
cleanopencv :
	rm -rf $(MB_DIR)/deps/opencv-*
	rm -rf $(LIB_DIR)/libopencv*
	rm -rf $(BIN_DIR)/opencv*
	rm -rf $(INCLUDE_DIR)/opencv*
	rm -rf $(SHARE_DIR)/OpenCV
cleanlame :
	rm -rf $(MB_DIR)/deps/lame-*
	rm -rf $(LIB_DIR)/libmp3lame*
	rm -rf $(BIN_DIR)/lame
	rm -rf $(INCLUDE_DIR)/lame
cleanboost :
	rm -rf $(MB_DIR)/deps/boost_*
	rm -rf $(LIB_DIR)/libboost*
	rm -rf $(INCLUDE_DIR)/boost
cleanffmpeg :
	rm -rf $(MB_DIR)/deps/ffmpeg-*
	rm -rf $(LIB_DIR)/libav*
	rm -rf $(LIB_DIR)/libsw*
	rm -rf $(BIN_DIR)/ff*
	rm -rf $(INCLUDE_DIR)/libav*
	rm -rf $(INCLUDE_DIR)/libsw*
	rm -rf $(SHARE_DIR)/ffmpeg
cleancmake :
	rm -rf $(MB_DIR)/deps/cmake-*
	rm -rf $(BIN_DIR)/c*
	rm -rf $(SHARE_DIR)/cmake*

ifeq ($(OS), Linux)
cleanqt :
	rm -rf $(MB_DIR)/deps/qt-*
	rm -rf $(LIB_DIR)/libQt*
	rm -rf $(INCLUDE_DIR)/Qt*
	rm -rf $(LIB_DIR)/plugins
	rm -rf $(LIB_DIR)/mkspecs
	rm -rf $(LIB_DIR)/examples
	rm -rf $(LIB_DIR)/imports
	rm -rf $(LIB_DIR)/demos
	rm -rf $(BIN_DIR)/q*
cleanphonon :
	rm -rf $(MB_DIR)/deps/phonon-*
	rm -rf $(LIB_DIR)/libphonon*
	rm -rf $(INCLUDE_DIR)/KDE
	rm -rf $(INCLUDE_DIR)/phonon
	rm -rf $(SHARE_DIR)/phonon
cleandeps : cleancmake cleanffmpeg cleanboost cleanlame cleanopencv cleanyasm cleanzlib cleanqt
else
cleandeps : cleancmake cleanffmpeg cleanboost cleanlame cleanopencv cleanyasm cleanzlib
endif

cleangui : cleangui2
	rm -rf $(MB_DIR)/gui/*.o
	rm -rf $(MB_DIR)/gui/moc_*
ifeq ($(OS), Darwin)
cleangui2 :
	rm -rf $(MB_DIR)/gui/MateBook.app/Contents/MacOS/MateBook
	rm -rf $(MB_DIR)/gui/MateBook.app/Contents/Frameworks
	rm -rf $(BIN_DIR)/MateBook.app/Contents/MacOS/MateBook
	rm -rf $(BIN_DIR)/MateBook.app/Contents/Frameworks
else
cleangui2 :
	rm -rf $(MB_DIR)/gui/MateBook
endif

cleantracker : cleantracker2
	rm -rf $(MB_DIR)/tracker/build.gcc/tracker
ifeq ($(OS), Darwin)
cleantracker2 :
	rm -rf $(MB_DIR)/gui/MateBook.app/Contents/MacOS/tracker
	rm -rf $(MB_DIR)/gui/MateBook.app/Contents/MacOS/*.sh
	rm -rf $(BIN_DIR)/MateBook.app/Contents/MacOS/tracker
	rm -rf $(BIN_DIR)/MateBook.app/Contents/MacOS/*.sh
else
cleantracker2 :
	rm -rf $(BIN_DIR)/tracker/${MB_VER}
endif

clean : cleandeps cleangui cleantracker
	rm -rf $(MB_DIR)/gui/MateBook.app
	rm -rf $(MB_DIR)/usr
	rm -rf $(MB_DIR)/deps/*
.PHONY : cleancmake cleanffmpeg cleanboost cleanlame cleanopencv cleanyasm cleanzlib cleanqt cleandeps cleangui cleantracker cleanall
