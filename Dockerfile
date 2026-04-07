FROM python:3.13-slim

WORKDIR /project

RUN pip install uv

COPY pyproject.toml .
RUN uv pip install --system .

COPY download.py .
COPY dbt/ dbt/
CMD ["bash"]