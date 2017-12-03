#!/usr/bin/make -f
#
# Run with desired targets, typically either no args (which is the
# same as "all" below), or a key/cert pair.
#  Eg: ./tls.make myclient.key myclient.crt
#

KEYSIZE = 4096
DAYS = 10000
OPENSSL = openssl

all: ca.crt tiller.key tiller.crt

%.key:
	$(OPENSSL) genrsa -out $@ $(KEYSIZE)

ca.crt: ca.key
	$(OPENSSL) req \
	 -x509 -new -nodes -sha256 \
	 -key $< \
	 -days $(DAYS) \
	 -out $@ \
	 -extensions v3_ca \
	 -subj '/CN=tiller-CA'

%.csr: %.key
	$(OPENSSL) req \
	 -new -sha256 \
	 -key $< \
	 -out $@ \
	 -subj '/CN=$*'

%.crt: %.csr ca.key ca.crt
	$(OPENSSL) x509 \
	 -req \
	 -in $< \
	 -out $@ \
	 -CA ca.crt \
	 -CAkey ca.key \
	 -CAcreateserial \
	 -days $(DAYS) \
	 -extensions v3_ext

.NOTPARALLEL:
.PRECIOUS: ca.key ca.srl
