perl Configure VC-WIN64A --prefix=C:\OpenSSL-x64 no-shared no-ssl2 no-ssl3 no-idea no-srp no-weak-ssl-ciphers no-camellia no-krb5 no-md2 no-md4 no-mdc2 no-whirlpool no-comp
ms\do_win64a
nmake -f ms\nt.mak
nmake -f ms\nt.mak install
