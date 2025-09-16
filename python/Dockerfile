


FROM python:3.9-slim-buster 
WORKDIR /python
COPY requirements.txt .
# COPY test.py .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "test2.py"] 
# Replace with your application's entry point
