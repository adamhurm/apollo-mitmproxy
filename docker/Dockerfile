FROM python:3.11-bullseye as wheelbuilder

ARG MITMPROXY_WHEEL
COPY $MITMPROXY_WHEEL /wheels/
RUN pip install wheel && pip wheel --wheel-dir /wheels /wheels/${MITMPROXY_WHEEL}

FROM python:3.11-slim-bullseye

RUN useradd -mU mitmproxy
RUN apt-get update \
    && apt-get install -y --no-install-recommends gosu nano \
    && rm -rf /var/lib/apt/lists/*

COPY --from=wheelbuilder /wheels /wheels
RUN pip install --no-index --find-links=/wheels mitmproxy
RUN rm -rf /wheels

VOLUME /home/mitmproxy/.mitmproxy

COPY docker-entrypoint.sh /usr/local/bin/
COPY apollo_mitmproxy_script.py .
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8080

CMD ["mitmdump", "-s", "apollo_mitmproxy_script.py", "--listen-host", "0.0.0.0"]
