from fedora:41 as builder

workdir /root/
run dnf install -y git golang

run curl -fOL https://github.com/shsms/mime-rs/releases/download/v0.1.0/mime-linux-x86_64.tar.gz
# Pin the v0.1.0 asset's checksum; update it when bumping the version.
run echo "2ebfc3ce2f47707dce1bc398208462469665a91316f1852ba30c13b76e895a2a  mime-linux-x86_64.tar.gz" | sha256sum -c -
run tar -xzf mime-linux-x86_64.tar.gz

copy ./ ulysses-annotated
run cd ulysses-annotated/scripts && go build dl-anno.go
run cd ulysses-annotated/scripts && chmod +x download generate

from fedora:41
workdir /root/

run dnf install -y make procps-ng tidy calibre python3-pip && dnf clean all

run python3 -m pip install --no-cache-dir --break-system-packages ebookmaker pytidylib

copy --from=builder /root/mime /usr/bin/
copy --from=builder /root/ulysses-annotated/scripts/download /usr/bin/
copy --from=builder /root/ulysses-annotated/scripts/generate /usr/bin/
copy --from=builder /root/ulysses-annotated .
# env stage=generate
# cmd make $stage
