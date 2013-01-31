#
#   goahead-macosx-default.mk -- Makefile to build Embedthis GoAhead for macosx
#

PRODUCT         ?= goahead
VERSION         ?= 3.1.0
BUILD_NUMBER    ?= 1
PROFILE         ?= default
ARCH            ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS              ?= macosx
CC              ?= /usr/bin/clang
LD              ?= /usr/bin/ld
CONFIG          ?= $(OS)-$(ARCH)-$(PROFILE)

BIT_CFG_PREFIX  ?= /etc/goahead
BIT_PRD_PREFIX  ?= /usr/lib/goahead
BIT_VER_PREFIX  ?= $(BIT_PRD_PREFIX)/3.1.0
BIT_BIN_PREFIX  ?= $(BIT_VER_PREFIX)/bin
BIT_INC_PREFIX  ?= $(BIT_VER_PREFIX)/inc
BIT_LOG_PREFIX  ?= /var/log/goahead
BIT_SPL_PREFIX  ?= /var/spool/goahead
BIT_SRC_PREFIX  ?= /usr/src/goahead-3.1.0
BIT_WEB_PREFIX  ?= /var/www/goahead-default
BIT_UBIN_PREFIX ?= /usr/local/bin
BIT_MAN_PREFIX  ?= /usr/local/share/man/man1

CFLAGS          += -w
DFLAGS          += $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS)))
IFLAGS          += -I$(CONFIG)/inc
LDFLAGS         += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS        += -L$(CONFIG)/bin
LIBS            += -lpthread -lm -ldl

DEBUG           ?= debug
CFLAGS-debug    := -g
DFLAGS-debug    := -DBIT_DEBUG
LDFLAGS-debug   := -g
DFLAGS-release  := 
CFLAGS-release  := -O2
LDFLAGS-release := 
CFLAGS          += $(CFLAGS-$(DEBUG))
DFLAGS          += $(DFLAGS-$(DEBUG))
LDFLAGS         += $(LDFLAGS-$(DEBUG))

unexport CDPATH

all compile: prep \
        $(CONFIG)/bin/libest.dylib \
        $(CONFIG)/bin/ca.crt \
        $(CONFIG)/bin/libgo.dylib \
        $(CONFIG)/bin/goahead \
        $(CONFIG)/bin/goahead-test

.PHONY: prep

prep:
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(BIT_PRD_PREFIX)" = "" ] ; then echo WARNING: BIT_PRD_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/goahead-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/goahead-$(OS)-$(PROFILE)-bit.h >/dev/null ; then\
		echo cp projects/goahead-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h  ; \
		cp projects/goahead-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
	@echo $(DFLAGS) $(CFLAGS) >projects/.flags

clean:
	rm -rf $(CONFIG)/bin/libest.dylib
	rm -rf $(CONFIG)/bin/ca.crt
	rm -rf $(CONFIG)/bin/libgo.dylib
	rm -rf $(CONFIG)/bin/goahead
	rm -rf $(CONFIG)/bin/goahead-test
	rm -rf $(CONFIG)/obj/estLib.o
	rm -rf $(CONFIG)/obj/action.o
	rm -rf $(CONFIG)/obj/alloc.o
	rm -rf $(CONFIG)/obj/auth.o
	rm -rf $(CONFIG)/obj/cgi.o
	rm -rf $(CONFIG)/obj/crypt.o
	rm -rf $(CONFIG)/obj/file.o
	rm -rf $(CONFIG)/obj/fs.o
	rm -rf $(CONFIG)/obj/http.o
	rm -rf $(CONFIG)/obj/js.o
	rm -rf $(CONFIG)/obj/jst.o
	rm -rf $(CONFIG)/obj/options.o
	rm -rf $(CONFIG)/obj/osdep.o
	rm -rf $(CONFIG)/obj/rom-documents.o
	rm -rf $(CONFIG)/obj/route.o
	rm -rf $(CONFIG)/obj/runtime.o
	rm -rf $(CONFIG)/obj/socket.o
	rm -rf $(CONFIG)/obj/upload.o
	rm -rf $(CONFIG)/obj/est.o
	rm -rf $(CONFIG)/obj/matrixssl.o
	rm -rf $(CONFIG)/obj/openssl.o
	rm -rf $(CONFIG)/obj/goahead.o
	rm -rf $(CONFIG)/obj/test.o
	rm -rf $(CONFIG)/obj/gopass.o
	rm -rf $(CONFIG)/obj/webcomp.o
	rm -rf $(CONFIG)/obj/cgitest.o

clobber: clean
	rm -fr ./$(CONFIG)

$(CONFIG)/inc/est.h: 
	rm -fr $(CONFIG)/inc/est.h
	cp -r src/deps/est/est.h $(CONFIG)/inc/est.h

$(CONFIG)/inc/bitos.h: 
	rm -fr $(CONFIG)/inc/bitos.h
	cp -r src/bitos.h $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/estLib.o: \
        src/deps/est/estLib.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/est.h \
        $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/estLib.o -arch x86_64 $(DFLAGS) -I$(CONFIG)/inc src/deps/est/estLib.c

$(CONFIG)/bin/libest.dylib:  \
        $(CONFIG)/inc/est.h \
        $(CONFIG)/obj/estLib.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libest.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 3.1.0 -current_version 3.1.0 $(LIBPATHS) -install_name @rpath/libest.dylib $(CONFIG)/obj/estLib.o $(LIBS)

$(CONFIG)/bin/ca.crt: src/deps/est/ca.crt
	rm -fr $(CONFIG)/bin/ca.crt
	cp -r src/deps/est/ca.crt $(CONFIG)/bin/ca.crt

$(CONFIG)/inc/goahead.h: 
	rm -fr $(CONFIG)/inc/goahead.h
	cp -r src/goahead.h $(CONFIG)/inc/goahead.h

$(CONFIG)/inc/js.h: 
	rm -fr $(CONFIG)/inc/js.h
	cp -r src/js.h $(CONFIG)/inc/js.h

$(CONFIG)/obj/action.o: \
        src/action.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h \
        $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/action.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/action.c

$(CONFIG)/obj/alloc.o: \
        src/alloc.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/alloc.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/alloc.c

$(CONFIG)/obj/auth.o: \
        src/auth.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/auth.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/auth.c

$(CONFIG)/obj/cgi.o: \
        src/cgi.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/cgi.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/cgi.c

$(CONFIG)/obj/crypt.o: \
        src/crypt.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/crypt.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/crypt.c

$(CONFIG)/obj/file.o: \
        src/file.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/file.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/file.c

$(CONFIG)/obj/fs.o: \
        src/fs.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/fs.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/fs.c

$(CONFIG)/obj/http.o: \
        src/http.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/http.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/http.c

$(CONFIG)/obj/js.o: \
        src/js.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/js.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/js.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/js.c

$(CONFIG)/obj/jst.o: \
        src/jst.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h \
        $(CONFIG)/inc/js.h
	$(CC) -c -o $(CONFIG)/obj/jst.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/jst.c

$(CONFIG)/obj/options.o: \
        src/options.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/options.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/options.c

$(CONFIG)/obj/osdep.o: \
        src/osdep.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/osdep.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/osdep.c

$(CONFIG)/obj/rom-documents.o: \
        src/rom-documents.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/rom-documents.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/rom-documents.c

$(CONFIG)/obj/route.o: \
        src/route.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/route.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/route.c

$(CONFIG)/obj/runtime.o: \
        src/runtime.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/runtime.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/runtime.c

$(CONFIG)/obj/socket.o: \
        src/socket.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/socket.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/socket.c

$(CONFIG)/obj/upload.o: \
        src/upload.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/upload.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/upload.c

$(CONFIG)/obj/est.o: \
        src/ssl/est.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h \
        src/deps/est/est.h \
        $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/est.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/ssl/est.c

$(CONFIG)/obj/matrixssl.o: \
        src/ssl/matrixssl.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/matrixssl.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/ssl/matrixssl.c

$(CONFIG)/obj/openssl.o: \
        src/ssl/openssl.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/bitos.h \
        $(CONFIG)/inc/goahead.h
	$(CC) -c -o $(CONFIG)/obj/openssl.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc -Isrc/deps/est src/ssl/openssl.c

$(CONFIG)/bin/libgo.dylib:  \
        $(CONFIG)/inc/bitos.h \
        $(CONFIG)/inc/goahead.h \
        $(CONFIG)/inc/js.h \
        $(CONFIG)/obj/action.o \
        $(CONFIG)/obj/alloc.o \
        $(CONFIG)/obj/auth.o \
        $(CONFIG)/obj/cgi.o \
        $(CONFIG)/obj/crypt.o \
        $(CONFIG)/obj/file.o \
        $(CONFIG)/obj/fs.o \
        $(CONFIG)/obj/http.o \
        $(CONFIG)/obj/js.o \
        $(CONFIG)/obj/jst.o \
        $(CONFIG)/obj/options.o \
        $(CONFIG)/obj/osdep.o \
        $(CONFIG)/obj/rom-documents.o \
        $(CONFIG)/obj/route.o \
        $(CONFIG)/obj/runtime.o \
        $(CONFIG)/obj/socket.o \
        $(CONFIG)/obj/upload.o \
        $(CONFIG)/obj/est.o \
        $(CONFIG)/obj/matrixssl.o \
        $(CONFIG)/obj/openssl.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libgo.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 3.1.0 -current_version 3.1.0 $(LIBPATHS) -install_name @rpath/libgo.dylib $(CONFIG)/obj/action.o $(CONFIG)/obj/alloc.o $(CONFIG)/obj/auth.o $(CONFIG)/obj/cgi.o $(CONFIG)/obj/crypt.o $(CONFIG)/obj/file.o $(CONFIG)/obj/fs.o $(CONFIG)/obj/http.o $(CONFIG)/obj/js.o $(CONFIG)/obj/jst.o $(CONFIG)/obj/options.o $(CONFIG)/obj/osdep.o $(CONFIG)/obj/rom-documents.o $(CONFIG)/obj/route.o $(CONFIG)/obj/runtime.o $(CONFIG)/obj/socket.o $(CONFIG)/obj/upload.o $(CONFIG)/obj/est.o $(CONFIG)/obj/matrixssl.o $(CONFIG)/obj/openssl.o $(LIBS) -lest

$(CONFIG)/obj/goahead.o: \
        src/goahead.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h \
        $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/goahead.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/goahead.c

$(CONFIG)/bin/goahead:  \
        $(CONFIG)/bin/libgo.dylib \
        $(CONFIG)/inc/bitos.h \
        $(CONFIG)/inc/goahead.h \
        $(CONFIG)/inc/js.h \
        $(CONFIG)/obj/goahead.o
	$(CC) -o $(CONFIG)/bin/goahead -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/goahead.o -lgo $(LIBS) -lest

$(CONFIG)/obj/test.o: \
        test/test.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/goahead.h \
        $(CONFIG)/inc/js.h \
        $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/test.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc test/test.c

$(CONFIG)/bin/goahead-test:  \
        $(CONFIG)/bin/libgo.dylib \
        $(CONFIG)/inc/bitos.h \
        $(CONFIG)/inc/goahead.h \
        $(CONFIG)/inc/js.h \
        $(CONFIG)/obj/test.o
	$(CC) -o $(CONFIG)/bin/goahead-test -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/test.o -lgo $(LIBS) -lest

version: 
	@echo 3.1.0-1

root-install:  \
        compile
	rm -f $(BIT_PRD_PREFIX)/latest $(BIT_UBIN_PREFIX)/bit
	rm -f $(BIT_PRD_PREFIX)/latest
	for n in goahead; do rm -f $(BIT_UBIN_PREFIX)/$$n ; done
	install -d -m 755 $(BIT_CFG_PREFIX) $(BIT_BIN_PREFIX)
	install -m 644 src/auth.txt src/route.txt $(BIT_CFG_PREFIX)
	cp -R -P ./$(CONFIG)/bin/* $(BIT_BIN_PREFIX)
	rm -f $(BIT_BIN_PREFIX)/goahead-test
	ln -s $(VERSION) $(BIT_PRD_PREFIX)/latest
	if [ '$(BIT_UBIN_PREFIX)' != '' ] ; then 	for n in goahead; do 	rm -f $(BIT_UBIN_PREFIX)/$$n ; 	ln -s $(BIT_BIN_PREFIX)/$$n $(BIT_UBIN_PREFIX)/$$n ; 	done ; 	fi

install:  \
        compile
	sudo $(MAKE) -C . -f projects/$(PRODUCT)-$(OS)-$(PROFILE).mk $(MAKEFLAGS) root-install

root-uninstall: 
	rm -fr $(BIT_CFG_PREFIX) $(BIT_PRD_PREFIX)

uninstall: 
	sudo $(MAKE) -C . -f projects/$(PRODUCT)-$(OS)-$(PROFILE).mk $(MAKEFLAGS) root-uninstall
