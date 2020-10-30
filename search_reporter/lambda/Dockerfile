FROM python:3.7

RUN pip install pip-tools
COPY requirements.in requirements.in
RUN pip-compile
RUN pip install -r requirements.txt

COPY src/ src/

CMD ["python", "src/main.py"]
