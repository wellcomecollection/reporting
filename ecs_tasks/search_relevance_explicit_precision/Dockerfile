FROM python:3.7

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

EXPOSE 80

COPY ./src /src

CMD ["python", "src/search_relevance_explicit_precision.py"]