FROM ubuntu:18.04
RUN  apt-get update && apt install python -y && apt install python-pip -y && pip install flask 
WORKDIR /flask/

COPY . .
COPY ./index.html ./templates/
ENTRYPOINT ["python"]
CMD ["app.py"]
