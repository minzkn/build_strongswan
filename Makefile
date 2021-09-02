#
#   Copyright (C) 2015 MINZKN.COM , HWPORT.COM
#   All rights reserved.
#
#   Maintainers
#     JaeHyuk Cho ( <mailto:minzkn@minzkn.com> , https://www.minzkn.com/ )
#

# check for minimal make version (NOTE: this check will break at make 10.x !)
override DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION:=3.81#
ifneq ($(firstword $(sort $(MAKE_VERSION) $(DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION))),$(DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION))
  $(error you have make "$(MAKE_VERSION)". GNU make >= $(DEF_HWPORT_REQUIRE_MINIMUM_MAKE_VERSION) is required !)
endif

# ----
  
ifneq ($(wildcard /bin/bash),)
  SHELL=/bin/bash# default bash shell
else
  ifeq ($(strip $(SHELL)),)
    SHELL=/bin/sh# default unix shell
  endif
endif

JOBS:=64#

# ----

# Delete default rules. We don't use them. This saves a bit of time.
.SUFFIXES:

# ----

DEF_HWPORT_PATH_CURRENT:=$(abspath .)#
DEF_HWPORT_PATH_DISTFILES:=$(abspath $(DEF_HWPORT_PATH_CURRENT)/../distfiles)#
DEF_HWPORT_PATH_STAGE1:=$(DEF_HWPORT_PATH_CURRENT)/objs#
DEF_HWPORT_PATH_STAGE2:=$(DEF_HWPORT_PATH_CURRENT)/objs/output#
DEF_HWPORT_PATH_STAGE3:=$(DEF_HWPORT_PATH_CURRENT)/objs/rootfs#

DEF_HWPORT_PREFIX:=/usr#
DEF_HWPORT_SYSCONFDIR:=/etc#
DEF_HWPORT_LOCALSTATEDIR:=/var#

DEF_HWPORT_PATH_SOURCE_ZLIB:=$(DEF_HWPORT_PATH_CURRENT)/zlib-1.2.11# from https://zlib.net/
DEF_HWPORT_PATH_SOURCE_GMP:=$(DEF_HWPORT_PATH_CURRENT)/gmp-6.2.1# from https://gmplib.org/
DEF_HWPORT_PATH_SOURCE_OPENSSL:=$(DEF_HWPORT_PATH_CURRENT)/openssl-1.1.1l# from https://www.openssl.org/
DEF_HWPORT_PATH_SOURCE_OPENLDAP:=$(DEF_HWPORT_PATH_CURRENT)/openldap-2.5.7# from https://www.openldap.org/
DEF_HWPORT_PATH_SOURCE_CURL:=$(DEF_HWPORT_PATH_CURRENT)/curl-7.78.0# from https://curl.se/
DEF_HWPORT_PATH_SOURCE_STRONGSWAN:=$(DEF_HWPORT_PATH_CURRENT)/strongswan-5.9.3# from https://www.strongswan.org/

# ----

.PHONY: all maintainer-clean distclean clean mostlyclean
.PHONY: dist installcheck installdirs install install-strip uninstall check info dvi TAGS
.PHONY: help build

all: build

maintainer-clean: distclean
	@echo "maintainer-clean"

distclean: clean
	@echo "distclean"

clean: mostlyclean
	@echo "clean"

mostlyclean:
	@echo "mostlyclean"
	@rm -rf "$(DEF_HWPORT_PATH_STAGE3)"
	@rm -rf "$(DEF_HWPORT_PATH_STAGE2)"
	@rm -rf "$(DEF_HWPORT_PATH_STAGE1)"

dist: install
	@echo "dist install"

installcheck: install

installdirs:
	@echo "installing directory"

install: all installdirs
	@echo "installing"

install-strip: install
	@echo "stripping"

uninstall:

check: all

info:

dvi:

TAGS:

help:
	@echo "help"

build: \
$(DEF_HWPORT_PATH_STAGE1)/strongswan/.done
	@echo "build complete."

# ----

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/zlib.html
.PHONY: zlib
zlib: $(DEF_HWPORT_PATH_STAGE1)/zlib/.done
$(DEF_HWPORT_PATH_STAGE1)/zlib/.done: $(DEF_HWPORT_PATH_SOURCE_ZLIB)
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))" && \
	    CROSS_PREFIX="" \
	    CFLAGS="-fPIC" \
	    LDFLAGS="" \
	    ./configure \
	    --prefix="$(DEF_HWPORT_PREFIX)" \
	    --includedir="$(DEF_HWPORT_PREFIX)/include" \
	    --libdir="$(DEF_HWPORT_PREFIX)/lib" \
	    --shared
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@touch "$(@)"

# http://www.linuxfromscratch.org/lfs/view/development/chapter06/gmp.html
.PHONY: gmp
gmp: $(DEF_HWPORT_PATH_STAGE1)/gmp/.done
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done: $(DEF_HWPORT_PATH_SOURCE_GMP)
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))" && \
	    ABI=64 \
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib" \
	    ./configure \
	    --prefix="$(DEF_HWPORT_PREFIX)" \
	    --sysconfdir="$(DEF_HWPORT_SYSCONFDIR)" \
	    --localstatedir="$(DEF_HWPORT_LOCALSTATEDIR)" \
	    --enable-cxx
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib'," "$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib/libgmp.la"
	@sed -i -e "s,^dependency_libs\=\(.*\)\s$(DEF_HWPORT_PREFIX)/lib/libgmp\.la\(.*\)$$,dependency_libs=\1 $(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib/libgmp.la\2,g" "$(DEF_HWPORT_PATH_STAGE2)/usr/lib/libgmpxx.la"
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib'," "$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib/libgmpxx.la"
	@touch "$(@)"

# http://www.linuxfromscratch.org/blfs/view/7.8/postlfs/openssl.html
# https://wiki.openssl.org/index.php/Compilation_and_Installation
.PHONY: openssl
openssl: $(DEF_HWPORT_PATH_STAGE1)/openssl/.done
$(DEF_HWPORT_PATH_STAGE1)/openssl/.done: $(DEF_HWPORT_PATH_SOURCE_OPENSSL) \
$(DEF_HWPORT_PATH_STAGE1)/zlib/.done \
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))" && \
		./config \
			--prefix="$(DEF_HWPORT_PREFIX)" \
			--openssldir="$(DEF_HWPORT_SYSCONFDIR)/ssl" \
			--libdir="$(DEF_HWPORT_PREFIX)/lib" \
			-D_REENTRANT \
			-D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 \
			-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 \
			-I$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/include \
			-L$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib \
			shared threads \
			> /dev/null
	@make -j1 -C "$(dir $(@))" DESTDIR="$(abspath $(DEF_HWPORT_PATH_STAGE2))" depend
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(abspath $(DEF_HWPORT_PATH_STAGE2))" all
	@make -C "$(dir $(@))" DESTDIR="$(abspath $(DEF_HWPORT_PATH_STAGE2))" install
	@touch "$(@)"

.PHONY: openldap
openldap: $(DEF_HWPORT_PATH_STAGE1)/openldap/.done
$(DEF_HWPORT_PATH_STAGE1)/openldap/.done: $(DEF_HWPORT_PATH_SOURCE_OPENLDAP) \
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done \
$(DEF_HWPORT_PATH_STAGE1)/openssl/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))" && \
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib" \
	    ./configure \
	    --prefix="$(DEF_HWPORT_PREFIX)" \
	    --sysconfdir="$(DEF_HWPORT_SYSCONFDIR)" \
	    --localstatedir="$(DEF_HWPORT_LOCALSTATEDIR)" \
	    --disable-bdb \
	    --disable-hdb \
	    --with-yielding-select="yes" \
	    --without-cyrus-sasl \
	    --with-mp="gmp" \
	    --with-tls="openssl"
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib'," "$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib/liblber.la"
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib'," "$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib/libldap.la"
	@touch "$(@)"

.PHONY: curl
curl: $(DEF_HWPORT_PATH_STAGE1)/curl/.done
$(DEF_HWPORT_PATH_STAGE1)/curl/.done: $(DEF_HWPORT_PATH_SOURCE_CURL) \
$(DEF_HWPORT_PATH_STAGE1)/openssl/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))" && \
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib" \
	    ./configure \
	    --prefix="$(DEF_HWPORT_PREFIX)" \
	    --sysconfdir="$(DEF_HWPORT_SYSCONFDIR)" \
	    --localstatedir="$(DEF_HWPORT_LOCALSTATEDIR)" \
	    --disable-debug \
	    --disable-ldap \
	    --disable-ldaps \
	    --without-kerberos \
	    --without-libssh2 \
	    --enable-ipv6 \
	    --enable-threads \
	    --disable-ares \
	    --enable-http \
	    --enable-ftp \
	    --disable-gopher \
	    --enable-file \
	    --disable-dict \
	    --enable-manual \
	    --disable-telnet \
	    --enable-smtp \
	    --enable-pop3 \
	    --enable-imap \
	    --enable-rtsp \
	    --enable-nonblocking \
	    --enable-largefile \
	    --enable-maintainer-mode \
	    --disable-sspi \
	    --disable-manual \
	    --disable-ntlm-wb \
	    --enable-hidden-symbols \
	    --disable-curldebug \
	    --without-krb4 \
	    --without-librtmp \
	    --without-spnego \
	    --without-gnutls \
	    --without-nss \
	    --with-zlib="$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)" \
	    --without-libidn \
	    --with-ssl="$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)" \
	    --with-ca-path="$(DEF_HWPORT_SYSCONFDIR)/ssl/certs" \
	    --without-ca-bundle \
	    --with-random=/dev/urandom \
	    --with-lber-lib="lber" \
	    --with-ldap-lib="ldap"
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"	
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@sed -i -e "s,^libdir=.*$$,libdir='$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib'," "$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib/libcurl.la"
	@touch "$(@)"

.PHONY: strongswan
strongswan: $(DEF_HWPORT_PATH_STAGE1)/strongswan/.done
$(DEF_HWPORT_PATH_STAGE1)/strongswan/.done: $(DEF_HWPORT_PATH_SOURCE_STRONGSWAN) \
$(DEF_HWPORT_PATH_STAGE1)/gmp/.done \
$(DEF_HWPORT_PATH_STAGE1)/openssl/.done \
$(DEF_HWPORT_PATH_STAGE1)/openldap/.done \
$(DEF_HWPORT_PATH_STAGE1)/curl/.done
	@mkdir -p "$(dir $(@))" && rm -rf "$(dir $(@))/*" && tar -c --exclude=.svn/* --exclude=.git/* -C "$(<)" . | tar -xv -C "$(dir $(@))/"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE2)"
	@mkdir -p "$(DEF_HWPORT_PATH_STAGE3)"
	@cd "$(dir $(@))";\
	    CPPFLAGS="-I$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/include" \
	    LDFLAGS="-L$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib" \
	    LD_LIBRARY_PATH="$(DEF_HWPORT_PATH_STAGE2)$(DEF_HWPORT_PREFIX)/lib" \
	    ./configure \
	    --prefix="$(DEF_HWPORT_PREFIX)" \
	    --sysconfdir="$(DEF_HWPORT_SYSCONFDIR)" \
	    --localstatedir="$(DEF_HWPORT_LOCALSTATEDIR)" \
	    --without-lib-prefix \
	    --enable-acert=yes \
	    --enable-addrblock=yes \
	    --enable-led \
	    --enable-pkcs11=yes \
	    --enable-kernel-netlink=yes \
	    --enable-socket-default=yes \
	    --enable-openssl=yes \
	    --enable-gcrypt=no \
	    --enable-gmp=yes \
	    --enable-af-alg=no \
	    --enable-curl=yes \
	    --enable-charon=yes \
	    --enable-tnccs-11=no \
	    --enable-tnccs-20=no \
	    --enable-tnccs-dynamic=no \
	    --enable-eap-sim-pcsc=no \
	    --enable-eap-sim \
	    --enable-eap-sim-file \
	    --enable-eap-aka \
	    --enable-eap-aka-3gpp2 \
	    --enable-eap-simaka-sql \
	    --enable-eap-simaka-pseudonym \
	    --enable-eap-simaka-reauth \
	    --enable-eap-identity \
	    --enable-eap-md5 \
	    --enable-eap-gtc \
	    --enable-eap-mschapv2 \
	    --enable-eap-tls \
	    --enable-eap-ttls \
	    --enable-eap-peap \
	    --enable-eap-tnc \
	    --enable-eap-dynamic \
	    --enable-eap-radius \
	    --enable-unity=no \
	    --enable-stroke=yes \
	    --enable-sql=no \
	    --enable-pki=yes \
	    --enable-scepclient=no \
	    --enable-scripts=yes \
	    --enable-vici=no \
	    --enable-swanctl=yes \
	    --enable-socket-dynamic \
	    --disable-monolithic \
	    --disable-ldap \
	    --disable-xauth-pam \
	    --disable-connmark \
	    --disable-forecast \
	    --disable-soup
	@make -j$(JOBS) -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)"
	@make -C "$(dir $(@))" DESTDIR="$(DEF_HWPORT_PATH_STAGE2)" install
	@touch "$(@)"

# ----

.DEFAULT:
	@echo "unknown goals ($@))"

# End of Makefile
