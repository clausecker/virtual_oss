#
# Copyright (c) 2012-2023 Hans Petter Selasky. All rights reserved.
# Copyright (c) 2024 The FreeBSD Foundation
#
# Portions of this software were developed by Christos Margiolis
# <christos@FreeBSD.org> under sponsorship from the FreeBSD Foundation.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

.PATH: . backend_oss backend_bt backend_null backend_sndio
.PATH: contrib/libsamplerate

PROG=		virtual_oss
MAN=		${PROG}.8
PTHREAD_LIBS?=	-lpthread
PREFIX?=	/usr/local
LOCALBASE?=	/usr/local
BINDIR=		${PREFIX}/sbin
MANDIR=		${PREFIX}/share/man/man
LIBDIR=		${PREFIX}/lib

SRCS=	\
	virtual_audio_delay.c \
	virtual_compressor.c \
	virtual_ctl.c \
	virtual_eq.c \
	virtual_format.c \
	virtual_main.c \
	virtual_mul.c \
	virtual_oss.c \
	virtual_ring.c \
	backend_oss.c \
	backend_null.c

# libsamplerate
SRCS+=	samplerate.c \
	src_linear.c \
	src_sinc.c \
	src_zoh.c
CFLAGS+=	-DENABLE_SINC_BEST_CONVERTER \
		-DENABLE_SINC_MEDIUM_CONVERTER \
		-DENABLE_SINC_FAST_CONVERTER
CPPFLAGS+=	-Icontrib/libsamplerate

.if defined(HAVE_SNDSTAT)
CFLAGS+=	-DHAVE_SNDSTAT
LDFLAGS+= 	-lnv
.endif

.if defined(HAVE_BLUETOOTH)
SRCS+=		backend_bt.c avdtp.c sbc_encode.c
CFLAGS+=	-DHAVE_BLUETOOTH
LDFLAGS+=	-lbluetooth -lsdp
.endif

.if defined(HAVE_BLUETOOTH) && defined(HAVE_BLUETOOTH_SPEAKER)
SRCS+=		bt_speaker.c
CFLAGS+= 	-DHAVE_BLUETOOTH_SPEAKER
LINKS+= 	${BINDIR}/virtual_oss ${BINDIR}/virtual_bt_speaker
MAN+= 		virtual_bt_speaker.8
.endif

.if defined(HAVE_SNDIO)
SRCS+=		backend_sndio.c
CFLAGS+= 	-DHAVE_SNDIO
LDFLAGS+=	-lsndio
.endif

.if defined(HAVE_EQUALIZER)
SRCS+=		virtual_equalizer.c
CFLAGS+= 	-DHAVE_EQUALIZER
LDFLAGS+= 	-lfftw3
LINKS+= 	${BINDIR}/virtual_oss ${BINDIR}/virtual_equalizer
MAN+= 		virtual_equalizer.8
.endif

.if defined(HAVE_COMMAND)
SRCS+=		virtual_command.c
CFLAGS+= 	-DHAVE_COMMAND
LINKS+= 	${BINDIR}/virtual_oss ${BINDIR}/virtual_oss_cmd
MAN+= 		virtual_oss_cmd.8
.endif

.if defined(HAVE_FFMPEG)
CFLAGS+=	-DHAVE_FFMPEG
LDFLAGS+= 	-lavdevice -lavutil -lavcodec -lavresample -lavformat
.endif

.if defined(HAVE_HTTPD)
SRCS+=		virtual_httpd.c
CFLAGS+=	-DHAVE_HTTPD
.endif

.if defined(HAVE_DEBUG)
DEBUG_FLAGS=	-g -O0
.endif

CFLAGS+= 	-I${LOCALBASE}/include
LDFLAGS+= 	-L${LIBDIR} ${PTHREAD_LIBS} -lm -lcuse

.include <bsd.prog.mk>

help:
	@echo "Targets are: all, install, clean, help"
