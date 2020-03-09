# build_strongswan
strongswan build script with dependency packages

* https://www.minzkn.com/moniwiki/wiki.php/AnalysisStrongswan
* https://github.com/minzkn/build_strongswan
	<pre>
	$ git clone https://github.com/minzkn/build_strongswan.git
	</pre>


Dependency sources
==================

* gmp-6.1.2
* zlib-1.2.11
* openssl-1.0.2k : openldap-2.4.44와 빌드 의존성에 심볼 수정이 다소 필요
* libressl-2.5.4
* openldap-2.4.44
* curl-7.54.0
* strongswan-5.5.1 or strongswan-5.5.2 or strongswan-5.5.3


HOWTO build
===========

<pre>
$ make def_hwport_root=/usr/local/strongswan-5.5.3
...
</pre>

이렇게 빌드하면 최종 objs/output하위에 /usr/local/strongswan-5.5.3이 만들어지고 이 하위에 prefix 기준으로 배치되게 되며 objs/output/usr 을 실행 실행할 타겟 보드의 / 로 위치하게 되면 타겟보드에서 /usr/local/strongswan-5.5.3/usr/sbin/ipsec 경로의 ipsec 명령어를 환경변수등의 별도 설정 없이 실행하는한 경로로 잡혀서 구동가능하게 빌드됨.

즉, "" + "/objs/output" + "${def_hwport_root}" + "${def_hwport_sbindir}" + "/ipsec" 이 위치하게 되는 형태로 빌드구성됨.

빌드가 완료되면 "objs/output" 에 최종 stage2 (build후 install 첫 단계, 선별되지 않은 전체 설치) 에 해당하는 빌드결과물 생성
빌드하는 디렉토리와 실제 소스원본의 디렉토리에 영향을 주지 않는 구조로 script가 작성되어 있어서 빌드 결과물 및 중간과정물들은 모두 "objs" 디렉토리에서 생성됩니다.

SeeAlso
=======

* "Required Kernel Modules - strongSwan":http://wiki.strongswan.org/projects/strongswan/wiki/KernelModules
* "strongSwan 4.2 - Installation":https://www.strongswan.org/docs/install42.htm
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
	$ make -j17 all
	$ make -j17 DESTDIR=${STAGE2} install
	</pre>


# End of README.md
