# build_strongswan
strongswan build script with dependency packages

빌드 기본 환경 : Ubuntu 배포판의 경우
    <pre>
    $ sudo apt install build-essential autoconf automake autotools-dev
    </pre>

* https://www.strongswan.org/
* https://www.minzkn.com/moniwiki/wiki.php/AnalysisStrongswan
* https://github.com/minzkn/build_strongswan
	<pre>
	$ git clone https://github.com/minzkn/build_strongswan.git
	</pre>


Dependency sources
==================

* >= gmp-6.2.1
** from https://gmplib.org/
* >= zlib-1.2.11
** from https://zlib.net/
* >= openssl-1.1.1g
** from https://www.openssl.org/
* >= curl-7.73.0
** from https://curl.se/
* >= strongswan-5.9.1
** from https://www.strongswan.org/

TODO: LDAP, ...

HOWTO build
===========

<pre>
$ make -j64
...
</pre>

이렇게 빌드하면 최종 "objs/output" 하위에 "/usr/local/strongswan" 이 만들어지고 이 하위에 prefix 기준으로 배치되게 되며 "objs/output/usr" 을 실행 실행할 타겟 보드의 / 로 위치하게 되면 타겟보드에서 "/usr/local/strongswan/usr/sbin/ipsec" 경로의 ipsec 명령어를 환경변수등의 별도 설정 없이 실행하는한 경로로 잡혀서 구동가능하게 빌드됨.

빌드가 완료되면 "objs/output" 에 최종 stage2 (build후 install 첫 단계, 선별되지 않은 전체 설치) 에 해당하는 빌드결과물 생성
빌드하는 디렉토리와 실제 소스원본의 디렉토리에 영향을 주지 않는 구조로 script가 작성되어 있어서 빌드 결과물 및 중간과정물들은 모두 "objs" 디렉토리에서 생성됩니다.


SeeAlso
=======

* "strongSwan home page":https://www.strongswan.org/
** "strongSwan 4.2 - Installation":https://www.strongswan.org/docs/install42.htm
** "Required Kernel Modules - strongSwan":http://wiki.strongswan.org/projects/strongswan/wiki/KernelModules
* "Autoconf options for the most current strongSwan release":https://wiki.strongswan.org/projects/strongswan/wiki/Autoconf
* 일반적인 autoconf/automake 기반의 source를 빌드하는 일반적인 방법 요약
	<pre>
	$ mkdir -p ${STAGE1}              /* 빌드작업을 수행할 경로를 생성 */
	$ cd ${STAGE1}
	$ ${SOURCE}/configure \
	  --prefix=${RUNTIME_ROOTENTRY}${RUNTIME_PREFIX} \
	  --exec_prefix=${RUNTIME_ROOTENTRY}${RUNTIME_PREFIX} \
	  --sysconfdir=${RUNTIME_ROOTENTRY}/etc \
	  --localstatedir=${RUNTIME_ROOTENTRY}/var
	$ make -j$(JOBS) all
	$ make -j$(JOBS) DESTDIR=${STAGE2} install
	</pre>


# End of README.md
