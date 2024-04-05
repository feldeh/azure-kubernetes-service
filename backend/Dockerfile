FROM --platform=linux/amd64 python:3.9

WORKDIR /server

COPY ./requirements.txt /server/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /server/requirements.txt

RUN pip install --no-cache-dir --upgrade opencv-python-headless

COPY ./src /server/src

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]
