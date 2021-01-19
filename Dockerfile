from fedora:33 as builder

workdir /root/
run dnf install -y git go

run  git clone https://github.com/shsms/ideacrawler
# run  cd ideacrawler && make build
run go get github.com/shsms/ideacrawler

run curl -OL https://github.com/shsms/mime/releases/latest/download/mime-linux-amd64.tar.gz
run tar -xvf mime-linux-amd64.tar.gz

copy ./ ulysses-annotated
run cd ulysses-annotated/scripts && go build dl-anno.go
run cd ulysses-annotated/scripts && chmod +x download generate

from fedora:33
workdir /root/

run dnf install -y make procps-ng tidy calibre pip \
  	&& dnf clean all \
	&& rm -rf /var/cache/yum

run pip  --no-cache-dir install ebookmaker pytidylib

copy --from=builder /root/go/bin/ideacrawler /usr/bin/
copy --from=builder /root/mime /usr/bin/
copy --from=builder /root/ulysses-annotated/scripts/download /usr/bin/
copy --from=builder /root/ulysses-annotated/scripts/generate /usr/bin/
copy --from=builder /root/ulysses-annotated .
# env stage=generate
# cmd nohup ideacrawler &; make $stage
