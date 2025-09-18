


FROM python:3.9-slim-buster 

# WORKDIR /python
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt
# COPY . .
# CMD ["python", "test2.py"] 
# Replace with your application's entry point


RUN mkdir /usr/src/app
WORKDIR /usr/src/app
COPY ./requirements.txt .
COPY ./test2.py .
RUN pip install -r requirements.txt
ENV PYTHONUNBUFFERED=1
COPY . .