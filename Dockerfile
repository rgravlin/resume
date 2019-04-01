FROM resume:builder

COPY . /usr/app/
RUN chown nobody /usr/app
USER nobody
