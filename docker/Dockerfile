FROM alpine:latest

RUN apk add --no-cache python3 py3-pip python3-dev rust cargo libffi-dev
RUN pip install mitmproxy
COPY apollo_mitmproxy_script.py .

EXPOSE 8080

ENTRYPOINT ["mitmdump", "-s", "apollo_mitmproxy_script.py", "--listen-host", "0.0.0.0"]
